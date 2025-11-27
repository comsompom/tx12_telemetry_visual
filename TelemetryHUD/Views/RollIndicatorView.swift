//
//  RollIndicatorView.swift
//  TelemetryHUD
//
//  Roll angle indicator arc
//

import SwiftUI

struct RollIndicatorView: View {
    let roll: Double
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius: CGFloat = 280
            let thickness: CGFloat = 20
            
            ZStack {
                // Arc background
                ArcShape(startAngle: .degrees(30), endAngle: .degrees(150), radius: radius)
                    .stroke(Color(red: 0.196, green: 0.392, blue: 1.0), lineWidth: thickness)
                    .position(x: centerX, y: centerY)
                
                ArcShape(startAngle: .degrees(210), endAngle: .degrees(330), radius: radius)
                    .stroke(Color(red: 0.784, green: 0.706, blue: 0.196), lineWidth: thickness)
                    .position(x: centerX, y: centerY)
                
                // Tick marks
                ForEach([-60, -45, -30, -20, -10, 10, 20, 30, 45, 60], id: \.self) { angle in
                    let angleRad = Double(angle - 90) * .pi / 180.0
                    let rInner = radius - 5
                    let rOuter = radius + thickness + 5
                    let x1 = centerX + rInner * cos(angleRad)
                    let y1 = centerY + rInner * sin(angleRad)
                    let x2 = centerX + rOuter * cos(angleRad)
                    let y2 = centerY + rOuter * sin(angleRad)
                    
                    Path { path in
                        path.move(to: CGPoint(x: x1, y: y1))
                        path.addLine(to: CGPoint(x: x2, y: y2))
                    }
                    .stroke(Color.white, lineWidth: 2)
                    
                    // Label
                    let rText = radius + 40
                    let tx = centerX + rText * cos(angleRad)
                    let ty = centerY + rText * sin(angleRad)
                    
                    Text("\(abs(angle))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .position(x: tx, y: ty)
                }
                
                // Rotate entire indicator
                .rotationEffect(.degrees(roll))
                
                // Center triangle indicator
                TriangleShape()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .position(x: centerX, y: centerY - radius + 10)
            }
        }
    }
}

struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

