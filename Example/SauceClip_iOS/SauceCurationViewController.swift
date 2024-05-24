import UIKit
import WebKit
import SauceClip_iOS

class SauceCurationViewController: UIViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // UIScrollView 초기화 및 설정
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 상단 뷰 생성 및 설정
        let topView = UIView()
        topView.backgroundColor = .gray  // 색상은 예시입니다. 적절히 조정 가능
        topView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(topView)
        
        // SauceCurationView 초기화 및 설정
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
        
        scrollView.addSubview(sauceCurationView)
        sauceCurationView.translatesAutoresizingMaskIntoConstraints = false
        sauceCurationView.scrollView.isScrollEnabled = false
        // 하단 뷰 생성 및 설정
        let bottomView = UIView()
        bottomView.backgroundColor = .gray  // 색상은 예시입니다. 적절히 조정 가능
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(bottomView)
        
        // 제약조건 설정
        NSLayoutConstraint.activate([
            // 상단 뷰 제약조건
            topView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 100),
            
            // SauceCurationView 제약조건
            sauceCurationView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            sauceCurationView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            sauceCurationView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            sauceCurationView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 하단 뷰 제약조건
            bottomView.topAnchor.constraint(equalTo: sauceCurationView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            bottomView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
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
