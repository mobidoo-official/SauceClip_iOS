import UIKit
import WebKit
import SauceClip_iOS

class ClipPIPViewController: SauceClipViewController {
   
    var partnerId: String?
    var clipId: Int?
    var curationId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = SauceClipConfig(
            isEnterEnabled: true,
            isExitEnabled: true,
            isMoveProductEnabled: true,
            isMoveCartEnabled: true,
            isOnShareEnabled: true,
            delegate: self
        )
        configure(with: config)
        
        guard let partnerId = partnerId, let clipId = clipId, let curationId = curationId else {
            return
        }
        
        let sauceClipLib = SauceClipLib()
        sauceClipLib.viewController = self
        sauceClipLib.setInit(partnerID: partnerId, clipID: "\(clipId)", curationID: "\(curationId)")
        sauceClipLib.setProductVC(on: true)
        sauceClipLib.setStageMode(on: true)
        sauceClipLib.load()
    }
}

extension ClipPIPViewController: SauceClipDelegate {
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
        startPictureInPicture()
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage cartInfo: SauceCartInfo?) {
        print(cartInfo?.clipIdx)
    }
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage productInfo: SauceProductInfo?) {
        print(productInfo?.clipIdx)
    }
    
}

extension ClipPIPViewController: PIPUsable {
    public var initialState: PIPState { return .full }
}
