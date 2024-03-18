import UIKit
import WebKit
import SauceClip_iOS

class SauceViewController: SauceClipViewController {
    var urlString = String()
    var handlerStates: [MessageHandlerName: Bool] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = SauceViewControllerConfig(
            url: urlString,
            isEnterEnabled: handlerStates[.enter] ?? false,
            isExitEnabled: handlerStates[.exit] ?? false,
            isMoveProductEnabled: handlerStates[.moveProduct] ?? false,
            isMoveCartEnabled: handlerStates[.moveCart] ?? false,
            isOnShareEnabled: handlerStates[.onShare] ?? false,
            delegate: self
        )
        configure(with: config)
    }
}

// SauceClipDelegate 프로토콜 채택 및 구현
extension SauceViewController: SauceClipDelegate {
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveEnterMessage message: WKScriptMessage) {
        print("enter")
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveExitMessage message: WKScriptMessage) {
        self.dismiss(animated: true)
        print("exit")
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveLoginMessage message: WKScriptMessage) {
        print("login")
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage message: WKScriptMessage) {
        print("cart")
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage message: WKScriptMessage) {
        print("product")
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveOnShareMessage message: WKScriptMessage) {
        print("share")
    }
}
