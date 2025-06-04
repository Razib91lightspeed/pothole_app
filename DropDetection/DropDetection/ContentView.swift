import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DropDetectionViewModel()

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 25) {
                    Text(viewModel.isMonitoring ? "🟢 Monitoring Drops" : "🔴 Not Monitoring")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(viewModel.isMoving ? "📱 Phone is in motion" : "📴 Stationary")
                        .foregroundColor(viewModel.isMoving ? .green : .gray)
                        .font(.callout)

                    Button(action: {
                        viewModel.isMonitoring ? viewModel.stopMonitoring() : viewModel.startMonitoring()
                    }) {
                        Text(viewModel.isMonitoring ? "Stop" : "Start")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 160, height: 160)
                            .background(
                                RadialGradient(
                                    gradient: Gradient(colors: viewModel.isMonitoring
                                                       ? [Color.red.opacity(0.8), Color.red]
                                                       : [Color.green.opacity(0.8), Color.green]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .gray.opacity(0.6), radius: 10, x: 0, y: 10)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.2), lineWidth: 4)
                            )
                    }

                    if !viewModel.motionLog.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("📈 Last 20 Motion Readings")
                                .font(.headline)

                            ForEach(viewModel.motionLog) { entry in
                                VStack(alignment: .leading, spacing: 2) {
                                       Text("🕒 \(viewModel.format(date: entry.timestamp))")
                                       Text("📍 Lat: \(String(format: "%.5f", entry.latitude)), Lon: \(String(format: "%.5f", entry.longitude))")
                                       Text("📈 Magnitude: \(String(format: "%.3f", entry.magnitude))")
                                   }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ContentView()
}
