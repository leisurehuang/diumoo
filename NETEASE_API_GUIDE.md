# 网易云音乐API集成 - 完整指南

## ✅ 已完成配置

### 1. API服务器状态

**服务器位置**: `/Users/lei/Documents/diumoo/api-enhanced`
**运行端口**: `http://localhost:3000`
**状态**: ✅ 已安装并运行中

### 2. 测试API

```bash
# 搜索歌曲
curl "http://localhost:3000/search?keywords=周杰伦"

# 获取歌单
curl "http://localhost:3000/playlist/track/all?id=3778678"

# 获取歌曲播放链接
curl "http://localhost:3000/song/url?id=347230"
```

### 3. 可用频道

| 频道ID | 名称 | 歌单ID | 说明 |
|--------|------|--------|------|
| 0 | 热歌榜 | 3778678 | 热门歌曲 |
| 1 | 新歌榜 | 3779629 | 最新歌曲 |
| 2 | 飙升榜 | 19723756 | 快速上升 |
| 3 | 华语金曲 | 2884035 | 华语经典 |

---

## 📋 在Xcode中添加文件

### 需要添加的文件：
1. `DMNetEaseMusicFetcher.swift` - 网易云音乐API客户端

### 步骤：

1. **打开Xcode项目**
   ```bash
   open /Users/lei/Documents/diumoo/diumoo.xcworkspace
   ```

2. **添加新文件**
   - 在左侧项目导航器中，右键点击 `core` 文件夹
   - 选择 "Add Files to diumoo..."
   - 选择 `DMNetEaseMusicFetcher.swift`
   - ✅ 勾选 "Copy items if needed"
   - ✅ 确保 Target 选中 "diumoo"
   - 点击 "Add"

3. **构建项目**
   - 按 **⌘+Shift+K** (Clean)
   - 按 **⌘+B** (Build)

---

## 🚀 启动API服务器

### 方法1：使用启动脚本（推荐）

```bash
cd /Users/lei/Documents/diumoo
./start_netease_api.sh
```

### 方法2：手动启动

```bash
cd /Users/lei/Documents/diumoo/api-enhanced
node app.js
```

### 检查服务器状态

```bash
curl "http://localhost:3000/search?keywords=测试"
```

如果返回JSON数据，说明服务器运行正常。

---

## 🎵 使用网易云音乐

### 启动顺序

1. **启动API服务器**（首次使用或重启后）
   ```bash
   cd /Users/lei/Documents/diumoo
   ./start_netease_api.sh
   ```

2. **打开Xcode并运行应用**
   - 打开 `diumoo.xcworkspace`
   - 点击运行按钮 (⌘+R)

3. **切换频道**（在应用中）
   - 频道0: 热歌榜
   - 频道1: 新歌榜
   - 频道2: 飙升榜
   - 频道3: 华语金曲

### 预期结果

✅ **成功标志：**
- 应用正常启动
- 可以播放歌曲
- 歌曲信息显示正确（标题、歌手、专辑）
- 切换频道加载不同歌曲

⚠️ **如果失败：**
1. 检查API服务器是否运行：`curl http://localhost:3000`
2. 查看控制台错误日志
3. 确认文件已添加到Xcode项目

---

## 🔧 API配置

### 修改服务器端口（如果需要）

编辑 `api-enhanced/server.js`，找到端口配置：
```javascript
const port = options.port || process.env.PORT || '3000'
```

修改后重启服务器。

### 添加更多频道

编辑 `DMNetEaseMusicFetcher.swift`，在 `popularPlaylists` 数组中添加：

```swift
[
    "channel_id": "4" as AnyObject,
    "name": "你的频道名" as AnyObject,
    "name_en": "Your Channel" as AnyObject,
    "playlist_id": "歌单ID" as AnyObject,
    "cover": "封面图片URL" as AnyObject
]
```

获取歌单ID：访问网易云音乐网页版，找到歌单，从URL中提取ID。

---

## 📚 API文档

### 主要端点

| 端点 | 参数 | 说明 |
|------|------|------|
| `/search` | `keywords=关键词` | 搜索歌曲 |
| `/playlist/track/all` | `id=歌单ID` | 获取歌单歌曲 |
| `/song/url` | `id=歌曲ID` | 获取播放链接 |
| `/song/detail` | `ids=歌曲ID` | 获取歌曲详情 |
| `/artist/songs` | `id=歌手ID` | 获取歌手歌曲 |

完整文档：访问 `http://localhost:3000` 在浏览器中查看

---

## ❓ 常见问题

### Q: 提示"无法连接到服务器"

**A:** API服务器未启动
```bash
# 检查服务器是否运行
ps aux | grep "node app.js"

# 如果没有运行，启动它
cd /Users/lei/Documents/diumoo/api-enhanced
node app.js
```

### Q: 歌曲无法播放

**A:** 可能原因：
1. 网络问题 - 检查网络连接
2. 歌曲需要VIP - 部分歌曲需要网易云音乐VIP
3. 地区限制 - 某些歌曲有地区限制

### Q: 服务器端口冲突

**A:** 端口3000被占用
```bash
# 查找占用进程
lsof -i :3000

# 停止旧进程
kill -9 <进程ID>

# 或修改配置使用其他端口
```

### Q: 每次都要手动启动API服务器吗？

**A:** 是的，每次重启电脑后需要：
1. 启动API服务器：`./start_netease_api.sh`
2. 打开diumoo应用

如需自动启动，可以配置LaunchAgent（macOS自动启动服务）。

---

## 📝 技术细节

### API架构

```
Diumoo App (macOS)
    ↓
DMNetEaseMusicFetcher (Swift)
    ↓ HTTP请求
NetEase API Server (Node.js) localhost:3000
    ↓ 加密/解密
网易云音乐官方API
    ↓
返回歌曲数据 (JSON)
```

### 数据流

1. 用户选择频道（如"热歌榜"）
2. `DMNetEaseMusicFetcher` 请求歌单ID `3778678`
3. API服务器返回歌曲列表（JSON）
4. 转换为Douban格式（兼容现有代码）
5. 应用播放歌曲

---

## 🎉 完成！

现在你的Diumoo应用已经集成了网易云音乐API！

**优势：**
- ✅ 海量正版音乐
- ✅ 实时更新的榜单
- ✅ 无需手动添加歌曲
- ✅ 支持多个频道

**下一步：**
- 在Xcode中添加 `DMNetEaseMusicFetcher.swift`
- 启动API服务器
- 运行应用并享受音乐！
