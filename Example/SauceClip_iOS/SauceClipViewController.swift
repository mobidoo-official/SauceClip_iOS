import UIKit
import WebKit
import SauceClip_iOS

class SauceViewController: SauceClipViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        sauceClipLib.setInit(partnerID: Config.partnerID, clipID:
                                Config.clipID, curationID: Config.curationID )
        sauceClipLib.setProductVC(on: true)
        sauceClipLib.setStageMode(on: Config.stage)
        sauceClipLib.load()
    }
}

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
        guard let error = sauceError else { return }
        let alertController = UIAlertController(title:"\(error.errorType)", message: "\(error.errorDetails)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveAddCartMessage addCartInfo: SauceCartInfo?) {
        print(addCartInfo?.clipIdx)
        print(addCartInfo?.productCode)
    }
    
}
