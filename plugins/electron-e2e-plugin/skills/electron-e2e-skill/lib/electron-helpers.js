/**
 * Electron E2E Helpers
 * Core utilities for launching and testing Electron applications
 */

const { _electron: electron } = require('playwright');
const path = require('path');

/**
 * Default app path for multi-ai-app
 */
const DEFAULT_APP_PATH = '/Users/mikko/code/multi-ai-app';

/**
 * Get the Electron executable path based on platform
 */
function getElectronPath(appPath) {
  const electronPath = path.join(appPath, 'node_modules/electron/dist');

  if (process.platform === 'darwin') {
    return path.join(electronPath, 'Electron.app/Contents/MacOS/Electron');
  } else if (process.platform === 'win32') {
    return path.join(electronPath, 'electron.exe');
  }
  return path.join(electronPath, 'electron');
}

/**
 * Launch Electron app with test configuration
 * @param {Object} options - Launch options
 * @param {string} options.cwd - Working directory (app path)
 * @param {string} options.executablePath - Custom electron executable path
 * @param {Object} options.env - Additional environment variables
 * @param {number} options.timeout - Launch timeout in ms (default: 30000)
 * @param {boolean} options.recordVideo - Record video to /tmp/e2e-videos
 * @returns {Promise<ElectronApplication>}
 */
async function launchApp(options = {}) {
  const appPath = options.cwd || DEFAULT_APP_PATH;

  const launchOptions = {
    executablePath: options.executablePath || getElectronPath(appPath),
    args: ['.'],
    cwd: appPath,
    env: {
      ...process.env,
      NODE_ENV: 'test',
      ELECTRON_IS_E2E_TEST: '1',
      ...options.env
    },
    timeout: options.timeout || 30000
  };

  if (options.recordVideo) {
    launchOptions.recordVideo = {
      dir: '/tmp/e2e-videos',
      size: { width: 1280, height: 720 }
    };
  }

  console.log(`Launching Electron app from: ${appPath}`);
  const app = await electron.launch(launchOptions);
  console.log('Electron app launched successfully');

  return app;
}

/**
 * Wait for app to be fully ready (window loaded + React hydrated)
 * @param {ElectronApplication} app - Electron application
 * @param {Object} options - Wait options
 * @param {number} options.timeout - Max wait time in ms
 * @param {string} options.readySelector - Selector to wait for (optional)
 * @returns {Promise<Page>}
 */
async function waitForAppReady(app, options = {}) {
  const timeout = options.timeout || 15000;

  // Get the first window
  console.log('Waiting for main window...');
  const page = await app.firstWindow();

  // Wait for load state
  await page.waitForLoadState('domcontentloaded', { timeout });

  // Wait for React to hydrate - look for main app container
  try {
    await page.waitForSelector('.flex.h-screen', { timeout: timeout / 2 });
    console.log('App UI loaded');
  } catch (e) {
    // Fallback: just wait a bit for React
    console.log('Waiting for React to initialize...');
    await page.waitForTimeout(2000);
  }

  // If custom ready selector provided, wait for it
  if (options.readySelector) {
    await page.waitForSelector(options.readySelector, { timeout });
  }

  console.log('App is ready');
  return page;
}

/**
 * Evaluate code in the Electron main process
 * @param {ElectronApplication} app - Electron application
 * @param {Function} fn - Function to evaluate
 * @param {...any} args - Arguments to pass to function
 * @returns {Promise<any>}
 */
async function evaluateMain(app, fn, ...args) {
  return app.evaluate(fn, ...args);
}

/**
 * Get all windows in the Electron app
 * @param {ElectronApplication} app - Electron application
 * @returns {Promise<Page[]>}
 */
async function getAllWindows(app) {
  return app.windows();
}

/**
 * Take a timestamped screenshot
 * @param {Page} page - Playwright page
 * @param {string} name - Screenshot name (without extension)
 * @param {Object} options - Screenshot options
 * @returns {Promise<string>} Path to saved screenshot
 */
async function screenshot(page, name, options = {}) {
  const timestamp = Date.now();
  const filename = `/tmp/e2e-${name}-${timestamp}.png`;

  await page.screenshot({
    path: filename,
    fullPage: options.fullPage !== false,
    ...options
  });

  console.log(`Screenshot saved: ${filename}`);
  return filename;
}

/**
 * Clean shutdown of the Electron app
 * @param {ElectronApplication} app - Electron application
 */
async function closeApp(app) {
  console.log('Closing Electron app...');
  await app.close();
  console.log('App closed');
}

/**
 * Check if the app is packaged (production) or development
 * @param {ElectronApplication} app - Electron application
 * @returns {Promise<boolean>}
 */
async function isPackaged(app) {
  return app.evaluate(async ({ app }) => app.isPackaged);
}

/**
 * Get app version from main process
 * @param {ElectronApplication} app - Electron application
 * @returns {Promise<string>}
 */
async function getAppVersion(app) {
  return app.evaluate(async ({ app }) => app.getVersion());
}

/**
 * Set window size
 * @param {Page} page - Playwright page
 * @param {number} width - Window width
 * @param {number} height - Window height
 */
async function setWindowSize(page, width, height) {
  await page.setViewportSize({ width, height });
}

module.exports = {
  DEFAULT_APP_PATH,
  getElectronPath,
  launchApp,
  waitForAppReady,
  evaluateMain,
  getAllWindows,
  screenshot,
  closeApp,
  isPackaged,
  getAppVersion,
  setWindowSize
};
