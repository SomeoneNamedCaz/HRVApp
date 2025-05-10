//
//  BluetoothHandler.swift
//  HRVApp
//
//  Created by Caz Cullimore on 5/10/25.
//
import CoreBluetooth

class BluetoothHandler: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var watch: CBPeripheral!
    @Published var peripheralNameToObj: [String: CBPeripheral] = [:]

    let heartRateService = CBUUID(string: "0x180D") // heart rate serivce ID
    let deviceInfoService = CBUUID(string: "0x180A")
    
    let heartRateMeasurmentCharacteristic = CBUUID(string: "0x2A37")
    var characteristic: CBMutableCharacteristic?
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    // this is triggered on start
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        if central.state == .poweredOn {
            let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [heartRateService])
            if !connectedPeripherals.isEmpty {
                watch =  connectedPeripherals[0] // Assumes only one previously connected watch
                centralManager.connect(watch)
                print("conected", connectedPeripherals)
                for per in connectedPeripherals {
                    peripheralNameToObj[per.name ?? "unnamed"] = per
                }
            }
            self.centralManager.scanForPeripherals(withServices: [heartRateService], options: nil)// TODO: test when disconnected
        } else {
            print("Bluetooth is not available.")
        }
    }

    // this is called when a peripheral is found after a scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !peripheralNameToObj.values.contains(peripheral) && peripheral.name != nil {
            peripheralNameToObj[peripheral.name!] = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect", peripheral.name)
        peripheral.delegate = self
        peripheral.discoverServices([heartRateService])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral", peripheral)
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral updated state")
        if peripheral.state == .poweredOn {
            
        } else {
            print("Peripheral is not available.")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("peripheral received read")
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("updated notification state", characteristic)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("peripheral received write")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.name ?? "unnamed peripheral", "did discover service", peripheral.services)
            if let services = peripheral.services {
                for service in services {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            print("discover chars")
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.properties.contains(.notify) {
                      peripheral.setNotifyValue(true, for: characteristic)
                        
                    }

                    peripheral.readValue(for: characteristic)
                    

                }
            }
        }

        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            print("updated")
            if heartRateMeasurmentCharacteristic == characteristic.uuid {
                print("CHAR",characteristic, characteristic.value, error)
                let hr = heartRate(from: characteristic)
                print("heart rate",  hr)
            }
        }
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return 0}
      let byteArray = [UInt8](characteristicData)
        if byteArray.count < 2 {
            return -1
        }
      let firstBitValue = byteArray[0] & 0x01
      if firstBitValue == 0 {
        // Heart Rate Value Format is in the 2nd byte
        return Int(byteArray[1])
      } else {
        // Heart Rate Value Format is in the 2nd and 3rd bytes
        return (Int(byteArray[1]) << 8) + Int(byteArray[2])
      }
    }
    func connectButtonPressed(peripheralName: String){
        if peripheralNameToObj[peripheralName]!.state == CBPeripheralState.connected {
            centralManager.cancelPeripheralConnection(peripheralNameToObj[peripheralName]!)
            print("disconnect")
            
        }else{
            
            centralManager.connect(peripheralNameToObj[peripheralName]!)
            print("connected")
        }
        print(peripheralNameToObj[peripheralName]!)
        objectWillChange.send()
    }
    func getConnectionStatusString(peripheralName:String) -> String {
        switch peripheralNameToObj[peripheralName]!.state {
        case CBPeripheralState.connected:
            return "(Connected)"
        case CBPeripheralState.connecting:
            return"(Connecting)"
        default:
            return"(Disconnected)"
        }
    }
}
