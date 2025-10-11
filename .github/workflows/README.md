# 🚀 GitHub Actions Workflows for Marina Hotel Mobile App

This directory contains comprehensive GitHub Actions workflows for building, testing, and releasing the Marina Hotel Mobile App.

## 📁 Available Workflows

### 1. 🎯 Enhanced APK Building (`build-signed-apk-enhanced.yml`)
**Purpose**: Build signed APK files with automatic keystore generation and comprehensive quality checks.

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual dispatch with build type selection
- Release events

**Features**:
- ✅ Automatic keystore generation and APK signing
- ✅ Split APK support (Universal, ARM64, ARM32, x86_64)
- ✅ Code quality checks (Flutter analyze, tests, coverage)
- ✅ Comprehensive build analysis and reporting
- ✅ Automatic GitHub release creation
- ✅ File integrity verification with checksums

**Outputs**:
- Debug and Release APK files
- Architecture-specific APKs for smaller download sizes
- Universal APK for maximum compatibility
- GitHub Release with detailed changelog

### 2. 🏪 Play Store AAB Building (`build-aab-playstore.yml`)
**Purpose**: Build Android App Bundle (AAB) files specifically for Google Play Store upload.

**Triggers**:
- Push to version tags (`v*.*.*`)
- Push to release branches (`release-*`)
- Manual dispatch with version input

**Features**:
- ✅ Production keystore generation
- ✅ AAB file optimization for Play Store
- ✅ Play Store metadata generation
- ✅ Comprehensive release notes
- ✅ File integrity verification

**Outputs**:
- Signed AAB file ready for Play Store upload
- Play Store metadata and documentation
- GitHub Release with upload instructions

### 3. 📱 Existing APK Building (`build-apks.yml`)
**Purpose**: Build both Flutter and Android native APKs with basic functionality.

**Features**:
- ✅ Flutter app building
- ✅ Android native app building
- ✅ Combined artifact creation
- ✅ Basic build reporting

### 4. 🚀 Release Management (`release.yml`)
**Purpose**: Create GitHub releases with APK files for distribution.

**Features**:
- ✅ Automatic release creation on tags
- ✅ Manual release creation
- ✅ Combined Flutter and Android APKs
- ✅ Release notes generation

## 🚀 Quick Start Guide

### For Development Testing
1. **Push your changes** to `main` or `develop` branch
2. **Wait for workflow completion** (5-10 minutes)
3. **Download APKs** from the Artifacts section
4. **Install and test** on your Android device

### For Production Release
1. **Create a version tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. **Wait for workflows to complete**
3. **Download APKs** from GitHub Releases
4. **Distribute** to users or upload to app stores

### For Play Store Upload
1. **Create a release tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. **Wait for AAB workflow completion**
3. **Download AAB file** from GitHub Releases
4. **Upload to Google Play Console**

## 📱 APK Types Explained

### Universal APK
- **File**: `marina-hotel-*-universal-*.apk`
- **Size**: ~25-30 MB
- **Compatibility**: All Android devices
- **Use Case**: Direct distribution, maximum compatibility

### Architecture-Specific APKs
- **ARM64**: `marina-hotel-*-arm64-*.apk` (~20-25 MB)
  - Modern 64-bit ARM devices (recommended)
- **ARM32**: `marina-hotel-*-arm32-*.apk` (~18-23 MB)
  - Older 32-bit ARM devices
- **x86_64**: `marina-hotel-*-x86_64-*.apk` (~22-27 MB)
  - x86_64 devices and emulators

### Android App Bundle (AAB)
- **File**: `marina-hotel-*-playstore-*.aab`
- **Size**: ~20-25 MB (optimized)
- **Compatibility**: Google Play Store only
- **Use Case**: Play Store upload, automatic optimization

## 🔐 Security Features

### Automatic Signing
- **Keystore Generation**: Automatic RSA 2048-bit keystore creation
- **Validity**: 10,000 days (27+ years)
- **Security**: Strong encryption and secure key management
- **No Manual Setup**: No need to manage keystores manually

### Code Protection
- **Obfuscation**: Release builds are obfuscated
- **Minification**: Code and resources are minified
- **ProGuard**: Additional protection rules applied
- **Debug Symbols**: Available for crash analysis

## 📊 Build Monitoring

### Workflow Status
- 🟢 **Success**: Build completed successfully
- 🟡 **In Progress**: Build is running
- 🔴 **Failed**: Build failed (check logs)
- ⏭️ **Skipped**: Build was skipped (check conditions)

### Build Logs
- **Code Quality**: Flutter analyze, tests, coverage
- **Build Process**: Detailed build steps and timing
- **APK Analysis**: File sizes and optimization details
- **Error Handling**: Clear error messages and solutions

## 🛠️ Configuration

### Environment Variables
```yaml
FLUTTER_VERSION: '3.24.5'          # Flutter SDK version
JAVA_VERSION: '17'                  # Java version
ANDROID_API_LEVEL: '34'            # Target Android API level
ANDROID_BUILD_TOOLS_VERSION: '34.0.0'  # Build tools version
```

### App Configuration
```yaml
APP_NAME: 'Marina Hotel'           # App display name
APP_PACKAGE: 'com.marinahotel.mobile'  # Package identifier
APP_VERSION: '1.0.0'               # Version name
APP_VERSION_CODE: '1'              # Version code
```

## 🔧 Troubleshooting

### Common Issues

#### Build Fails
1. **Check Flutter version compatibility**
2. **Verify pubspec.yaml dependencies**
3. **Check Android SDK setup**
4. **Review build logs for specific errors**

#### APK Installation Issues
1. **Enable "Unknown Sources"** in Android settings
2. **Use Universal APK** for maximum compatibility
3. **Check Android version** (requires API 21+)
4. **Verify APK integrity** using checksums

#### Play Store Upload Issues
1. **Use AAB file** (not APK) for Play Store
2. **Check package name** matches Play Console
3. **Verify signing** with production keystore
4. **Review Play Store requirements**

### Getting Help
1. **Check workflow logs** in Actions tab
2. **Review error messages** in build summary
3. **Verify configuration** matches requirements
4. **Contact development team** for support

## 📈 Performance Optimization

### Build Speed
- **Caching**: Dependencies are cached between builds
- **Parallel Jobs**: Multiple build types run in parallel
- **Incremental Builds**: Only changed components are rebuilt

### APK Size
- **Split APKs**: Architecture-specific builds reduce size
- **Code Obfuscation**: Reduces APK size and improves security
- **Resource Optimization**: Images and assets are optimized
- **ProGuard**: Removes unused code and resources

## 🎯 Best Practices

### Development
1. **Test locally** before pushing changes
2. **Use feature branches** for new features
3. **Write tests** for new functionality
4. **Review code quality** before merging

### Release Management
1. **Use semantic versioning** (v1.0.0, v1.1.0, etc.)
2. **Create release notes** for each version
3. **Test APKs** before distribution
4. **Keep release history** for rollback if needed

### Security
1. **Never commit keystores** to repository
2. **Use strong passwords** for keystores
3. **Backup keystores** securely
4. **Rotate keys** periodically

## 📞 Support

For technical support or questions about the build process:

1. **Check this documentation** first
2. **Review workflow logs** for specific errors
3. **Create an issue** in the repository
4. **Contact the development team**

---

**Last Updated**: $(date)
**Flutter Version**: 3.24.5
**Android Target SDK**: 34

*This documentation is maintained by the Marina Hotel development team.*