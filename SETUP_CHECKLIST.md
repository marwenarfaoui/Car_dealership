# ✅ Setup Checklist - MonApp Testing & Deployment

Complete this checklist to ensure your mobile testing and deployment environment is fully configured.

---

## Phase 1: Environment Setup

### System Requirements

- [ ] Node.js 18+ installed
  ```bash
  node -v    # Should be v18 or higher
  npm -v     # Should work
  ```

- [ ] Java Development Kit (JDK) 11+ installed
  ```bash
  java -version
  ```

- [ ] Android SDK installed
  - [ ] Android Studio installed or just SDK
  - [ ] API level 30+ available
  - [ ] Android Emulator available (if needed for testing)

- [ ] Git installed and configured
  ```bash
  git --version
  git config --global user.name "Your Name"
  git config --global user.email "your@email.com"
  ```

### Environment Variables (Android)

**Linux/macOS:**
- [ ] `ANDROID_HOME` set correctly
- [ ] `$ANDROID_HOME/emulator` added to PATH
- [ ] `$ANDROID_HOME/platform-tools` added to PATH

**Windows:**
- [ ] Run `setup-env.bat` and restart terminal, OR
- [ ] Manually set environment variables

---

## Phase 2: Project Installation

- [ ] Navigate to project directory
  ```bash
  cd "c:\Users\marwe\Desktop\rendu mobile\MonApp"
  ```

- [ ] Install npm dependencies
  ```bash
  npm install
  ```

- [ ] Verify Fastlane installation
  ```bash
  fastlane --version
  ```

- [ ] Test basic commands
  ```bash
  npm test
  npm run lint
  npm run build:release
  ```

---

## Phase 3: Testing Configuration

### Unit Tests (Jest)

- [ ] Tests are runnable
  ```bash
  npm test
  ```

- [ ] Coverage report works
  ```bash
  npm run test:coverage
  ```

- [ ] Test files are in `__tests__/`
  - [ ] `__tests__/App.test.tsx` exists and passes

### E2E Tests (Detox)

- [ ] Detox configuration exists (`.detoxrc.js`)
- [ ] Detox test files exist (`e2e/starter.test.js`)
- [ ] Android emulator available (if testing E2E)
  ```bash
  emulator -list-avds
  ```

### Gradle Tests

- [ ] Can build test APK
  ```bash
  cd android && ./gradlew assembleDebugAndroidTest
  ```

- [ ] Unit tests pass
  ```bash
  cd android && ./gradlew testDebugUnitTest
  ```

---

## Phase 4: Build Configuration

### Debug Build

- [ ] Can build debug APK
  ```bash
  npm run android
  # or
  cd android && ./gradlew assembleDebug
  ```

- [ ] App runs on emulator or device

### Release Build

- [ ] Can build release bundle
  ```bash
  npm run build:release
  # Creates: android/app/build/outputs/bundle/release/app-release.aab
  ```

- [ ] No build errors

- [ ] App signing configured (see [ANDROID_SIGNING.md](./ANDROID_SIGNING.md))
  - [ ] Keystore created
  - [ ] `android/gradle.properties` configured with signing keys
  - [ ] Keystore file stored securely

---

## Phase 5: Fastlane Setup

- [ ] Fastlane directory exists with:
  - [ ] `fastlane/Fastfile` with Android lanes
  - [ ] `fastlane/Appfile` with package identifier

- [ ] Fastlane commands work:
  ```bash
  fastlane android test
  fastlane android build_debug
  fastlane android build_release
  ```

### Google Play Configuration (Optional)

- [ ] Google Play Store account created
- [ ] Developer account activated
- [ ] App created in Play Console
- [ ] Service account created with JSON key
- [ ] Service account JSON downloaded and secured
- [ ] Path to JSON configured in Fastlane or environment
- [ ] Deploy test successful (optional)
  ```bash
  fastlane android deploy_internal    # Requires config above
  ```

---

## Phase 6: GitHub Configuration

### Repository Setup

- [ ] Repository initialized
  ```bash
  git init
  git remote add origin <your-repo-url>
  ```

- [ ] `.gitignore` configured properly
  - [ ] `node_modules/` ignored
  - [ ] `service-account.json` ignored
  - [ ] `*.jks` and `*.keystore` ignored
  - [ ] `.env` files ignored

- [ ] Initial commit made
  ```bash
  git add .
  git commit -m "Initial commit: React Native app with tests and deployment"
  git push -u origin main
  ```

### GitHub Actions Setup

- [ ] `.github/workflows/mobile.yml` exists
- [ ] Workflow triggers configured
- [ ] Secrets configured (if deploying):
  - [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT` secret added (if using Google Play)
  - [ ] Secret value is service account JSON content

**To add secrets:**
1. Go to repository Settings
2. Secrets and variables → Actions
3. New repository secret
4. Name: `GOOGLE_PLAY_SERVICE_ACCOUNT`
5. Value: Contents of service account JSON file

---

## Phase 7: Local Deployment Script

- [ ] `deploy.sh` script exists
- [ ] Script is executable
  ```bash
  chmod +x deploy.sh
  ```

- [ ] Script runs successfully
  ```bash
  ./deploy.sh
  ```

---

## Phase 8: Documentation Review

- [ ] Read [README.md](./README.md)
- [ ] Read [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
- [ ] Read [ANDROID_SIGNING.md](./ANDROID_SIGNING.md)
- [ ] Understand the CI/CD workflow from `.github/workflows/mobile.yml`

---

## Phase 9: Testing the Complete Pipeline

### Local Testing

- [ ] Run all tests locally
  ```bash
  npm test && npm run lint
  ```

- [ ] Build release locally
  ```bash
  npm run build:release
  ```

- [ ] Run deployment script
  ```bash
  ./deploy.sh
  ```

### GitHub Actions Testing

- [ ] Create a test branch
  ```bash
  git checkout -b test-ci
  ```

- [ ] Make a small change and push
  ```bash
  git add .
  git commit -m "Test CI/CD pipeline"
  git push origin test-ci
  ```

- [ ] Create a Pull Request on GitHub
- [ ] Verify GitHub Actions runs tests
- [ ] Merge PR to `main` if tests pass
- [ ] Verify deployment workflow triggers (if configured)

---

## Phase 10: Team Onboarding

- [ ] Team members cloned the repo
- [ ] Team members ran `npm install`
- [ ] Team members can run tests
  ```bash
  npm test
  ```

- [ ] Team members can build APK
  ```bash
  npm run android
  ```

- [ ] Team members understand the development workflow

---

## 🎯 Final Verification

After completing all sections, verify:

| Component | Command | Expected Result |
|-----------|---------|-----------------|
| Node.js | `node -v` | Version 18+ |
| npm | `npm -v` | Version 6+ |
| Android SDK | `$ANDROID_HOME` set | Path displayed |
| Jest | `npm test` | Tests pass ✓ |
| Linting | `npm run lint` | No major errors |
| Build Debug | `npm run android` | APK created |
| Build Release | `npm run build:release` | AAB created |
| Fastlane | `fastlane --version` | Version displayed |
| Deploy Script | `./deploy.sh` | Runs without errors |
| GitHub | Push to main | Actions workflow runs |

---

## 📞 Troubleshooting

If any step fails:

1. **Check [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** for detailed instructions
2. **Check GitHub Actions logs** for CI/CD issues
3. **Review error messages** carefully
4. **Check environment variables**:
   ```bash
   echo $ANDROID_HOME
   echo $GRADLE_OPTS
   ```

5. **Clean and reinstall** if necessary:
   ```bash
   npm run clean
   rm -rf node_modules
   npm install
   ```

---

## ✅ Completion

Once all checkboxes are complete:

✅ Your development environment is ready
✅ Testing infrastructure is operational
✅ Deployment pipeline is configured
✅ Team can collaborate effectively
✅ Ready for continuous deployment!

---

**Checklist completed on:** _________________ (date)
**Completed by:** _________________ (name)
