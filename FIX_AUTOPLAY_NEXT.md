# 修复自动播放下一首功能

## 问题描述

歌曲播放完成后不会自动播放下一首。

## 原因分析

原代码试图通过监听 `AVPlayer` 的 `rate` 属性变化来检测歌曲是否结束：

```objc
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ((self.playingItem.floatDuration > 5) && (self.playingItem.floatDuration - [self.currentTime]) < 1) {
            [self playableItemDidEnd:musicPlayer.currentItem];
        }
    }
}
```

**问题：**
- `observeValueForKeyPath` 只在 rate 变化时被调用
- 歌曲播放到结尾时，rate 可能不变，导致检测失效
- 依赖时间判断不够可靠

## 解决方案

添加 `AVPlayerItemDidPlayToEndTimeNotification` 通知监听，这是iOS/macOS推荐的方式来检测媒体播放完成。

## 修改内容

### 文件：`diumoo/core/DMControlCenter/DMControlCenter.m`

#### 1. 在 `init` 方法中添加通知监听器（第73-82行）

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(playSpecialNotification:)
                                             name:@"playspecial"
                                           object:nil];

// 新增：监听播放完成通知
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(itemDidFinishPlaying:)
                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                           object:nil];
```

#### 2. 添加播放完成处理方法（第230行之后）

```objc
- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *item = (AVPlayerItem *)notification.object;
    if (item == self.playingItem) {
        NSLog(@"Song finished, skipping to next");
        [self skip];
    }
}
```

## 工作原理

1. **AVPlayerItemDidPlayToEndTimeNotification**
   - 系统自动在媒体播放完成时发送此通知
   - 比手动检测更可靠
   - 是Apple推荐的做法

2. **自动播放流程**
   ```
   歌曲播放完成
   ↓
   系统发送 AVPlayerItemDidPlayToEndTimeNotification
   ↓
   itemDidFinishPlaying: 被调用
   ↓
   调用 skip 方法
   ↓
   获取下一首歌曲
   ↓
   自动播放
   ```

3. **skip 方法**（已存在）
   - 从 playlist fetcher 获取下一首歌曲
   - 调用 startToPlay: 播放新歌曲
   - 如果列表为空，会自动获取新歌曲

## 测试步骤

1. **重新编译应用**
   - 在 Xcode 中按 ⌘+B 编译
   - 或 ⌘+Shift+K 清理后重新编译

2. **测试自动播放**
   - 播放一首歌曲
   - 等待歌曲播放完成
   - 应该自动播放下一首

3. **查看日志**
   控制台应该显示：
   ```
   Song finished, skipping to next
   fetchPlaylist fetching playlist for channel X
   startToPlay: has a state = start to play (新歌曲名)
   ```

## 兼容性

- ✅ macOS 10.10+
- ✅ AVPlayer framework
- ✅ Objective-C
- ✅ 向后兼容现有代码

## 预期效果

修复后：
- ✅ 歌曲播放完成自动播放下一首
- ✅ 列表循环播放
- ✅ 列表播放完后自动获取新歌曲
- ✅ 控制台日志显示清晰

## 注意事项

1. **VIP歌曲处理**
   - 如果遇到无法播放的VIP歌曲，会自动跳过
   - FairPlay DRM错误可以忽略

2. **网络问题**
   - 如果网络中断，会尝试重试
   - 失败3次后会停止播放

3. **列表为空**
   - 如果所有歌曲播放完，会自动从API获取新歌曲
   - 不会中断播放体验

## 相关文件

- `DMControlCenter.m` - 播放器控制中心（已修改）
- `DMPlaylistFetcher.swift` - 歌曲列表管理（已使用网易云音乐API）
- `DMNetEaseMusicFetcher.swift` - 网易云音乐API客户端

---

**修改完成！请在 Xcode 中重新编译并测试。**
