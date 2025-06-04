//
//  ContentView.swift
//  DropDetection
//
//  Created by Razib Hasan on 5.6.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DropDetectionViewModel()

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text(viewModel.isMonitoring ? "🟢 Monitoring Drops" : "🔴 Not Monitoring")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)

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
                .padding(.bottom)

                Text(viewModel.lastDropInfo)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}



#Preview {
    ContentView()
}
