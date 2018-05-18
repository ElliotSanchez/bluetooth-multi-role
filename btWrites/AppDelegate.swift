import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        BtServer.shared.start()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        BtServer.shared.stop()
    }



}

