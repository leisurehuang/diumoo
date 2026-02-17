# Contributing to Diumoo

First off, thank you for considering contributing to Diumoo! It's people like you that make Diumoo such a great tool.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Description**: A clear and concise description of the problem
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Screenshots**: If applicable, add screenshots
- **Environment**:
  - macOS version
  - Diumoo version
  - Xcode version (if building from source)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When suggesting a feature:

- Use a clear and descriptive title
- Provide a detailed description of the suggested enhancement
- Explain why this enhancement would be useful

### Pull Requests

1. **Fork the repository** and create your branch from `master`
2. **Make your changes** with clear commit messages
3. **Test thoroughly** on multiple macOS versions if possible
4. **Update documentation** if you've changed functionality
5. **Submit a pull request** with a description of your changes

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/diumoo.git
   cd diumoo
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the workspace:
   ```bash
   open diumoo.xcworkspace
   ```

4. Build the project:
   - Select the `diumoo` scheme
   - Press `⌘B` to build

## Coding Standards

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Prefer `let` over `var` when possible
- Use meaningful variable and function names

### Objective-C Style

- Follow [Cocoa Coding Guidelines](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
- Use 4 spaces for indentation
- Prefix class names with `DM`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
feat: add NetEase Cloud Music integration
fix: resolve media key handling issue
docs: update README with new features
refactor: simplify channel list loading logic
test: add unit tests for playlist fetcher
chore: update CocoaPods dependencies
```

## Project Structure

Understanding the project structure will help you navigate the codebase:

```
diumoo/
├── diumoo/
│   ├── core/              # Core business logic
│   ├── ui/                # User interface components
│   └── Assets.xcassets/   # Image resources
├── resources/             # Additional resources
└── third-party/           # Local dependencies
```

## Testing

Before submitting a PR, ensure:

- [ ] Code builds without warnings
- [ ] App launches successfully on macOS 10.12+
- [ ] New features are tested
- [ ] Documentation is updated
- [ ] Commit messages follow conventions

## Questions?

Feel free to open an issue with the `question` label, and we'll do our best to help!

---

**Happy Contributing!** 🎉
