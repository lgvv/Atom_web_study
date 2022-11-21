//
//  Banana.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import Foundation

// MARK: - User
struct Banana: Codable {
    let imgName: String
    let bananaClasses: [Int: String]
    let probability: [Int: Float]
    let argmax: Int

    enum CodingKeys: String, CodingKey {
        case imgName = "img_name"
        case bananaClasses = "banana_classes"
        case probability = "Probability"
        case argmax
    }
}


