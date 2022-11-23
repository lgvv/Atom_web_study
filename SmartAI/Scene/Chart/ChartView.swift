//
//  ChartView.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import SwiftUI
import Charts

struct SalesSummary: Identifiable {
    var id: String = UUID().uuidString
    
    var weekday: String
    var sales: Int
}

let sfData: [SalesSummary] = [
    .init(weekday: "안녕", sales: 100),
    .init(weekday: "가방", sales: 150),
    .init(weekday: "옷", sales: 50)
]

let cuData: [SalesSummary] = [
    .init(weekday: "안녕", sales: 50),
    .init(weekday: "가방", sales: 100),
    .init(weekday: "옷", sales: 150)
]


struct Series: Identifiable {
    let city: String
    let sales: [SalesSummary]
    
    var id: String { city }
}

let seriesData: [Series] = [
    .init(city: "다림쥐네 집", sales: sfData),
    .init(city: "씨유 집", sales: cuData)
]

// MARK: - 바나나 차트
struct BananaChartInfo: Identifiable {
    var id = UUID().uuidString
    
    /**바나나 이름 */ var name: String
    /** 확률 */ var probability: String
}

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

struct ChartInfo: Identifiable {
    let type: String
    let bananas: [BananaChartInfo]
    
    var id: String { type }
}

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
