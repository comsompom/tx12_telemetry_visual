//
//  SpeedometerView.swift
//  TelemetryHUD
//
//  Analog speedometer gauge
//

import SwiftUI

struct SpeedometerView: View {
    let speed: Double
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2 + 10
            let radius: CGFloat = 65
            let minVal: Double = 0
            let maxVal: Double = 100
            let startAngle: Double = 135
            let totalAngle: Double = 270
            
            ZStack {
                // Panel background
                Rectangle()
                    .fill(Color(white: 0.12))
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                // Gauge background circle
                Circle()
                    .fill(Color(white: 0.04))
                    .frame(width: radius * 2, height: radius * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .position(x: centerX, y: centerY)
                
                // Tick marks
                ForEach(0..<21, id: \.self) { i in
                    let val = Double(i) * 5
                    let pct = (val - minVal) / (maxVal - minVal)
                    let angleDeg = startAngle + (pct * totalAngle)
                    let angleRad = (angleDeg + 90) * .pi / 180.0
                    
                    let isMajor = val.truncatingRemainder(dividingBy: 10) == 0
                    let rOut = radius - 2
                    let rIn = isMajor ? radius - 10 : radius - 6
                    
                    Path { path in
                        let x1 = centerX + rIn * cos(angleRad)
                        let y1 = centerY + rIn * sin(angleRad)
                        let x2 = centerX + rOut * cos(angleRad)
                        let y2 = centerY + rOut * sin(angleRad)
                        path.move(to: CGPoint(x: x1, y: y1))
                        path.addLine(to: CGPoint(x: x2, y: y2))
                    }
                    .stroke(isMajor ? Color.white : Color(white: 0.6), lineWidth: isMajor ? 2 : 1)
                    
                    // Label for major ticks
                    if isMajor {
                        let rText = radius - 20
                        let tx = centerX + rText * cos(angleRad)
                        let ty = centerY + rText * sin(angleRad)
                        
                        Text("\(Int(val))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .position(x: tx, y: ty)
                    }
                }
                
                // Needle
                let clamped = max(minVal, min(maxVal, speed))
                let pct = (clamped - minVal) / (maxVal - minVal)
                let angleRad = (startAngle + (pct * totalAngle) + 90) * .pi / 180.0
                let nx = centerX + (radius - 5) * cos(angleRad)
                let ny = centerY + (radius - 5) * sin(angleRad)
                
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: nx, y: ny))
                }
                .stroke(Color.red, lineWidth: 3)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .position(x: centerX, y: centerY)
                
                // Labels
                VStack(spacing: 0) {
                    Text("SPEED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(white: 0.8))
                    Text("km/h")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(white: 0.8))
                }
                .position(x: centerX, y: centerY + 50)
            }
        }
    }
}

