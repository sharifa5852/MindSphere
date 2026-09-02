# MindSphere Flutter app

## API configuration

The API address is configured at build time; it is not committed in source code.

For an Android emulator with the backend running on this computer:

```powershell
flutter run
```

For a physical phone, replace the value with your computer's current LAN address:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000/api
```

For a production build, pass an HTTPS API address:

```powershell
flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api
```

Do not put API keys, MongoDB credentials, or Firebase Admin credentials in the Flutter app.
