# Firebase Setup Guide for BookSlot

This guide will help you set up Firebase for the BookSlot application.

## Prerequisites

- A Firebase account (free tier is sufficient)
- Flutter project with Firebase dependencies added

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter your project name (e.g., "bookslot-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Firebase to Your App

### For Web (Chrome/Debug)

1. In Firebase Console, click the Web icon (`</>`)
2. Enter your app name (e.g., "BookSlot Web")
3. Click "Register app"
4. Copy the Firebase configuration values
5. Update `lib/firebase_options.dart` with your actual values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

### For Android

1. In Firebase Console, click the Android icon
2. Enter your package name (e.g., "com.example.bookslot")
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Update `android/build.gradle` and `android/app/build.gradle` as instructed

### For iOS

1. In Firebase Console, click the iOS icon
2. Enter your bundle ID (e.g., "com.example.bookslot")
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 3: Set Up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location (choose closest to your users)
5. Click "Create"

## Step 4: Set Up Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. Click "Save"

## Step 5: Configure Firestore Rules

Go to Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read schedules, only admins can write
    match /schedules/{scheduleId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Users can read their own bookings, admins can read all
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
  }
}
```

## Step 6: Update Firebase Configuration

After setting up your Firebase project, update the `lib/firebase_options.dart` file with your actual configuration values from the Firebase Console.

## Step 7: Run the App

```bash
flutter pub get
flutter run
```

## Features Available with Firebase

- ✅ Real-time data synchronization
- ✅ Cloud persistence
- ✅ User authentication
- ✅ Automatic data backup
- ✅ Cross-device synchronization
- ✅ Offline support (with local fallback)

## Testing

The app will automatically detect if Firebase is available:
- If Firebase is configured and accessible, it uses Firebase
- If Firebase is not available, it falls back to local storage
- Demo accounts work in both modes

## Demo Accounts

- **Admin**: `admin@bookslot.com` / `admin123`
- **User**: `user@bookslot.com` / `user123`

## Troubleshooting

### Firebase Initialization Failed

1. Check your Firebase configuration in `firebase_options.dart`
2. Ensure your Firebase project is set up correctly
3. Verify Firestore rules allow read/write access
4. Check internet connectivity

### Authentication Issues

1. Ensure Email/Password authentication is enabled
2. Check Firebase Auth rules
3. Verify user exists in Firestore users collection

### Firestore Permission Denied

1. Review and update Firestore rules
2. Ensure user is authenticated
3. Check user role (isAdmin field)

## Production Deployment

For production deployment:

1. Change Firestore rules to be more restrictive
2. Enable Firebase App Check
3. Set up proper error handling
4. Configure Firebase Security Rules appropriately
5. Enable Firebase Analytics and Crashlytics

## Next Steps

- Add push notifications
- Implement file storage for images
- Set up Firebase Functions for backend logic
- Add Firebase Analytics for tracking
- Enable Firebase Performance Monitoring
