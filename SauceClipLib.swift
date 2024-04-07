//
//  SauceClipLib.swift
//  SauceClip_iOS
//
//  Created by 김원철 on 4/4/24.
//

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
