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
}

@objc public protocol SauceClipDelegate: AnyObject {
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveEnterMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveExitMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveLoginMessage message: WKScriptMessage)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveProductMessage productInfo: SauceProductInfo)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveMoveCartMessage cartInfo: SauceCartInfo)
    @objc optional func sauceClipManager(_ manager: SauceClipViewController, didReceiveOnShareMessage shareInfo: SauceShareInfo)
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
    public weak var delegate: SauceClipDelegate? // Delegate 추가
    public init(isEnterEnabled: Bool? = false,
                isExitEnabled: Bool? = false,
                isLoginEnabled: Bool? = false,
                isMoveProductEnabled: Bool? = false,
                isMoveCartEnabled: Bool? = false,
                isOnShareEnabled: Bool? = false,
                delegate: SauceClipDelegate?) {
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
    public var isProductViewShow: Bool?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func configure(with config: SauceClipConfig) {
        configureWebView()
        setupWebViewLayout()
        self.delegate = config.delegate
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
            print("Invalid URL")
            return
        }
        
        let configuration = WKWebViewConfiguration()
        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        newWebView.navigationDelegate = self // 현재 ViewController가 navigationDelegate가 되도록 설정합니다.
        
        self.view.addSubview(newWebView)
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newWebView.topAnchor.constraint(equalTo: self.view.topAnchor),
            newWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            newWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            newWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let request = URLRequest(url: url)
        newWebView.load(request)
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
        guard let jsonString = message.body as? String else {
            print("message.body is not a String")
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert jsonString to Data")
            return
        }
        
        let decoder = JSONDecoder()
        
        switch message.name {
        case MessageHandlerName.enter.rawValue:
            delegate?.sauceClipManager?(self, didReceiveEnterMessage: message)
        case MessageHandlerName.exit.rawValue:
            delegate?.sauceClipManager?(self, didReceiveExitMessage: message)
        case MessageHandlerName.login.rawValue:
            delegate?.sauceClipManager?(self, didReceiveLoginMessage: message)
        case MessageHandlerName.moveProduct.rawValue:
            if let productInfo = try? decoder.decode(SauceProductInfo.self, from: jsonData) {
                if self.isProductViewShow ?? true {
                    openURLInNewWebView(productInfo.linkUrl)
                    delegate?.sauceClipManager?(self, didReceiveMoveProductMessage: productInfo)
                }
            }
        case MessageHandlerName.moveCart.rawValue:
            if let cartInfo = try? decoder.decode(SauceCartInfo.self, from: jsonData) {
                delegate?.sauceClipManager?(self, didReceiveMoveCartMessage: cartInfo)
            }
        case MessageHandlerName.onShare.rawValue:
            if let shareInfo = try? decoder.decode(SauceShareInfo.self, from: jsonData) {
                delegate?.sauceClipManager?(self, didReceiveOnShareMessage: shareInfo)
            }
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
