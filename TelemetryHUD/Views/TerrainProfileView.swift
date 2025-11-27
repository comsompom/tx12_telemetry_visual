//
//  TerrainProfileView.swift
//  TelemetryHUD
//
//  Terrain elevation profile graph
//

import SwiftUI

struct TerrainProfileView: View {
    let altitude: Double
    let terrainAltitude: Double
    let history: [(Double, Double)] // (altitude, terrain)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let startX: CGFloat = 0
            
            ZStack {
                // Panel background
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                if history.count >= 2 {
                    // Calculate scale
                    let allVals = history.flatMap { [$0.0, $0.1] }
                    let minVal = allVals.min() ?? 0
                    let maxVal = allVals.max() ?? 100
                    let span = max(maxVal - minVal, 20.0)
                    let minVisual = minVal - 10
                    let maxVisual = maxVal + 20
                    let totalRange = maxVisual - minVisual
                    let scaleY = height / totalRange
                    
                    // Terrain fill
                    Path { path in
                        let points = history.enumerated().map { index, pair in
                            let offsetIdx = index - (history.count - 1)
                            let stepSize = width / CGFloat(history.count)
                            let x = width - 50 + CGFloat(offsetIdx) * stepSize
                            let y = height - ((pair.1 - minVisual) * scaleY)
                            return CGPoint(x: max(startX, x), y: y)
                        }
                        
                        if !points.isEmpty {
                            path.move(to: CGPoint(x: points[0].x, y: height))
                            for point in points {
                                path.addLine(to: point)
                            }
                            path.addLine(to: CGPoint(x: points.last!.x, y: height))
                            path.closeSubpath()
                        }
                    }
                    .fill(Color(white: 0.16))
                    
                    // Terrain line
                    Path { path in
                        let points = history.enumerated().map { index, pair in
                            let offsetIdx = index - (history.count - 1)
                            let stepSize = width / CGFloat(history.count)
                            let x = width - 50 + CGFloat(offsetIdx) * stepSize
                            let y = height - ((pair.1 - minVisual) * scaleY)
                            return CGPoint(x: max(startX, x), y: y)
                        }
                        
                        if !points.isEmpty {
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color(white: 0.8), lineWidth: 2)
                    
                    // Aircraft altitude line
                    Path { path in
                        let points = history.enumerated().map { index, pair in
                            let offsetIdx = index - (history.count - 1)
                            let stepSize = width / CGFloat(history.count)
                            let x = width - 50 + CGFloat(offsetIdx) * stepSize
                            let y = height - ((pair.0 - minVisual) * scaleY)
                            return CGPoint(x: max(startX, x), y: y)
                        }
                        
                        if !points.isEmpty {
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color(red: 0.627, green: 0.745, blue: 0.882), lineWidth: 2)
                    
                    // Current position indicator
                    if let lastPoint = history.last {
                        let offsetIdx = history.count - 1 - (history.count - 1)
                        let stepSize = width / CGFloat(history.count)
                        let planeX = width - 50 + CGFloat(offsetIdx) * stepSize
                        let planeY = height - ((lastPoint.0 - minVisual) * scaleY)
                        let terrY = height - ((lastPoint.1 - minVisual) * scaleY)
                        
                        // Vertical line
                        Path { path in
                            path.move(to: CGPoint(x: planeX, y: planeY))
                            path.addLine(to: CGPoint(x: planeX, y: terrY))
                        }
                        .stroke(Color.red, lineWidth: 1)
                        
                        // Plane icon
                        PlaneIconView()
                            .frame(width: 20, height: 20)
                            .position(x: planeX, y: planeY)
                    }
                }
                
                // Info text
                VStack(alignment: .leading, spacing: 4) {
                    let agl = altitude - terrainAltitude
                    Text("MSL: \(Int(altitude))m  TERR: \(Int(terrainAltitude))m  AGL: \(String(format: "%.1f", agl))m")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.leading, 20)
                .padding(.top, 10)
            }
        }
    }
}

struct PlaneIconView: View {
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            ZStack {
                // Plane body
                Path { path in
                    path.move(to: CGPoint(x: centerX + 7.5, y: centerY))
                    path.addLine(to: CGPoint(x: centerX + 2.5, y: centerY - 2.5))
                    path.addLine(to: CGPoint(x: centerX - 5, y: centerY - 2.5))
                    path.addLine(to: CGPoint(x: centerX - 7.5, y: centerY - 5))
                    path.addLine(to: CGPoint(x: centerX - 7.5, y: centerY))
                    path.addLine(to: CGPoint(x: centerX - 5, y: centerY))
                    path.addLine(to: CGPoint(x: centerX - 2.5, y: centerY + 1))
                    path.addLine(to: CGPoint(x: centerX + 2.5, y: centerY + 1))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.627, green: 0.745, blue: 0.882))
                
                // Wing
                Path { path in
                    path.move(to: CGPoint(x: centerX - 2.5, y: centerY))
                    path.addLine(to: CGPoint(x: centerX + 2.5, y: centerY))
                    path.addLine(to: CGPoint(x: centerX - 1, y: centerY + 4))
                    path.closeSubpath()
                }
                .fill(Color.white)
            }
        }
    }
}

