import UIKit
import WebKit
import SauceClip_iOS

class SauceCurationViewController: UIViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 헤더 영역 생성
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        let titleLabel = UILabel()
        titleLabel.text = "Sauce Curation"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let headerStackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalCentering
        headerStackView.alignment = .center
        headerStackView.spacing = 10
        
        headerView.addSubview(headerStackView)
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            headerStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
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
            sauceCurationView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            sauceCurationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sauceCurationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        sauceCurationView.load()
        
        // 새로운 뷰 추가
        let additionalView = UIView()
        additionalView.backgroundColor = .lightGray
        self.view.addSubview(additionalView)
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            additionalView.topAnchor.constraint(equalTo: sauceCurationView.bottomAnchor, constant: 20),
            additionalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            additionalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            additionalView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // "컨텐츠" 라벨 추가
        let contentLabel = UILabel()
        contentLabel.text = "컨텐츠"
        contentLabel.textAlignment = .center
        additionalView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: additionalView.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: additionalView.centerYAnchor)
        ])
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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
