import UIKit
import WebKit
import SauceClip_iOS

class SauceCurationViewController: UIViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let sauceCurationView = SauceCurationLib()
        sauceCurationView.delegate = self
        
        let config = SauceCurationLib.SauceCurationConfig(
            isBroadCastEnabled: true,
            delegate: self
        )
        sauceCurationView.configure(with: config)
        sauceCurationView.setInit(partnerID: Config.partnerID, curationID: Config.curationID)
        sauceCurationView.setStageMode(on: true) // 스테이지 환경 사용 default: false
        sauceCurationView.setPvVisibility(true) //  전시 클립 영상 내 조회 수 노출 여부 default: true
        sauceCurationView.setHorizontalPadding(10) // 클립 좌우 여백  default: 0
        self.view.addSubview(sauceCurationView)
        sauceCurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sauceCurationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        sauceCurationView.load()
    }
}

extension SauceCurationViewController: SauceCurationDelegate {
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo?) {
        // PIP 를 지원할 경우
        let pipViewController = ClipPIPViewController()
        pipViewController.modalPresentationStyle = .fullScreen
        pipViewController.partnerId = broadCastInfo?.partnerId
        pipViewController.clipId = broadCastInfo?.clipId
        pipViewController.curationId = broadCastInfo?.curationId
        PIPKit.show(with: pipViewController)
        
        // PIP 를 지원 안할 경우
        /*
         let viewController = ClipViewController()
         viewController.modalPresentationStyle = .fullScreen
         viewController.partnerId = broadCastInfo?.partnerId
         viewController.clipId = broadCastInfo?.clipId
         viewController.curationId = broadCastInfo?.curationId
         self.present(viewController, animated: true)
         */
    }
    
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveErrorMessage sauceError: SauceError?) {
        guard let error = sauceError else { return }
        let alertController = UIAlertController(title:"\(error.errorType)", message: "\(error.errorDetails)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
