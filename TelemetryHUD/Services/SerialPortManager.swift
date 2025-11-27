//
//  SerialPortManager.swift
//  TelemetryHUD
//
//  Serial port communication using IOKit
//

import Foundation
import Combine
import Darwin

class SerialPortManager: ObservableObject {
    @Published var isConnected = false
    @Published var errorMessage: String?
    
    private var fileDescriptor: Int32 = -1
    private var readSource: DispatchSourceRead?
    private let parser: TelemetryParser
    private let serialQueue: DispatchQueue
    
    init(parser: TelemetryParser) {
        self.parser = parser
        self.serialQueue = DispatchQueue(label: "serial.queue")
    }
    
    func connect(to portPath: String, baudRate: Int = 115200) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            // Open serial port
            let fd = open(portPath, O_RDWR | O_NOCTTY | O_NONBLOCK)
            guard fd >= 0 else {
                DispatchQueue.main.async {
                    strongSelf.errorMessage = "Failed to open \(portPath): \(String(cString: strerror(errno)))"
                    strongSelf.isConnected = false
                }
                return
            }
            
            strongSelf.fileDescriptor = fd
            
            // Configure serial port
            var options: termios = termios()
            guard tcgetattr(fd, &options) == 0 else {
                close(fd)
                DispatchQueue.main.async {
                    strongSelf.errorMessage = "Failed to get terminal attributes"
                    strongSelf.isConnected = false
                }
                return
            }
            
            // Set baud rate
            cfsetispeed(&options, speed_t(baudRate))
            cfsetospeed(&options, speed_t(baudRate))
            
            // 8N1 configuration
            options.c_cflag &= ~tcflag_t(PARENB)
            options.c_cflag &= ~tcflag_t(CSTOPB)
            options.c_cflag &= ~tcflag_t(CSIZE)
            options.c_cflag |= tcflag_t(CS8)
            options.c_cflag |= tcflag_t(CREAD | CLOCAL)
            options.c_cflag &= ~tcflag_t(CRTSCTS)
            
            options.c_lflag &= ~tcflag_t(ICANON | ECHO | ECHOE | ISIG)
            options.c_iflag &= ~tcflag_t(IXON | IXOFF | IXANY)
            options.c_oflag &= ~tcflag_t(OPOST)
            
            options.c_cc.0 = cc_t(0)  // VMIN
            options.c_cc.1 = cc_t(0)  // VTIME
            
            guard tcsetattr(fd, TCSANOW, &options) == 0 else {
                close(fd)
                DispatchQueue.main.async {
                    strongSelf.errorMessage = "Failed to set terminal attributes"
                    strongSelf.isConnected = false
                }
                return
            }
            
            // Create dispatch source for reading
            let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: strongSelf.serialQueue)
            
            source.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.readData()
            }
            
            source.setCancelHandler { [weak self] in
                guard let self = self else { return }
                if self.fileDescriptor >= 0 {
                    close(self.fileDescriptor)
                    self.fileDescriptor = -1
                }
            }
            
            strongSelf.readSource = source
            source.resume()
            
            DispatchQueue.main.async {
                strongSelf.isConnected = true
                strongSelf.errorMessage = nil
                print("Connected to \(portPath) at \(baudRate) baud")
            }
        }
        
        serialQueue.async(execute: workItem)
    }
    
    private func readData() {
        var buffer = [UInt8](repeating: 0, count: 100)
        let bytesRead = read(fileDescriptor, &buffer, buffer.count)
        
        if bytesRead > 0 {
            let data = Data(buffer.prefix(bytesRead))
            parser.appendData(data)
        } else if bytesRead < 0 {
            if errno != EAGAIN && errno != EWOULDBLOCK {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "Read error: \(String(cString: strerror(errno)))"
                    self?.isConnected = false
                }
            }
        }
    }
    
    func disconnect() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.readSource?.cancel()
            strongSelf.readSource = nil
            
            if strongSelf.fileDescriptor >= 0 {
                close(strongSelf.fileDescriptor)
                strongSelf.fileDescriptor = -1
            }
            
            DispatchQueue.main.async {
                strongSelf.isConnected = false
            }
        }
        
        serialQueue.async(execute: workItem)
    }
    
    static func findSerialPorts() -> [String] {
        var ports: [String] = []
        
        // Check /dev/cu.* devices (macOS)
        let fileManager = FileManager.default
        if let devContents = try? fileManager.contentsOfDirectory(atPath: "/dev") {
            for item in devContents {
                if item.hasPrefix("cu.") && (item.contains("usbmodem") || item.contains("usbserial")) {
                    ports.append("/dev/\(item)")
                }
            }
        }
        
        return ports.sorted()
    }
    
    deinit {
        disconnect()
    }
}
