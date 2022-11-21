//
//  ChartView.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import SwiftUI
import Charts

struct MountPrice: Identifiable {
    var id = UUID()
    var mount: String
    var value: Double
}

struct ChartView: View {
    
    let data: [MountPrice] = [
        MountPrice(mount: "jan/22", value: 5),
        MountPrice(mount: "feb/22", value: 4),
        MountPrice(mount: "mar/22", value: 7),
        MountPrice(mount: "apr/22", value: 15),
        MountPrice(mount: "may/22", value: 14),
        MountPrice(mount: "jun/22", value: 27),
        MountPrice(mount: "jul/22", value: 27)
    ]
    
    var body: some View {
        List {
            Chart(data) {
                LineMark(
                    x: .value("Mount", $0.mount),
                    y: .value("Value", $0.value)
                )
                PointMark(
                    x: .value("Mount", $0.mount),
                    y: .value("Value", $0.value)
                )
            }
            .background(Color.red)
            .frame(height: 250)
        }
        .background(Color.green)
    }
}
