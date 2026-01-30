# 📋 Linux-Clipboard | AI-Powered Clipboard Manager

[English](README_en.md) | [简体中文](README.md)

---

## 🌍 Features Overview

![Version](https://img.shields.io/badge/version-v0.4.4-blue.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Electron](https://img.shields.io/badge/Electron-33.4.11-9feaf9.svg)
![React](https://img.shields.io/badge/React-19.2.3-61dafb.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8.2-3178c6.svg)

A sophisticated AI-powered clipboard manager for Linux with system tray support. Built with Electron, React, and Google Gemini AI, it enables seamless searching, indexing, and categorization of both text and image content.

### ✨ Key Features

#### 🎯 Core Functionality
- **🔍 AI-Powered Search**: Search through clipboard history using natural language. AI understands image content and text context.
- **🖼️ Image Recognition**: Automatically describe and tag images using Gemini 3 Flash Preview
- **🏷️ Intelligent Tagging**: Auto-generate keywords for code snippets, links, and long-form text
- **📂 Smart Filters**: Instantly filter by content type: Text, Code, Links, or Images
- **⭐ Favorites**: Star important snippets for quick access
- **🚀 Quick Copy**: One-click recovery of previous clipboard items

#### 🖥️ Desktop Integration
- **🔔 System Tray**: Minimize to system tray, runs in background
- **⌨️ Global Shortcuts**: `Ctrl+Shift+V` to toggle window visibility
- **🔒 Secure Storage**: Encrypted storage for API keys using AES-256-GCM
- **⚙️ Settings Panel:**
  - Toggle auto-start on boot
  - Configure API keys
  - Customize clipboard behavior

#### 🛠️ Developer Features
- **Hot Module Replacement**: Fast development with Vite HMR
- **Type Safety**: Full TypeScript support
- **Modern UI**: Glassmorphism design with Tailwind CSS
- **Auto-updates**: Built-in update mechanism

### 🏗️ Architecture

```
linux-clipboard/
├── electron/              # Electron main process
│   ├── main.ts           # Application entry point
│   ├── preload.ts        # Preload script (IPC bridge)
│   ├── clipboard-manager.ts    # Clipboard monitoring
│   ├── tray-manager.ts         # System tray integration
│   ├── shortcuts-manager.ts    # Global shortcuts
│   └── store/            # Configuration & secure storage
│       ├── config-store.ts
│       └── secure-store.ts
├── src/                  # React frontend
│   ├── App.tsx           # Main application component
│   ├── components/       # React components
│   └── services/         # API services
├── scripts/              # Build & automation scripts
└── docs/                 # Documentation
```

### 🛠️ Tech Stack

#### Frontend
- **Framework**: React 19.2.3
- **Language**: TypeScript 5.8.2
- **Styling**: Tailwind CSS (Glassmorphism)
- **Icons**: Lucide React 0.562.0
- **Build Tool**: Vite 6.2.0

#### Backend (Electron Main)
- **Runtime**: Electron 33.4.11
- **Storage**: electron-store 8.2.0
- **Security**: crypto (Node.js built-in)

#### AI Services
- **Provider**: Google Gemini AI
- **SDK**: @google/genai 1.34.0
- **Model**: Gemini 3 Flash Preview

### 📦 Installation

#### From .deb Package (Recommended for Ubuntu/Debian)

```bash
# Download the latest release
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v0.4.4/linux-clipboard_0.4.4_amd64.deb

# Install
sudo dpkg -i linux-clipboard_0.4.4_amd64.deb

# Run
linux-clipboard
```

#### From Source

```bash
# Clone repository
git clone https://github.com/Li-zhienxuan/Linux-Clipboard.git
cd Linux-Clipboard

# Install dependencies
npm install

# Run in development mode
npm run electron:dev

# Build for production
npm run electron:build:deb
```

### 🚀 Usage

1. **First Launch**:
   - Open the application
   - Configure your Google Gemini API Key in settings
   - Grant necessary permissions

2. **Clipboard Monitoring**:
   - Copy text or images (Ctrl+C)
   - Content is automatically captured and indexed
   - AI generates tags and descriptions

3. **Search & Retrieve**:
   - Press `Ctrl+Shift+V` or click tray icon
   - Type in the search bar
   - Click item to copy back to clipboard

4. **Manage History**:
   - ⭐ Star important items
   - 🗑️ Delete unwanted entries
   - 📂 Filter by type or time

### 📚 Documentation

Detailed documentation available in [docs/](docs/):

| Document | Description |
|----------|-------------|
| [INDEX.md](docs/INDEX.md) | Complete documentation index |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | Development guide |
| [cnb-cloud-build-guide.md](docs/cnb-cloud-build-guide.md) | CNB cloud native build guide |
| [Build.md](docs/Build.md) | Build history and records |
| [Repair.md](docs/Repair.md) | Troubleshooting guide |
| [AUTO_RELEASE_GUIDE.md](docs/AUTO_RELEASE_GUIDE.md) | Release automation |
| [CLAUDE.md](docs/CLAUDE.md) | Claude Code project guide |

### 🔧 Development

```bash
# Development server (React only)
npm run dev

# Electron development mode
npm run electron:dev

# Production build
npm run build

# Build .deb package
npm run electron:build:deb

# Preview production build
npm run preview
```

### 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### 📄 License

MIT License - see LICENSE file for details

---

## 📊 Project Status

- **Current Version**: v0.4.4
- **Latest Release**: [GitHub Releases](https://github.com/Li-zhienxuan/Linux-Clipboard/releases)
- **Issue Tracker**: [GitHub Issues](https://github.com/Li-zhienxuan/Linux-Clipboard/issues)
- **Changelog**: [Build.md](docs/Build.md)

## 🔗 Related Links

- **GitHub**: https://github.com/Li-zhienxuan/Linux-Clipboard
- **CNB**: https://cnb.cool/ZhienXuan/Linux-Clipboard
- **Issues**: https://github.com/Li-zhienxuan/Linux-Clipboard/issues

---

*Developed with ❤️ by Linux-Clipboard Team*
*Built with Electron, React, and Google Gemini AI*
