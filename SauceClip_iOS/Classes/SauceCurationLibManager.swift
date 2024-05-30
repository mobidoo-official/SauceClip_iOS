import WebKit

public struct APIEnvironment {
    public enum Environment: String {
        case development = "Development"
        case staging = "Staging"
        case production = "Production"
    }
    // 개발 환경 관리
    public static var buildEnvironment: Environment = .development

    // 현재 환경에 맞는 API 호스트 URL을 반환하는 정적 프로퍼티
    public static var current: String {
        switch buildEnvironment {
        case .development:
            return "https://dev.showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"
        case .staging:
            return "https://stage.showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"
        case .production:
            return "https://showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"
        }
    }
}

public class SauceCurationLib: WKWebView {
    private var partnerId: String?
    private var curationId: String?
    private var target: APIEnvironment.Environment = .staging
    
    private var paddingOption = ""
    private var pvOption = ""
    private var previewAutoPlayOption = ""
    
    public var messageHandlerNames: [MessageHandlerName] = []
    
    public weak var delegate: SauceCurationDelegate?
    
    var contentController = WKUserContentController()
    required init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        super.init(frame: .zero, configuration: configuration)
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true  // Inline media playback allows.
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []  // No user interaction required for playback.
        }
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        
        super.init(frame: frame, configuration: configuration)
        self.configureWebView()
    }
    
    private func configureWebView() {
        self.navigationDelegate = self
        self.uiDelegate = self
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    public struct SauceCurationConfig {
        public let isBroadCastEnabled: Bool
        
        public weak var delegate: SauceCurationDelegate? // Delegate 추가
        public init(isBroadCastEnabled: Bool? = false,
                    delegate: SauceCurationDelegate?) {
            self.isBroadCastEnabled = isBroadCastEnabled ?? false
            self.delegate = delegate
        }
    }
    
    public func configure(with config: SauceCurationConfig) {
        self.delegate = config.delegate
        if config.isBroadCastEnabled {
            self.configuration.userContentController.add(self, name: MessageHandlerName.moveBroadcast.rawValue)
        }
        self.configuration.userContentController.add(self, name: MessageHandlerName.onCollectionError.rawValue)
        self.configuration.userContentController.add(self, name: MessageHandlerName.sendDOMRect.rawValue)
    }
    
    public func setInit(partnerID: String, curationID: String) {
        self.partnerId = partnerID
        self.curationId = curationID
    }
    
    public func setPvVisibility(_ hidden: Bool) {
        if !hidden {
            pvOption = "window.SauceClipCollectionLib.setCurationClipPvStyle('{\"display\": \"none\"}')"
        }
    }
    
    public func setHorizontalPadding(_ size: Int) {
        paddingOption = """
window.SauceClipCollectionLib.setCurationHorizontalContentsStyle('{"padding-left": "\(size)px", "padding-right": "\(size)px"}')
"""
    }
    
    public func setPreviewAutoPlay(_ on: Bool) {
        if on {
            previewAutoPlayOption = "window.SauceClipCollectionLib.setCurationClipPreviewAutoplay(true)"
        } else {
            previewAutoPlayOption = "window.SauceClipCollectionLib.setCurationClipPreviewAutoplay(false)"
        }
    }
    
    public func setStageMode(on: Bool) {
        target = APIEnvironment.buildEnvironment
    }
    
    private func updateWebViewHeight(height: CGFloat) {
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
        
        //           // Optionally, if you want to adjust the content size of the UIScrollView directly:
        //           self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: height)
    }
    
    public func load() {
        if let partnerId = partnerId, let curationId = curationId {
            var htmlString = String()
            switch target {
            case .development:
                htmlString = """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                  <script src="https://dev.showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"></script>
                </head>
                <body>
                  <div id="sauce_clip_curation"></div>
                  <script>
                    window.addEventListener('load', () => {
                      const partnerId = '\(partnerId)'
                      window.SauceClipCollectionLib.setInit({ partnerId })
                      \(pvOption)
                      \(paddingOption)
                      \(previewAutoPlayOption)
                      window.SauceClipCollectionLib.loadCuration({ curationId: '\(curationId)', elementId: 'sauce_clip_curation' })
                    })
                  </script>
                </body>
                <style>
                  html, body {
                    padding: 0;
                    margin: 0;
                    height: fit-content;
                    overflow-x: hidden;
                  }
                </style>
                </html>
                """
            case .staging:
                htmlString = """
                        <!DOCTYPE html>
                        <html lang="en">
                        <head>
                          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                          <script src="https://stage.showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"></script>
                        </head>
                        <body>
                          <div id="sauce_clip_curation"></div>
                          <script>
                            window.addEventListener('load', () => {
                              const partnerId = '\(partnerId)'
                              window.SauceClipCollectionLib.setInit({ partnerId })
                             \(pvOption)
                             \(paddingOption)
                             \(previewAutoPlayOption)
                              window.SauceClipCollectionLib.loadCuration({ curationId: '\(curationId)', elementId: 'sauce_clip_curation' })
                            })
                          </script>
                        </body>
                        <style>
                          html, body {
                            padding: 0;
                            margin: 0;
                            height: fit-content;
                            overflow-x: hidden;
                          }
                        </style>
                        </html>
                        """
            case .production:
                htmlString = """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                  <script src="https://showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"></script>
                </head>
                <body>
                  <div id="sauce_clip_curation"></div>
                  <script>
                    window.addEventListener('load', () => {
                      const partnerId = '\(partnerId)'
                      window.SauceClipCollectionLib.setInit({ partnerId })
                      \(pvOption)
                      \(paddingOption)
                      \(previewAutoPlayOption)
                      window.SauceClipCollectionLib.loadCuration({ curationId: '\(curationId)', elementId: 'sauce_clip_curation' })
                    })
                  </script>
                </body>
                <style>
                  html, body {
                    padding: 0;
                    margin: 0;
                    height: fit-content;
                    overflow-x: hidden;
                  }
                </style>
                </html>
                """
            }
            
            self.loadHTMLString(htmlString, baseURL: nil)
            
        } else {
            //print("clipId, partnerId is required")
        }
    }
}
@objc public protocol SauceCurationDelegate: AnyObject {
    @objc optional func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo?)
    @objc optional func sauceCurationManager(_ manager: SauceCurationLib, didReceiveErrorMessage sauceError: SauceError?)
}

extension SauceCurationLib: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let decoder = JSONDecoder()
        switch message.name {
        case MessageHandlerName.moveBroadcast.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let broadCastInfo = try? decoder.decode(SauceBroadcastInfo.self, from: jsonData) {
                delegate?.sauceCurationManager?(self, didReceiveBroadCastMessage: broadCastInfo)
            } else {
                delegate?.sauceCurationManager?(self, didReceiveBroadCastMessage: nil)
            }
            
        case MessageHandlerName.onCollectionError.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let sauceError = try? decoder.decode(SauceError.self, from: jsonData) {
                delegate?.sauceCurationManager?(self, didReceiveErrorMessage: sauceError)
            } else {
                delegate?.sauceCurationManager?(self, didReceiveErrorMessage: nil)
            }
            
        case MessageHandlerName.sendDOMRect.rawValue:
            if let jsonString = message.body as? String, !jsonString.isEmpty,
               let jsonData = jsonString.data(using: .utf8),
               let size = try? decoder.decode(DomSize.self, from: jsonData) {
                self.translatesAutoresizingMaskIntoConstraints = false
                
                if let existingHeightConstraint = self.constraints.first(where: { $0.firstAttribute == .height }) {
                    existingHeightConstraint.constant = CGFloat(size.domRect.height)
                } else {
                    let heightConstraint = self.heightAnchor.constraint(equalToConstant: CGFloat(size.domRect.height))
                    heightConstraint.isActive = true
                }
                
                NSLayoutConstraint.activate([
                    self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor)
                ])
            }
            
        default:
            break
        }
    }
}

// MARK: - WKNavigationDelegate
extension SauceCurationLib: WKNavigationDelegate {
    // Handle navigation delegate methods if needed
}

// MARK: - SauceCurationLib
extension SauceCurationLib: WKUIDelegate {
    // Handle UI delegate methods if needed
}
