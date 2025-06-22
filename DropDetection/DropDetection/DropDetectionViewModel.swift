import Foundation
import CoreMotion
import CoreLocation

// MARK: - Model for drop event
struct DropEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let magnitude: Double
}

// MARK: - Model for motion data entry
struct MotionEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let magnitude: Double
    let latitude: Double
    let longitude: Double
}

class DropDetectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()

    // Thresholds
    private let accelerationThreshold = 2.5  // Above this = drop
    private let motionThreshold = 1.05        // Above this = phone is moving

    // Published properties for UI binding
    @Published var isMonitoring = false
    @Published var isMoving = false
    @Published var recentDrops: [DropEvent] = []
    @Published var motionLog: [MotionEntry] = []
    
    @Published var lastLat: Double = 0.0
    @Published var lastLon: Double = 0.0
    @Published var lastAccuracy: Double = -1.0
    @Published var lastSpeed: Double = -1.0
    @Published var lastHeading: Double = 0.0
    @Published var locationTimestamp: String = "N/A"

    private var currentLocation: CLLocation?

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        // Request permission - should show "Always" or "While using the app"
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Start monitoring motion + location
    func startMonitoring() {
        isMonitoring = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }

            // Calculate acceleration magnitude
            let mag = sqrt(data.acceleration.x * data.acceleration.x +
                           data.acceleration.y * data.acceleration.y +
                           data.acceleration.z * data.acceleration.z)

            // Determine if phone is moving
            self.isMoving = mag > self.motionThreshold

            // Create a motion log entry
            let entry = MotionEntry(
                timestamp: Date(),
                magnitude: mag,
                latitude: self.lastLat,
                longitude: self.lastLon
            )
            self.motionLog.insert(entry, at: 0)
            if self.motionLog.count > 20 {
                self.motionLog.removeLast()
            }

            // Check for a drop event
            if mag > self.accelerationThreshold {
                self.handleDropDetected(magnitude: mag)
            }
        }
    }

    // MARK: - Stop all updates
    func stopMonitoring() {
        isMonitoring = false
        isMoving = false
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionLog.removeAll()
    }

    // MARK: - Handle detected drop
    private func handleDropDetected(magnitude: Double) {
        guard let location = currentLocation else {
            print("⚠️ Drop detected but no valid location available")
            return
        }

        let event = DropEvent(
            timestamp: Date(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            magnitude: magnitude
        )

        DispatchQueue.main.async {
            self.recentDrops.insert(event, at: 0)
            if self.recentDrops.count > 5 {
                self.recentDrops.removeLast()
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Automatically start location updates if permission granted
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        case .denied, .restricted:
            print("❌ Location access denied/restricted")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc

        // Update published properties for UI
        lastLat = loc.coordinate.latitude
        lastLon = loc.coordinate.longitude
        lastAccuracy = loc.horizontalAccuracy
        lastSpeed = loc.speed
        locationTimestamp = isoDateString(from: loc.timestamp)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Use true north if available, otherwise magnetic
        lastHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }

    // MARK: - Helpers

    private func isoDateString(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
