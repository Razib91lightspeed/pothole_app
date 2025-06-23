import Foundation
import CoreMotion
import CoreLocation

// MARK: - Model representing a detected drop event
struct DropEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let magnitude: Double
}

// MARK: - Main ViewModel for motion + location tracking
class DropDetectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Managers for sensors
    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()

    // Thresholds for detecting motion & drops
    private let accelerationThreshold = 2.5  // g-force > 2.5 means possible drop
    private let motionThreshold = 1.05       // g-force > 1.05 means moving

    // Published properties for UI binding
    @Published var isMonitoring = false
    @Published var isMoving = false
    @Published var recentDrops: [DropEvent] = []

    // Location + heading info
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var accuracy: Double = -1.0
    @Published var speed: Double = -1.0
    @Published var heading: Double = 0.0
    @Published var locationTime: String = "N/A"

    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Start monitoring sensors
    func startMonitoring() {
        isMonitoring = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }

            // Compute g-force magnitude
            let mag = data.acceleration.magnitude()

            // Determine motion
            self.evaluateMotion(mag: mag)

            // Check for drop
            if mag > self.accelerationThreshold {
                self.recordDrop(magnitude: mag)
            }

            // Always print JSON on motion update
            self.printJSON(acceleration: mag)
        }
    }

    // MARK: - Stop monitoring
    func stopMonitoring() {
        isMonitoring = false
        isMoving = false
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    // MARK: - Evaluate motion using accel + GPS speed
    private func evaluateMotion(mag: Double) {
        let accelMoving = mag > motionThreshold
        let gpsMoving = speed >= 0.1

        DispatchQueue.main.async {
            self.isMoving = accelMoving || gpsMoving
        }
    }

    // MARK: - Register drop event
    private func recordDrop(magnitude: Double) {
        let event = DropEvent(
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude,
            magnitude: magnitude
        )

        DispatchQueue.main.async {
            self.recentDrops.insert(event, at: 0)
            if self.recentDrops.count > 5 {
                self.recentDrops.removeLast()
            }
        }
    }

    // MARK: - Print JSON to console
    private func printJSON(acceleration: Double) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let jsonDict: [String: Any] = [
            "timestamp": timestamp,
            "locationtamp": locationTime,
            "acceleration_ms": acceleration,
            "latitude": latitude,
            "longitude": longitude,
            "direction_degree_to_north": heading,
            "gps_accuracy": accuracy,
            "gps_speed": speed
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    }

    // MARK: - Location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        accuracy = loc.horizontalAccuracy
        speed = max(loc.speed, 0)  // Clamp invalid speed
        locationTime = ISO8601DateFormatter().string(from: loc.timestamp)

        // Always print JSON on location update
        printJSON(acceleration: motionManager.accelerometerData?.acceleration.magnitude() ?? 0)
    }

    // MARK: - Heading updates
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }

    // MARK: - Permissions handling
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
}

// MARK: - Helper for computing magnitude
private extension CMAcceleration {
    func magnitude() -> Double {
        sqrt(x * x + y * y + z * z)
    }
}
