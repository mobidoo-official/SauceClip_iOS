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
            isOnShareEnabled: handlerStates[.onShare] ?? false,
            delegate: self
        )
        configure(with: config)
        
        let sauceClipLib = SauceClipLib()
        sauceClipLib.viewController = self
        sauceClipLib.setInit(partnerID: "파트너 아이디", clipID: "클립 아이디")
        sauceClipLib.setProductVC(on: true)
        sauceClipLib.setStageMode(on: true)
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
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage cartInfo: SauceCartInfo?) {
        print(cartInfo?.clipIdx)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage productInfo: SauceProductInfo?) {
        print(productInfo?.clipIdx)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveErrorMessage errorType: String, errorDetails: String) {
        // 여기에서 에러 메시지에 대한 커스텀 처리를 구현합니다.
        print("에러 타입: \(errorType), 에러 상세: \(errorDetails)")
    }
    
}
