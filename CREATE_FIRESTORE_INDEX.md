# 🔥 URGENT: Create Firestore Index

## Error Explanation

You're getting this error because Firestore requires a **composite index** for queries that:
1. Filter by one field (`userId`)
2. Order by another field (`timestamp`)

## ✅ SOLUTION: Create the Index

### Option 1: Quick Fix (Click the Link)

**Click this link** (it will auto-create the index):

```
https://console.firebase.google.com/v1/r/project/krushiai-e6a17/firestore/indexes?create_composite=ClRwcm9qZWN0cy9rcnVzaGlhaS1lNmExNy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvbW9kZWxfaGlzdG9yeS9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgl0aW1lc3RhbXAQAhoMCghfX25hbWVfXxAC
```

### Option 2: Manual Creation

1. Go to: https://console.firebase.google.com/
2. Select project: **krushiai-e6a17**
3. Click **Firestore Database** → **Indexes** tab
4. Click **"Create Index"**
5. Configure:
   - **Collection ID**: `model_history`
   - **Fields to index**:
     1. Field: `userId` | Order: Ascending
     2. Field: `timestamp` | Order: Descending
6. Click **"Create"**
7. Wait 2-5 minutes for index to build

---

## ⏱️ Index Building Time

- Small database: 1-2 minutes
- Medium database: 3-5 minutes
- Large database: 5-15 minutes

You'll see a **"Building"** status that will change to **"Enabled"** when ready.

---

## 🔄 After Index is Created

1. Close and reopen the app
2. Navigate to History tab
3. Data will load successfully!

---

## 📝 What This Index Does

Creates an optimized query path for:
```
WHERE userId == currentUser
ORDER BY timestamp DESC
```

This is necessary for efficient querying in Firestore.
