//
//  DMBaiduMusicFetcher.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/16/2026.
//  Baidu Music FM API Client
//

import Foundation
import AppKit

// MARK: - Baidu Music API Client

@objcMembers public class DMBaiduMusicFetcher: NSObject {
    
    // MARK: - API Endpoints
    static internal let BAIDU_FM_API_BASE = "http://fm.baidu.com/dev/api/"
    static internal let CHANNEL_LIST_ENDPOINT = "channellist"
    static internal let PLAYLIST_ENDPOINT = "playlist"
    static internal let SONG_INFO_ENDPOINT = "songinfo"
    
    // MARK: - Properties
    internal var playlist: Array<Dictionary<String, AnyObject>> = []
    internal var channels: Array<Dictionary<String, AnyObject>> = []
    
    // MARK: - Initialization
    public override init() {
        super.init()
        fetchChannels()
    }
    
    deinit {
        self.playlist.removeAll()
        self.channels.removeAll()
    }
    
    // MARK: - Channel List API
    internal func fetchChannels() {
        let urlString = DMBaiduMusicFetcher.BAIDU_FM_API_BASE + DMBaiduMusicFetcher.CHANNEL_LIST_ENDPOINT + "?format=json"
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let session = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("\(#function) failed to fetch channels: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("\(#function) received empty data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let channelList = json["list"] as? Array<[String: Any]> {
                    
                    self.channels = channelList.map { channel -> [String: AnyObject] in
                        var dict: [String: AnyObject] = [:]
                        dict["channel_id"] = String(describing: channel["id"] ?? "") as AnyObject
                        dict["channel_name"] = String(describing: channel["name"] ?? "") as AnyObject
                        return dict
                    }
                    
                    print("\(#function) fetched \(self.channels.count) channels")
                }
            } catch {
                print("\(#function) failed to parse JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    
    // MARK: - Playlist API
    public func fetchPlaylist(fromChannel channelId: String, count: Int = 10, callback: @escaping (Bool) -> Void) {
        let urlString = DMBaiduMusicFetcher.BAIDU_FM_API_BASE + DMBaiduMusicFetcher.PLAYLIST_ENDPOINT + "?format=json&id=\(channelId)"
        guard let url = URL(string: urlString) else {
            callback(false)
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        
        let session = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("\(#function) failed: \(error.localizedDescription)")
                callback(false)
                return
            }
            
            guard let data = data else {
                print("\(#function) received empty data")
                callback(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let songList = json["list"] as? Array<[String: Any]> {
                    
                    // Convert Baidu songs to Douban format
                    let convertedSongs = songList.compactMap { song -> [String: AnyObject]? in
                        return self.convertBaiduSongToDoubanFormat(song)
                    }
                    
                    self.playlist.removeAll()
                    self.playlist.append(contentsOf: convertedSongs)
                    
                    print("\(#function) fetched \(self.playlist.count) songs from channel \(channelId)")
                    callback(true)
                } else {
                    print("\(#function) unexpected JSON format")
                    callback(false)
                }
            } catch {
                print("\(#function) failed to parse JSON: \(error.localizedDescription)")
                callback(false)
            }
        }
        session.resume()
    }
    
    // MARK: - Song Info API
    internal func fetchSongInfo(songId: String, callback: @escaping ([String: AnyObject]?) -> Void) {
        let urlString = DMBaiduMusicFetcher.BAIDU_FM_API_BASE + DMBaiduMusicFetcher.SONG_INFO_ENDPOINT + "?format=json&id=\(songId)"
        guard let url = URL(string: urlString) else {
            callback(nil)
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(#function) failed: \(error.localizedDescription)")
                callback(nil)
                return
            }
            
            guard let data = data else {
                print("\(#function) received empty data")
                callback(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    callback(json as [String: AnyObject])
                } else {
                    print("\(#function) unexpected JSON format")
                    callback(nil)
                }
            } catch {
                print("\(#function) failed to parse JSON: \(error.localizedDescription)")
                callback(nil)
            }
        }
        session.resume()
    }
    
    // MARK: - Format Conversion
    private func convertBaiduSongToDoubanFormat(_ baiduSong: [String: Any]) -> [String: AnyObject]? {
        guard let songId = baiduSong["id"] else {
            print("\(#function) missing song ID")
            return nil
        }
        
        var doubanSong: [String: AnyObject] = [:]
        
        // Basic info
        doubanSong["sid"] = String(describing: songId) as AnyObject
        doubanSong["ssid"] = String(describing: baiduSong["artistId"] ?? songId) as AnyObject
        doubanSong["aid"] = String(describing: baiduSong["albumId"] ?? "") as AnyObject
        
        // Title and artist
        doubanSong["title"] = String(describing: baiduSong["title"] ?? "Unknown Title") as AnyObject
        doubanSong["artist"] = String(describing: baiduSong["artist"] ?? "Unknown Artist") as AnyObject
        doubanSong["albumtitle"] = String(describing: baiduSong["albumTitle"] ?? "Unknown Album") as AnyObject
        
        // Stream URL (use high quality if available)
        if let songLink = baiduSong["songLink"] as? String, !songLink.isEmpty {
            doubanSong["url"] = songLink as AnyObject
        } else if let highRate = baiduSong["highRate"] as? String, !highRate.isEmpty {
            doubanSong["url"] = highRate as AnyObject
        } else {
            print("\(#function) missing stream URL for song \(songId)")
            return nil
        }
        
        // Album art
        if let picUrl = baiduSong["picUrl"] as? String, !picUrl.isEmpty {
            doubanSong["picture"] = picUrl as AnyObject
        } else if let picRadio = baiduSong["picRadio"] as? String, !picRadio.isEmpty {
            doubanSong["picture"] = picRadio as AnyObject
        } else {
            // Use default image
            doubanSong["picture"] = "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject
        }
        
        // Duration
        if let duration = baiduSong["duration"] as? Int {
            doubanSong["length"] = String(duration) as AnyObject
        } else if let time = baiduSong["time"] as? Int {
            doubanSong["length"] = String(time) as AnyObject
        } else {
            doubanSong["length"] = "240" as AnyObject // Default 4 minutes
        }
        
        // Album URL (Baidu Music doesn't have album URLs, use a placeholder)
        doubanSong["album"] = "" as AnyObject
        
        // Like status (default false)
        doubanSong["like"] = "0" as AnyObject
        
        // Subtype (normal song)
        doubanSong["subtype"] = "0" as AnyObject
        
        return doubanSong
    }
    
    // MARK: - Public Methods
    public func getOnePlayableItem() -> DMPlayableItem? {
        if self.playlist.count > 0 {
            let songInfo = self.playlist[0]
            let subtype = songInfo["subtype"] as! String
            let filterAds = UserDefaults.standard.value(forKey: "filterAds") as? Int ?? 0
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
    
    public func getChannels() -> Array<Dictionary<String, AnyObject>> {
        return self.channels
    }
}
