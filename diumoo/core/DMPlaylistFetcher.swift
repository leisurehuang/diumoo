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
    // This should actually be an enum type
    // But Objective-C does not support String type enum
    // This is all we can do
    // FIXME: When project convert to Swift completely
    static public let kFetchPlaylistTypeNew = "n"
    static public let kFetchPlaylistTypeEnd = "e"
    static public let kFetchPlaylistTypePlaying = "p"
    static public let kFetchPlaylistTypeSkip = "s"
    static public let kFetchPlaylistTypeRate = "r"
    static public let kFetchPlaylistTypeUnrate = "u"
    static public let kFetchPlaylistTypeBye = "b"

    static internal let PLAYLIST_FETCH_URL_BASE = "https://douban.fm/j/mine/playlist"
    static internal let DOUBAN_FM_ORIGIN_URL = ".douban.fm"
    static internal let DOUBAN_ALBUM_GET_URL = "https://douban.fm/j/app/radio/people"

    public var delegate: DMPlaylistFetcherDelegate?

    internal var playlist: Array<Dictionary<String, AnyObject>> = []
    internal var playedSongs: Dictionary<String, Any> = [:]
    internal var searchResults: NSOrderedSet = []

    internal var netEaseFetcher: DMNetEaseMusicFetcher?
    internal lazy var netEaseFetcherInstance: DMNetEaseMusicFetcher = {
        return DMNetEaseMusicFetcher()
    }()

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
        let url = URL.init(string: urlString)
        let request = URLRequest.init(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)

        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                do {
                    let jResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    let albumDict = jResponse as! Dictionary<String, AnyObject>
                    let songArray = albumDict["song"] as? Array<Dictionary<String, AnyObject>>
                    callback(songArray)
                } catch {
                    print("\(#function) ::  Invalid Json returned from server")
                }
            }
        }
        session.resume()
    }

    public func fetchSongs(withMusician musicianID: String, callback: @escaping (Bool) -> Void) {
        let dict: [String: Any] = [
            "type": DMPlaylistFetcher.kFetchPlaylistTypeNew,
            "channel": Int(0),
            "r": self.randomString(),
            "from": "mainsite",
            "context": "context=channel:0|musician_id:\(musicianID)"
        ]
        let urlString = DMPlaylistFetcher.PLAYLIST_FETCH_URL_BASE + "?" + dict.urlEncodedString()
        self.sendRequest(forURL: urlString) { list in
            if list != nil {
                self.playlist.removeAll()
                self.playlist.append(contentsOf: list!)
                callback(true)
            } else {
                callback(false)
            }
        }
    }

    public func fetchSongs(withSoundtrackID songID: String, callback: @escaping (Bool) -> Void) {
        let dict: [String: Any] = [
            "type": DMPlaylistFetcher.kFetchPlaylistTypeNew,
            "channel": Int(10),
            "r": self.randomString(),
            "from": "mainsite",
            "context": "context=channel:10|subject_id:\(songID)"
        ]

        let urlstring = DMPlaylistFetcher.PLAYLIST_FETCH_URL_BASE + "?" + dict.urlEncodedString()

        self.sendRequest(forURL: urlstring) { list in
            if list != nil {
                self.playlist.removeAll()
                self.playlist.append(contentsOf: list!)
                callback(true)
            } else {
                callback(false)
            }
        }
    }

    public func fetchSongs(withAlbum album: String, callback: @escaping (Bool) -> Void) {
        let data = Date()
        let expire = Int(data.timeIntervalSince1970 + 1000 * 60 * 5 * 30)
        let dict: [String: Any] = [
            "type": DMPlaylistFetcher.kFetchPlaylistTypeNew,
            "context": "channel:0|subject_id:\(album)",
            "channel": Int(0),
            "app_name": "radio_ipad",
            "version": "1",
            "expire": expire
        ]

        let urlstring = DMPlaylistFetcher.DOUBAN_ALBUM_GET_URL + "?" + dict.urlEncodedString()
        self.sendRequest(forURL: urlstring) { list in
            if list != nil {
                var albumSong = [] as Array<Dictionary<String, AnyObject>>
                for song in list! {
                    if song["aid"] as! String == album {
                        albumSong.append(song)
                    }
                }
                if albumSong.count > 0 {
                    self.playlist = albumSong
                    callback(true)
                } else {
                    callback(false)
                }
            }
        }

    }
}
