//
//  CameraCoordinator.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/20.
//

import UIKit

protocol CameraCoordinatorDelegate {
    func didCapture(for image: UIImage, _ coordinator: CameraCoordinator)
}

class CameraCoordinator: Coordinator, CameraViewControllerProtocol {
    
    var childCoordinators: [Coordinator] = []
    var delegate: CameraCoordinatorDelegate?
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = CameraViewController()
        viewController.delegate = self
        
        self.navigationController.viewControllers = [viewController]
    }
    
    // MARK: - CameraViewControllerProtocol
    func didTapCaptureButton(for image: UIImage) {
        self.delegate?.didCapture(for: image, self)
    }
}
