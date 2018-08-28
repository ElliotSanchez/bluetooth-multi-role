import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Shared.btHybridServer.start()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {

        Shared.btHybridServer.suspending()
    }

    func applicationWillTerminate(_ application: UIApplication) {

        Shared.btHybridServer.suspending()
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {

        Shared.btHybridServer.suspending()
    }
}

