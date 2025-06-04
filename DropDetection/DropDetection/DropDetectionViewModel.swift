import Foundation
import CoreMotion
import CoreLocation
import SwiftUI

struct DropEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let magnitude: Double
}

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
    private let accelerationThreshold = 2.5
    private let motionThreshold = 1.05 // movement threshold for motion status

    @Published var isMonitoring = false
    @Published var lastDropInfo: String = "No drop detected yet."
    @Published var recentDrops: [DropEvent] = []
    @Published var motionLog: [MotionEntry] = []
    @Published var isMoving: Bool = false

    private var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startMonitoring() {
        isMonitoring = true
        motionManager.accelerometerUpdateInterval = 0.2

        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }

            let magnitude = sqrt(data.acceleration.x * data.acceleration.x +
                                 data.acceleration.y * data.acceleration.y +
                                 data.acceleration.z * data.acceleration.z)
            let latitude = self.currentLocation?.coordinate.latitude ?? 0.0
            let longitude = self.currentLocation?.coordinate.longitude ?? 0.0

            DispatchQueue.main.async {
                self.isMoving = magnitude > self.motionThreshold

                let entry = MotionEntry(
                    timestamp: Date(),
                    magnitude: magnitude,
                    latitude: latitude,
                    longitude: longitude
                )
                self.motionLog.insert(entry, at: 0)
                if self.motionLog.count > 20 {
                    self.motionLog.removeLast()
                }
            }

            if magnitude > self.accelerationThreshold {
                self.handleDropDetected(magnitude: magnitude, location: self.currentLocation)
            }
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        motionManager.stopAccelerometerUpdates()
        motionLog.removeAll()
        isMoving = false
    }

    private func handleDropDetected(magnitude: Double, location: CLLocation?) {
        guard let location = location else { return }

        let newEvent = DropEvent(
            timestamp: Date(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            magnitude: magnitude
        )

        DispatchQueue.main.async {
            self.lastDropInfo = """
            Latest Drop:
            \(self.format(date: newEvent.timestamp))
            Lat: \(String(format: "%.5f", newEvent.latitude))
            Lon: \(String(format: "%.5f", newEvent.longitude))
            Magnitude: \(String(format: "%.2f", newEvent.magnitude))
            """

            self.recentDrops.insert(newEvent, at: 0)
            if self.recentDrops.count > 5 {
                self.recentDrops.removeLast()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
