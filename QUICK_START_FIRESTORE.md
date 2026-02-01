# 🚀 Quick Start Guide - Firebase Firestore Integration

## What Was Created

### ✅ **New Files Created:**

1. **`lib/models/history_model.dart`**
   - Data model for storing AI predictions
   - Handles conversion to/from Firestore

2. **`lib/services/firestore_service.dart`**
   - Complete database service
   - Save, fetch, delete history operations
   - User profile management

3. **`lib/screens/history/history_screen.dart`**
   - UI to view all saved predictions
   - Filter by model type
   - Delete individual or all records

4. **`lib/screens/model_prediction_example_screen.dart`**
   - Example showing how to integrate Firestore
   - Copy this pattern to your AI screens

### ✅ **Updated Files:**

1. **`pubspec.yaml`**
   - Added `cloud_firestore: ^5.5.0`
   - Added `intl: ^0.19.0` for date formatting

2. **`lib/screens/dashboard/dashboard_screen.dart`**
   - Added navigation to History screen
   - Click "History" in bottom nav to view

---

## 🎯 Next Steps

### Step 1: Install Dependencies
```powershell
cd D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai
flutter pub get
```

### Step 2: Firebase Console Setup

#### A. Enable Firestore
1. Go to https://console.firebase.google.com/
2. Select project: **krushiai-e6a17**
3. Click **"Firestore Database"** → **"Create database"**
4. Choose **"Start in test mode"**
5. Select location (e.g., asia-south1)
6. Click **"Enable"**

#### B. Fix Google Sign-In Error

**Get SHA-1 fingerprint:**
```powershell
cd D:\CHARUSAT\Sem-6\MAD\KrushiAI\krushi_ai\android
.\gradlew signingReport
```

Copy the SHA-1 value (looks like: `AA:BB:CC:...`)

**Add to Firebase:**
1. Firebase Console → **Settings** (gear icon)
2. Scroll to **"Your apps"** → Android app
3. Click **"Add fingerprint"**
4. Paste SHA-1
5. Click **"Save"**
6. Download new **google-services.json**
7. Replace at: `android/app/google-services.json`

**Enable Google Sign-In:**
1. Go to **Authentication** → **Sign-in method**
2. Click **"Google"** → Toggle **Enable**
3. Add support email → **Save**

#### C. Configure Security Rules
1. Firestore Database → **"Rules"** tab
2. Copy rules from `FIRESTORE_DATABASE_SETUP.md` (Step 2)
3. Click **"Publish"**

### Step 3: Build & Run
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 💡 How to Use in Your Code

### Save AI Model Prediction to Database

```dart
import 'package:krushi_ai/services/firestore_service.dart';

final _firestoreService = FirestoreService();

// After getting your AI model's prediction
Future<void> saveModelPrediction() async {
  try {
    // Example: You called your AI API and got a result
    final modelResponse = await yourAiApiCall();
    
    // Save to Firestore
    await _firestoreService.saveHistory(
      modelType: 'crop_disease',      // Type: crop_disease, soil_analysis, etc.
      input: userInputText,            // What user entered/uploaded
      output: modelResponse,           // AI model's prediction
      metadata: {                      // Optional extra data
        'confidence': 0.95,
        'disease_name': 'Early Blight',
        'image_url': uploadedImageUrl,
      },
    );
    
    print('✅ Saved to history!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### View History
Users can click **"History"** in the bottom navigation to see all saved predictions.

---

## 📊 Available Model Types

Use these for the `modelType` parameter:

- `'crop_disease'` - Disease detection predictions
- `'soil_analysis'` - Soil health analysis
- `'weather_forecast'` - Weather-based recommendations
- `'pest_detection'` - Pest identification
- `'crop_recommendation'` - Crop suggestions

---

## 🔧 Available Methods in FirestoreService

```dart
// Save prediction
await _firestoreService.saveHistory(...)

// Get all history
final list = await _firestoreService.getUserHistory(limit: 50)

// Get history stream (real-time)
Stream<List<HistoryModel>> stream = _firestoreService.getHistoryStream()

// Delete one record
await _firestoreService.deleteHistory(historyId)

// Clear all history
await _firestoreService.clearUserHistory()

// Get statistics
final stats = await _firestoreService.getUsageStats()
```

---

## 📁 Database Structure

### Collection: `model_history`
```
{
  "userId": "user_firebase_uid",
  "userEmail": "user@example.com",
  "modelType": "crop_disease",
  "input": "Yellow spots on tomato leaves",
  "output": "Detected: Early Blight. Confidence: 87%...",
  "metadata": {
    "confidence": 0.87,
    "disease_name": "Early Blight"
  },
  "timestamp": "2026-01-26T10:30:00Z"
}
```

---

## ✅ Testing Checklist

- [ ] Run `flutter pub get`
- [ ] Enable Firestore in Firebase Console
- [ ] Add SHA-1 fingerprint
- [ ] Download new google-services.json
- [ ] Enable Google Sign-In
- [ ] Set security rules
- [ ] Build app successfully
- [ ] Test login (Email or Google)
- [ ] Save a prediction (use example screen)
- [ ] View in History screen
- [ ] Check Firebase Console → Firestore → Data
- [ ] Test delete functionality

---

## 🎯 Where to Add Your AI Integration

**Option 1**: Use the Example Screen
- File: `lib/screens/model_prediction_example_screen.dart`
- Already has complete integration
- Just replace mock prediction with real API call

**Option 2**: Add to Existing Screens
- Copy the `_firestoreService.saveHistory()` pattern
- Add after your AI model returns results
- See examples in `model_prediction_example_screen.dart`

---

## 🆘 Quick Troubleshooting

**Google Sign-In Error 10**
→ Add SHA-1 fingerprint & download new google-services.json

**Permission Denied Error**
→ Check Firestore security rules are published

**Data Not Saving**
→ Ensure user is logged in, check console logs

**History Screen Empty**
→ Save at least one prediction first

---

## 📚 Full Documentation

See **`FIRESTORE_DATABASE_SETUP.md`** for complete step-by-step instructions.

---

**Ready to test!** 🚀

Run:
```powershell
flutter clean
flutter pub get
flutter run
```
