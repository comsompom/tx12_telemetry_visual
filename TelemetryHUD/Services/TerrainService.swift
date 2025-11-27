//
//  TerrainService.swift
//  TelemetryHUD
//
//  Terrain elevation service using Open-Meteo API
//

import Foundation

class TerrainService {
    private let session = URLSession.shared
    private var lastUpdate: Date?
    private let updateInterval: TimeInterval = 2.0
    
    func fetchElevation(latitude: Double, longitude: Double, completion: @escaping (Double?) -> Void) {
        // Throttle requests
        if let lastUpdate = lastUpdate, Date().timeIntervalSince(lastUpdate) < updateInterval {
            return
        }
        
        guard latitude != 0 && longitude != 0 else {
            completion(nil)
            return
        }
        
        let urlString = "https://api.open-meteo.com/v1/elevation?latitude=\(latitude)&longitude=\(longitude)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Terrain API error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let elevation = json["elevation"] as? [Double],
                  let firstElevation = elevation.first else {
                completion(nil)
                return
            }
            
            self.lastUpdate = Date()
            completion(firstElevation)
        }
        
        task.resume()
    }
}

