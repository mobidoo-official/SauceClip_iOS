import UIKit
import WebKit
import SauceClip_iOS

class SauceCuraionViewController: UIViewController {
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
        sauceCurationView.setInit(partnerID: "8", curationID: "99")
        sauceCurationView.setStageMode(on: true)
        
        self.view.addSubview(sauceCurationView)
        sauceCurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sauceCurationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sauceCurationView.heightAnchor.constraint(equalToConstant: 300), // 높이를 350으로 설정
            sauceCurationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sauceCurationView.widthAnchor.constraint(equalToConstant: 300) // 너비를 300으로 설정
        ])
        
        sauceCurationView.load()
    }
}

extension SauceCuraionViewController: SauceCurationDelegate {
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo?) {
     
        let viewController = SampleClipVC()
        viewController.modalPresentationStyle = .fullScreen
        viewController.partnerId = broadCastInfo?.partnerId
        viewController.clipId = broadCastInfo?.clipId
        viewController.curationId = broadCastInfo?.curationId
        present(viewController, animated: true)
    }
}

