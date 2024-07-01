import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
//        let vc = ConfigViewController()
//        window?.rootViewController = vc
        let navigationController = UINavigationController(rootViewController: MainViewController())
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
        return true
    }
}



