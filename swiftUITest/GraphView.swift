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
    var body: some View {
        VStack {
//
            
            Text("Heart rate Variability")
            Chart {
                LineMark(
                    x: .value("Shape Type", "shape1"),
                    y: .value("Total Count", 5)
                )
                LineMark(
                    x: .value("Shape Type", "shape2"),
                    y: .value("Total Count", 10)
                )
                LineMark(
                    x: .value("Shape Type","shape3"),
                    y: .value("Total Count", 8)
                )
            }
            Text("Heart rate")
            Chart {
                LineMark(
                    x: .value("Shape Type", "shape1"),
                    y: .value("Total Count", 5)
                )
                LineMark(
                    x: .value("Shape Type", "shape2"),
                    y: .value("Total Count", 10)
                )
                LineMark(
                    x: .value("Shape Type","shape3"),
                    y: .value("Total Count", 8)
                )
            }
        }
//        .frame(height: 200)
    }
}

#Preview {
    GraphView()
}

