import Flutter
import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Reuse the single engine created in AppDelegate — no second engine
        // created here. The location/battery EventChannels and the
        // location_control MethodChannel are also registered once on that
        // engine in AppDelegate, so they (and the LocationHandler instance
        // behind them) are unaffected by this scene connecting/disconnecting.
        let flutterVC = FlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterVC
        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("📱 App entered background")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("📱 App entering foreground")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("🛑 Scene disconnected")
    }
}
