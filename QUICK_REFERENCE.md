# 🚀 Quick Reference Card - MonApp Commands

## Development

```bash
npm start              # Start Metro bundler (Terminal 1)
npm run android        # Run app on device/emulator (Terminal 2)
npm run lint          # Check code quality
npm test              # Run tests in watch mode
npm test -- --coverage # Generate coverage report
```

## Building

```bash
npm run android       # Build and run debug
npm run build:release # Build release AAB
npm run clean         # Clean all builds
```

## Testing

```bash
npm test                  # Jest unit tests
npm run test:coverage     # Unit tests + coverage
npm run detox:build      # Build E2E tests
npm run detox:test       # Run E2E tests
cd android && ./gradlew testDebugUnitTest  # Android tests
```

## Deployment

```bash
./deploy.sh                        # Complete local pipeline
fastlane android test              # Test via Fastlane
fastlane android build_release     # Build release
fastlane android deploy_internal   # Deploy to Play Store
```

## Make Commands (if available)

```bash
make help              # Show all available targets
make test             # Run tests
make build-release    # Build release
make deploy           # Full deployment
```

---

## 🧪 Testing Checklist

- [ ] `npm test` passes
- [ ] `npm run lint` shows no major errors
- [ ] `npm run build:release` succeeds
- [ ] APK/AAB files generated in `android/app/build/outputs/`
- [ ] Ready to commit and push

---

## 📦 Release Checklist Before Deployment

- [ ] All tests passing (`npm test`)
- [ ] Version bump in `package.json`
- [ ] Build successful (`npm run build:release`)
- [ ] AAB file created and valid
- [ ] App signing configured (keystore + gradle.properties)
- [ ] Release notes prepared
- [ ] Screenshots/assets ready for Play Store
- [ ] Privacy policy URL available

---

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `package.json` | Dependencies & npm scripts |
| `.detoxrc.js` | E2E test configuration |
| `jest.config.js` | Unit test configuration |
| `fastlane/Fastfile` | Deployment lanes |
| `.github/workflows/mobile.yml` | CI/CD pipeline |
| `android/app/build.gradle` | Android build settings |
| `DEPLOYMENT_GUIDE.md` | Full documentation |
| `deploy.sh` | Local deployment script |

---

## 📊 File Paths

```
Source Code:           src/
Unit Tests:            __tests__/
E2E Tests:             e2e/
Android Native:        android/
Fastlane Config:       fastlane/
GitHub Actions:        .github/workflows/
Build Outputs:         android/app/build/outputs/
```

---

## 🆘 Emergency Commands

```bash
# Clear all caches
npm cache clean --force
npx jest --clearCache

# Force reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Deep clean
npm run clean
cd android && ./gradlew clean

# Check environment
echo $ANDROID_HOME        # Linux/macOS
echo %ANDROID_HOME%       # Windows
java -version
node -v
npm -v
```

---

## 🔐 Security Reminders

⚠️ **NEVER COMMIT:**
- `service-account.json` (Google Play credentials)
- `*.jks` or `*.keystore` files
- `.env` files with passwords
- `gradle.properties` with credentials

✅ **DO STORE SECURELY:**
- Keystore backups (encrypted)
- Keystore passwords (password manager)
- Service account JSON (secure location)

---

## 📞 Documentation

Need help? Check:
1. `README.md` - Quick start
2. `DEPLOYMENT_GUIDE.md` - Complete guide
3. `ANDROID_SIGNING.md` - Signing setup
4. `SETUP_CHECKLIST.md` - Verification
5. `IMPLEMENTATION_SUMMARY.md` - What was set up

---

**Print this card and keep it handy!**
