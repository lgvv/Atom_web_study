//
//  Coordinator.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/19.
//

import UIKit

extension UIViewController {
    func showResultViewController() {
        let vc = ResultViewController()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        self.present(vc, animated: true)
    }
}
