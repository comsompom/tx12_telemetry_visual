//
//  HorizonView.swift
//  TelemetryHUD
//
//  Horizon display with sky and ground
//

import SwiftUI

struct HorizonView: View {
    let roll: Double
    let pitch: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky
                Rectangle()
                    .fill(Color(red: 0.627, green: 0.745, blue: 0.882))
                    .frame(width: geometry.size.width * 2, height: geometry.size.height)
                    .offset(y: -geometry.size.height / 2 + pitch * 10)
                    .rotationEffect(.degrees(-roll))
                    .offset(x: -geometry.size.width / 2, y: -geometry.size.height / 2)
                
                // Ground
                Rectangle()
                    .fill(Color(red: 0.510, green: 0.392, blue: 0.275))
                    .frame(width: geometry.size.width * 2, height: geometry.size.height)
                    .offset(y: geometry.size.height / 2 + pitch * 10)
                    .rotationEffect(.degrees(-roll))
                    .offset(x: -geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Horizon line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 2, height: 2)
                    .offset(y: pitch * 10)
                    .rotationEffect(.degrees(-roll))
                    .offset(x: -geometry.size.width / 2)
                
                // Aircraft reference (center)
                AircraftReferenceView()
            }
        }
    }
}

struct AircraftReferenceView: View {
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            let leftWing = Path { path in
                path.move(to: CGPoint(x: centerX - 40, y: centerY))
                path.addLine(to: CGPoint(x: centerX - 10, y: centerY))
                path.addLine(to: CGPoint(x: centerX - 10, y: centerY + 10))
                path.closeSubpath()
            }
            
            let rightWing = Path { path in
                path.move(to: CGPoint(x: centerX + 10, y: centerY))
                path.addLine(to: CGPoint(x: centerX + 40, y: centerY))
                path.addLine(to: CGPoint(x: centerX + 10, y: centerY + 10))
                path.closeSubpath()
            }
            
            ZStack {
                leftWing.fill(Color.red)
                leftWing.stroke(Color.red, lineWidth: 4)
                
                rightWing.fill(Color.red)
                rightWing.stroke(Color.red, lineWidth: 4)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
                    .position(x: centerX, y: centerY)
            }
        }
    }
}

