import UIKit

//class ExhibitionViewController: UIViewController {
//
//    var partnerID: String?
//    var curationID: String?
//    var isStageMode: Bool = true
//
import UIKit
import WebKit
import SauceClip_iOS

class ClipCurationViewController: UIViewController {
    var handlerStates: [MessageHandlerName: Bool] = [:]
    private var scrollView: UIScrollView!
    var partnerID: String?
    var curationID: String?
    var isStageMode: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "SauceCuration"
        
        // 헤더 영역 생성
        let headerView = UIView()
        headerView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        let titleLabel = UILabel()
        titleLabel.text = "컨텐츠 A"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        let headerStackView = UIStackView(arrangedSubviews: [titleLabel])
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
        sauceCurationView.setInit(partnerID: partnerID ?? "", curationID: curationID ?? "")
        sauceCurationView.setStageMode(on: isStageMode) // 스테이지 환경 사용 default: false
        sauceCurationView.setPvVisibility(true) //  전시 클립 영상 내 조회 수 노출 여부 default: true
        sauceCurationView.setHorizontalPadding(10) // 클립 좌우 여백  default: 0
        
        self.view.addSubview(sauceCurationView)
        sauceCurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sauceCurationView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        sauceCurationView.load()
        
        let additionalView = UIView()
        additionalView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        self.view.addSubview(additionalView)
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            additionalView.topAnchor.constraint(equalTo: sauceCurationView.bottomAnchor, constant: 20),
            additionalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            additionalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            additionalView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        let contentLabel = UILabel()
        contentLabel.text = "컨텐츠 B"
        contentLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        additionalView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: additionalView.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: additionalView.centerYAnchor)
        ])
    }
}

extension ClipCurationViewController: SauceCurationDelegate {
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo?) {

        let vc = ClipPlayerViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.partnerID = broadCastInfo?.partnerId
        vc.curationID = "\(broadCastInfo?.clipId)"
        vc.isStageMode = isStageMode
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func sauceCurationManager(_ manager: SauceCurationLib, didReceiveErrorMessage sauceError: SauceError?) {
        guard let error = sauceError else { return }
        let alertController = UIAlertController(title:"\(error.errorType)", message: "\(error.errorDetails)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}
