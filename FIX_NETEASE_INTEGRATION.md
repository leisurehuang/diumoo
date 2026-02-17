# 🔧 修复NetEase集成问题的步骤

## 问题诊断

如果您运行app后仍然使用Douban FM而不是NetEase，请按照以下步骤操作：

---

## 步骤1: 确认文件已添加到Xcode项目

### 检查方法：

1. 在Xcode中打开项目：
   ```bash
   open diumoo.xcworkspace
   ```

2. 在左侧项目导航器中，检查以下文件是否存在并已添加到 **diumoo target**：
   - ✅ `diumoo/core/DMNetEaseAPIClient.swift`
   - ✅ `diumoo/core/DMPlaylistFetcher.swift` (已修改)

3. 如果文件显示为**红色**（缺失），需要添加到项目：
   - 右键点击 `core` 文件夹
   - 选择 "Add Files to diumoo..."
   - 选择 `DMNetEaseAPIClient.swift`
   - **重要**: 确保勾选 "Copy items if needed" 和 "diumoo" target

---

## 步骤2: 清理并重新编译

### 方法A: 在Xcode中
```
菜单栏 → Product → Clean Build Folder (Shift+Cmd+K)
然后 Product → Build (Cmd+B)
```

### 方法B: 使用命令行
```bash
# 进入项目目录
cd /Users/lei/Documents/diumoo

# 清理构建
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo clean

# 删除Build文件夹
rm -rf ~/Library/Developer/Xcode/DerivedData/diumoo-*

# 重新构建
xcodebuild -workspace diumoo.xcworkspace -scheme diumoo -configuration Release build
```

---

## 步骤3: 验证编译日志

在Xcode中编译时，查看日志确认：

```
CompileSwift normal x86_64
    Compiling DMNetEaseAPIClient.swift
    Compiling DMPlaylistFetcher.swift
    Compiling DMPlayableItem.swift
```

如果看到 `Compiling DMNetEaseAPIClient.swift`，说明文件已被正确编译。

---

## 步骤4: 检查运行时日志

运行app后，打开Console.app查看日志：

```bash
# 过滤diumoo日志
log stream --predicate 'process == "diumoo"' --level debug
```

或者在Xcode中：
```
运行app后 → 打开Debug Area (Cmd+Shift+Y)
查看console输出
```

**应该看到**:
```
Fetching from NetEase Personal FM: https://music.163.com/api/personal_fm
```

**如果仍然看到**:
```
Fetching from Douban FM: https://douban.fm/j/mine/playlist
```

说明代码没有更新，需要返回步骤1。

---

## 步骤5: 强制使用NetEase的临时方案

如果上述步骤都不行，可以临时修改代码：

### 打开 `DMPlaylistFetcher.swift`，找到第80行左右：

```swift
public func fetchPlaylist(fromChannel channel: String, Type type: String, sid: String?, startAttribute attribute: String?) {
    // 临时强制使用NetEase
    self.fetchNetEasePlaylist(channel: channel, type: type, sid: sid, attribute: attribute)
    return
}
```

注释掉原来的条件判断，直接调用NetEase方法。

---

## 步骤6: 验证网络请求

### 使用Charles Proxy或Wireshark检查：

运行app时，应该看到请求：
```
GET https://music.163.com/api/personal_fm
User-Agent: Mozilla/5.0
Referer: https://music.163.com
```

如果仍然看到：
```
GET https://douban.fm/j/mine/playlist
```

说明确实还在使用Douban API。

---

## 常见问题排查

### Q1: 编译错误 "Cannot find type 'DMNetEaseAPIClient'"

**原因**: `DMNetEaseAPIClient.swift` 没有被添加到项目

**解决**: 返回步骤1，将文件添加到Xcode项目

---

### Q2: 编译成功但运行时崩溃

**原因**: 可能是Swift/Objective-C桥接问题

**解决**: 在 `diumoo-Bridging-Header.h` 中添加：
```objc
#import "DMNetEaseAPIClient-Swift.h"
```

---

### Q3: App启动但无法播放音乐

**原因**: NetEase API返回错误或网络问题

**解决**: 
1. 检查网络连接
2. 查看Console.app中的错误日志
3. 确认可以访问 music.163.com

---

### Q4: 想回退到Douban FM

**解决**: 修改 `DMPlaylistFetcher.swift` 第58行：
```swift
static internal let USE_NETEASE = false  // 改为false
```

---

## 完整重置步骤（如果以上都不行）

```bash
# 1. 完全清理
cd /Users/lei/Documents/diumoo
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf Pods/
rm -rf build/

# 2. 重新安装依赖
pod install

# 3. 打开Xcode
open diumoo.xcworkspace

# 4. 在Xcode中:
#    - 确认所有Swift文件都在项目中
#    - Clean Build Folder (Shift+Cmd+K)
#    - 删除 ~/Library/Developer/Xcode/DerivedData 中的文件夹
#    - 重新编译 (Cmd+B)

# 5. 运行 (Cmd+R)
```

---

## 调试命令

```bash
# 查看app进程
ps aux | grep diumoo

# 查看app的网络连接
lsof -i -P | grep diumoo

# 查看Swift编译的符号
nm build/Release/diumoo.app/Contents/MacOS/diumoo | grep NetEase
```

如果 `nm` 命令输出中有 `DMNetEaseAPIClient`，说明代码已成功编译。

---

## 验证成功的标志

当NetEase集成成功时，您应该看到：

1. ✅ Console日志显示 "Fetching from NetEase Personal FM"
2. ✅ 网络请求发往 `music.163.com`
3. ✅ 音乐开始播放（来自NetEase）
4. ✅ 封面图正常显示

---

## 仍然有问题？

请提供以下信息：

1. Xcode版本
2. macOS版本
3. Console.app中的错误日志
4. 编译是否成功
5. 是否看到 "Compiling DMNetEaseAPIClient.swift"

我会进一步帮您诊断！
