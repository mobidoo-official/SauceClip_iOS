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
            pipSize: CGSize(width: 100, height: 200),
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
        PIPKit.dismiss(animated: true)
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
    
    func sauceClipManager(_ manager: SauceClipViewController, didReceiveErrorMessage sauceError: SauceError?) {
        guard let error = sauceError else { return }
        let alertController = UIAlertController(title:"\(error.errorType)", message: "\(error.errorDetails)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
