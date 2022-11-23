//
//  ChartView.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import SwiftUI
import Charts

struct ChartView: View {

    var bananaData: [ChartInfo] = []
    
    init(bananaData: [ChartInfo]) {
        self.bananaData = bananaData
    }
    
    var body: some View {
        EmptyView()
        
        Chart(bananaData) { banana in
            ForEach(banana.bananas) { element in
                LineMark(
                    x: .value("확률", element.probability),
                    y: .value("이름", element.name)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                
                PointMark(
                    x: .value("확률", element.probability),
                    y: .value("이름", element.name)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                .symbol(by: .value("심볼", banana.type))
            }
        }
        
        EmptyView()
    }
}
