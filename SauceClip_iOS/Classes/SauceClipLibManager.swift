import Foundation
import UIKit
import WebKit

public enum MessageHandlerName: String {
    case enter = "sauceclipEnter"
    case exit = "sauceclipMoveExit"
    case login = "sauceclipMoveLogin"
    case moveProduct = "sauceclipMoveProduct"
    case moveCart = "sauceclipMoveCart"
    case onShare = "sauceclipOnShare"
    case moveBroadcast = "sauceclipMoveBroadcast"
    case onError = "sauceclipPlayerError"
    case sendDOMRect = "sauceclipSendDOMRect"
    case onCollectionError = "sauceclipCollectionError"
}

@objc public protocol SauceClipDelegate: AnyObject {
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveEnterMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveExitMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveLoginMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage productInfo: SauceProductInfo?)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage cartInfo: SauceCartInfo?)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveOnShareMessage shareInfo: SauceShareInfo?)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveErrorMessage sauceError: SauceError?)
}

protocol SauceClipManager: AnyObject {
    func configure(with config: SauceClipConfig)
    func loadURL(_ urlString: String)
}

public struct SauceClipConfig {
    public let isEnterEnabled: Bool
    public let isExitEnabled: Bool
    public let isLoginEnabled: Bool
    public let isMoveProductEnabled: Bool
    public let isMoveCartEnabled: Bool
    public let isOnShareEnabled: Bool
    public let pipSize: CGSize?
    public weak var delegate: SauceClipDelegate? // Delegate 추가
    public init(isEnterEnabled: Bool? = false,
                isExitEnabled: Bool? = false,
                isLoginEnabled: Bool? = false,
                isMoveProductEnabled: Bool? = false,
                isMoveCartEnabled: Bool? = false,
                isOnShareEnabled: Bool? = false,
                pipSize: CGSize? = nil,
                delegate: SauceClipDelegate?) {
        self.isEnterEnabled = isEnterEnabled ?? false
        self.isExitEnabled = isExitEnabled ?? false
        self.isLoginEnabled = isLoginEnabled ?? false
        self.isMoveProductEnabled = isMoveProductEnabled ?? false
        self.isMoveCartEnabled = isMoveCartEnabled ?? false
        self.isOnShareEnabled = isOnShareEnabled ?? false
        self.pipSize = pipSize
        self.delegate = delegate
    }
}

open class SauceClipViewController: UIViewController, WKScriptMessageHandler, SauceClipManager {
    
    public var webView: WKWebView!
    private var contentController = WKUserContentController()
    public weak var delegate: SauceClipDelegate?
    public var messageHandlerNames: [MessageHandlerName] = []
    public var url: String?
    public var isProductViewShow: Bool?
    
    private var leftButton: UIButton!
    private var rightButton: UIButton!
    
    public var pipSize: CGSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func configure(with config: SauceClipConfig) {
        configureWebView()
        setupWebViewLayout()
        setupButtons()
        self.delegate = config.delegate
        if let size = config.pipSize {
            pipSize = size
        }
        configureMessageHandlers(with: config)
    }
    
    public func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func openURLInNewWebView(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            //  print("Invalid URL")
            return
        }
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = contentController
        configuration.allowsPictureInPictureMediaPlayback = true
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        
        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        newWebView.navigationDelegate = self
        self.view.addSubview(newWebView)
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            newWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            newWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            newWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let request = URLRequest(url: url)
        newWebView.load(request)
    }
    
    private func setupButtons() {
        leftButton = UIButton(type: .custom)
        rightButton = UIButton(type: .custom)
        
        guard let bundleURL = Bundle(for: SauceClipViewController.self).url(forResource: "assets", withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            return
        }
        
        let closeImage = UIImage(named: "CloseButton", in: bundle, compatibleWith: nil)
        let pipImage = UIImage(named: "PIPButton", in: bundle, compatibleWith: nil)
        
        leftButton.setImage(closeImage, for: .normal)
        rightButton.setImage(pipImage, for: .normal)
        
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            rightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            rightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    @objc open func leftButtonTapped() {
        PIPKit.dismiss(animated: true)
    }
    
    @objc open func rightButtonTapped() {
        let name = "dispatchEvent(sauceclipPIP(false))"
        webView.evaluateJavaScript(name) { (Result, Error) in
            if let error = Error {
                print("evaluateJavaScript Error : \(error)")
            } else {
                self.stopPictureInPicture()
            }
        }
    }
    
    private func configureMessageHandlers(with config: SauceClipConfig) {
        var handlers = [MessageHandlerName]()
        if config.isEnterEnabled { handlers.append(.enter) }
        if config.isExitEnabled { handlers.append(.exit) }
        if config.isLoginEnabled { handlers.append(.login) }
        if config.isMoveCartEnabled { handlers.append(.moveCart) }
        if config.isMoveProductEnabled { handlers.append(.moveProduct) }
        if config.isOnShareEnabled { handlers.append(.onShare) }
        self.messageHandlerNames = handlers
        registerMessageHandlers()
    }
    
    private func registerMessageHandlers() {
        contentController.removeAllUserScripts()
        messageHandlerNames.forEach { name in
            contentController.add(self, name: name.rawValue)
        }
    }
    
    public func startPictureInPicture() {
        rightButton.isHidden = false
        leftButton.isHidden = false
        webView.isUserInteractionEnabled = false
        webView.evaluateJavaScript("dispatchEvent(sauceclipPIP(true))") { (result, error) in
            if let error = error {
                print("JavaScript 실행 오류: \(error.localizedDescription)")
            } else {
                print("JavaScript 실행 완료")
            }
        }
        PIPKit.startPIPMode()
        
    }
    
    public func stopPictureInPicture() {
        rightButton.isHidden = true
        leftButton.isHidden = true
        webView.isUserInteractionEnabled = true
        PIPKit.stopPIPMode()
    }
    
    public func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = true
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        contentController.add(self, name: "sauceclipPlayerError")
        
        configuration.userContentController = contentController
        configuration.allowsPictureInPictureMediaPlayback = true
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
    }
    
    private func setupWebViewLayout() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let decoder = JSONDecoder()
        switch message.name {
        case MessageHandlerName.enter.rawValue:
            delegate?.sauceClipManager?(self, didReceiveEnterMessage: message)
        case MessageHandlerName.exit.rawValue:
            delegate?.sauceClipManager?(self, didReceiveExitMessage: message)
        case MessageHandlerName.login.rawValue:
            delegate?.sauceClipManager?(self, didReceiveLoginMessage: message)
        case MessageHandlerName.moveProduct.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let productInfo = try? decoder.decode(SauceProductInfo.self, from: jsonData) {
                openURLInNewWebView(productInfo.linkUrl)
                delegate?.sauceClipManager?(self, didReceiveMoveProductMessage: productInfo)
            } else {
                delegate?.sauceClipManager?(self, didReceiveMoveProductMessage: nil)
            }
            
        case MessageHandlerName.moveCart.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let cartInfo = try? decoder.decode(SauceCartInfo.self, from: jsonData) {
                delegate?.sauceClipManager?(self, didReceiveMoveCartMessage: cartInfo)
            } else {
                delegate?.sauceClipManager?(self, didReceiveMoveCartMessage: nil)
            }
            
        case MessageHandlerName.onShare.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let shareInfo = try? decoder.decode(SauceShareInfo.self, from: jsonData) {
                delegate?.sauceClipManager?(self, didReceiveOnShareMessage: shareInfo)
            } else {
                delegate?.sauceClipManager?(self, didReceiveOnShareMessage: nil)
            }
            
        case MessageHandlerName.onError.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let sauceError = try? decoder.decode(SauceError.self, from: jsonData) {
                delegate?.sauceClipManager?(self, didReceiveErrorMessage: sauceError)
            } else {
                delegate?.sauceClipManager?(self, didReceiveErrorMessage: nil)
            }
            
        default:
            break
        }
    }
}

public class SauceClipLib {
    public init() {}
    
    var partnerId: String?
    var clipId: String?
    var curationId: String?
    var target = false
    var isProductViewShow = true
    
    public weak var viewController: SauceClipViewController?
    
    public func setInit(partnerID: String, clipID: String, curationID: String? =  nil) {
        self.partnerId = partnerID
        self.clipId = clipID
        self.curationId = curationID
    }
    
    public func setStageMode(on: Bool = false) {
        target = on
    }
    
    public func setProductVC(on: Bool = true) {
        isProductViewShow = on
    }
    
    public func load() {
        guard let partnerId = partnerId, let clipId = clipId else {
            return
        }
        
        // Start constructing the base URL string without curationId.
        var urlString = String()
        if target {
            urlString = "https://stage.player.sauceclip.com/player?partnerId=\(partnerId)&clipId=\(clipId)"
        } else {
            urlString = "https://player.sauceclip.com/player?partnerId=\(partnerId)&clipId=\(clipId)"
        }
        
        
        // Add curationId to the URL string only if it's not nil.
        if let curationid = curationId {
            urlString += "&curationId=\(curationid)"
        }
        
        DispatchQueue.main.async {
            self.viewController?.isProductViewShow = self.isProductViewShow
            self.viewController?.loadURL(urlString)
        }
    }
}

extension SauceClipViewController: PIPUsable {
    public var initialState: PIPState { return .full }
}

// MARK: - WKNavigationDelegate
extension SauceClipViewController: WKNavigationDelegate {
    // Handle navigation delegate methods if needed
}

// MARK: - WKUIDelegate
extension SauceClipViewController: WKUIDelegate {
    // Handle UI delegate methods if needed
}
