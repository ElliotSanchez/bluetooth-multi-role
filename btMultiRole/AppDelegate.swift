import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BleEventLogger().log("\(#function)")

        Shared.btHybridServer.start()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        BleEventLogger().log("\(#function)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BleEventLogger().log("\(#function)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        BleEventLogger().log("\(#function)")

        //Shared.btHybridServer.suspending()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        BleEventLogger().log("\(#function)")

        Shared.btHybridServer.suspending()
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        BleEventLogger().log("\(#function)")

        Shared.btHybridServer.suspending()
    }

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        BleEventLogger().log("\(#function)")
        return true
    }

    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        BleEventLogger().log("\(#function)")
    }
}

