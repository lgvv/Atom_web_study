//
//  Coordinator.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/20.
//

import UIKit

// 1. 코디네이터 프로토콜을 졍의합니다.
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

// 2. 앱 코디네이터를 생성합니다.
class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showCameraViewController()
    }
    
    // MARK: - show
    private func showCameraViewController() {
        let vc = CameraViewController()
        self.navigationController?.viewControllers = [vc]
    }
}

