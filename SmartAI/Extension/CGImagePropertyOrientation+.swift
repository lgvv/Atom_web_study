//
//  CGImagePropertyOrientation+UIImageOrientation+.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/20.

import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    /**
     Converts a `UIImageOrientation` to a corresponding
     `CGImagePropertyOrientation`. The cases for each
     orientation are represented by different raw values.
     
     - Tag: ConvertOrientation
     */
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
