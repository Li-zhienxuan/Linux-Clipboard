# CODEBUDDY.md

This file provides guidance to CodeBuddy Code when working with code in this repository.

## Project Overview

**Linux-Clipboard** is an AI-powered clipboard manager built with React 19, TypeScript, and Electron. It features Google Gemini AI for image recognition and intelligent search, with a Spotlight-style glassmorphism UI.

## Common Commands

```bash
# Development
npm run dev                    # Start Vite dev server (localhost:5173)
npm run electron:dev           # Run Electron in development mode

# Building
npm run build                  # Build React frontend + Electron main/preload
npm run electron:build         # Build all Electron targets
npm run electron:build:deb     # Build Linux .deb package only

# Preview
npm run preview               # Preview production build locally
```

## Building and Packaging

### Development Build
The project uses Vite for both frontend and Electron main process:
- Frontend: `vite build` → `dist/`
- Electron main: compiled via vite → `dist-electron/main.js`
- Electron preload: compiled via vite → `dist-electron/preload.js`

### Production Packaging
Uses electron-builder configured in `electron-builder.json`:
- Output directory: `release/`
- Supported formats: `.deb`, AppImage
- Package name: `linux-clipboard_<version>_amd64.deb`
- Install location: `/opt/Linux-Clipboard/`

### Important: Environment Detection
**CRITICAL**: Always use `app.isPackaged` to detect production vs development mode, NOT `process.env.NODE_ENV`:

```typescript
// ✅ CORRECT
const isDev = !app.isPackaged;

// ❌ WRONG - will fail in production
const isDev = process.env.NODE_ENV !== 'production';
```

This is because `NODE_ENV` is not reliably set during electron-builder packaging.

## Architecture

### Directory Structure
```
Linux-Clipboard/
├── electron/                      # Electron main process
│   ├── main.ts                   # Main entry point
│   ├── preload.ts                # Preload script (IPC bridge)
│   ├── clipboard-manager.ts      # Clipboard polling service
│   ├── tray-manager.ts           # System tray integration
│   ├── shortcuts-manager.ts      # Global keyboard shortcuts
│   └── store/
│       └── config-store.ts       # Persistent settings (electron-store)
├── src/                          # React frontend
│   ├── App.tsx                   # Main React app
│   ├── index.tsx                 # React entry point
│   ├── components/
│   │   └── ClipboardCard.tsx    # Clipboard item card component
│   └── services/
│       └── geminiService.ts      # Gemini AI integration
├── resources/                    # Static resources
│   └── icons/                    # Application icons
├── dist/                         # Frontend build output
├── dist-electron/                # Electron build output
└── release/                      # Final packaged applications
```

### Key Components

**Electron Main Process** (`electron/main.ts`):
- Window management with tray minimization
- IPC handlers for clipboard, settings, API keys
- Initializes clipboard manager, tray, and shortcuts
- Auto-start support via `app.setLoginItemSettings()`

**Clipboard Manager** (`electron/clipboard-manager.ts`):
- Polls system clipboard every 1 second
- Detects text and images
- Sends new content to renderer via IPC
- Handles image → base64 conversion

**Tray Manager** (`electron/tray-manager.ts`):
- Creates system tray icon (uses `process.resourcesPath` in production)
- Context menu: Show/Hide, Settings, Quit
- Double-click to show window

**Shortcuts Manager** (`electron/shortcuts-manager.ts`):
- Registers global shortcuts (default: `Ctrl+Shift+V`)
- Toggle window visibility

**Config Store** (`electron/store/config-store.ts`):
- Uses electron-store for persistent settings
- Stores: Gemini API key, auto-start, shortcuts
- Location: `~/.config/linux-clipboard/config.json`

### Frontend Architecture

**Single-file state management** in `App.tsx` using React Hooks:
- `useState` for clipboard items, filters, search
- `useEffect` for clipboard monitoring, localStorage persistence
- IPC communication via window.electron (exposed by preload)

**ClipboardCard** (`components/ClipboardCard.tsx`):
- Displays individual clipboard items
- Type indicators (text/code/link/image)
- Actions: copy, star, delete
- AI-generated tags display

**Gemini Service** (`services/geminiService.ts`):
- `analyzeImage()`: Describes images and generates tags
- `suggestTags()`: Generates smart tags for text/code/links
- Uses `@google/genai` SDK with Gemini 3 Flash Preview

### Resource Paths in Production

**Critical path resolution**:
```typescript
// Icons for tray (production)
const iconPath = path.join(process.resourcesPath, 'icons/icon.png');

// HTML file (production)
const htmlPath = path.join(dirname(app.getAppPath()), 'dist', 'index.html');
```

electron-builder places resources in:
- Packaged app: `/opt/Linux-Clipboard/resources/`
- process.resourcesPath points to this directory

## Environment Variables

Required for Gemini AI features:
- **API Key**: Stored via IPC in electron-store
- Get key from: https://aistudio.google.com/
- Accessed in renderer via: `window.electron.getApiKey()`

## Common Development Tasks

### Testing Production Build Locally
```bash
npm run build
npm run electron:build
sudo dpkg -i release/linux-clipboard_*.deb
/opt/Linux-Clipboard/linux-clipboard
```

### Debugging Electron Main Process
Check logs:
```bash
# Run from command line to see console output
/opt/Linux-Clipboard/linux-clipboard

# Or check stderr
/opt/Linux-Clipboard/linux-clipboard 2>&1 | tee debug.log
```

### Fixing Icon Issues
If tray icon is empty:
1. Verify `resources/icons/icon.png` exists
2. Check electron-builder copies it: `electron-builder.json` → `buildResources`
3. Ensure production path uses `process.resourcesPath`

### Fixing "Failed to load URL: localhost:5173"
This means `app.isPackaged` is returning false in production:
1. Verify you're using `!app.isPackaged`, not `NODE_ENV` check
2. Rebuild: `npm run build && npm run electron:build:deb`
3. Reinstall the new .deb package

## Security

### API Key Storage

**Critical**: The Gemini API Key is stored securely using encryption.

**Implementation** (`electron/store/secure-store.ts`):
- **Encryption**: AES-256-GCM encryption
- **Key Derivation**: Machine-specific key using scrypt
- **File Permissions**: 600 (read/write for owner only)
- **Storage Location**: `~/.config/linux-clipboard/linux-clipboard-secure.json`

**Security Features**:
1. **Encrypted at Rest**: API Key is encrypted before writing to disk
2. **Machine-Bound**: Encryption key derived from machine ID (hostname + username + platform)
3. **Secure Permissions**: Config file automatically set to 600 permissions
4. **Authenticated Encryption**: Uses GCM mode for integrity verification

**Migration from v0.2.0**:
If upgrading from v0.2.0 where API Key was stored in plaintext:
```bash
# Remove old config (API Key will need to be re-entered)
rm ~/.config/linux-clipboard/linux-clipboard-config.json
```

**Verification**:
```bash
# Check file permissions (should be 600)
ls -la ~/.config/linux-clipboard/

# Check encrypted content (API Key should not be readable)
cat ~/.config/linux-clipboard/linux-clipboard-secure.json
```

## Known Issues and Solutions

### Issue: App crashes with "GPU process isn't usable" after installing .deb
**Cause**: The app tried to connect to localhost:5173 instead of loading the packaged files.

**Solution**: Fixed by changing environment detection from `process.env.NODE_ENV !== 'production'` to `!app.isPackaged` in:
- `electron/main.ts:9`
- `electron/tray-manager.ts:16`

### Issue: Tray icon shows as empty
**Cause**: Incorrect path resolution for `icon.png` in production.

**Solution**: Use `process.resourcesPath` directly (not `|| app.getAppPath()`) in production builds.

## Type Definitions

Core types defined in `types.ts`:
- `ContentType`: 'text' | 'image' | 'link' | 'code'
- `TimeMode`: 'all' | 'year' | 'month' | 'week'
- `ClipboardItem`: id, type, content, description, timestamp, tags, isFavorite
- `AppState`: Application state interface

## IPC Communication

Exposed in `electron/preload.ts` as `window.electron`:
- `clipboard.read()`: Read current clipboard
- `app.toggle()`: Show/hide window
- `app.minimize()`: Hide to tray
- `settings.get()`: Get all settings
- `settings.set(key, value)`: Update setting
- `getApiKey()`: Get Gemini API key
- `setApiKey(key)`: Save Gemini API key

## Tech Stack Versions

- React: 19.2.3
- TypeScript: 5.8.2
- Electron: 33.4.11
- Vite: 6.2.0
- electron-builder: 25.1.8
- @google/genai: 1.34.0
- Tailwind CSS: via CDN (see index.html)
