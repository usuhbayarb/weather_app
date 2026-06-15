# Цаг Агаар Flutter App

WeatherAPI холболт, Android/iOS бодит төхөөрөмж дээр ажиллуулахад шаардагдах үндсэн платформ файлууд нэмэгдсэн.

## API

`lib/services/weather_service.dart` файлд WeatherAPI холбогдсон. Оруулсан API key default утгаар тохируулагдсан.

Илүү аюулгүй ажиллуулах бол build үед ингэж дамжуулна:

```bash
flutter run --dart-define=WEATHER_API_KEY=YOUR_KEY
```

## Android бодит утас дээр турших

```bash
flutter pub get
flutter run -d <android-device-id>
```

Android permission:
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION

## iPhone дээр турших

macOS + Xcode шаардлагатай.

```bash
flutter pub get
cd ios
pod install
cd ..
flutter run -d <iphone-device-id>
```

Xcode дээр нээх шаардлагатай бол:

```bash
open ios/Runner.xcodeproj
```

Signing & Capabilities хэсэгт өөрийн Apple Team сонгоно.

## Тайлбар

- App bundle id одоогоор `com.example.weatherApp`.
- Android application id одоогоор `com.example.weather_app`.
- App Store / Play Store руу гаргахын өмнө эдгээрийг өөрийн домэйн/брэндээр солино.
