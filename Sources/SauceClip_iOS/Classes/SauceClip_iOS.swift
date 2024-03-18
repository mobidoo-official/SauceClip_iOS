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
}

@objc public protocol SauceClipDelegate: AnyObject {
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveEnterMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveExitMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveLoginMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveOnShareMessage message: WKScriptMessage)
}

// SauceLiveManager 프로토콜 추가
protocol SauceClipManager: AnyObject {
    func configure(with config: SauceViewControllerConfig)
    func loadURL(_ urlString: String)
}

public struct SauceViewControllerConfig {
    public let url: String
    public let isEnterEnabled: Bool
    public let isExitEnabled: Bool
    public let isLoginEnabled: Bool
    public let isMoveProductEnabled: Bool
    public let isMoveCartEnabled: Bool
    public let isOnShareEnabled: Bool
    public weak var delegate: SauceClipDelegate? // Delegate 추가
    public init(url: String,
                isEnterEnabled: Bool? = false,
                isExitEnabled: Bool? = false,
                isLoginEnabled: Bool? = false,
                isMoveProductEnabled: Bool? = false,
                isMoveCartEnabled: Bool? = false,
                isOnShareEnabled: Bool? = false,
                delegate: SauceClipDelegate?) {
        
        self.url = url
        self.isEnterEnabled = isEnterEnabled ?? false
        self.isExitEnabled = isExitEnabled ?? false
        self.isLoginEnabled = isLoginEnabled ?? false
        self.isMoveProductEnabled = isMoveProductEnabled ?? false
        self.isMoveCartEnabled = isMoveCartEnabled ?? false
        self.isOnShareEnabled = isOnShareEnabled ?? false
        self.delegate = delegate
    }
}

open class SauceClipViewController: UIViewController, WKScriptMessageHandler, SauceClipManager {
  
    public var webView: WKWebView!
    private var contentController = WKUserContentController()
    public weak var delegate: SauceClipDelegate?
    public var messageHandlerNames: [MessageHandlerName] = []
    public var url: String?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 구성 객체를 사용하여 SauceLiveViewController 설정
    public func configure(with config: SauceViewControllerConfig) {
        configureWebView()
        setupWebViewLayout()
        self.url = config.url
        self.delegate = config.delegate
        // Additional configuration based on the provided config
        configureMessageHandlers(with: config)
        if let url = self.url {
            self.loadURL(url)
        }
    }
    
    public func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func configureMessageHandlers(with config: SauceViewControllerConfig) {
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
    
    public func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = true
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
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
        switch message.name {
        case MessageHandlerName.enter.rawValue:
            delegate?.sauceClipManager?(self, didReceiveEnterMessage: message)
        case MessageHandlerName.exit.rawValue:
            delegate?.sauceClipManager?(self, didReceiveExitMessage: message)
        case MessageHandlerName.login.rawValue:
            delegate?.sauceClipManager?(self, didReceiveLoginMessage: message)
        case MessageHandlerName.moveProduct.rawValue:
            delegate?.sauceClipManager?(self, didReceiveMoveProductMessage: message)
        case MessageHandlerName.moveCart.rawValue:
            delegate?.sauceClipManager?(self, didReceiveMoveCartMessage: message)
        case MessageHandlerName.onShare.rawValue:
            delegate?.sauceClipManager?(self, didReceiveOnShareMessage: message)
        default:
            break
        }
    }
}

// MARK: - WKNavigationDelegate
extension SauceClipViewController: WKNavigationDelegate {
    // Handle navigation delegate methods if needed
}

// MARK: - WKUIDelegate
extension SauceClipViewController: WKUIDelegate {
    // Handle UI delegate methods if needed
}
