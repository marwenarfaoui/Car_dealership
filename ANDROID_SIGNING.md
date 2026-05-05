# Android App Signing Configuration

This file contains instructions for setting up Android app signing for release builds.

## Step 1: Create a Keystore

Generate a keystore file for signing Android apps:

```bash
keytool -genkey -v -keystore monapp-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias monapp-key
```

You will be prompted to enter:
- Password for the keystore
- Password for the key
- Key information (name, organization, etc.)

**Store this file securely!** You'll need it for all future releases.

## Step 2: Configure Gradle Signing

Create or edit `android/gradle.properties` and add:

```properties
MYAPP_RELEASE_STORE_FILE=monapp-release-key.jks
MYAPP_RELEASE_STORE_PASSWORD=your_keystore_password
MYAPP_RELEASE_KEY_ALIAS=monapp-key
MYAPP_RELEASE_KEY_PASSWORD=your_key_password
```

## Step 3: Update build.gradle

Edit `android/app/build.gradle` and update the `signingConfigs`:

```gradle
android {
    ...
    signingConfigs {
        release {
            storeFile file(MYAPP_RELEASE_STORE_FILE)
            storePassword MYAPP_RELEASE_STORE_PASSWORD
            keyAlias MYAPP_RELEASE_KEY_ALIAS
            keyPassword MYAPP_RELEASE_KEY_PASSWORD
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Step 4: Build Signed Release APK/AAB

```bash
cd android
./gradlew bundleRelease    # For AAB (recommended for Play Store)
./gradlew assembleRelease  # For APK
```

## Important Security Notes

⚠️ **NEVER commit the keystore file or passwords to version control!**

- Keep `monapp-release-key.jks` in a secure location
- Store passwords in environment variables or secure vaults
- For CI/CD, use GitHub Secrets or similar secure storage
- Rotate passwords periodically

## Backing Up Your Keystore

If you lose the keystore, you cannot update your app on the Play Store!

1. Create a secure backup of the keystore file
2. Document the keystore password and key password
3. Store backups in a secure location (encrypted drive, password manager, etc.)

## Troubleshooting

### "Certificate has expired"
```bash
keytool -list -v -keystore monapp-release-key.jks
```

### Regenerating if Lost
If you lose the keystore and need to publish updates:
1. Create a new keystore with a different alias
2. Contact Google Play Support for assistance
3. In future, consider using Play App Signing

## Play App Signing (Recommended)

Google Play can manage app signing for you:
1. Enable "Google Play App Signing" in Play Console
2. Upload your AAB without signing, or with signing
3. Google Play handles the signing for distribution

This provides better security and allows for key rotation.
