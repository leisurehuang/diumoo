//
//  DMLocalMusicFetcher.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/17/2026.
//  Local music playlist as fallback when external APIs fail
//

import Foundation
import AppKit

// MARK: - Local Music Fetcher (Fallback Solution)

@objcMembers public class DMLocalMusicFetcher: NSObject {

    // MARK: - Properties
    internal var playlist: Array<Dictionary<String, AnyObject>> = []
    internal var channels: Array<Dictionary<String, AnyObject>> = []

    private let sampleSongs: Array<Dictionary<String, AnyObject>> = [
        [
            "sid": "local_001" as AnyObject,
            "ssid": "local_album_001" as AnyObject,
            "aid": "local_album_001" as AnyObject,
            "title": "Example Song 1" as AnyObject,
            "artist": "Artist Name" as AnyObject,
            "albumtitle": "Sample Album" as AnyObject,
            "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" as AnyObject,
            "picture": "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject,
            "length": "360" as AnyObject,
            "album": "" as AnyObject,
            "like": "0" as AnyObject,
            "subtype": "0" as AnyObject,
            "from": "local" as AnyObject
        ],
        [
            "sid": "local_002" as AnyObject,
            "ssid": "local_album_001" as AnyObject,
            "aid": "local_album_001" as AnyObject,
            "title": "Example Song 2" as AnyObject,
            "artist": "Another Artist" as AnyObject,
            "albumtitle": "Sample Album" as AnyObject,
            "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3" as AnyObject,
            "picture": "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject,
            "length": "300" as AnyObject,
            "album": "" as AnyObject,
            "like": "0" as AnyObject,
            "subtype": "0" as AnyObject,
            "from": "local" as AnyObject
        ],
        [
            "sid": "local_003" as AnyObject,
            "ssid": "local_album_001" as AnyObject,
            "aid": "local_album_001" as AnyObject,
            "title": "Example Song 3" as AnyObject,
            "artist": "Third Artist" as AnyObject,
            "albumtitle": "Sample Album" as AnyObject,
            "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3" as AnyObject,
            "picture": "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject,
            "length": "240" as AnyObject,
            "album": "" as AnyObject,
            "like": "0" as AnyObject,
            "subtype": "0" as AnyObject,
            "from": "local" as AnyObject
        ]
    ]

    // MARK: - Initialization
    public override init() {
        super.init()
        setupChannels()
        loadDefaultPlaylist()
    }

    deinit {
        self.playlist.removeAll()
        self.channels.removeAll()
    }

    // MARK: - Channel Setup
    private func setupChannels() {
        self.channels = [
            [
                "channel_id": "0" as AnyObject,
                "name": "本地歌单" as AnyObject,
                "name_en": "Local Playlist" as AnyObject,
                "seq_id": "0" as AnyObject,
                "cover": "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject
            ],
            [
                "channel_id": "1" as AnyObject,
                "name": "测试音乐" as AnyObject,
                "name_en": "Test Music" as AnyObject,
                "seq_id": "1" as AnyObject,
                "cover": "https://img.icons8.com/ios/512/compact-disc.png" as AnyObject
            ]
        ]
    }

    // MARK: - Playlist Management
    private func loadDefaultPlaylist() {
        self.playlist = self.sampleSongs as Array<Dictionary<String, AnyObject>>
        print("\(#function) loaded \(self.playlist.count) local songs")
    }

    public func fetchPlaylist(fromChannel channelId: String, count: Int = 10, callback: @escaping (Bool) -> Void) {
        print("\(#function) fetching from local channel \(channelId)")

        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            // Reload playlist
            self.loadDefaultPlaylist()

            // Shuffle songs for variety
            self.playlist.shuffle()

            print("\(#function) fetched \(self.playlist.count) songs from local storage")
            callback(true)
        }
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

    // MARK: - Configuration Methods
    public func addCustomSong(title: String, artist: String, url: String, picture: String? = nil) {
        let newSong: Dictionary<String, AnyObject> = [
            "sid": "custom_\(UUID().uuidString)" as AnyObject,
            "ssid": "custom_album" as AnyObject,
            "aid": "custom_album" as AnyObject,
            "title": title as AnyObject,
            "artist": artist as AnyObject,
            "albumtitle": "Custom Song" as AnyObject,
            "url": url as AnyObject,
            "picture": (picture ?? "https://img.icons8.com/ios/512/compact-disc.png") as AnyObject,
            "length": "240" as AnyObject,
            "album": "" as AnyObject,
            "like": "0" as AnyObject,
            "subtype": "0" as AnyObject,
            "from": "custom" as AnyObject
        ]

        self.playlist.append(newSong)
        print("\(#function) added custom song: \(title) - \(artist)")
    }
}
