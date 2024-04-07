//
//  SauceCurationView.swift
//  SauceClip_iOS
//
//  Created by 김원철 on 4/4/24.
//

import UIKit
import WebKit

class CustomWebView: WKWebView, WKScriptMessageHandler {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        var contentController = WKUserContentController()
        super.init(frame: frame, configuration: configuration)
        self.configuration.userContentController.add(self, name: "sauceclipMoveBroadcast")
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // WKScriptMessageHandler 프로토콜 구현
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "sauceclipMoveBroadcast", let messageBody = message.body as? String {
            // JavaScript에서 보낸 메시지를 처리합니다. 예: sauceclipMoveBroadcast 기능 구현
            print("Received message from JavaScript: \(messageBody)")
            // 여기에 sauceclipMoveBroadcast 관련 동작 구현
        }
    }
    
    public func configureWebView() {
        
    }
    
    
    // 초기 설정을 위한 함수
    func setInit(partnerID: String, curaionID: String) {
    }
    
    // 컨텐츠나 설정에 대한 커스터마이징을 위한 함수
    func setCuration() {
        // 커스터마이징 로직을 구현, 예를 들어 특정 도메인의 컨텐츠만 로드하도록 필터링
    }
    
    // HTML 컨텐츠를 로드하기 위한 함수
    func load(html: String) {
        let htmlString = ""
        self.loadHTMLString(html, baseURL: nil) // HTML 문자열 로드, 필요에 따라 baseURL 설정
    }
}
