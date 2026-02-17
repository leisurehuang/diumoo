//
//  DMPlaylistFetcher.swift
//  diumoo
//
//  Created by Yancheng Zheng on 6/18/16.
//
//

import Foundation
import AppKit

// MARK: - Dictionary Extensions for URL Encoding

extension Dictionary where Key == String, Value == Any {
    func urlEncodedString() -> String {
        var parts: [String] = []
        for (key, value) in self {
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"
            parts.append("\(encodedKey)=\(encodedValue)")
        }
        return parts.joined(separator: "&")
    }

    func hString() -> String {
        var parts: [String] = []
        for (key, value) in self {
            parts.append("\(key):\(value)")
        }
        return parts.joined(separator: "|")
    }
}

@objc public protocol DMPlaylistFetcherDelegate {
    func fetchPlaylist(WithDictionary dict: Dictionary<String, AnyObject>, startAttribute attribute: String, errorThreshould errCount: NSInteger) -> Void
    func fetchPlaylistSuccess(startSong: DMPlayableItem?) -> Void
}

@objcMembers public class DMPlaylistFetcher: NSObject {
    public static let kFetchPlaylistTypeNew = "n"
    public static let kFetchPlaylistTypeEnd = "e"
    public static let kFetchPlaylistTypePlaying = "p"
    public static let kFetchPlaylistTypePause = "u"
    public static let kFetchPlaylistTypeSkip = "s"
    public static let kFetchPlaylistTypeBan = "b"
    public static let kFetchPlaylistTypeBye = "b"
    public static let kFetchPlaylistTypeLike = "r"
    public static let kFetchPlaylistTypeRate = "r"
    public static let kFetchPlaylistTypeUnrate = "ur"

    // Expose sharedController to Objective-C
    @objc public class func sharedController() -> DMPlaylistFetcher {
        return sharedInstance
    }

    // Singleton instance
    private static let sharedInstance: DMPlaylistFetcher = {
        return DMPlaylistFetcher()
    }()

    public var delegate: DMPlaylistFetcherDelegate?

    internal var playlist: Array<Dictionary<String, AnyObject>> = []
    internal var playedSongs: Dictionary<String, Any> = [:]
    internal var searchResults: NSOrderedSet = []

    internal var netEaseFetcher: DMNetEaseMusicFetcher?
    internal lazy var netEaseFetcherInstance: DMNetEaseMusicFetcher = {
        return DMNetEaseMusicFetcher()
    }()

    // Expose netEaseFetcherInstance to Objective-C
    @objc public func getNetEaseChannels() -> Array<Dictionary<String, AnyObject>> {
        if self.netEaseFetcher == nil {
            self.netEaseFetcher = self.netEaseFetcherInstance
        }
        return self.netEaseFetcher?.getChannels() ?? []
    }

    internal func randomString() -> String {
        let rand1: UInt32 = arc4random();
        let rand2: UInt32 = arc4random();
        return String(format: "%5x%5x", ((rand1 & 0xfffff) | 0x10000), rand2)
    }

    deinit {
        self.playlist.removeAll()
        self.playedSongs.removeAll()
        self.delegate = nil
    }

    public func fetchPlaylist(fromChannel channel: String, Type type: String, sid: String?, startAttribute attribute: String?) {
        var newType = type
        if newType == DMPlaylistFetcher.kFetchPlaylistTypeEnd && self.playlist.count == 0 {
            newType = DMPlaylistFetcher.kFetchPlaylistTypeNew
        } else if sid == nil {
            newType = DMPlaylistFetcher.kFetchPlaylistTypeNew
        } else {
            self.playedSongs[sid!] = type
        }

        let pref = UserDefaults.standard
        let quality = pref.value(forKey: "musicQuality") as! NSNumber

        let fetchDictionary: [String: Any] = [
            "type": type,
            "channel": Int(channel),
            "sid": ((sid != nil) ? sid : ""),
            "h": (self.playedSongs as [String: Any]).hString(),
            "r": self.randomString(),
            "from": "mainsite",
            "kbps": quality
        ]
        self.fetchPlaylist(withDictionary: fetchDictionary, startAttribute: attribute, errCount: 0)
    }

    public func fetchPlaylist(withDictionary dict: [String: Any], startAttribute attribute: String?, errCount: Int) {
        let validAttr = attribute ?? ""

        let channelId = String(describing: dict["channel"] ?? "0")

        if self.netEaseFetcher == nil {
            self.netEaseFetcher = self.netEaseFetcherInstance
        }

        self.netEaseFetcher?.fetchPlaylist(fromChannel: channelId) { [weak self] success in
            guard let self = self else { return }

            if success, let fetcher = self.netEaseFetcher {
                if attribute != nil && fetcher.playlist.count > 0 {
                    let aSong = DMPlayableItem.init(WithDict: fetcher.playlist[0])
                    self.playlist = Array(fetcher.playlist.dropFirst())
                    self.delegate?.fetchPlaylistSuccess(startSong: aSong)
                } else {
                    self.playlist.append(contentsOf: fetcher.playlist)
                    self.delegate?.fetchPlaylistSuccess(startSong: nil)
                }
            } else {
                self.delegate?.fetchPlaylist(WithDictionary: dict as Dictionary<String, AnyObject>, startAttribute: validAttr, errorThreshould: errCount + 1)
            }
        }
    }

    public func getOnePlayableItem() -> DMPlayableItem? {
        if self.playlist.count > 0 {
            let songInfo = self.playlist[0]
            let subtype = songInfo["subtype"] as! String
            let filterAds = UserDefaults.standard.value(forKey: "filterAds") as! Int
            if subtype == "T" && filterAds == 1 {
                self.playlist.remove(at: 0)
                return self.getOnePlayableItem()
            }

            self.playlist.remove(at: 0)
            return DMPlayableItem.init(WithDict: songInfo)
        } else {
            return nil
        }
    }

    public func clearPlaylist() {
        self.playlist.removeAll()
    }

    internal func sendRequest(forURL urlString: String, callback: @escaping (Array<Dictionary<String, AnyObject>>?) -> Void) {
        // Note: This method is deprecated and no longer used
        // NetEase Music API is used instead
        print("\(#function) WARNING: sendRequest is deprecated, not fetching from \(urlString)")
        callback(nil)
    }

    public func fetchSongs(withMusician musicianID: String, callback: @escaping (Bool) -> Void) {
        // Deprecated: Douban FM API method, no longer supported
        print("\(#function) Deprecated method called - not supported")
        callback(false)
    }

    public func fetchSongs(withSoundtrackID songID: String, callback: @escaping (Bool) -> Void) {
        // Deprecated: Douban FM API method, no longer supported
        print("\(#function) Deprecated method called - not supported")
        callback(false)
    }

    public func fetchSongs(withAlbum album: String, callback: @escaping (Bool) -> Void) {
        callback(false)
    }
}
