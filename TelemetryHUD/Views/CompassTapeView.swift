//
//  CompassTapeView.swift
//  TelemetryHUD
//
//  Compass heading tape at top of screen
//

import SwiftUI

struct CompassTapeView: View {
    let heading: Double
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let centerX = width / 2
            let pixelsPerDegree: CGFloat = 8
            let visibleDegrees = Int((width / pixelsPerDegree) / 2) + 10
            let normalizedHeading = heading.truncatingRemainder(dividingBy: 360)
            let startDeg = Int(normalizedHeading) - visibleDegrees
            let endDeg = Int(normalizedHeading) + visibleDegrees
            
            ZStack {
                // Background
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .frame(height: 70)
                
                // Compass marks
                ForEach(startDeg..<endDeg, id: \.self) { deg in
                    let dispDeg = ((deg % 360) + 360) % 360
                    let delta = Double(deg) - normalizedHeading
                    let xPos = centerX + CGFloat(delta * Double(pixelsPerDegree))
                    
                    if dispDeg % 90 == 0 {
                        // Cardinal direction
                        let txt = cardinalText(for: dispDeg)
                        VStack(spacing: 0) {
                            Text(txt)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(txt == "N" ? Color(red: 0.627, green: 0.745, blue: 0.882) : .white)
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 3, height: 20)
                        }
                        .position(x: xPos, y: 35)
                    } else if dispDeg % 10 == 0 {
                        // Major mark
                        VStack(spacing: 0) {
                            Text("\(dispDeg)")
                                .font(.system(size: 12))
                                .foregroundColor(Color(white: 0.8))
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 2, height: 15)
                        }
                        .position(x: xPos, y: 40)
                    } else if dispDeg % 5 == 0 {
                        // Minor mark
                        Rectangle()
                            .fill(Color(white: 0.6))
                            .frame(width: 1, height: 8)
                            .position(x: xPos, y: 56)
                    }
                }
                
                // Center triangle
                TriangleShape()
                    .fill(Color.red)
                    .frame(width: 20, height: 15)
                    .position(x: centerX, y: 60)
                
                // Heading display
                HStack {
                    Spacer()
                    Text("\(Int(normalizedHeading))°")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.trailing, 80)
                }
                .padding(.top, 20)
            }
        }
    }
    
    private func cardinalText(for degrees: Int) -> String {
        let normalized = degrees % 360
        if normalized < 0 { return cardinalText(for: normalized + 360) }
        switch normalized {
        case 0: return "N"
        case 90: return "E"
        case 180: return "S"
        case 270: return "W"
        default: return ""
        }
    }
}

