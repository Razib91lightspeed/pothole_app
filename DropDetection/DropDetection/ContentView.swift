import SwiftUI

struct ContentView: View {
    // ViewModel that handles motion + location logic
    @StateObject private var viewModel = DropDetectionViewModel()

    var body: some View {
        ScrollView { // Allows content to scroll if it overflows vertically
            VStack(spacing: 20) {
                
                // App title
                Text("🚀 Drop Detection")
                    .font(.largeTitle)
                    .bold()

                // Monitoring status indicator
                Text(viewModel.isMonitoring ? "🟢 Monitoring" : "🔴 Not Monitoring")
                    .font(.headline)
                    .foregroundColor(viewModel.isMonitoring ? .green : .red)

                // Motion status (whether phone is moving or stationary)
                Text(viewModel.isMoving ? "📱 Phone is in motion" : "📴 Phone is stationary")
                    .font(.subheadline)
                    .foregroundColor(viewModel.isMoving ? .orange : .gray)

                // Start/Stop monitoring button
                Button(action: {
                    // Toggle monitoring state on button press
                    viewModel.isMonitoring ? viewModel.stopMonitoring() : viewModel.startMonitoring()
                }) {
                    Text(viewModel.isMonitoring ? "Stop" : "Start")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 200) // Big circular button
                        .background(viewModel.isMonitoring ? Color.red : Color.green)
                        .clipShape(Circle()) // Make button circular
                }

                // Group showing location data in key-value rows
                GroupBox(label: Label("📍 Location", systemImage: "location")) {
                    infoRow("Lat", String(format: "%.5f", viewModel.latitude))
                    infoRow("Lon", String(format: "%.5f", viewModel.longitude))
                    infoRow("Accuracy", String(format: "%.1f m", viewModel.accuracy))
                    infoRow("Speed", String(format: "%.2f m/s", viewModel.speed))
                    infoRow("Heading", String(format: "%.1f°", viewModel.heading))
                    infoRow("Time", viewModel.locationTime)
                }

                // Group showing recent drop detections
                GroupBox(label: Label("🚨 Drops", systemImage: "exclamationmark.triangle")) {
                    if viewModel.recentDrops.isEmpty {
                        // Display placeholder if no drops yet
                        Text("No drops detected yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        // Show list of recent drop events
                        ForEach(viewModel.recentDrops) { drop in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Time: \(drop.timestamp)")
                                Text("Lat: \(String(format: "%.5f", drop.latitude))")
                                Text("Lon: \(String(format: "%.5f", drop.longitude))")
                                Text("Mag: \(String(format: "%.2f g", drop.magnitude))")
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                Spacer(minLength: 20) // Add spacing at bottom
            }
            .padding() // Outer padding for layout
        }
    }

    // Helper to create consistent key-value row
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label + ":").bold() // Key label
            Spacer()
            Text(value) // Value text
        }
    }
}
