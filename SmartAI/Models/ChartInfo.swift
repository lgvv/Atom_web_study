////
////  ChartInfo.swift
////  SmartAI
////
////  Created by Hamlit Jason on 2022/11/22.
////
//
//import Foundation
//
//class ChartItem: Identifiable {
//    let id = UUID().uuidString
//    
//    var bananaClass: String
//    var probability: String
//    
//    init(bananaClass: String, probability: String) {
//        self.bananaClass = bananaClass
//        self.probability = probability
//    }
//}
//
//class ChartInfo: ObservableObject, Identifiable {
//    let id = UUID().uuidString
//    
//    @Published var localData: [ChartItem] = [] {
//        didSet { print("🧓🏾 \(localData)")}
//    }
//    
//    @Published var serverData: [ChartItem] = [] {
//        didSet { print("🧕🏻 \(serverData)")}
//    }
//}
