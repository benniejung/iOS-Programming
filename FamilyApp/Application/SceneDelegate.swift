//
//  SceneDelegate.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/12.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

      func scene(_ scene: UIScene,
                 willConnectTo session: UISceneSession,
                 options connectionOptions: UIScene.ConnectionOptions) {
          guard let windowScene = (scene as? UIWindowScene) else { return }

          let window = UIWindow(windowScene: windowScene)
          self.window = window

          // 로그인 상태 확인
          if let user = Auth.auth().currentUser {
              let userId = user.uid

              // ✅ Firestore 사용자 문서 확인
              Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
                  if let snapshot = snapshot, snapshot.exists {
                      print("✅ 사용자 정보 있음")
                      self.setRootView(TabBarController(), in: window)
                  } else {
                      print("⚠️ 사용자 문서 없음 → 강제 로그아웃")
                      try? Auth.auth().signOut()
                      self.setRootView(LoginViewController(), in: window)
                  }
              }
          } else {
              // 비로그인 상태
              print("❌ 로그인된 사용자가 없습니다.")
              setRootView(LoginViewController(), in: window)
          }
      }

      private func setRootView(_ vc: UIViewController, in window: UIWindow) {
          let navigationController = UINavigationController(rootViewController: vc)
          DispatchQueue.main.async {
              window.rootViewController = navigationController
              window.makeKeyAndVisible()
          }
      }

    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

