//
//  SceneDelegate.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        
        let navigationCotroller = UINavigationController()
        window?.rootViewController = navigationCotroller
        
        let coordinator = AppCoordinator(navigationController: navigationCotroller)
        coordinator.start()
        
        window?.makeKeyAndVisible()
    }
}
