# 🔥 Firebase Setup Quick Guide

## ⚠️ IMPORTANT: Complete These Steps Before Running the App

---

## Step 1: Create Firebase Project (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: **KrushiAI**
4. Disable Google Analytics (optional)
5. Click **"Create project"**
6. Wait for project creation

---

## Step 2: Add Android App to Firebase

1. In Firebase project, click the **Android icon** (⚙️)
2. **Android package name:** `com.example.krushi_ai`
   - Find this in `android/app/build.gradle` under `applicationId`
3. **App nickname:** KrushiAI (optional)
4. **Debug signing certificate:** Leave blank for now
5. Click **"Register app"**

---

## Step 3: Download google-services.json

1. Click **"Download google-services.json"**
2. **IMPORTANT:** Place the file in:
   ```
   android/app/google-services.json
   ```
   NOT in `android/` root directory!

---

## Step 4: Update Android Build Files

### File 1: `android/build.gradle`

Find the `buildscript` section and add Google Services:

```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        
        // ADD THIS LINE ⬇️
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### File 2: `android/app/build.gradle`

Add at the **BOTTOM** of the file:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// ... rest of the file ...

// ADD THIS LINE AT THE VERY BOTTOM ⬇️
apply plugin: 'com.google.gms.google-services'
```

Also update `minSdkVersion` in the same file:

```gradle
defaultConfig {
    applicationId "com.example.krushi_ai"
    minSdkVersion 21  // Change this from flutter.minSdkVersion
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}
```

---

## Step 5: Enable Email/Password Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click **"Email/Password"**
5. Toggle **"Enable"** switch
6. Click **"Save"**

---

## Step 6: Verify Setup

Run these commands:

```bash
cd d:/CHARUSAT/Sem-6/MAD/KrushiAI/krushi_ai
flutter clean
flutter pub get
```

---

## Step 7: Run the App

```bash
flutter run
```

Or use your IDE's run button.

---

## ✅ Verification Checklist

Before running the app, verify:

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` in `android/app/` directory
- [ ] `android/build.gradle` has Google Services classpath
- [ ] `android/app/build.gradle` has Google Services plugin at bottom
- [ ] `minSdkVersion` is 21 or higher
- [ ] Email/Password auth enabled in Firebase Console
- [ ] `flutter pub get` completed successfully

---

## 🐛 Common Issues

### Issue 1: "google-services.json not found"
**Solution:** Ensure file is in `android/app/` NOT `android/`

### Issue 2: "Minimum SDK version error"
**Solution:** Update `minSdkVersion` to 21 in `android/app/build.gradle`

### Issue 3: "Plugin with id 'com.google.gms.google-services' not found"
**Solution:** Add classpath in `android/build.gradle` buildscript dependencies

### Issue 4: "Email/Password sign-in is disabled"
**Solution:** Enable Email/Password in Firebase Console → Authentication → Sign-in method

---

## 📱 Testing After Setup

1. **Launch app** → Should show loading screen then login
2. **Tap "Sign Up"** → Fill registration form
3. **Register** → Should succeed and go to login
4. **Login** → Should authenticate and go to dashboard
5. **Close and reopen app** → Should auto-login to dashboard
6. **Tap logout** → Should return to login

---

## 🎓 Need Help?

Refer to the complete lab report:
- [LAB_5_AUTHENTICATION_REPORT.md](file:///d:/CHARUSAT/Sem-6/MAD/KrushiAI/LAB_5_AUTHENTICATION_REPORT.md)

---

**Setup Time:** ~10-15 minutes  
**Difficulty:** Easy  
**Required:** Internet connection

---

Good luck! 🚀
