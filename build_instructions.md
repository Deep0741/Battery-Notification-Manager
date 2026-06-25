# Build & Setup Instructions

Since local command execution is unavailable on the agent's runner, follow these simple terminal commands to initialize the project, copy the generated premium asset icons, and run the desktop utility.

---

## Step 1: Initialize Flutter Windows Project

Open your terminal (PowerShell or Command Prompt) in the directory `c:\Users\Deep\OneDrive\Documents\Projects\Battery Notification Manager` and run:

```powershell
flutter create --platforms=windows .
```

This generates the standard native Windows directory (`windows/`) and template files.

---

## Step 2: Restore Custom Configurations

The `flutter create` command will have created default versions of `pubspec.yaml` and `lib/main.dart`. Overwrite them with our custom code using these commands:

```powershell
# Restore custom pubspec.yaml
copy pubspec.yaml.backup pubspec.yaml /Y

# Restore custom lib/main.dart
copy lib\main.dart.backup lib\main.dart /Y
```

---

## Step 3: Set Up Assets and Icons

Create the `assets/` folder in the project root and copy the generated premium icons from the agent's workspace:

```powershell
# Create assets folder
mkdir assets

# Copy normal icon
copy "C:\Users\Deep\.gemini\antigravity\brain\878b8c34-7474-448c-ae67-280871b6f355\app_icon_1782313865577.png" "assets\app_icon.png" /Y

# Copy alert icon
copy "C:\Users\Deep\.gemini\antigravity\brain\878b8c34-7474-448c-ae67-280871b6f355\app_icon_alert_1782313882179.png" "assets\app_icon_alert.png" /Y
```

---

## Step 4: Install Dependencies

Fetch all the plugins (like `window_manager`, `tray_manager`, `win32`, etc.) defined in `pubspec.yaml`:

```powershell
flutter pub get
```

---

## Step 5: Run the Application

Launch the application in debug mode on Windows:

```powershell
flutter run -d windows
```

---

## Step 6: Build for Production

To compile a highly optimized, production-ready release build:

```powershell
flutter build windows
```

The compiled executable and supporting files will be located at:
`build\windows\x64\runner\Release\`
