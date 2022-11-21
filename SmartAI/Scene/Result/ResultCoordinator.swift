//
//  ResultCoordinator.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/20.
//

import UIKit

protocol ResultCoordinatorDelegate {
    func didSelectedImage(_ coordinator: ResultCoordinator)
}

class ResultCoordinator: Coordinator, ResultViewControllerProtocol {
    
    var childCoordinators: [Coordinator] = []
    var delegate: ResultCoordinatorDelegate?
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ResultViewController()
        viewController.delegate = self
        self.navigationController.viewControllers = [viewController]
    }
    
    // MARK: - ResultViewControllerProtocol
    func didTapImageView() {
        self.delegate?.didSelectedImage(self)
    }
    
}
