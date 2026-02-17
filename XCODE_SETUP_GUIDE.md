# 在 Xcode 中添加新文件 - 快速指南

## 需要添加的文件

1. **DMLocalMusicFetcher.swift** - 本地歌单管理器（必需）

## 步骤（1分钟完成）

### 方法1：在 Xcode 中添加（推荐）

1. 打开 Xcode：
   ```bash
   open diumoo.xcworkspace
   ```

2. 在左侧项目导航器中：
   - 找到 `diumoo` → `core` 文件夹
   - 右键点击 `core` 文件夹
   - 选择 **"Add Files to diumoo..."**

3. 在文件选择器中：
   - 导航到 `/Users/lei/Documents/diumoo/diumoo/core/`
   - 选择 **DMLocalMusicFetcher.swift**
   - ✅ 勾选 "Copy items if needed"
   - ✅ 勾选 "Create groups"
   - ✅ 确保 Target 选中 **"diumoo"**
   - 点击 **"Add"**

4. 构建：
   - 按 **⌘+Shift+K** (Clean Build Folder)
   - 按 **⌘+B** (Build)

### 方法2：命令行添加

```bash
# 备份项目文件
cp diumoo.xcodeproj/project.pbxproj diumoo.xcodeproj/project.pbxproj.backup

# 使用 xcode-edit (如果已安装)
# 或者直接在 Xcode 中添加（方法1更安全）
```

## 预期结果

✅ **成功：**
- 构建无错误
- 可以运行应用
- 播放测试音乐

⚠️ **可能的警告（可忽略）：**
- LSP 在编辑器中显示类型错误（正常，完整构建时会解决）
- 关于 DMPlayableItem 的警告（正常）

❌ **如果失败：**
1. 确保选择了正确的 Target (diumoo)
2. 确保文件添加到 core 组
3. Clean Build Folder 后重新构建
4. 检查控制台输出的具体错误信息

## 验证构建

构建成功后，控制台应该显示：
```
** BUILD SUCCEEDED **
```

如果有错误，复制完整的错误信息。
