//
//  DMNetEaseAPIClient.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/17/2026.
//  Native NetEase Cloud Music API client (remote API only)
//

import Foundation

@objcMembers public class DMNetEaseAPIClient: NSObject {

    // MARK: - Configuration

    static let shared = DMNetEaseAPIClient()

    private let baseURL = "https://music.163.com"
    private let timeout: TimeInterval = 10.0

    private override init() {
        super.init()
        print("🎵 DMNetEaseAPIClient initialized (using remote NetEase API)")
    }

    // MARK: - Public API Methods

    public func fetchToplistDetail(completion: @escaping ([String: Any]?) -> Void) {
        let path = "/api/toplist/detail"
        makeRequest(path: path, method: "GET", params: [:]) { result in
            completion(result)
        }
    }

    public func fetchPlaylistTracks(playlistId: String, limit: Int = 100, completion: @escaping ([[String: Any]]?) -> Void) {
        let path = "/api/v6/playlist/detail"
        let params: [String: Any] = [
            "id": playlistId,
            "n": 100000,
            "s": 8
        ]

        print("📋 Fetching playlist: \(playlistId)")

        makeRequest(path: path, method: "POST", params: params) { result in
            guard let result = result,
                  let playlist = result["playlist"] as? [String: Any],
                  let trackIds = playlist["trackIds"] as? [[String: Any]] else {
                print("❌ Failed to parse playlist response")
                completion(nil)
                return
            }

            print("✅ Got playlist with \(trackIds.count) tracks")

            let limitedTrackIds = Array(trackIds.prefix(limit))
            let ids = limitedTrackIds.compactMap { $0["id"] as? Int }
            let idsString = ids.map { String($0) }.joined(separator: ",")

            self.fetchSongDetail(ids: idsString) { songs in
                completion(songs)
            }
        }
    }

    public func fetchSongDetail(ids: String, completion: @escaping ([[String: Any]]?) -> Void) {
        let path = "/api/v3/song/detail"

        let idArray = ids.split(separator: ",").map { id in "{\"id\":\(id)}" }
        let cParam = "[\(idArray.joined(separator: ","))]"

        let params: [String: Any] = [
            "c": cParam
        ]

        print("🎵 Fetching \(ids.split(separator: ",").count) song details")

        makeRequest(path: path, method: "POST", params: params) { result in
            guard let result = result,
                  let songs = result["songs"] as? [[String: Any]] else {
                print("❌ Failed to parse song detail response")
                completion(nil)
                return
            }

            print("✅ Got \(songs.count) song details")
            completion(songs)
        }
    }

    public func fetchSongURL(songId: Int, completion: @escaping (String?) -> Void) {
        let path = "/api/song/enhance/player/url"
        
        // Format: ["123","456"]
        let idsArray = "[\"\(songId)\"]"
        
        let params: [String: Any] = [
            "ids": idsArray,
            "br": 999000
        ]

        makeRequest(path: path, method: "POST", params: params) { result in
            guard let result = result,
                  let data = result["data"] as? [[String: Any]],
                  let firstSong = data.first,
                  let url = firstSong["url"] as? String,
                  !url.isEmpty else {
                print("❌ Failed to get song URL")
                completion(nil)
                return
            }

            print("✅ Got song URL: \(url.prefix(50))...")
            completion(url)
        }
    }

    // MARK: - Private Request Methods

    private func makeRequest(path: String, method: String, params: [String: Any], completion: @escaping ([String: Any]?) -> Void) {
        // Ensure path starts with /api
        let fullPath = path.hasPrefix("/api") ? path : "/api" + path

        guard let url = URL(string: baseURL + fullPath) else {
            print("❌ Invalid URL: \(baseURL + fullPath)")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeout

        // Add required headers
        request.setValue("music.163.com", forHTTPHeaderField: "Host")
        request.setValue("https://music.163.com", forHTTPHeaderField: "Origin")
        request.setValue("https://music.163.com", forHTTPHeaderField: "Referer")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Use iPhone User-Agent to avoid anti-bot
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.47(0x18002f2f) NetEaseMusic/9.0.95 Core/10.0.101 Channel/App Store", forHTTPHeaderField: "User-Agent")

        // Add device info headers
        request.setValue("16.2", forHTTPHeaderField: "osver")
        request.setValue("iphone", forHTTPHeaderField: "os")
        request.setValue("9.0.95", forHTTPHeaderField: "appver")
        request.setValue("140", forHTTPHeaderField: "versioncode")
        request.setValue("1920x1080", forHTTPHeaderField: "resolution")
        request.setValue("distribution", forHTTPHeaderField: "channel")

        // Add device ID
        let deviceId = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16)
        request.setValue(String(deviceId), forHTTPHeaderField: "deviceId")

        // Build request body
        if method == "POST" && !params.isEmpty {
            var bodyComponents = [String]()
            for (key, value) in params {
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue: String
                if let stringValue = value as? String {
                    encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? stringValue
                } else if let numberValue = value as? NSNumber {
                    encodedValue = numberValue.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? numberValue.stringValue
                } else {
                    encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"
                }
                bodyComponents.append("\(encodedKey)=\(encodedValue)")
            }

            let bodyString = bodyComponents.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
        }

        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil)
                return
            }

            print("📡 API Response: \(httpResponse.statusCode) - \(path)")

            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 301 else {
                print("❌ HTTP status: \(httpResponse.statusCode)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let code = json["code"] as? Int ?? -1

                    if code == 200 || code == 301 {
                        completion(json)
                    } else {
                        let message = json["message"] as? String ?? "Unknown error"
                        print("❌ API error (code \(code)): \(message)")
                        completion(nil)
                    }
                } else {
                    print("❌ Failed to parse JSON")
                    completion(nil)
                }
            } catch {
                print("❌ JSON serialization error: \(error.localizedDescription)")
                completion(nil)
            }
        }

        session.resume()
    }
}
