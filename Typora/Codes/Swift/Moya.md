```swift
import Alamofire
import Moya

class ApiProtocol: PluginType {

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {

        guard case let Result.success(response) = result else {return}

        if let dict = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any] {
            if let code = dict["resultCode"] as? String {
                if code == "303" {
                     // Application.shared.clearUserInfo()
                }
            }
        }
    }

}
```

```swift
import UIKit
import ObjectMapper

class ApiResponse<T: Mappable>: Mappable {

    /// 在 `data` 里面是非数组的
    var item: T?
    /// 在 `data` 里面是数组的
    var items: [T]?
    /// message
    var message: String?
    /// 状态码 PS:服务器返回的是字符串型,在转换的时候映射为 Int 型
    var code: Int?

    var memberStatus: Bool?

    required init?(map: Map) {}
    func mapping(map: Map) {
        memberStatus <- map["memberStatus"]
        item    <- map["datas"]
        items   <- map["datas"]
        message <- map["message"]
        code    <- (map["resultCode"], TransformOf<Int, String>(fromJSON: { $0?.int },
                                                      toJSON: { $0.map { $0.string } }))
    }
}

class ApiResponseEmpty: Mappable {

    var message: String?
    var code: Int?
    var memberStatus: Bool?

    required init?(map: Map) {}

    func mapping(map: Map) {
        memberStatus <- map["memberStatus"]
        message <- map["message"]
        code    <- (map["resultCode"], TransformOf<Int, String>(fromJSON: { $0?.int },
                                                         toJSON: { $0?.string  }))
    }
}

/// 获取基础类型 String Int 等
class ApiResponseBaseObject<T>: Mappable {

    var item: T?
    var items: [T]?
    var message: String?
    var code: Int?
    var memberStatus: Bool?

    required init?(map: Map) {}

    func mapping(map: Map) {
        memberStatus <- map["memberStatus"]
        item    <- map["datas"]
        items   <- map["datas"]
        message <- map["message"]
        code    <- (map["resultCode"], TransformOf<Int, String>(fromJSON: { $0?.int },
                                                         toJSON: { $0?.string  }))
    }
}
```

```swift
import UIKit
import Moya
import CommonCrypto
import DeviceKit

let ApiProvider = MoyaProvider<Api>(plugins: [ApiProtocol()])

let enKey = "62ZwTMeafGB143ed2d3Ro+vfwQwk/TZjHK6988"

enum Api {
    
    // 苹果登陆
    case appleLogin(String, String, String, String)
    case start(String?)
    // 关心的人列表
    case careList
    
}

extension Api: TargetType {
    
    var baseURL: URL {
        #if DEBUG
        return URL(string: "<https://api.miaosud.com>")!
        //return URL(string: "<http://192.168.0.55:19012>")!
        #else
        return URL(string: "<https://api.miaosud.com>")!
        #endif
    }
    
    var path: String {
        switch self {
        
        // 关心的人 liebi
        case .careList:
            return "account/friends/info/list"
        case .login(_,_):
            return "account/user/authc/login"
        case .messages:
            return "friend/otherApplys"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .careList, .messages : return.get
        default: return .post
        }
    }
    
    var sampleData: Data {
        return "sampleData.".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        
        let userId: Int = Application.shared.userInfo?.userId ?? 0
        let uuid: String = Application.shared.userInfo?.udid ?? ""
        
        switch self {
        case .careList:
            return .requestParameters(
                parameters: [
                    "phone": Application.shared.userInfo?.phone ?? "",
                    "udid": uuid,
                    "userId": userId
                ],
                encoding: URLEncoding.default)
        case .login(let tel , let code):
            return .requestParameters(
                parameters: [
                    "phone": tel,
                    "udid": uuid,
                    "code": code,
                    "type": 1
                ],
                encoding: URLEncoding.default)
        case .messages:
            return .requestParameters(
                parameters: [
                    "phone": Application.shared.userInfo?.phone ?? "",
                    "udid": uuid,
                    "userId": userId
                ],
                encoding: URLEncoding.default)
        case .appleLogin(let token, let authCode, let userId, let nickName):
            return .requestParameters(
                parameters: [
                    "userId": userId,
                    "authCode": authCode,
                    "identityToken": token,
                    "nickName": nickName,
                    "udid": uuid
                ],
                encoding: URLEncoding.default)
            
        
        }
        
    }
    
    /// 请求头
    var headers: [String: String]? {
        
        var UmengToken: String = ""
        if let pushToken = UserDefaults.standard.object(forKey: "umpId") as? String {
            UmengToken = pushToken
        }
        let timestamp: TimeInterval = NSDate().timeIntervalSince1970
        let udid = Application.shared.userInfo?.udid ?? ""
        
        let deviceInfo = ["udid": udid,
                          "createTime": "",
                          "lastTime": "",
                          "firstIp": IP ?? "",
                          "lastIp": IP ?? "",
                          "parter": "app_store",
                          "channel": "Apple Store",
                          "sysOs": "iOS",
                          "productName": "Locate",
                          "networktype": Application.shared.userInfo?.netStatus,
                          "sysVersion": UIDevice.current.systemVersion,
                          "deviceBrand": "Apple",
                          "idfa": Application.shared.userInfo?.idfa ?? "", /// 暂时无用此字段,传空
                          "deviceModel": Device.current.safeDescription,
                          "idfv": "",
                          "umengPid": UmengToken,
                          "productVersion": Application.shared.productVersion
        ]
        
        let data = try? JSONSerialization.data(withJSONObject: deviceInfo, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        
        return ["u_udid": Application.shared.userInfo?.udid ?? "",
                "u_sign": "udid=\\(Application.shared.userInfo?.udid ?? "")&timestamp=\\(timestamp)&\\(enKey)".md5.lowercased(),
                "u_userId": Application.shared.userInfo?.userId?.string ?? "0",
                "u_device": str ?? "",
                "u_timestamp": "\\(timestamp)",
                "u_token": "",
                "u_efrom": "Locate",
                "language": Application.shared.language.value,
                "u_phone": Application.shared.userInfo?.phone ?? ""]
    }
}

/// 获取当前设备的 ip 地址
private var IP: String? {
    var addresses = [String]()
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            let flags = Int32(ptr!.pointee.ifa_flags)
            var addr = ptr!.pointee.ifa_addr.pointee
            if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        if let address = String(validatingUTF8: hostname) {
                            addresses.append(address)
                        }
                    }
                }
            }
            ptr = ptr!.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    return addresses.first
}

extension String {
    var md5: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format: "%02X", $1) }
    }
    var utf8: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? self
    }
}
```