import UIKit
import WebKit
import SauceClip_iOS

class SauceCurationViewController: UIViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let sauceCurationView = SauceCurationLib()
        sauceCurationView.delegate = self
        let config = SauceCurationLib.SauceCurationConfig(
            isBroadCastEnabled: handlerStates[.moveBroadcast] ?? false,
            delegate: self
        )
        sauceCurationView.configure(with: config)
        sauceCurationView.setInit(partnerID: Config.partnerID, curationID: Config.curationID)
        sauceCurationView.setStageMode(on: Config.stage)
        sauceCurationView.setPvVisibility(false)
        sauceCurationView.setPreviewAutoPlay(true)
        sauceCurationView.setHorizontalPadding(10)
        
        self.view.addSubview(sauceCurationView)
        sauceCurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sauceCurationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        sauceCurationView.load()
    }
}

extension SauceCurationViewController: SauceCurationDelegate {
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo?) {
        // 일반 VC
//        let viewController = ClipViewController()
//        viewController.modalPresentationStyle = .fullScreen
//        viewController.partnerId = broadCastInfo?.partnerId
//        viewController.clipId = broadCastInfo?.clipId
//        viewController.curationId = broadCastInfo?.curationId
//        present(viewController, animated: true)
        
        
        // PIP 구현시
        let viewController = ClipPIPViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.partnerId = broadCastInfo?.partnerId
        viewController.clipId = broadCastInfo?.clipId
        viewController.curationId = broadCastInfo?.curationId
        PIPKit.show(with: viewController)
 
    }
    
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveErrorMessage sauceError: SauceError?) {
        print(sauceError?.errorCode)
    }
}


