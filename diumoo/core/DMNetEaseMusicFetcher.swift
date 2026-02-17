//
//  DMNetEaseMusicFetcher.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/17/2026.
//  NetEase Cloud Music API Client (native implementation)
//

import Foundation
import AppKit

@objcMembers public class DMNetEaseMusicFetcher: NSObject {

    // MARK: - API Configuration
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
        print("📡 Fetching channels from NetEase native API...")

        DMNetEaseAPIClient.shared.fetchToplistDetail { [weak self] result in
            guard let self = self else { return }

            guard let result = result,
                  let list = result["list"] as? Array<[String: Any]> else {
                print("❌ Failed to parse toplist data")
                return
            }

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
                print("✅ Fetched \(convertedChannels.count) channels from NetEase native API")
            }
        }
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
        guard let playlistInfo = channels.first(where: { ($0["channel_id"] as? String) == channelId }),
              let playlistId = playlistInfo["playlist_id"] as? String else {
            print("\(#function) invalid channel ID: \(channelId)")
            callback(false)
            return
        }

        // Fetch playlist tracks using native API
        DMNetEaseAPIClient.shared.fetchPlaylistTracks(playlistId: playlistId, limit: count) { [weak self] songs in
            guard let self = self else {
                callback(false)
                return
            }

            guard let songs = songs, !songs.isEmpty else {
                print("\(#function) no songs found")
                callback(false)
                return
            }

            // Convert songs to Douban format (without real URLs yet)
            let tempSongs = songs.compactMap { song -> [String: AnyObject]? in
                return self.convertNetEaseSongToDoubanFormat(song)
            }

            // Fetch real URLs for all songs
            self.fetchRealUrlsForSongs(tempSongs, callback: callback)
        }
    }

    // Fetch real URLs for all songs (batch processing)
    private func fetchRealUrlsForSongs(_ songs: Array<Dictionary<String, AnyObject>>, callback: @escaping (Bool) -> Void) {
        guard songs.count > 0 else {
            self.playlist.removeAll()
            callback(false)
            return
        }

        print("🎵 Fetching real URLs for \(songs.count) songs...")

        let group = DispatchGroup()
        var songsWithUrls: Array<Dictionary<String, AnyObject>> = []
        let queue = DispatchQueue(label: "com.diumoo.songUrls", attributes: .concurrent)

        for song in songs {
            group.enter()
            guard let songId = song["sid"] as? String,
                  let songIdInt = Int(songId) else {
                group.leave()
                continue
            }

            DMNetEaseAPIClient.shared.fetchSongURL(songId: songIdInt) { realUrl in
                defer { group.leave() }

                guard let realUrl = realUrl, !realUrl.isEmpty else {
                    return
                }

                var updatedSong = song
                updatedSong["url"] = realUrl as AnyObject

                queue.async {
                    songsWithUrls.append(updatedSong)
                }
            }
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

            print("✅ Fetched \(self.playlist.count) songs with real URLs")
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
        guard let songIdInt = Int(songId) else {
            callback(nil)
            return
        }

        DMNetEaseAPIClient.shared.fetchSongURL(songId: songIdInt) { realUrl in
            callback(realUrl)
        }
    }
}
