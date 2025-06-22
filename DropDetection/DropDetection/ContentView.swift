import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DropDetectionViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Text(viewModel.isMonitoring ? "🟢 Monitoring" : "🔴 Not Monitoring")
                        .foregroundColor(.white)
                        .font(.title2)

                    Text(viewModel.isMoving ? "📱 Phone is in motion" : "📴 Stationary")
                        .foregroundColor(viewModel.isMoving ? .green : .gray)

                    Button(action: {
                        viewModel.isMonitoring ? viewModel.stopMonitoring() : viewModel.startMonitoring()
                    }) {
                        Text(viewModel.isMonitoring ? "Stop" : "Start")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 160, height: 160)
                            .background(viewModel.isMonitoring ? Color.red : Color.green)
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("MOTION DATA")
                            .foregroundColor(.gray)
                        HStack {
                            Text("Timestamp")
                            Spacer()
                            Text(viewModel.motionLog.first?.timestamp.ISO8601Format() ?? "N/A")
                        }
                        HStack {
                            Text("Acceleration (m/s²)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.motionLog.first?.magnitude ?? 0))
                        }
                        HStack {
                            Text("Moving?")
                            Spacer()
                            Text(viewModel.isMoving ? "Yes" : "No")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("LOCATION DATA")
                            .foregroundColor(.gray)
                        HStack {
                            Text("Lat")
                            Spacer()
                            Text(String(format: "%.5f", viewModel.lastLat))
                        }
                        HStack {
                            Text("Lon")
                            Spacer()
                            Text(String(format: "%.5f", viewModel.lastLon))
                        }
                        HStack {
                            Text("Accuracy (m)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.lastAccuracy))
                        }
                        HStack {
                            Text("Speed (m/s)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.lastSpeed))
                        }
                        HStack {
                            Text("Heading (° to North)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.lastHeading))
                        }
                        HStack {
                            Text("Location Time")
                            Spacer()
                            Text(viewModel.locationTimestamp)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    if !viewModel.recentDrops.isEmpty {
                        VStack(alignment: .leading) {
                            Text("RECENT DROPS")
                                .foregroundColor(.gray)
                            ForEach(viewModel.recentDrops) { drop in
                                VStack(alignment: .leading) {
                                    Text("🕒 \(drop.timestamp.ISO8601Format())")
                                    Text("Lat: \(drop.latitude), Lon: \(drop.longitude), Mag: \(String(format: "%.2f", drop.magnitude))")
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }
}
