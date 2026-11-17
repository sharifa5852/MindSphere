# MindSphere Flutter app

## API configuration

The API defaults to `10.0.2.2` on Android emulators and `localhost` on web,
Windows, macOS, and the iOS simulator. `10.0.2.2` does not reach the computer
from a physical Android phone. MongoDB being connected confirms only the
backend-to-database connection; the phone must also be able to reach the API.

Start the backend first:

```powershell
cd backend
npm.cmd start
```

For a physical Android phone on Windows, connect it by USB, enable USB debugging,
and accept the debugging prompt on the phone. From the project root, run:

```powershell
.\frontend\scripts\run-phone.ps1
```

The script checks the backend, runs `adb reverse tcp:5000 tcp:5000`, builds an
update with `API_BASE_URL=http://127.0.0.1:5000/api`, and installs it without
uninstalling the existing app. Approve any install prompt on the phone. It then
launches the app and attaches Flutter for hot reload. This avoids changing Wi-Fi
addresses and router/firewall issues. Keep the phone connected and the backend
running. Rerun the script after reconnecting the phone or restarting it; reverse
port forwarding is temporary. Pass `-DeviceId <id>` if multiple phones are
connected, `-Port <port>` for a different backend port, or `-NoResident` to leave
the app running without the Flutter hot-reload session.

For an Android emulator, the defaults work automatically. To set the address
explicitly:

```powershell
cd frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

For a physical phone, connect both the phone and the backend computer to the
same Wi-Fi (not mobile data), then use the computer's Wi-Fi IPv4 address from
`ipconfig`:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000/api
```

Before running the app, open `http://192.168.x.x:5000/api/health` in the
phone's browser. It must show a JSON success response. If it does not, allow
Node.js/port 5000 through the Windows firewall and turn off Wi-Fi client/AP
isolation on the router. A `No route to host` error means the phone cannot
reach that LAN address; it is not a Firebase login or password failure.

For a production build, pass an HTTPS API address:

```powershell
flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api
```

Do not put API keys, MongoDB credentials, or Firebase Admin credentials in the Flutter app.

## AI configuration

The backend uses `GEMINI_MODEL=gemini-3.5-flash-lite` and
`GEMINI_FALLBACK_MODEL=gemini-3.6-flash`. Configure these in `backend/.env`
and restart the backend after changing them. A busy model is retried once,
then the fallback is tried. Each attempt has a 12-second limit; AI requests
in the app allow 60 seconds, including optional local emotion detection.
If both models are unavailable, chat shows a retry message. Mood analysis
does not invent an emotion or confidence score when the providers fail.

## Add demo data

With the backend `.env` configured and MongoDB reachable, set `DEMO_USER_ID`
to the Firebase UID of the account that should see the sample data, then run:

```powershell
cd backend
$env:DEMO_USER_ID = "your-firebase-user-uid"
$env:DEMO_USER_EMAIL = "your-account-email"
npm.cmd run seed:demo
```

This adds 20 demo mood check-ins, 20 journal entries, 20 assessment-history
records, and 20 clearly labeled therapist profiles. Running it again replaces
only data created by this demo seeder and preserves real user entries. The
Firebase account and optional expected email are checked before any writes.
The shared demo directory profiles are updated in place. The
therapist profiles are fictional and marked unverified.
