//
//  ChartInfo.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/22.
//

import Foundation

class ChartInfo: ObservableObject {
    let identifier = UUID().uuidString
    
    @Published var localData: [(String, String)] = [] {
        didSet { print("🧓🏾 \(localData)")}
    }
    
    @Published var serverData: [(String, String)] = [] {
        didSet { print("🧕🏻 \(serverData)")}
    }
}
