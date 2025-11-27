//
//  HUDView.swift
//  TelemetryHUD
//
//  Main HUD visualization view
//

import SwiftUI

struct HUDView: View {
    @ObservedObject var viewModel: TelemetryViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                
                // Horizon display
                HorizonView(roll: viewModel.roll, pitch: viewModel.pitch)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Pitch ladder
                PitchLadderView(roll: viewModel.roll, pitch: viewModel.pitch)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Roll indicator
                RollIndicatorView(roll: viewModel.roll)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Compass tape
                VStack {
                    CompassTapeView(heading: viewModel.yaw)
                        .frame(height: 70)
                    Spacer()
                }
                
                // Bottom panels
                VStack {
                    Spacer()
                    HStack(spacing: 0) {
                        // Speedometer
                        SpeedometerView(speed: viewModel.groundSpeed)
                            .frame(width: 260, height: 160)
                        
                        // Terrain profile
                        TerrainProfileView(
                            altitude: viewModel.absoluteAltitude,
                            terrainAltitude: viewModel.terrainAltitude,
                            history: viewModel.terrainHistory
                        )
                        .frame(maxWidth: .infinity, maxHeight: 160)
                    }
                }
                
                // Right side altitude panel
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AltitudePanelView(altitude: viewModel.altitude)
                            .frame(width: 100, height: 250)
                            .padding(.trailing, 20)
                    }
                    .padding(.bottom, 200)
                }
                
                // Top left info
                VStack {
                    HStack {
                        ModeView(mode: viewModel.mode)
                            .padding(20)
                        Spacer()
                        GPSView(satellites: viewModel.satellites)
                            .padding(20)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ModeView: View {
    let mode: String
    
    var body: some View {
        Text("MODE: \(mode)")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(isWarningMode(mode) ? .red : .green)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(4)
    }
    
    private func isWarningMode(_ mode: String) -> Bool {
        mode.contains("FAILSAFE") || mode.contains("RTL")
    }
}

struct GPSView: View {
    let satellites: Int
    
    var body: some View {
        Text("GPS: \(satellites)")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(4)
    }
}

struct AltitudePanelView: View {
    let altitude: Double
    
    var body: some View {
        VStack {
            Text("\(String(format: "%.2f", altitude)) m")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white, lineWidth: 2)
        )
    }
}

