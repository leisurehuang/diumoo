//
//  DMNetEaseMusicFetcher.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/17/2026.
//  NetEase Cloud Music API Client (using local API server)
//

import Foundation
import AppKit

@objcMembers public class DMNetEaseMusicFetcher: NSObject {

    // MARK: - API Configuration
    internal let API_BASE_URL = "http://localhost:3000"
    internal var playlist: Array<Dictionary<String, AnyObject>> = []
    internal var channels: Array<Dictionary<String, AnyObject>> = []

    // Popular playlists (playlist IDs from NetEase Cloud Music)
    private let popularPlaylists: Array<Dictionary<String, AnyObject>> = [
        [
            "channel_id": "0" as AnyObject,
            "name": "热歌榜" as AnyObject,
            "name_en": "Hot Songs" as AnyObject,
            "playlist_id": "3778678" as AnyObject,
            "cover": "https://p2.music.126.net/UeTuwE7pvjBpypWLudqukA==/109951163835936985.jpg" as AnyObject
        ],
        [
            "channel_id": "1" as AnyObject,
            "name": "新歌榜" as AnyObject,
            "name_en": "New Songs" as AnyObject,
            "playlist_id": "3779629" as AnyObject,
            "cover": "https://p1.music.126.net/SrsqrYWkZQjdAdEgC9h6qg==/109951163834803835.jpg" as AnyObject
        ],
        [
            "channel_id": "2" as AnyObject,
            "name": "飙升榜" as AnyObject,
            "name_en": "Soaring Songs" as AnyObject,
            "playlist_id": "19723756" as AnyObject,
            "cover": "https://p2.music.126.net/N2sy9rukLJKEQlVBxGrUvg==/109951163834790235.jpg" as AnyObject
        ],
        [
            "channel_id": "3" as AnyObject,
            "name": "华语金曲" as AnyObject,
            "name_en": "Chinese Classics" as AnyObject,
            "playlist_id": "2884035" as AnyObject,
            "cover": "https://p1.music.126.net/vmOtRKiSFMWuO5YOgPVtOQ==/18941917794452599.jpg" as AnyObject
        ]
    ]

    // MARK: - Initialization
    public override init() {
        super.init()
        // Initially set to popular playlists as fallback
        self.channels = popularPlaylists
        
        // Dynamically fetch channel list from NetEase API
        fetchChannelsFromAPI()
        
        print("\(#function) NetEase Music API fetcher initialized")
    }

    deinit {
        self.playlist.removeAll()
        self.channels.removeAll()
    }

    // MARK: - Dynamic Channel Fetching
    private func fetchChannelsFromAPI() {
        let urlString = "\(API_BASE_URL)/toplist/detail"
        guard let url = URL(string: urlString) else {
            print("\(#function) invalid URL for channel list")
            return
        }

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
                   let list = json["list"] as? Array<[String: Any]> {

                    // Convert NetEase toplist to channel format
                    let convertedChannels = list.enumerated().compactMap { index, toplist -> [String: AnyObject]? in
                        guard let name = toplist["name"] as? String,
                              let playlistId = toplist["id"] as? Int else {
                            return nil
                        }

                        return [
                            "channel_id": String(index) as AnyObject,
                            "name": name as AnyObject,
                            "name_en": self.getEnglishName(for: name) as AnyObject,
                            "playlist_id": String(playlistId) as AnyObject,
                            "cover": (toplist["coverImgUrl"] as? String ?? "https://img.icons8.com/ios/512/compact-disc.png") as AnyObject
                        ]
                    }

                    if !convertedChannels.isEmpty {
                        self.channels = convertedChannels
                        print("\(#function) fetched \(convertedChannels.count) channels from NetEase API")
                    }
                } else {
                    print("\(#function) unexpected JSON format")
                }
            } catch {
                print("\(#function) failed to parse JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }

    // Get English name for Chinese toplist names
    private func getEnglishName(for chineseName: String) -> String {
        let nameMap: [String: String] = [
            "飙升榜": "Soaring",
            "新歌榜": "New Songs",
            "热歌榜": "Hot Songs",
            "说唱榜": "Rap",
            "欧美榜": "Western",
            "古典榜": "Classical",
            "电子榜": "Electronic",
            "抖音榜": "TikTok",
            "电音榜": "EDM",
            "UK排行榜": "UK Chart",
            "美国Billboard榜": "Billboard",
            "Beatport全球电子舞曲榜": "Beatport",
            "韩国Melon排行榜": "Melon",
            "日本公信榜": "Oricon",
            "YouTube音乐榜": "YouTube",
            "台湾Hito排行榜": "Hito",
            "中国TOP排行榜：港台榜": "China HK/TW",
            "中国TOP排行榜：内地榜": "China Mainland",
            "香港电台中文歌曲龙虎榜": "HK Radio",
            "华语金曲榜": "Chinese Classics",
            "中国嘻哈榜": "Chinese Hip-Hop",
            "法国NRJ Vos Hits榜": "NRJ",
            "韩国Mnet排行榜": "Mnet",
            "韩国Genie排行榜": "Genie",
            "壁虎专业": "Gecko",
            "Billboard日本热榜": "Billboard Japan"
        ]
        
        return nameMap[chineseName] ?? chineseName
    }

    // MARK: - Playlist Fetching
    public func fetchPlaylist(fromChannel channelId: String, count: Int = 20, callback: @escaping (Bool) -> Void) {
        print("\(#function) fetching playlist for channel \(channelId)")

        // Find playlist by channel_id
        guard let playlistInfo = popularPlaylists.first(where: { ($0["channel_id"] as? String) == channelId }),
              let playlistId = playlistInfo["playlist_id"] as? String else {
            print("\(#function) invalid channel ID: \(channelId)")
            callback(false)
            return
        }

        // Fetch playlist tracks from NetEase API
        let urlString = "\(API_BASE_URL)/playlist/track/all?id=\(playlistId)&limit=\(count)"
        guard let url = URL(string: urlString) else {
            print("\(#function) invalid URL: \(urlString)")
            callback(false)
            return
        }

        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)

        let session = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("\(#function) request failed: \(error.localizedDescription)")
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
                   let songs = json["songs"] as? Array<[String: Any]> {

                    // First, convert without real URLs
                    let tempSongs = songs.compactMap { song -> [String: AnyObject]? in
                        return self.convertNetEaseSongToDoubanFormat(song)
                    }

                    // Then fetch real URLs for all songs
                    self.fetchRealUrlsForSongs(tempSongs, callback: callback)
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

    // Fetch real URLs for all songs (batch processing)
    private func fetchRealUrlsForSongs(_ songs: Array<Dictionary<String, AnyObject>>, callback: @escaping (Bool) -> Void) {
        guard songs.count > 0 else {
            self.playlist.removeAll()
            callback(false)
            return
        }

        let group = DispatchGroup()
        var songsWithUrls: Array<Dictionary<String, AnyObject>> = []
        let queue = DispatchQueue(label: "com.diumoo.songUrls", attributes: .concurrent)

        for (index, song) in songs.enumerated() {
            group.enter()
            guard let songId = song["sid"] as? String else {
                group.leave()
                continue
            }

            // Fetch real URL for this song
            let urlString = "\(API_BASE_URL)/song/url?id=\(songId)"
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }

            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let dataArray = json["data"] as? Array<[String: Any]>,
                      let firstSong = dataArray.first,
                      let realUrl = firstSong["url"] as? String,
                      !realUrl.isEmpty else {
                    // Skip songs without valid URLs
                    return
                }

                var updatedSong = song
                updatedSong["url"] = realUrl as AnyObject

                queue.async {
                    songsWithUrls.append(updatedSong)
                }
            }
            task.resume()

            // Add delay to avoid rate limiting
            Thread.sleep(forTimeInterval: 0.1)
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            // Sort songs by original order
            let sortedSongs = songsWithUrls.sorted { song1, song2 in
                let index1 = songs.firstIndex { $0["sid"] as? String == song1["sid"] as? String } ?? 0
                let index2 = songs.firstIndex { $0["sid"] as? String == song2["sid"] as? String } ?? 0
                return index1 < index2
            }

            self.playlist.removeAll()
            self.playlist.append(contentsOf: sortedSongs)

            print("\(#function) fetched \(self.playlist.count) songs with real URLs")
            callback(true)
        }
    }

    // MARK: - Song Conversion
    private func convertNetEaseSongToDoubanFormat(_ netEaseSong: [String: Any], withRealUrl: Bool = true) -> [String: AnyObject]? {
        guard let id = netEaseSong["id"] as? Int,
              let name = netEaseSong["name"] as? String,
              let ar = netEaseSong["ar"] as? Array<[String: Any]>,
              let al = netEaseSong["al"] as? [String: Any],
              let artist = ar.first?["name"] as? String,
              let albumName = al["name"] as? String else {
            print("\(#function) missing required fields")
            return nil
        }

        var doubanSong: [String: AnyObject] = [:]

        // Song ID
        doubanSong["sid"] = String(id) as AnyObject
        doubanSong["ssid"] = String(id) as AnyObject
        doubanSong["aid"] = String(id) as AnyObject

        // Basic info
        doubanSong["title"] = name as AnyObject
        doubanSong["artist"] = artist as AnyObject
        doubanSong["albumtitle"] = albumName as AnyObject

        // URLs
        if withRealUrl {
            // Temporary placeholder, will be replaced with real URL
            doubanSong["url"] = "" as AnyObject
        } else {
            doubanSong["url"] = "" as AnyObject
        }
        doubanSong["picture"] = (al["pic_url"] as? String ?? al["picUrl"] as? String ?? "https://img.icons8.com/ios/512/compact-disc.png") as AnyObject

        // Duration
        if let dt = netEaseSong["dt"] as? Int {
            doubanSong["length"] = String(dt / 1000) as AnyObject
        } else {
            doubanSong["length"] = "240" as AnyObject
        }

        // Album URL (empty for NetEase)
        doubanSong["album"] = "" as AnyObject

        // Like status (default false)
        doubanSong["like"] = "0" as AnyObject

        // Subtype (normal song)
        doubanSong["subtype"] = "0" as AnyObject

        // Source
        doubanSong["from"] = "netease" as AnyObject

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

    // MARK: - Helper: Fetch actual song URL
    public func fetchRealSongUrl(forSongId songId: String, callback: @escaping (String?) -> Void) {
        let urlString = "\(API_BASE_URL)/song/url?id=\(songId)"
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
                callback(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? Array<[String: Any]>,
                   let firstSong = dataArray.first,
                   let realUrl = firstSong["url"] as? String {
                    callback(realUrl)
                } else {
                    callback(nil)
                }
            } catch {
                print("\(#function) JSON parse error: \(error.localizedDescription)")
                callback(nil)
            }
        }
        session.resume()
    }
}
