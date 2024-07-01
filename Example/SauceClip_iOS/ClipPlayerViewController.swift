//import UIKit
//
//class ClipPlayerViewController: UIViewController {
//    
//
    
import UIKit
import WebKit
import SauceClip_iOS

class ClipPlayerViewController: SauceClipViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    
    var partnerID: String?
    var clipID: String?
    var curationID: String?
    var isStageMode: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("keaton1234")
        print(isStageMode)
        
        let config = SauceClipConfig(
            isEnterEnabled: handlerStates[.enter] ?? false,
            isExitEnabled: handlerStates[.exit] ?? false,
            isMoveProductEnabled: handlerStates[.moveProduct] ?? false,
            isMoveCartEnabled: handlerStates[.moveCart] ?? false,
            isAddCartEnabled: handlerStates[.addCart] ?? false,
            isOnShareEnabled: handlerStates[.onShare] ?? false,
            delegate: self
        )
        configure(with: config)
        let sauceClipLib = SauceClipLib()
        sauceClipLib.viewController = self
        sauceClipLib.setInit(partnerID: partnerID ?? "", clipID:
                                clipID ?? "" , curationID: "")
        sauceClipLib.setProductVC(on: true)
        sauceClipLib.setStageMode(on: isStageMode)
        sauceClipLib.load()
    }
}

extension ClipPlayerViewController: SauceClipDelegate {
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
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveOnShareMessage shareInfo: SauceShareInfo?) {
        print(shareInfo?.clipId)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage: WKScriptMessage?) {
        // 장바구니 이동
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage productInfo: SauceProductInfo?) {
        print(productInfo?.clipIdx)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveErrorMessage sauceError: SauceError?) {
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveAddCartMessage addCartInfo: SauceCartInfo?) {
        print(addCartInfo?.clipIdx)
        print(addCartInfo?.productCode)
    }
    
}
