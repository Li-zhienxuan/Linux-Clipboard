import { execSync } from 'child_process';
import { existsSync, mkdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function build() {
  console.log('Building Electron with TypeScript...');

  try {
    // Ensure dist-electron directory exists
    const outDir = 'dist-electron';
    if (!existsSync(outDir)) {
      mkdirSync(outDir, { recursive: true });
    }

    // Compile TypeScript
    execSync('npx tsc -p tsconfig.electron.json', {
      stdio: 'inherit',
      cwd: __dirname
    });

    console.log('✓ Electron build completed');
  } catch (error) {
    console.error('✗ Build failed:', error.message);
    process.exit(1);
  }
}

build();
