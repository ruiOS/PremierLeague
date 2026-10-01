//
//  SceneDelegate.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 29/09/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let mainWindow = UIWindow(windowScene: windowScene)

        // MARK: Root navigation stack
        let teamsVC = TeamsViewBuilder().build()
        let navigationController = UINavigationController(rootViewController: teamsVC)
        navigationController.navigationBar.prefersLargeTitles = true

        mainWindow.rootViewController = navigationController
        mainWindow.makeKeyAndVisible()
        self.window = mainWindow
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
