# 🔥 Firebase Console Setup - Manual Steps Required

## ✅ What I've Done:

### 1. ✅ Installed Dependencies
- `cloud_firestore: ^5.5.0` ✅ Installed
- `intl: ^0.19.0` ✅ Installed

### 2. ✅ Retrieved SHA-1 Fingerprint
```
SHA-1: BD:14:77:C2:A5:7B:05:7C:E0:0F:F3:C5:8D:A3:85:67:CD:5D:F0:BB
```

---

## 🌐 What You Need to Do in Firebase Console:

I cannot access the Firebase Console web interface, so you need to complete these steps manually:

### 📋 **STEP 1: Enable Cloud Firestore Database**

1. Open browser and go to: https://console.firebase.google.com/
2. Select project: **krushiai-e6a17**
3. In left sidebar, click **"Build"** → **"Firestore Database"**
4. Click **"Create database"** button
5. Select **"Start in test mode"**
6. Choose location: **asia-south1** (India)
7. Click **"Enable"**
8. Wait 1-2 minutes for provisioning

---

### 🔒 **STEP 2: Configure Security Rules**

1. Once Firestore is enabled, click **"Rules"** tab
2. Delete all existing rules
3. Copy and paste this entire block:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    match /model_history/{historyId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      allow update, delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow create, update: if isAuthenticated() && isOwner(userId);
      allow delete: if false;
    }
    
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

4. Click **"Publish"** button
5. Confirm changes

---

### 🔑 **STEP 3: Add SHA-1 Fingerprint**

1. In Firebase Console, click the **gear icon** (⚙️) → **"Project settings"**
2. Scroll down to **"Your apps"** section
3. Find your Android app: **com.example.krushi_ai**
4. Under "SHA certificate fingerprints", click **"Add fingerprint"**
5. Paste this EXACT value:
   ```
   BD:14:77:C2:A5:7B:05:7C:E0:0F:F3:C5:8D:A3:85:67:CD:5D:F0:BB
   ```
6. Click **"Save"**

---

### 📥 **STEP 4: Download Updated google-services.json**

1. In the same **Project settings** page
2. Scroll to your Android app section
3. Click **"Download google-services.json"** button
4. Save the file
5. Replace the existing file at:
   ```
   D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai\android\app\google-services.json
   ```
6. Make sure to REPLACE the old file completely

---

### 🔐 **STEP 5: Enable Google Sign-In**

1. In Firebase Console left sidebar, click **"Authentication"**
2. Click **"Sign-in method"** tab
3. Find **"Google"** in the list
4. Click on it
5. Toggle the switch to **"Enable"**
6. Set **Project support email** (use your email: 23dcs033@charusat.edu.in)
7. Click **"Save"**

---

### 📊 **STEP 6: Create Collections (Optional)**

You can skip this - collections will be created automatically when you save data.

But if you want to create them manually:

1. Go to **"Firestore Database"** → **"Data"** tab
2. Click **"Start collection"**
3. Collection ID: `model_history`
4. Click "Auto-ID" for document
5. Add fields:
   - Field: `userId` | Type: string | Value: `test_user`
   - Field: `userEmail` | Type: string | Value: `test@test.com`
   - Field: `modelType` | Type: string | Value: `crop_disease`
   - Field: `input` | Type: string | Value: `Test input`
   - Field: `output` | Type: string | Value: `Test output`
   - Field: `metadata` | Type: map | Leave empty
   - Field: `timestamp` | Type: timestamp | Click "current timestamp"
6. Click **"Save"**

---

## ✅ **Verification Checklist**

After completing the above steps, verify:

- [ ] Firestore Database shows as "Enabled" in Firebase Console
- [ ] Security rules are published (you'll see "Last published" timestamp)
- [ ] SHA-1 fingerprint appears under your Android app settings
- [ ] New google-services.json file is downloaded and replaced
- [ ] Google Sign-In shows as "Enabled" in Authentication
- [ ] (Optional) Collections are visible in Firestore Data tab

---

## 🚀 **After Completing All Steps**

Run these commands:

```powershell
cd D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai
flutter clean
flutter pub get
flutter run
```

---

## 🎯 **Expected Result**

Once you complete all Firebase Console steps:

1. ✅ App will build successfully
2. ✅ Google Sign-In will work without errors
3. ✅ Firestore connection will be established
4. ✅ History screen will load without "channel-error"
5. ✅ You can save predictions to database
6. ✅ View saved history in the app

---

## 🆘 **If You Get Stuck**

### Firestore Not Enabling
- Wait 2-3 minutes after clicking "Enable"
- Refresh the Firebase Console page
- Check your internet connection

### SHA-1 Not Accepting
- Make sure you copied the ENTIRE fingerprint including colons
- It should be exactly: `BD:14:77:C2:A5:7B:05:7C:E0:0F:F3:C5:8D:A3:85:67:CD:5D:F0:BB`
- Don't add quotes or extra spaces

### google-services.json Download
- Make sure you're downloading from the ANDROID app section
- File should be exactly named `google-services.json`
- Replace the file completely, don't rename the old one

### Google Sign-In Not Enabling
- Make sure you provide a valid support email
- The email must be associated with your Google account

---

## 📸 **Visual Guide**

### Firestore Database Location:
```
Firebase Console
 └── Left Sidebar
     └── Build
         └── Firestore Database  ← Click here
```

### Authentication Location:
```
Firebase Console
 └── Left Sidebar
     └── Build
         └── Authentication  ← Click here
             └── Sign-in method tab
```

### Project Settings Location:
```
Firebase Console
 └── Top Left: Gear Icon (⚙️)  ← Click here
     └── Project settings
         └── Scroll down to "Your apps"
```

---

## ⏱️ **Estimated Time**

- Step 1 (Enable Firestore): 3 minutes
- Step 2 (Security Rules): 2 minutes
- Step 3 (SHA-1): 1 minute
- Step 4 (Download JSON): 1 minute
- Step 5 (Enable Google Sign-In): 2 minutes

**Total: ~10 minutes**

---

## 🎉 **Once Complete**

Your app will have:
- ✅ Working Google Sign-In
- ✅ Firestore database connection
- ✅ Ability to save model predictions
- ✅ History screen showing saved data
- ✅ Real-time updates
- ✅ Secure user data

---

**Your SHA-1 Fingerprint (copy this):**
```
BD:14:77:C2:A5:7B:05:7C:E0:0F:F3:C5:8D:A3:85:67:CD:5D:F0:BB
```

**Start here:** https://console.firebase.google.com/

**Good luck! 🚀**
