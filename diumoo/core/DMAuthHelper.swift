//
//  DMAuthHelper.swift
//  diumoo
//
//  Created by Yancheng Zheng on 6/25/16.
//
//

import Foundation
import AppKit

@objcMembers public class DMAuthHelper: NSObject {
    public static let kAuthAttributeUsername = "alias"
    public static let kAuthAttributePassword = "form_password"
    public static let kAuthAttributeCaptchaSolution = "captcha_solution"
    public static let kAuthAttributeCaptchaCode = "captcha_id"

    internal static let DOUBAN_FM_INDEX = "https://douban.fm/"
    internal static let AUTH_URL_STRING = "https://douban.fm/j/login"
    internal static let DOUBAN_CHECK_LOGIN = "https://douban.fm/j/check_loggedin?san=1"
    internal static let DOUBAN_USER_INFO = "https://douban.fm/j/v2/user_info?avatar_size=large"
    internal static let PROMOTION_CHLS_URL = "https://douban.fm/j/explore/promotion_chls"
    internal static let RECENT_CHLS_URL = "https://douban.fm/j/explore/recent_chls"
    internal static let DOUBAN_CAPTCHA_STR = "https://douban.fm/j/new_captcha"
    internal static let DOUBAN_PEOPLE_PREFIX = "https://www.douban.com/people/"

    public static let AccountStateChangedNotification = Notification.Name.init("accountstatechanged")

    private(set) public var username: String? = nil
    private(set) public var userUrl: String? = nil
    private(set) public var userIcon = NSImage.init(named: NSImage.userName)
    private(set) public var isPro: Bool = false
    private(set) public var promotion_chls: Array<Dictionary<String, AnyObject>> = []
    private(set) public var recent_chls: Array<Dictionary<String, AnyObject>> = []
    private(set) public var userInfo: Dictionary<String, AnyObject> = [:]

    // Singleton
    @objc public static let sharedHelper = DMAuthHelper()

    // Disallow init directly
    private override init() {
    }

    public static func getNewCaptchaCode() -> String {
        let url = URL.init(string: DMAuthHelper.DOUBAN_CAPTCHA_STR)
        do {
            let code = try String.init(contentsOf: url!, encoding: String.Encoding.ascii)
            return code.replacingOccurrences(of: "\"", with: "")
        } catch {
            return ""
        }
    }

    @objc public func authWithDictionary(_ aDict: Dictionary<String, String>?) -> NSError? {
        var authRequest: URLRequest? = nil

        if let authDict = aDict {
            let authStringBody = self.encodeAuthDictionary(authDict)
            let requestBody = authStringBody.data(using: String.Encoding.utf8)
            authRequest = URLRequest.init(url: URL.init(string: DMAuthHelper.AUTH_URL_STRING)!)
            authRequest?.httpMethod = "POST"
            authRequest?.httpBody = requestBody
        } else {
            authRequest = URLRequest.init(url: URL.init(string: DMAuthHelper.DOUBAN_USER_INFO)!)
            authRequest?.httpMethod = "GET"
        }

        var response: URLResponse?

        do {
            let urlData = try NSURLConnection.sendSynchronousRequest(authRequest!, returning: &response)
            return self.handleConnectionResponse(response!, Data: urlData)
        } catch {
            print("\(#function) caught: \(error)")
            return NSError.init(domain: "douban.fm", code: 0, userInfo: nil)
        }
    }

    public func logout() {
        self.username = nil
        self.userUrl = nil
        self.userIcon = NSImage.init(named: NSImage.userName)
        self.userInfo.removeAll()
        self.promotion_chls.removeAll()
        self.recent_chls.removeAll()
        self.isPro = false

        // Delete cookie
        let cookies = HTTPCookieStorage.shared.cookies

        for cookie in cookies! {
            if cookie.domain == ".douban.fm" {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }

        // Reset user default
        UserDefaults.standard.set(false, forKey: "isPro")
        UserDefaults.standard.set(64, forKey: "musicQuality")
    }

    private func encodeAuthDictionary(_ aDict: Dictionary<String, String>) -> String {
        return "remember=on&source=radio&\(aDict.urlEncodedString())"
    }

    private func constructUserInfo(fromDict aDict: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
        let name = aDict["name"] as! String
        let userId = aDict["user_id"] as! String
        let userlink = DMAuthHelper.DOUBAN_PEOPLE_PREFIX + userId
        let is_pro = (aDict["pro_status"] as! String != "E")
        let icon = aDict["icon"] as! String
        let user_info = ["name": name,
                         "url": userlink,
                         "id": userId,
                         "icon": icon,
                         "is_pro": is_pro] as [String: Any]
        return user_info as Dictionary<String, AnyObject>

    }

    private func fetchUserInfoAfterLogin() -> Dictionary<String, AnyObject> {
        var authRequest = URLRequest.init(url: URL.init(string: DMAuthHelper.DOUBAN_USER_INFO)!)
        authRequest.httpMethod = "GET"
        var response: URLResponse?

        let urlData = try! NSURLConnection.sendSynchronousRequest(authRequest, returning: &response)
        let jsonRet = try! JSONSerialization.jsonObject(with: urlData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>

        return constructUserInfo(fromDict: jsonRet)
    }

    private func handleConnectionResponse(_ response: URLResponse, Data data: Data) -> NSError? {
        let jsonRect = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

        if jsonRect != nil {
            let resultDict = jsonRect as! Dictionary<String, AnyObject>

            if resultDict["r"] as? Int == 0 {
                let httpResponse = response as! HTTPURLResponse
                let headerFields = httpResponse.allHeaderFields as! Dictionary<String, String>
                let cookie = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                        for: response.url!)

                HTTPCookieStorage.shared.setCookies(cookie,
                        for: URL.init(string: DMAuthHelper.DOUBAN_FM_INDEX)!, mainDocumentURL: nil)
                self.loginSuccess(withUserInfo: fetchUserInfoAfterLogin())
            } else if resultDict.index(forKey: "name") != nil {
                self.loginSuccess(withUserInfo: constructUserInfo(fromDict: resultDict))
            } else {
                print("\(#function) json returns invalid data, cleanup and logout")
                self.logout()
                return NSError.init(domain: "AuthError", code: Int(-2), userInfo: nil)
            }
        } else {
            print("\(#function) Login invalid.")
            return NSError.init(domain: "AuthError", code: Int(-1), userInfo: nil)
        }
        return nil
    }

    private func fetchPromotionAndRecentChannels() {
        let promotion_url = URL.init(string: DMAuthHelper.PROMOTION_CHLS_URL)!
        let recent_url = URL.init(string: DMAuthHelper.RECENT_CHLS_URL)!

        let promotion_request = URLRequest.init(url: promotion_url)
        let recent_request = URLRequest.init(url: recent_url)

        if let promotion_data = try? NSURLConnection.sendSynchronousRequest(promotion_request, returning: nil) {
            let data = try? JSONSerialization.jsonObject(with: promotion_data,
                    options: JSONSerialization.ReadingOptions.mutableContainers)

            if let dict = data as? Dictionary<String, AnyObject> {
                if dict["status"] != nil {
                    promotion_chls = dict["data"]!["chls"] as! Array<Dictionary<String, AnyObject>>
                }
            }
        }
        if let recent_data = try? NSURLConnection.sendSynchronousRequest(recent_request, returning: nil) {
            let data = try? JSONSerialization.jsonObject(with: recent_data,
                    options: JSONSerialization.ReadingOptions.mutableContainers)

            if let dict = data as? Dictionary<String, AnyObject> {
                if dict["status"] != nil {
                    recent_chls = dict["data"]!["chls"] as! Array<Dictionary<String, AnyObject>>
                }
            }

        }

    }

    private func loginSuccess(withUserInfo info: Dictionary<String, AnyObject>) {
        self.fetchPromotionAndRecentChannels()

        self.username = info["name"] as? String
        self.userUrl = info["url"] as? String
        self.isPro = (info["is_pro"] as? Bool)!
        self.userIcon = NSImage.init(contentsOf: URL.init(string: (info["icon"] as! String))!)
        self.userInfo = info

        UserDefaults.standard.set(self.isPro, forKey: "isPro")
        if !self.isPro {
            UserDefaults.standard.set(64, forKey: "musicQuality")
        } else {
            let proQuality = UserDefaults.standard.integer(forKey: "pro_musicQuality")
            UserDefaults.standard.set(proQuality, forKey: "musicQuality")
        }

        NotificationCenter.default.post(name: DMAuthHelper.AccountStateChangedNotification,
                object: self)
    }

}
