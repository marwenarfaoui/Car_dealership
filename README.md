This is a new [**React Native**](https://reactnative.dev) project, bootstrapped using [`@react-native-community/cli`](https://github.com/react-native-community/cli).

# MonApp - React Native Mobile Application

A complete React Native application with comprehensive testing, CI/CD, and deployment automation.

## 📋 Features

✅ **Complete Test Suite**
- Unit tests with Jest and React Native Testing Library
- E2E tests with Detox
- Android UI tests with Espresso/Gradle
- Code linting with ESLint

✅ **Automated Deployment**
- Fastlane integration for Android builds and deployment
- Google Play Store deployment automation
- Flexible release tracks (internal, alpha, beta, production)

✅ **CI/CD Pipeline**
- GitHub Actions workflow for automated testing
- Automatic builds on push to main/develop
- Conditional deployment on successful tests

✅ **Developer Experience**
- Hot reload development with Metro
- Pre-configured testing environments
- Deployment scripts for local and automated workflows

---

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm
- **Java JDK** 11+
- **Android SDK** (API 30+)
- **Android Emulator** (optional, for testing)
- **Fastlane** (for deployment)

### Installation

```bash
# Clone the repository
cd MonApp

# Install dependencies
npm install

# For macOS/Linux, make scripts executable
chmod +x deploy.sh
```

### Running the App

**Start the Metro bundler:**
```bash
npm start
```

**In a new terminal, run on Android:**
```bash
npm run android
```

---

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:coverage

# Run tests in watch mode
npm test -- --watch
```

### E2E Tests (Detox)

Requires an Android emulator running with AVD name `Pixel_3a_API_30_x86`.

```bash
# Build the test APK
npm run detox:build

# Run E2E tests
npm run detox:test
```

### UI Tests (Gradle)

```bash
cd android
./gradlew testDebugUnitTest
```

---

## 📦 Building

### Debug Build

```bash
npm run android    # Builds and runs on device/emulator
```

### Release Build

```bash
npm run build:release    # Creates android/app/build/outputs/bundle/release/app-release.aab
```

---

## 🚀 Deployment

### Local Deployment

Deploy everything locally (requires Google Play Service Account):

```bash
./deploy.sh
```

This runs:
1. Linting
2. Unit tests
3. Android build
4. Fastlane deployment

### Fastlane Commands

```bash
# Test suite
fastlane android test

# Build tasks
fastlane android build_debug
fastlane android build_release

# Deployment
fastlane android deploy_internal    # Deploy to internal testing track
```

### GitHub Actions

Automatic deployment on push to `main` branch:
1. Unit tests run
2. Release AAB is built
3. Deployed to Google Play (internal track)

**Set up:**
1. Add `GOOGLE_PLAY_SERVICE_ACCOUNT` secret in GitHub Settings
2. Push to `main` branch to trigger workflow

---

## 📚 Documentation

- **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Complete deployment and testing guide
- **[ANDROID_SIGNING.md](./ANDROID_SIGNING.md)** - Android signing and keystore setup

---

## 🛠 Available Commands

Use `make` for shortcuts (if Makefile is available):

```bash
make help           # Show all available commands
make install        # Install dependencies
make test          # Run tests
make test-coverage # Tests with coverage
make lint          # Lint code
make build-debug   # Build debug APK
make build-release # Build release AAB
make deploy        # Full deployment pipeline
```

Or use npm scripts directly:

```bash
npm test            # Unit tests
npm run test:coverage    # With coverage
npm run lint        # Lint code
npm run clean       # Clean builds
npm run android     # Run on Android
npm run build:release    # Build release AAB
npm run detox:build      # Build E2E tests
npm run detox:test       # Run E2E tests
```

---

## 🔐 Setting Up Deployment

### Google Play Store

1. **Create a Service Account:**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select an existing one
   - Create a new Service Account with JSON key

2. **Configure Fastlane:**
   ```bash
   fastlane android deploy_internal
   ```

3. **For CI/CD (GitHub):**
   - Add the service account JSON as a GitHub Secret named `GOOGLE_PLAY_SERVICE_ACCOUNT`

### App Signing

For signing release builds, see [ANDROID_SIGNING.md](./ANDROID_SIGNING.md)

---

## 📁 Project Structure

```
MonApp/
├── __tests__/              # Unit tests
│   └── App.test.tsx
├── e2e/                    # E2E tests with Detox
│   ├── jest.config.js
│   └── starter.test.js
├── android/                # Android native code
│   └── app/build.gradle
├── fastlane/               # Fastlane configuration
│   ├── Fastfile
│   └── Appfile
├── .github/
│   └── workflows/
│       └── mobile.yml      # GitHub Actions CI/CD
├── .detoxrc.js             # Detox E2E configuration
├── jest.config.js          # Jest configuration
├── package.json
├── DEPLOYMENT_GUIDE.md     # Detailed deployment guide
├── ANDROID_SIGNING.md      # Signing configuration
└── deploy.sh               # Local deployment script
```

---

## 🐛 Troubleshooting

### Android Emulator Issues

```bash
# List available emulators
emulator -list-avds

# Start a specific emulator
emulator -avd Pixel_3a_API_30_x86
```

### Tests Fail

```bash
# Clear Jest cache
npx jest --clearCache

# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Build Failures

```bash
# Clean and rebuild
npm run clean
cd android && ./gradlew clean bundleRelease
```

---

## 📝 Environment Setup

### Linux/macOS

```bash
# Add to ~/.bashrc or ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export GRADLE_OPTS=-Xmx4096m
```

### Windows

Run `setup-env.bat` (provides a GUI setup) or set manually:

```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
```

---

## 📞 Support & Resources

- [React Native Documentation](https://reactnative.dev/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Jest Testing](https://jestjs.io/)
- [Detox E2E Testing](https://wix.github.io/Detox/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

## 📄 License

This project is part of the mobile development workshop.

---

## ✅ Getting Help

For issues or questions:
1. Check [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
2. Review GitHub Actions logs in the Actions tab
3. Check local test output: `npm test`
4. Review Fastlane logs: `fastlane android test`


For more information, please visit [CocoaPods Getting Started guide](https://guides.cocoapods.org/using/getting-started.html).

```sh
# Using npm
npm run ios

# OR using Yarn
yarn ios
```

If everything is set up correctly, you should see your new app running in the Android Emulator, iOS Simulator, or your connected device.

This is one way to run your app — you can also build it directly from Android Studio or Xcode.

## Step 3: Modify your app

Now that you have successfully run the app, let's make changes!

Open `App.tsx` in your text editor of choice and make some changes. When you save, your app will automatically update and reflect these changes — this is powered by [Fast Refresh](https://reactnative.dev/docs/fast-refresh).

When you want to forcefully reload, for example to reset the state of your app, you can perform a full reload:

- **Android**: Press the <kbd>R</kbd> key twice or select **"Reload"** from the **Dev Menu**, accessed via <kbd>Ctrl</kbd> + <kbd>M</kbd> (Windows/Linux) or <kbd>Cmd ⌘</kbd> + <kbd>M</kbd> (macOS).
- **iOS**: Press <kbd>R</kbd> in iOS Simulator.

## Congratulations! :tada:

You've successfully run and modified your React Native App. :partying_face:

### Now what?

- If you want to add this new React Native code to an existing application, check out the [Integration guide](https://reactnative.dev/docs/integration-with-existing-apps).
- If you're curious to learn more about React Native, check out the [docs](https://reactnative.dev/docs/getting-started).

# Troubleshooting

If you're having issues getting the above steps to work, see the [Troubleshooting](https://reactnative.dev/docs/troubleshooting) page.

# Learn More

To learn more about React Native, take a look at the following resources:

- [React Native Website](https://reactnative.dev) - learn more about React Native.
- [Getting Started](https://reactnative.dev/docs/environment-setup) - an **overview** of React Native and how setup your environment.
- [Learn the Basics](https://reactnative.dev/docs/getting-started) - a **guided tour** of the React Native **basics**.
- [Blog](https://reactnative.dev/blog) - read the latest official React Native **Blog** posts.
- [`@facebook/react-native`](https://github.com/facebook/react-native) - the Open Source; GitHub **repository** for React Native.
