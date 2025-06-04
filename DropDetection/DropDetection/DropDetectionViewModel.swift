//
//  DropDetectionViewModel.swift
//  DropDetection
//
//  Created by Razib Hasan on 5.6.2025.
//

import Foundation
import CoreMotion
import CoreLocation
import SwiftUI

class DropDetectionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()
    private let accelerationThreshold = 2.5

    @Published var isMonitoring = false
    @Published var lastDropInfo: String = "No drop detected yet."

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

            if magnitude > self.accelerationThreshold {
                self.handleDrop(magnitude: magnitude)
            }
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        motionManager.stopAccelerometerUpdates()
    }

    private func handleDrop(magnitude: Double) {
        guard let loc = currentLocation else { return }
        let msg = String(format: "Drop at %.4f, %.4f | Magnitude: %.2f",
                         loc.coordinate.latitude, loc.coordinate.longitude, magnitude)
        print("📉 Detected drop:", msg)
        lastDropInfo = msg
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}
