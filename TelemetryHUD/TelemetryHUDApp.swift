//
//  TelemetryHUDApp.swift
//  TelemetryHUD
//
//  Main application entry point
//

import SwiftUI

@main
struct TelemetryHUDApp: App {
    @StateObject private var parser = TelemetryParser()
    @StateObject private var serialManager: SerialPortManager
    @StateObject private var viewModel: TelemetryViewModel
    @State private var selectedPort: String = ""
    @State private var showPortSelection = true
    
    init() {
        let parser = TelemetryParser()
        let serialManager = SerialPortManager(parser: parser)
        let viewModel = TelemetryViewModel(parser: parser)
        
        _parser = StateObject(wrappedValue: parser)
        _serialManager = StateObject(wrappedValue: serialManager)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            if showPortSelection {
                PortSelectionView(
                    selectedPort: $selectedPort,
                    serialManager: serialManager,
                    showPortSelection: $showPortSelection
                )
            } else {
                HUDView(viewModel: viewModel)
                    .frame(minWidth: 1024, minHeight: 768)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct PortSelectionView: View {
    @Binding var selectedPort: String
    @ObservedObject var serialManager: SerialPortManager
    @Binding var showPortSelection: Bool
    @State private var availablePorts: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select USB Serial Port")
                .font(.title)
                .padding()
            
            if availablePorts.isEmpty {
                Text("No USB serial ports found")
                    .foregroundColor(.red)
                Button("Refresh") {
                    loadPorts()
                }
            } else {
                Picker("Port", selection: $selectedPort) {
                    ForEach(availablePorts, id: \.self) { port in
                        Text(port).tag(port)
                    }
                }
                .frame(width: 400)
                
                if let error = serialManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Connect") {
                    if !selectedPort.isEmpty {
                        serialManager.connect(to: selectedPort)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if serialManager.isConnected {
                                showPortSelection = false
                            }
                        }
                    }
                }
                .disabled(selectedPort.isEmpty || serialManager.isConnected)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 300)
        .onAppear {
            loadPorts()
        }
    }
    
    private func loadPorts() {
        availablePorts = SerialPortManager.findSerialPorts()
        if !availablePorts.isEmpty && selectedPort.isEmpty {
            selectedPort = availablePorts[0]
        }
    }
}

