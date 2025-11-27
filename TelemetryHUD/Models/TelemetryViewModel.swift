//
//  TelemetryViewModel.swift
//  TelemetryHUD
//
//  View model managing telemetry data and updates
//

import Foundation
import Combine

class TelemetryViewModel: ObservableObject {
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var groundSpeed: Double = 0.0
    @Published var verticalSpeed: Double = 0.0
    @Published var satellites: Int = 0
    @Published var mode: String = "WAIT"
    @Published var terrainAltitude: Double = 0.0
    @Published var homeAltitude: Double? = nil
    @Published var gpsFix: Bool = false
    
    @Published var terrainHistory: [(Double, Double)] = [] // (altitude, terrain)
    
    private let parser: TelemetryParser
    private let terrainService = TerrainService()
    private var updateTimer: Timer?
    private var terrainTimer: Timer?
    
    var absoluteAltitude: Double {
        if let home = homeAltitude {
            return home + altitude
        }
        return altitude
    }
    
    init(parser: TelemetryParser) {
        self.parser = parser
        startUpdates()
    }
    
    private func startUpdates() {
        // Update telemetry data at 30 Hz
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let data = self.parser.getTelemetry()
            
            DispatchQueue.main.async {
                self.roll = data.roll
                self.pitch = data.pitch
                self.yaw = data.yaw
                self.latitude = data.latitude
                self.longitude = data.longitude
                self.altitude = data.altitude
                self.groundSpeed = data.groundSpeed
                self.verticalSpeed = data.verticalSpeed
                self.satellites = data.satellites
                self.mode = data.mode
                self.terrainAltitude = data.terrainAltitude
                self.homeAltitude = data.homeAltitude
                self.gpsFix = data.gpsFix
                
                // Update terrain history
                let absAlt = self.absoluteAltitude
                self.terrainHistory.append((absAlt, data.terrainAltitude))
                if self.terrainHistory.count > 150 {
                    self.terrainHistory.removeFirst()
                }
            }
        }
        
        // Fetch terrain data every 2 seconds
        terrainTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let data = self.parser.getTelemetry()
            
            if data.gpsFix && data.latitude != 0 && data.longitude != 0 {
                self.terrainService.fetchElevation(latitude: data.latitude, longitude: data.longitude) { [weak self] elevation in
                    guard let self = self, let elevation = elevation else { return }
                    
                    DispatchQueue.main.async {
                        self.terrainAltitude = elevation
                        if self.homeAltitude == nil {
                            self.homeAltitude = elevation
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        updateTimer?.invalidate()
        terrainTimer?.invalidate()
    }
}

