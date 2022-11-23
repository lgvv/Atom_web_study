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
        Text("그래프는 2개(CoreML, CNN)\n서버 통신에 문제가 있는 경우 CNN의 생략될 수 있습니다.")
            .multilineTextAlignment(.center)
            .foregroundColor(.green)
        
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
