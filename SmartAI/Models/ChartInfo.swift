//
//  ChartInfo.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/22.
//

import Foundation

// MARK: - 바나나 차트
struct BananaChartInfo: Identifiable {
    let id = UUID().uuidString
    
    /**바나나 이름 */ let name: String
    /** 확률 */ let probability: String
}

struct ChartInfo: Identifiable {
    let type: String
    let bananas: [BananaChartInfo]
    
    var id: String { type }
}
