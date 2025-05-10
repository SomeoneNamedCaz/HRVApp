//
//  GraphView.swift
//  swiftUITest
//
//  Created by Caz Cullimore on 5/9/25.
//

//
//  ContentView.swift
//  swiftUITest
//
//  Created by Caz Cullimore on 5/9/25.
//

import SwiftUI
import Charts

struct GraphView: View {
    let dateFormatter: DateFormatter = DateFormatter()
    var body: some View {
        VStack {
            
            Text("Heart Rate Variability (ms)")
            
            Chart {
                LineMark(
                    x: .value("date","1/1/2000"),
                    y: .value("HRV", 50)
                )
                LineMark(
                    x: .value("date", "1/2/2000"),
                    y: .value("HRV", 60)
                )
                LineMark(
                    x: .value("date", "1/3/2000"),
                    y: .value("HRV", 65)
                )
            }
            .chartYScale(domain: [0,100])
            Text("Heart Rate (bpm)")
            Chart {
                LineMark(
                    x: .value("date", "1/1/2000"),
                    y: .value("HR", 78)
                )
                LineMark(
                    x: .value("date", "1/2/2000"),
                    y: .value("HR", 70)
                )
                LineMark(
                    x: .value("date", "1/3/2000"),
                    y: .value("HR", 75)
                )
            }
            .chartYScale(domain: [0,200])
        }
//        .frame(height: 200)
    }
}

#Preview {
    GraphView()
}
