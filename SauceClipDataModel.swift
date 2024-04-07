/// SauceClip 애플리케이션의 장바구니 정보를 나타내는 데이터 구조체입니다.
///
/// - Parameters:
///   - linkUrl: 제품에 접근할 수 있는 URL입니다.
///   - clipIdx: 제품과 연관된 클립의 고유 식별자입니다.
///   - productId: 제품의 고유 식별자입니다.
///   - price: 제품의 가격입니다. 이 값은 null일 수 있습니다.
///   - productImg: 제품 이미지의 URL입니다.
///   - productName: 제품의 이름입니다.
///   - externalProductId: 외부 시스템에서의 제품 고유 식별자입니다. 이 값은 null일 수 있습니다.
///

@objcMembers public class SauceCartInfo: NSObject, Codable {
    public let clipIdx: String
    public let productId: Int
    public let price: String
    public let productImg: String
    public let productName: String
    public let linkUrl: String?
    public let externalProductId: String?
}

/// SauceClip 애플리케이션의 제품 정보를 나타내는 데이터 구조체입니다.
///
/// - Parameters:
///   - linkUrl: 제품에 접근할 수 있는 URL입니다.
///   - clipIdx: 제품과 연관된 클립의 고유 식별자입니다.
///   - externalProductId: 외부 시스템에서의 제품 고유 식별자입니다. 이 값은 null일 수 있습니다.
///   - productId: 제품의 고유 식별자입니다.
@objcMembers public class SauceProductInfo: NSObject, Codable {
    public let linkUrl: String
    public let clipIdx: String
    public let externalProductId: String?
    public let productId: Int
}

/// SauceClip 애플리케이션의 공유 정보를 나타내는 데이터 구조체입니다.
///
/// - Parameters:
///   - linkUrl: 공유할 클립에 접근할 수 있는 URL입니다.
///   - clipId: 공유할 클립의 고유 식별자입니다.
///   - partnerId: 파트너의 고유 식별자입니다.
///   - thumbnailUrl: 썸네일 이미지의 URL입니다.
///   - title: 공유할 클립의 제목입니다.
///   - tags: 공유할 클립의 태그 목록입니다.
@objcMembers public class SauceShareInfo: NSObject, Codable {
    public let linkUrl: String
    public let clipId: String
    public let partnerId: String
    public let thumbnailUrl: String
    public let title: String
    public let tags: [String]
}

/// SauceClip 애플리케이션의 방송 정보를 나타내는 데이터 구조체입니다.
///
/// - Parameters:
///   - clipId: 클립의 고유 식별자입니다.
///   - curationId: 큐레이션의 고유 식별자입니다.
///   - partnerId: 파트너의 고유 식별자입니다.
///   - shortUrl: 짧은 URL입니다. 이 값은 null일 수 있습니다.

@objcMembers public class SauceBroadcastInfo: NSObject, Codable {
    public let clipId: Int
    public let curationId: Int
    public let partnerId: String
    public let shortUrl: String?
}
