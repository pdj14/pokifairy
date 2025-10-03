# Deep Link Testing Guide

This document explains how to test deep links in the PokiFairy app.

## Supported Deep Links

The app supports the following deep link schemes:

### Custom Scheme (pokifairy://)
- `pokifairy://chat` - Opens the AI chat page
- `pokifairy://model-selection` - Opens the model selection page
- `pokifairy://model-debug` - Opens the model debug page
- `pokifairy://settings` - Opens the settings page
- `pokifairy://home` - Opens the home page

### HTTPS Scheme (https://pokifairy.app)
- `https://pokifairy.app/chat` - Opens the AI chat page
- `https://pokifairy.app/model-selection` - Opens the model selection page
- `https://pokifairy.app/model-debug` - Opens the model debug page
- `https://pokifairy.app/settings` - Opens the settings page
- `https://pokifairy.app/home` - Opens the home page

## Testing on Android

### Using ADB (Android Debug Bridge)

1. Make sure your device is connected and the app is installed
2. Open a terminal and run:

```bash
# Test custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "pokifairy://chat" com.example.pokifairy

# Test HTTPS scheme
adb shell am start -W -a android.intent.action.VIEW -d "https://pokifairy.app/chat" com.example.pokifairy
```

### Using a Test HTML Page

Create an HTML file with the following content and open it in Chrome on your Android device:

```html
<!DOCTYPE html>
<html>
<head>
    <title>PokiFairy Deep Link Test</title>
</head>
<body>
    <h1>PokiFairy Deep Link Test</h1>
    <ul>
        <li><a href="pokifairy://chat">Open Chat (Custom Scheme)</a></li>
        <li><a href="pokifairy://model-selection">Open Model Selection (Custom Scheme)</a></li>
        <li><a href="pokifairy://model-debug">Open Model Debug (Custom Scheme)</a></li>
        <li><a href="pokifairy://settings">Open Settings (Custom Scheme)</a></li>
        <li><a href="https://pokifairy.app/chat">Open Chat (HTTPS)</a></li>
        <li><a href="https://pokifairy.app/model-selection">Open Model Selection (HTTPS)</a></li>
    </ul>
</body>
</html>
```

## Testing on iOS

### Using Safari

1. Open Safari on your iOS device
2. Type the deep link URL in the address bar:
   - `pokifairy://chat`
   - `https://pokifairy.app/chat`
3. Safari will prompt you to open the app

### Using Terminal (iOS Simulator)

```bash
# Test custom scheme
xcrun simctl openurl booted "pokifairy://chat"

# Test HTTPS scheme
xcrun simctl openurl booted "https://pokifairy.app/chat"
```

### Using Xcode

1. Open the project in Xcode
2. Run the app on a simulator or device
3. Go to Debug > Open URL
4. Enter the deep link URL

## Verifying Deep Link Configuration

### Android

Check that the AndroidManifest.xml contains the intent filters:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="pokifairy"/>
</intent-filter>
```

### iOS

Check that the Info.plist contains the URL types:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pokifairy</string>
        </array>
    </dict>
</array>
```

## Troubleshooting

### Deep links not working on Android
- Make sure the app is installed
- Check that the intent filters are correctly configured in AndroidManifest.xml
- Try uninstalling and reinstalling the app
- Check logcat for any errors: `adb logcat | grep -i pokifairy`

### Deep links not working on iOS
- Make sure the app is installed
- Check that CFBundleURLTypes is correctly configured in Info.plist
- Try uninstalling and reinstalling the app
- Check the Xcode console for any errors

### App opens but doesn't navigate to the correct page
- Verify that GoRouter is correctly configured to handle the deep link paths
- Check that the route paths match the deep link paths
- Add logging to the router to debug navigation issues

## Notes

- The HTTPS scheme requires domain verification for Android App Links
- For production, you'll need to set up the `.well-known/assetlinks.json` file on your domain
- Custom schemes (pokifairy://) work immediately without domain verification
