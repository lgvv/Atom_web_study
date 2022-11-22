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

struct ChartView: View {
    @Binding var temp: [String] {
        didSet { print("🫵🏼 \(temp)") }
    }
//    
//    init(temp: Binding<[String]> = .init([])) {
//        self._temp = temp
//    }
    var body: some View {
        Chart(seriesData) { series in
            ForEach(series.sales) { element in
                LineMark(
                    x: .value("Day", element.weekday),
                    y: .value("Sales", element.sales)
                )
                .foregroundStyle(by: .value("City", series.city))
                
                PointMark(
                    x: .value("Day", element.weekday),
                    y: .value("Sales", element.sales)
                )
                .foregroundStyle(by: .value("City", series.city))
                .symbol(by: .value("City", series.city))
            }
        }
    }
}
