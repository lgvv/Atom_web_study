//
//  Banana.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import Foundation

// MARK: - User
struct Banana: Codable {
    /** 이미지 이름*/ let imgName: String
    /** 바나나 클래스*/ let bananaClasses: [Int: String]
    /** 확률 정보*/ let probability: [Int: Float]
    /** 가장 높은 확률의 바나나*/ let argmax: Int

    enum CodingKeys: String, CodingKey {
        case imgName = "img_name"
        case bananaClasses = "banana_classes"
        case probability = "Probability"
        case argmax
    }
    
    let uuid = UUID().uuidString
}
