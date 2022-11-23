//
//  Coordinator.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/20.
//

import UIKit
import SwiftUI

// 1. 코디네이터 프로토콜을 졍의합니다.
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

// 2. 앱 코디네이터를 생성합니다.
final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showCameraViewController()
    }
    
    // MARK: - show
    private func showCameraViewController() {
        let coordinator = CameraCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        coordinator.start()
        self.childCoordinators.append(coordinator)
    }
    
    func showResultViewController(image: UIImage) {
        let resultViewController = ResultViewController()
        resultViewController.image = image
        let vc = UINavigationController(rootViewController: resultViewController)
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.delegate = resultViewController 
        }
        
        navigationController.present(vc, animated: true)
    }
    
    func showChartView(bananaData: [ChartInfo]) {
        let chartView = ChartView(bananaData: bananaData)
        let vc = UIHostingController(rootView: chartView)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AppCoordinator: CameraCoordinatorDelegate {
    func didCapture(for image: UIImage, _ coordinator: CameraCoordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== coordinator }
        self.showResultViewController(image: image)
    }
}

extension AppCoordinator: ResultCoordinatorDelegate {
    func didTapMoreInfo(for bananaData: [ChartInfo], _ coordinator: ResultCoordinator) {
        let chartView = ChartView(bananaData: bananaData)
        let vc = UIHostingController(rootView: chartView)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
