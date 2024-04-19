import WebKit
public class SauceClipLib {
    public init() {}
    
    var partnerId: String?
    var clipId: String?
    var curationId: String?
    var target = ""
    var isProductViewShow = true
    
    public weak var viewController: SauceClipViewController?
    
    public func setInit(partnerID: String, clipID: String, curationID: String? =  nil) {
        self.partnerId = partnerID
        self.clipId = clipID
        self.curationId = curationID
    }
    
    public func setStageMode(on: Bool = false) {
        if on {
            target = "stage"
        }
    }
    
    public func setProductVC(on: Bool = true) {
        isProductViewShow = on
    }
    
    public func load() {
        guard let partnerId = partnerId, let clipId = clipId else {
            return
        }
        
        // Start constructing the base URL string without curationId.
        var urlString = "https://\(target).player.sauceclip.com/player?partnerId=\(partnerId)&clipId=\(clipId)"
        
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

public class SauceCurationLib: WKWebView {
    private var partnerId: String?
    private var curationId: String?
    private var target = ""
    
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
            self.configuration.userContentController.add(self, name: "sauceclipMoveBroadcast")
        }
        
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
        if on {
            target = "stage"
        } else {
            target = ""
        }
    }
    
    
    
    public func load() {
        if let partnerId = partnerId, let curationId = curationId {
            var htmlString = String()
            if target == "stage" {
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
            } else {
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
}

extension SauceCurationLib: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let jsonString = message.body as? String else {
            delegate?.sauceCurationManager?(self, didReceiveBroadCastMessage: nil)
            return
        }
        guard let jsonData = jsonString.data(using: .utf8) else {
            return
        }
        
        let decoder = JSONDecoder()
        
        if message.name == MessageHandlerName.moveBroadcast.rawValue {
            if let broadCastInfo = try? decoder.decode(SauceBroadcastInfo.self, from: jsonData) {
                delegate?.sauceCurationManager?(self, didReceiveBroadCastMessage: broadCastInfo)
            }
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
