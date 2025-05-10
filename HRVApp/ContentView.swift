//
//  ContentView.swift
//  swiftUITest
//
//  Created by Caz Cullimore on 5/9/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var doHRV = false
    @State private var hrSampleRate = 5
    @ObservedObject private var bluetooth = BluetoothHandler()
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    GroupBox(label: Label("Daily Steps", systemImage: "shoeprints.fill")) {
                        ViewThatFits {
                            Text("0")
                                .font(.footnote)
                            
                        }
                        .frame(height: 15)
                        ProgressView(value: 0.0)
                    }
                    
                    
                    GroupBox(label: Label("Floors", systemImage: "figure.stair.stepper")) {
                        ViewThatFits {
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
                        ViewThatFits {
                            Text("60-160")
                                .font(.footnote)
                        }
                        .frame(height: 25)
                    }
                    
                    GroupBox(label: Label("Average HRV", systemImage: "bolt.heart.fill")) {
                        ViewThatFits {
                            Text("0")
                                .font(.footnote)
                        }
                        .frame(height: 25)
                    }
                    
                }
                Divider()
                Toggle(isOn: $doHRV) {
                    Text("Enable HRV")
                    Text("calculate HRV from heart rate data")
                }
                Divider()
                SetHeartRateSampleFreqButton(hrSampleRate: hrSampleRate, hrSampleRateBinding: $hrSampleRate)
                NavigationLink(destination: GraphView()

                ) {
                    Label {
                        Text("Graphs")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)

                    } icon: {}

                }
                .navigationTitle("Summary")

                ChangeDeviceButton(bluetooth: bluetooth)
            }
            
        }
        .padding()
    }
    

}
struct SetHeartRateSampleFreqButton: View {
    var hrSampleRate: Int
    var hrSampleRateBinding: Binding<Int>
    init(hrSampleRate: Int, hrSampleRateBinding: Binding<Int>) {
        self.hrSampleRate = hrSampleRate
        self.hrSampleRateBinding = hrSampleRateBinding
    }
    var body: some View {
        NavigationLink(destination:
                                VStack {
            Text("Sample heart rate every " + ((self.hrSampleRate == 1) ? "minute" : "\(self.hrSampleRate) minutes"))
            Picker("Heart Rate Sample Rate", selection: self.hrSampleRateBinding) {
            ForEach(0..<60) { Text(($0 == 1) ? "\($0) minute" : "\($0) minutes") }
        }
        .frame(width: 200)
        .pickerStyle(.wheel)
        
    }
                            
    ) {
        Label {
            Text("Heart Rate Sampling Interval: " + ((self.hrSampleRate == 1) ? "minute" : "\(self.hrSampleRate) minutes"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {}
        
    }
    }
}


struct ChangeDeviceButton: View {
    @ObservedObject private var bluetooth: BluetoothHandler
    init(bluetooth: BluetoothHandler) {
        self.bluetooth = bluetooth
    }
    
    var body: some View {
        NavigationLink(destination:
                        List(Array(bluetooth.peripheralNameToObj.keys), id: \.self) {
            peripheralName in
            var buttonName = peripheralName + " " +  bluetooth.getConnectionStatusString(peripheralName: peripheralName)
            
            Button(buttonName, action: {bluetooth.connectButtonPressed(peripheralName: peripheralName)
            })
        }
            .navigationTitle("Peripherals")
                       
        ) {
            Label{Text("Device")} icon:{}
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview {
    ContentView()
}
