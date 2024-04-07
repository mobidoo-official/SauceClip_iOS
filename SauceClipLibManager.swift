import WebKit
public class SauceClipLib {
    public init() {}
    
    var partnerId: String?
    var clipId: String?
    var target = ""
    
    public weak var viewController: SauceClipViewController?
    
    public func setInit(partnerID: String, clipID: String) {
        self.partnerId = partnerID
        self.clipId = clipID
    }
    
    public func setStageMode(on: Bool = false) {
        if on {
            target = "stage"
        }
    }
    
    public func load() {
        if let partnerId = partnerId, let clipId = clipId {
            let urlString = "https://\(target).player.sauceclip.com/player?partnerId=\(partnerId)&clipId=\(clipId)"
            DispatchQueue.main.async {
                print(urlString)
                self.viewController?.loadURL(urlString)
            }
        } else {
            print("clipId, partnerId is required")
        }
    }
}

public class SauceCurationLib: WKWebView {
    required init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        super.init(frame: .zero, configuration: configuration)
        configureWebView()
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        configureWebView()
    }
    
    var partnerId: String?
    var curationId: String?
    var target = ""
    
    public var messageHandlerNames: [MessageHandlerName] = []
    
    public weak var delegate: SauceCurationDelegate?
    
    var contentController = WKUserContentController()
    
    private func configureWebView() {
        self.configuration.websiteDataStore = WKWebsiteDataStore.default()
        self.configuration.allowsInlineMediaPlayback = true
        
        if #available(iOS 10.0, *) {
            self.configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        self.configuration.allowsPictureInPictureMediaPlayback = true
        if #available(iOS 14.0, *) {
            self.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            self.configuration.preferences.javaScriptEnabled = true
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
    
    public func setStageMode(on: Bool = false) {
        if on {
            target = "stage"
        }
    }
    
    public func load() {
        if let partnerId = partnerId, let curationId = curationId {
            var htmlString = String()
            if target == "stage" {
                htmlString = """
                        <!DOCTYPE html>
                        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                        <html lang="en">
                        <head>
                          <script src="https://stage.showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"></script>
                        </head>
                        <body>
                          <div id="sauce_clip_curation"></div>
                          <script>
                            window.addEventListener('load', () => {
                              const partnerId = '8'
                              window.SauceClipCollectionLib.setInit({ partnerId })
                              window.SauceClipCollectionLib.loadCuration({ curationId: '99', elementId: 'sauce_clip_curation' })
                            })
                          </script>
                        </body>
                        <style>
                          html, body {
                            padding: 0;
                            margin: 0;
                            overflow: hidden;
                          }
                        </style>
                        </html>
                        """
            } else {
                htmlString = """
                <!DOCTYPE html>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                <html lang="en">
                <head>
                  <script src="https://showcase.sauceclip.com/static/js/SauceClipCollectionLib.js"></script>
                </head>
                <body>
                  <div id="sauce_clip_curation"></div>
                  <script>
                    window.addEventListener('load', () => {
                      const partnerId = '\(partnerId)'
                      window.SauceClipCollectionLib.setInit({ partnerId })
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
            print("clipId, partnerId is required")
        }
    }
}
@objc public protocol SauceCurationDelegate: AnyObject {
    @objc optional func sauceCurationManager(_ manager: SauceCurationLib, didReceiveBroadCastMessage broadCastInfo: SauceBroadcastInfo)
}

extension SauceCurationLib: WKScriptMessageHandler {
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
        
        if message.name == MessageHandlerName.moveBroadcast.rawValue {
            if let broadCastInfo = try? decoder.decode(SauceBroadcastInfo.self, from: jsonData) {
                delegate?.sauceCurationManager?(self, didReceiveBroadCastMessage: broadCastInfo)
            }
        }
    }
}
