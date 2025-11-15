# Multi-Platform Build Workflow Documentation

## Overview
The GitHub Actions workflows have been refactored to build multiple platform targets (Android APK, Linux DEB/RPM, and Windows EXE) in parallel and release them all together.

## Workflow Structure

### 1. **build.yml** (Main Orchestrator)
- **Purpose**: Orchestrates the entire build pipeline by calling all platform-specific workflows
- **Jobs**:
  - `build-apk`: Calls the APK workflow
  - `build-linux`: Calls the Linux workflow
  - `build-windows`: Calls the Windows workflow
  - `release`: Collects all artifacts and creates a GitHub Release

### 2. **build-apk.yml** (Android Build Workflow)
- **Platform**: Ubuntu-latest
- **Output**: APK package
- **Build Steps**:
  1. Checkout code
  2. Setup Flutter
  3. Get dependencies
  4. Setup Android signing (keystore, passwords)
  5. Extract version from pubspec.yaml
  6. Build APK (`flutter build apk --release`)
  7. Organize and rename artifacts
  8. Upload artifacts with 1-day retention

### 3. **build-linux.yml** (Linux Build Workflow)
- **Platform**: Ubuntu-latest
- **Outputs**: DEB and RPM packages
- **Build Steps**:
  1. Checkout code
  2. Setup Flutter
  3. Get dependencies
  4. Build Linux application (`flutter build linux --release`)
  5. Package as DEB (Debian package)
  6. Package as RPM (Red Hat package)
  7. Upload artifacts with 1-day retention

### 4. **build-windows.yml** (Windows Build Workflow)
- **Platform**: Windows-latest
- **Output**: ZIP archive containing Windows executable
- **Build Steps**:
  1. Checkout code
  2. Setup Flutter
  3. Get dependencies
  4. Build Windows application (`flutter build windows --release`)
  5. Create ZIP archive
  6. Upload artifacts with 1-day retention

## Execution Flow

```
┌─────────────────────┐
│  push to master     │
└──────────┬──────────┘
           │
    ┌──────┼──────┬─────────────┐
    │      │      │             │
    ▼      ▼      ▼             ▼
┌────────┐ ┌────────────┐  ┌──────────┐
│  APK   │ │   Linux    │  │ Windows  │
│Workflow│ │ DEB + RPM  │  │   EXE    │
└────┬───┘ └────┬───────┘  └──┬───────┘
     │          │             │
     │(parallel builds)       │
     │          │             │
     └────┬─────┴─────────────┘
          │
          ▼
     ┌─────────┐
     │ Release │
     │  All    │
     │Artifacts│
     └─────────┘
```

## Artifact Organization

All artifacts are collected in a `dist/` directory:
- `app_name-1.0.0-abc1234_42.apk` (Android)
- `app_name-1.0.0-abc1234.deb` (Linux Debian)
- `app_name-1.0.0-abc1234.rpm` (Linux RPM)
- `app_name-1.0.0-abc1234.zip` (Windows)

## Release Process

1. All platform builds complete (in parallel)
2. Artifacts are downloaded to a central `dist/` directory
3. Version is extracted from `pubspec.yaml`
4. Check if release tag already exists
5. Create GitHub Release with all artifacts
6. Auto-generate release notes if new version

## Configuration

### Required GitHub Repository Secrets
- `STORE_PASSWORD` - Android keystore password
- `KEY_PASSWORD` - Android key password
- `KEY_ALIAS` - Android key alias
- `KEYSTORE_BASE64` - Base64-encoded keystore file

### Required GitHub Repository Variables
- `APP_NAME` - Application name (used for artifact naming)

## Benefits

✅ **Parallel Execution**: All platforms build simultaneously, reducing total build time
✅ **Modular Design**: Each platform has its own dedicated, reusable workflow
✅ **Clean Orchestration**: Main build.yml is simple and only calls sub-workflows
✅ **Error Isolation**: Failure in one platform doesn't block others
✅ **Clear Organization**: Each workflow has a single responsibility
✅ **Artifact Management**: Automatic cleanup after 1 day to save storage
✅ **Single Release Point**: All artifacts released together in one GitHub Release

## Customization Notes

1. **Maintainer Info** (Linux):
   - Update `Your Name <your.email@example.com>` in `build-linux.yml` line 68

2. **Package Names**:
   - Currently uses `my-flutter-app-0` - customize in build-linux.yml

3. **Windows Build**:
   - Creates a ZIP archive of the Release folder
   - Can be modified to create an MSIX installer instead

4. **Release Triggers**:
   - Currently creates releases on push to master
   - Runs tests on pull requests without creating releases
   - Modify the `if:` condition in build.yml release job to change this behavior

5. **Individual Workflow Execution**:
   - Each workflow (build-apk.yml, build-linux.yml, build-windows.yml) can also be called independently if needed
   - They use `workflow_call` trigger for reusability
