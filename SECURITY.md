# Security Policy

## Firebase API Keys Are Public

This repo contains Firebase client API keys in:

- `saxstart/lib/firebase_options.dart`
- `saxstart/android/app/google-services.json`
- `saxstart/ios/Runner/GoogleService-Info.plist` *(once iOS is set up)*

**These are not secrets.** They are public identifiers, intentionally
embedded in the client app and shipped to every user who installs it.

### Why this is safe

Per the official Firebase documentation:

> "API keys for Firebase are different from typical API keys. Unlike how API
> keys are typically used, API keys for Firebase services are not used to
> control access to backend resources; that can only be done with Firebase
> Security Rules."
>
> — <https://firebase.google.com/docs/projects/api-keys>

Access to the SaxStart backend is protected by:

1. **Firestore Security Rules** (see `saxstart/firestore.rules`) — users can
   only read and write their own documents under `users/{uid}`.
2. **Firebase Authentication** — every request must be signed by an
   authenticated user, and the rules verify `request.auth.uid` matches the
   resource owner.
3. **Android package ID restriction** — the Android API key is restricted in
   Google Cloud Console to only work for apps signed with the
   `com.saxstart.saxstart` package ID and SHA fingerprint.

### GitHub secret-scanning false positives

GitHub's secret scanner flags Google API keys by pattern match, even when
they are intentionally public Firebase client keys. Any alerts of this form
should be closed as **"False positive"** with a reference to this document.

## Reporting real security issues

If you discover a *real* vulnerability (for example, a Firestore rule bypass,
an XSS, or a credential leak that is *not* a Firebase client key), please
email the maintainer rather than opening a public issue.

## What IS secret and must never be committed

- Service account JSON files (`*-firebase-adminsdk-*.json`) — backend only
- RevenueCat secret keys (when we add IAP)
- Apple / Google signing key `.jks` / `.p12` files
- Any `.env` with private tokens

These are excluded from git via `.gitignore`.
