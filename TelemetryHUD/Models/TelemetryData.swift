//
//  TelemetryData.swift
//  TelemetryHUD
//
//  Telemetry data model and packet parsing
//

import Foundation
import Combine

struct TelemetryData {
    var roll: Double = 0.0
    var pitch: Double = 0.0
    var yaw: Double = 0.0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var altitude: Double = 0.0
    var groundSpeed: Double = 0.0
    var verticalSpeed: Double = 0.0
    var satellites: Int = 0
    var mode: String = "WAIT"
    var terrainAltitude: Double = 0.0
    var homeAltitude: Double? = nil
    var gpsFix: Bool = false
}

class TelemetryParser: ObservableObject {
    private let dataLock = NSLock()
    private(set) var telemetry = TelemetryData()
    private var buffer = Data()
    
    private func readInt16(from data: Data, offset: Int) -> Int16? {
        guard data.count >= offset + 2 else { return nil }
        var value: Int16 = 0
        data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return }
            memcpy(&value, base.advanced(by: offset), MemoryLayout<Int16>.size)
        }
        return Int16(bigEndian: value)
    }
    
    private func readUInt16(from data: Data, offset: Int) -> UInt16? {
        guard data.count >= offset + 2 else { return nil }
        var value: UInt16 = 0
        data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return }
            memcpy(&value, base.advanced(by: offset), MemoryLayout<UInt16>.size)
        }
        return UInt16(bigEndian: value)
    }
    
    private func readInt32(from data: Data, offset: Int) -> Int32? {
        guard data.count >= offset + 4 else { return nil }
        var value: Int32 = 0
        data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return }
            memcpy(&value, base.advanced(by: offset), MemoryLayout<Int32>.size)
        }
        return Int32(bigEndian: value)
    }
    
    private func readUInt8(from data: Data, offset: Int) -> UInt8? {
        guard data.count > offset else { return nil }
        var value: UInt8 = 0
        data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return }
            memcpy(&value, base.advanced(by: offset), MemoryLayout<UInt8>.size)
        }
        return value
    }
    
    func appendData(_ data: Data) {
        buffer.append(data)
        processBuffer()
    }
    
    private func processBuffer() {
        while buffer.count > 4 {
            guard let firstByte = buffer.first else { break }
            guard firstByte == 0xEA || firstByte == 0xC8 else {
                buffer.removeFirst()
                continue
            }
            
            let secondIndex = buffer.index(after: buffer.startIndex)
            guard secondIndex < buffer.endIndex else { break }
            let length = Int(buffer[secondIndex])
            
            // Validate packet length
            guard length >= 2 && length <= 64 else {
                buffer.removeFirst()
                continue
            }
            
            // Check if we have complete packet
            guard buffer.count >= length + 2 else { break }
            
            let packetRangeEnd = buffer.index(buffer.startIndex, offsetBy: length + 2)
            let packet = buffer[buffer.startIndex..<packetRangeEnd]
            let typeIndex = buffer.index(buffer.startIndex, offsetBy: 2)
            let payloadStart = buffer.index(buffer.startIndex, offsetBy: 3)
            let payloadEnd = buffer.index(buffer.startIndex, offsetBy: length + 1)
            let packetType = packet[typeIndex]
            let payload = buffer[payloadStart..<payloadEnd]
            
            parsePacket(type: packetType, payload: payload)
            
            // Remove processed packet
            buffer.removeFirst(length + 2)
        }
    }
    
    private func parsePacket(type: UInt8, payload: Data) {
        dataLock.lock()
        defer { dataLock.unlock() }
        
        switch type {
        case 0x02: // GPS data
            if payload.count >= 14 {
                if let lat = readInt32(from: payload, offset: 0),
                   let lon = readInt32(from: payload, offset: 4),
                   let gspd = readUInt16(from: payload, offset: 8) {
                    telemetry.latitude = Double(lat) / 1e7
                    telemetry.longitude = Double(lon) / 1e7
                    telemetry.groundSpeed = Double(gspd) / 10.0
                }
                
                if payload.count >= 15,
                   let sats = readUInt8(from: payload, offset: 14) {
                    telemetry.satellites = Int(sats)
                    telemetry.gpsFix = telemetry.satellites >= 4
                }
            }
            
        case 0x07: // Vertical speed
            if payload.count >= 2 {
                if let vspd = readInt16(from: payload, offset: 0) {
                    telemetry.verticalSpeed = Double(vspd) / 100.0
                }
            }
            
        case 0x09: // Barometric altitude
            if payload.count >= 2 {
                if let baro = readUInt16(from: payload, offset: 0) {
                    telemetry.altitude = (Double(baro) - 10000.0) / 10.0
                }
            }
            
        case 0x1E: // Attitude (pitch, roll, yaw)
            if payload.count >= 6 {
                if let pitchRaw = readInt16(from: payload, offset: 0),
                   let rollRaw = readInt16(from: payload, offset: 2),
                   let yawRaw = readInt16(from: payload, offset: 4) {
                    telemetry.pitch = Double(pitchRaw) / 10000.0 * 57.2958
                    telemetry.roll = Double(rollRaw) / 10000.0 * 57.2958
                    telemetry.yaw = Double(yawRaw) / 10000.0 * 57.2958
                }
            }
            
        case 0x21: // Flight mode
            if let modeString = String(data: payload, encoding: .utf8) {
                let cleanMode = modeString.replacingOccurrences(of: "\0", with: "").trimmingCharacters(in: .whitespaces)
                if !cleanMode.isEmpty {
                    telemetry.mode = cleanMode
                }
            }
            
        default:
            break
        }
    }
    
    func getTelemetry() -> TelemetryData {
        dataLock.lock()
        defer { dataLock.unlock() }
        return telemetry
    }
}

