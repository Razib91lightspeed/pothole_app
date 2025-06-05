# DropDetection – Real-Time Motion & Drop Detection App

DropDetection is a SwiftUI-based iOS app that monitors phone movement, detects sudden drops or jolts, and logs real-time accelerometer and GPS data. This app was developed by **Razib Hasan** as part of an internship project at **Solit**, focused on mobile sensing and infrastructure awareness.

---

## Features

- Real-time motion detection using CoreMotion  
- Shows whether the phone is in motion or stationary  
- Detects sudden drops/jolts using magnitude thresholds  
- Logs the latest 20 accelerometer readings with:
  - Timestamp (date & time)
  - Motion magnitude
  - GPS latitude & longitude  
- Clean SwiftUI-based UI with large animated Start/Stop button  
- Runs on real devices with Apple Developer ID setup  

---

## Tech Stack

| Component        | Framework        |
|------------------|------------------|
| Language         | Swift (SwiftUI)  |
| Motion Detection | CoreMotion       |
| Location Access  | CoreLocation     |
| UI Framework     | SwiftUI          |

---

## Project Structure

```plaintext
DropDetection/
├── DropDetectionApp.swift         # App entry point
├── ContentView.swift              # User interface
├── DropDetectionViewModel.swift  # Motion + GPS logic
├── Info.plist                     # App permissions
├── .gitignore
└── README.md
```

---

## Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/Razib91lightspeed/DropDetection.git
   cd DropDetection
   ```

2. Open in Xcode:
   ```bash
   open DropDetection.xcodeproj
   ```

3. Configure signing:
   - Go to `Signing & Capabilities`
   - Select your Apple ID team
   - Enable **Automatically manage signing**

4. Build to device:
   - Connect your iPhone via USB
   - Select your device from the top device list
   - Press ▶️ *Run*

5. On your iPhone:
   - Go to **Settings > General > VPN & Device Management**
   - Tap your developer email & Trust the developer profile

---

## 🔐 Permissions (Info.plist)

Make sure you’ve added:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to detect sudden drops.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app monitors location in the background for safety.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

---

## TODO

- [ ] CSV export button  
- [ ] Drop severity scoring  
- [ ] Push notifications for critical impacts  
- [ ] Map view to show drop locations  
- [ ] Firebase or iCloud sync  

---

## Author

**Razib Hasan**  
Intern at **Solit**  

---

## 📄 License

MIT License — feel free to use, modify, or contribute!
