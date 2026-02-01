# Firebase Firestore Database Setup Guide

## ✅ Complete Setup Instructions for KrushiAI

---

## 📋 **Step 1: Enable Cloud Firestore in Firebase Console**

### 1.1 Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **krushiai-e6a17**

### 1.2 Enable Firestore Database
1. In the left sidebar, click **"Build"** → **"Firestore Database"**
2. Click **"Create database"** button
3. Choose a location:
   - Select **"Start in test mode"** (for development)
   - Or **"Start in production mode"** (for production - more secure)
4. Click **"Next"**
5. Choose a Firestore location (e.g., `asia-south1` for India)
6. Click **"Enable"**

⏱️ **Wait 1-2 minutes** for Firestore to be provisioned.

---

## 🔒 **Step 2: Configure Firestore Security Rules**

### 2.1 Open Rules Tab
1. In Firestore Database page, click the **"Rules"** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the data
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Model History Collection Rules
    match /model_history/{historyId} {
      // Allow read if user is authenticated and owns the record
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      
      // Allow create if user is authenticated and userId matches auth.uid
      allow create: if isAuthenticated() && isOwner(request.resource.data.userId);
      
      // Allow update/delete if user is authenticated and owns the record
      allow update, delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Users Collection Rules
    match /users/{userId} {
      // Allow read if user is authenticated and accessing own data
      allow read: if isAuthenticated() && isOwner(userId);
      
      // Allow create/update if user is authenticated and accessing own data
      allow create, update: if isAuthenticated() && isOwner(userId);
      
      // Prevent deletion
      allow delete: if false;
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 2.2 Publish Rules
1. Click **"Publish"** button
2. Confirm the changes

---

## 📊 **Step 3: Create Firestore Collections (Optional)**

Firestore will automatically create collections when you first write data, but you can create them manually:

### 3.1 Create Collections Manually
1. Go to **"Firestore Database"** → **"Data"** tab
2. Click **"Start collection"**
3. Collection ID: `model_history`
4. Add a sample document:
   - Document ID: `sample_001` (Auto-generate)
   - Fields:
     ```
     userId: "test_user_id" (string)
     userEmail: "test@example.com" (string)
     modelType: "crop_disease" (string)
     input: "Sample input" (string)
     output: "Sample output" (string)
     metadata: {} (map)
     timestamp: (click "current timestamp")
     ```
5. Click **"Save"**

### 3.2 Create Users Collection
1. Click **"Start collection"**
2. Collection ID: `users`
3. Add a sample document (optional for testing)

---

## 🔑 **Step 4: Update Google Sign-In SHA-1 (Fix Sign-In Error)**

### 4.1 Get SHA-1 Fingerprint
Run this command in PowerShell:

```powershell
cd D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai\android
.\gradlew signingReport
```

Look for output like:
```
Variant: debug
SHA-1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

**Copy the SHA-1 fingerprint**

### 4.2 Add SHA-1 to Firebase
1. Go to Firebase Console → **Project Settings** (gear icon)
2. Scroll to **"Your apps"** section
3. Find your Android app (`com.example.krushi_ai`)
4. Click **"Add fingerprint"**
5. Paste your **SHA-1** fingerprint
6. Click **"Save"**

### 4.3 Download Updated google-services.json
1. In the same settings page
2. Click **"Download google-services.json"**
3. Replace the file at:
   ```
   D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai\android\app\google-services.json
   ```

### 4.4 Enable Google Sign-In
1. Go to **Authentication** → **Sign-in method**
2. Click on **"Google"**
3. Toggle **Enable**
4. Set **Project support email** (your email)
5. Click **"Save"**

---

## 💻 **Step 5: Install Dependencies**

Run these commands in PowerShell:

```powershell
cd D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai
flutter pub get
```

This will install:
- ✅ `cloud_firestore: ^5.5.0` - Firestore database
- ✅ `intl: ^0.19.0` - Date formatting

---

## 🚀 **Step 6: Build and Run**

### 6.1 Clean Build
```powershell
flutter clean
flutter pub get
```

### 6.2 Build Android
```powershell
flutter build apk --debug
```

### 6.3 Run on Device
```powershell
flutter run --debug
```

---

## 📱 **Step 7: Test Database Integration**

### 7.1 Test Saving Data
1. Launch the app
2. Login with Google or Email/Password
3. Go to Dashboard
4. Navigate to a feature that uses AI models
5. The prediction should automatically save to Firestore

### 7.2 Test Viewing History
1. Click **"History"** in the bottom navigation bar
2. You should see your saved predictions
3. Click on any item to view details
4. Test the delete functionality

### 7.3 Verify in Firebase Console
1. Go to **Firestore Database** → **Data**
2. Open `model_history` collection
3. You should see your saved records
4. Each record should have:
   - `userId`
   - `userEmail`
   - `modelType`
   - `input`
   - `output`
   - `metadata`
   - `timestamp`

---

## 🔍 **Step 8: Monitor Database Usage**

### 8.1 Check Usage Statistics
1. Go to **Firestore Database** → **Usage** tab
2. Monitor:
   - **Reads**: Number of document reads
   - **Writes**: Number of document writes
   - **Deletes**: Number of document deletes
   - **Storage**: Total data stored

### 8.2 Free Tier Limits
- **Stored data**: 1 GiB
- **Document reads**: 50,000/day
- **Document writes**: 20,000/day
- **Document deletes**: 20,000/day

---

## 📂 **Database Collections Structure**

### Collection: `model_history`
```
model_history/
  └── {historyId}/
      ├── userId: string
      ├── userEmail: string
      ├── modelType: string (crop_disease, soil_analysis, etc.)
      ├── input: string
      ├── output: string
      ├── metadata: map
      │   ├── confidence: number
      │   ├── image_url: string (optional)
      │   └── [custom fields]
      └── timestamp: timestamp
```

### Collection: `users`
```
users/
  └── {userId}/
      ├── fullName: string
      ├── email: string
      ├── phoneNumber: string (optional)
      ├── location: string (optional)
      └── updatedAt: timestamp
```

---

## 🎯 **How to Use in Your Code**

### Example 1: Save Model Prediction
```dart
import 'package:krushi_ai/services/firestore_service.dart';

final _firestoreService = FirestoreService();

// After getting AI model prediction
await _firestoreService.saveHistory(
  modelType: 'crop_disease',
  input: userInput,
  output: modelPrediction,
  metadata: {
    'confidence': 0.95,
    'disease_name': 'Early Blight',
  },
);
```

### Example 2: Fetch User History
```dart
// Get history as list
final historyList = await _firestoreService.getUserHistory(
  limit: 50,
  modelType: 'crop_disease', // Optional filter
);

// Or use stream for real-time updates
StreamBuilder<List<HistoryModel>>(
  stream: _firestoreService.getHistoryStream(limit: 50),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final historyList = snapshot.data!;
      // Display history
    }
    return CircularProgressIndicator();
  },
)
```

### Example 3: Delete History
```dart
// Delete single record
await _firestoreService.deleteHistory(historyId);

// Clear all history
await _firestoreService.clearUserHistory();
```

---

## ✅ **Checklist**

Before testing, ensure:

- [ ] Firestore Database is enabled in Firebase Console
- [ ] Security rules are configured and published
- [ ] SHA-1 fingerprint is added to Firebase
- [ ] Updated `google-services.json` is downloaded
- [ ] Google Sign-In is enabled in Authentication
- [ ] Dependencies are installed (`flutter pub get`)
- [ ] App builds without errors
- [ ] Test user can login successfully
- [ ] History saves correctly
- [ ] History displays in the History Screen
- [ ] Delete functionality works

---

## 🐛 **Troubleshooting**

### Issue 1: "Permission Denied" Error
**Solution**: Check Firestore security rules. Ensure user is authenticated.

### Issue 2: Data Not Saving
**Solution**: 
1. Check console logs for errors
2. Verify user is logged in (`FirebaseAuth.currentUser != null`)
3. Check network connection

### Issue 3: Google Sign-In Still Failing
**Solution**:
1. Verify SHA-1 is correctly added
2. Download fresh `google-services.json`
3. Run `flutter clean` and rebuild
4. Ensure Google Sign-In is enabled in Firebase Console

### Issue 4: "Collection Not Found"
**Solution**: Collections are auto-created on first write. Try saving data first.

---

## 📚 **Additional Resources**

- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

---

## 🎉 **Success!**

Once completed, your KrushiAI app will:
- ✅ Save all AI model predictions to Firebase Firestore
- ✅ Display prediction history to users
- ✅ Allow users to view and delete history
- ✅ Support Google Sign-In authentication
- ✅ Secure user data with proper security rules

---

**Last Updated**: January 26, 2026
**Version**: 1.0
