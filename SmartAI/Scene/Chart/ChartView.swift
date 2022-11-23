//
//  ChartView.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import SwiftUI
import Charts

let localBananaInfo: [BananaChartInfo] = [
    .init(name: "1", probability: "30"),
    .init(name: "2", probability: "10"),
    .init(name: "3", probability: "20"),
    .init(name: "4", probability: "40")
]

let serverBananaInfo: [BananaChartInfo] = [
    .init(name: "1", probability: "20"),
    .init(name: "2", probability: "30"),
    .init(name: "3", probability: "40"),
    .init(name: "4", probability: "10")
]

struct ChartView: View {

    var bananaData: [ChartInfo] = [
        .init(type: "로컬", bananas: localBananaInfo),
        .init(type: "서버", bananas: serverBananaInfo)
    ]
    
    var body: some View {
        EmptyView()
        
        Chart(bananaData) { banana in
            ForEach(banana.bananas) { element in
                LineMark(
                    x: .value("이름", element.name),
                    y: .value("확률", element.probability)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                
                PointMark(
                    x: .value("이름", element.name),
                    y: .value("확률", element.probability)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                .symbol(by: .value("심볼", banana.type))
            }
        }
        
        EmptyView()
    }
}
