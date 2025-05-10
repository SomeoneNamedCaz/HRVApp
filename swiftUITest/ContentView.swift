//
//  ContentView.swift
//  swiftUITest
//
//  Created by Caz Cullimore on 5/9/25.
//

import SwiftUI
import CoreBluetooth

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var watch: CBPeripheral!
    @Published var peripheralNameToObj: [String:CBPeripheral] = [:]
    
    let heartRateService = CBUUID(string: "0x180D") // heart rate serivce ID
    let deviceInfoService = CBUUID(string: "0x180A")
    let characteristicUUID = CBUUID(string: "9C9F1559-B149-D543-26B8-D03857A26DDA")
    var characteristic: CBMutableCharacteristic?
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    // this is triggered on start
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [heartRateService])
            if !connectedPeripherals.isEmpty{
                watch =  connectedPeripherals[0]
                centralManager.connect(watch)
                print("conected",connectedPeripherals)
                for per in connectedPeripherals {
                    peripheralNameToObj[per.name ?? "unnamed"] = per
                }
            }
            self.centralManager.scanForPeripherals(withServices: [heartRateService],  options: nil)// TODO: test when disconnected
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    // this is called when a peripheral is found after a scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!peripheralNameToObj.values.contains(peripheral) && peripheral.name != nil) {
            peripheralNameToObj[peripheral.name!] = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect", peripheral.name)
        peripheral.delegate = self
        print("services",peripheral.discoverServices(nil))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral", peripheral)
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral updated state")
        if peripheral.state == .poweredOn {
            let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify, .read, .write], value: nil, permissions: [.readable, .writeable])
//            let service = CBMutableService(type: serviceUUID, primary: true)
//            service.characteristics = [characteristic]
//            peripheralManager.add(service)
//            self.characteristic = characteristic
//            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        } else {
            print("Peripheral is not available.")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("peripheral received read")
        if request.characteristic.uuid == characteristicUUID {
            if let value = "Hello Central".data(using: .utf8) {
                request.value = value
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("peripheral received write")
        for request in requests {
            if request.characteristic.uuid == characteristicUUID {
                if let value = request.value, let message = String(data: value, encoding: .utf8) {
                    print("Received message: \(message)")
                }
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.name ?? "unnamed peripheral","did discover service", peripheral.services)
            if let services = peripheral.services {
                for service in services {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    //
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            print("discover chars")
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    print("chars", characteristic)
                    if characteristic.uuid == characteristicUUID {
                        peripheral.setNotifyValue(true, for: characteristic)
                        if let message = "Hello Peripheral".data(using: .utf8) {
                            peripheral.writeValue(message, for: characteristic, type: .withResponse)
                        }
                    }
                }
            }
        }
    
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            print("CHAR UUID",characteristic.uuid)
            if characteristic.uuid == characteristicUUID {
                if let value = characteristic.value, let message = String(data: value, encoding: .utf8) {
                    print("Received message: \(message)")
                }
            }
        }
}
    


//extension BluetoothViewModel: CBPeripheralDelegate {
//    
//
//    
//}


struct ContentView: View {
    @State private var doHRV = false;
    @State private var hrSampleRate = 5;
    @ObservedObject private var bluetooth = BluetoothViewModel()
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    GroupBox(label: Label("Daily Steps",systemImage:  "shoeprints.fill")) {
                        ScrollView(.vertical, showsIndicators: true) {
                            Text("0")
                                .font(.footnote)
                        }
                        .frame(height: 15)
                        ProgressView(value: 0.0)
                    }
                    GroupBox(label: Label("Floors",systemImage:  "figure.stair.stepper")) {
                        ScrollView(.vertical, showsIndicators: true) {
                            Text("0")
                                .font(.footnote)
                        }
                        .frame(height: 15)
                        ProgressView(value: 0.0)
                    }
                        
                }
                HStack {
                    GroupBox(label: Label {
                        Text("HR Range")
                    } icon: {
                        Image(systemName: "heart.fill")
                    }
                    ) {
                        ScrollView(.vertical, showsIndicators: true) {
                            Text("60-160")
                                .font(.footnote)
                        }
                        .frame(height: 25)
                    }
                    GroupBox(label: Label("Average HRV",systemImage:  "bolt.heart.fill")) {
                        ScrollView(.vertical, showsIndicators: true) {
                            Text("0")
                                .font(.footnote)
                        }
                        .frame(height: 15)
                        ProgressView(value: 0.0)
                    }
                        
                }
                Toggle(isOn: $doHRV) {
                    Text("Enable HRV")
                    Text("calculate HRV from heart rate data")
                }
                
                NavigationLink(destination:
                                VStack {
                    Text("Sample Heart Rate Every " + String(hrSampleRate) + " mins")
                    Picker("Heart Rate Sample Rate ", selection: $hrSampleRate) {
                        ForEach(0..<60) { Text("\($0) mins") }
                    }
                    .frame(width: 100)
                    //                                            .clipped()
                    .pickerStyle(.wheel)
                }
    
    
    
                ) {
                    Label {
                        Text("Sample HeartRate")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {}
                    
                }
                    NavigationLink(destination: GraphView()
                                   
                    ) {
                        Label {
                            Text("Go To Graphs")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                    
                            
                        } icon: {
                            Image(systemName: "chart.line.text.clipboard")
                        }
                        
                        
                    }
                    .navigationTitle("Summary")
                
                NavigationLink(destination:
//                                        VStack{
                    List(Array(bluetooth.peripheralNameToObj.keys), id:\.self) {
                        peripheralName in Button(peripheralName, action: {bluetooth.centralManager.connect(bluetooth.peripheralNameToObj[peripheralName]!)
                        })
                    }
                    .navigationTitle("Peripherals")
                    
                    ) {
                        Label("connect to device", systemImage: "dot.radiowaves.left.and.right")
                    }
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

func run(param:CBPeripheral) {
    print("ran", param)
}
