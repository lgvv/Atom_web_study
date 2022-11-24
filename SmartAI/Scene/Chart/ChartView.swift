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
        Text("그래프는 2개(CoreML, CNN)\n서버 통신에 문제가 있는 경우 CNN결과가 생략될 수 있습니다.")
            .multilineTextAlignment(.center)
            .foregroundColor(.green)
        
        Chart(bananaData) { banana in
            let sortedBanana = banana.bananas.sorted { $0.name < $1.name }
            
            ForEach(sortedBanana) { element in
                let probability: Float = Float(element.probability) ?? 0
                LineMark(
                    x: .value("이름", element.name),
                    y: .value("확률", probability)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                
                PointMark(
                    x: .value("이름", element.name),
                    y: .value("확률", probability)
                )
                .foregroundStyle(by: .value("타입", banana.type))
                .symbol(by: .value("심볼", banana.type))
            }
        }
        
        EmptyView()
    }
}
