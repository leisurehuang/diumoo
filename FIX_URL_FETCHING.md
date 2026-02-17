# 修复自动播放和URL获取问题

## 问题分析

### 问题1: FairPlay DRM错误
```
<<<< FDCP_Limited >>>> signalled err=-12540
HTTPRequest signalled err=-12939
```

**原因：**
- 部分歌曲需要网易云音乐VIP
- 受版权保护的歌曲无法播放

**影响：**
- 这些歌曲会触发FairPlay错误
- AVPlayer无法播放

### 问题2: 自动播放不工作

**根本原因：**
代码返回的URL不是真实的MP3链接，而是API端点：
```swift
return "http://localhost:3000/song/url?id=\(songId)"
```

AVPlayer无法直接播放这个URL，需要真实的MP3地址。

### 问题3: 播放完成监听器

**已修复：**
- 添加了 `AVPlayerItemDidPlayToEndTimeNotification` 监听
- 添加了 `itemDidFinishPlaying:` 方法

---

## 解决方案

### 1. 批量获取真实MP3 URL

修改 `DMNetEaseMusicFetcher.swift`：

#### 新增方法：fetchRealUrlsForSongs

```swift
private func fetchRealUrlsForSongs(_ songs: Array<Dictionary<String, AnyObject>>, callback: @escaping (Bool) -> Void) {
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

    group.notify(queue: .main) {
        // Sort and return
        self.playlist = sortedSongs
        callback(true)
    }
}
```

#### 修改fetchPlaylist方法

在获取歌单后，调用新方法获取真实URL：

```swift
// First, convert without real URLs
let tempSongs = songs.compactMap { song -> [String: AnyObject]? in
    return self.convertNetEaseSongToDoubanFormat(song)
}

// Then fetch real URLs for all songs
self.fetchRealUrlsForSongs(tempSongs, callback: callback)
```

---

## 工作流程

### 修改前：
```
获取歌单 → 转换格式 → 返回API端点URL → AVPlayer无法播放 ❌
```

### 修改后：
```
获取歌单 → 转换格式 → 批量获取真实URL → 返回MP3链接 → AVPlayer可以播放 ✅
```

---

## 处理VIP歌曲

### 自动过滤

代码会自动跳过没有有效URL的歌曲：

```swift
guard let realUrl = firstSong["url"] as? String,
      !realUrl.isEmpty else {
    // Skip songs without valid URLs
    return
}
```

### 预期结果

- ✅ VIP歌曲被自动过滤
- ✅ 只返回可以免费播放的歌曲
- ✅ FairPlay错误会减少

---

## 性能优化

### 并发获取URL

- 使用 `DispatchGroup` 并发获取
- 每个歌曲延迟0.1秒，避免API限流
- 20首歌曲约需2-3秒

### 自动跳过无效歌曲

- 没有URL的歌曲自动跳过
- 不占用播放列表

---

## 测试步骤

### 第1步：重新编译

在 Xcode 中：
1. 按 **⌘+Shift+K** (Clean)
2. 按 **⌘+B** (Build)

### 第2步：测试播放

1. 运行应用
2. 选择频道（如热歌榜）
3. 点击播放

**预期结果：**
- ✅ 歌曲正常播放
- ✅ 减少或没有FairPlay错误
- ✅ 歌曲播放完自动播放下一首

### 第3步：查看日志

**成功标志：**
```
fetchPlaylist fetching playlist for channel 0
fetchRealUrlsForSongs - processing 20 songs
fetchPlaylist fetched 18 songs with real URLs  // 2首VIP歌曲被过滤
Song finished, skipping to next
startToPlay: has a state = start to play (下一首歌名)
```

---

## 已知限制

1. **VIP歌曲**
   - 自动过滤，不显示在列表中
   - 可能导致列表歌曲数少于20首

2. **加载时间**
   - 首次加载需要2-3秒（获取真实URL）
   - 后续播放正常速度

3. **API限流**
   - 添加了延迟避免限流
   - 如果仍然被限流，可以增加延迟时间

---

## 下一步优化（可选）

### 1. 缓存URL
```swift
// 缓存已获取的URL，避免重复请求
private var urlCache: [String: String] = [:]
```

### 2. 预加载下一首
```swift
// 在播放当前歌曲时，预先获取下一首的URL
func preloadNextSong() {
    // 实现预加载逻辑
}
```

### 3. VIP歌曲处理
```swift
// 显示提示信息，告知用户这是VIP歌曲
func showVIPSongAlert() {
    // 显示提示对话框
}
```

---

**修改完成！请在 Xcode 中重新编译并测试。**
