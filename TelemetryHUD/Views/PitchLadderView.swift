//
//  PitchLadderView.swift
//  TelemetryHUD
//
//  Pitch ladder display
//

import SwiftUI

struct PitchLadderView: View {
    let roll: Double
    let pitch: Double
    
    var body: some View {
        GeometryReader { geometry in
            let size = max(geometry.size.width, geometry.size.height) * 1.5
            let pixelsPerDegree: CGFloat = 10
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            ZStack {
                ForEach(-45..<50, id: \.self) { angle in
                    if angle != 0 {
                        let yPos = centerY - CGFloat(angle) * pixelsPerDegree + CGFloat(pitch) * pixelsPerDegree
                        let length: CGFloat = angle % 10 == 0 ? 140 : 60
                        
                        // Line
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: length, height: 2)
                            .position(x: centerX, y: yPos)
                            .rotationEffect(.degrees(roll))
                            .offset(x: -centerX, y: -centerY)
                            .position(x: centerX, y: centerY)
                        
                        // Label for major angles
                        if angle % 10 == 0 {
                            Text("\(abs(angle))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .position(x: centerX - length/2 - 25, y: yPos)
                                .rotationEffect(.degrees(roll))
                                .offset(x: -centerX, y: -centerY)
                                .position(x: centerX, y: centerY)
                            
                            Text("\(abs(angle))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .position(x: centerX + length/2 + 5, y: yPos)
                                .rotationEffect(.degrees(roll))
                                .offset(x: -centerX, y: -centerY)
                                .position(x: centerX, y: centerY)
                        }
                    }
                }
            }
        }
    }
}

