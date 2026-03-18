# Anahuac-Connect

Aplicación Flutter para Anahuac-Connect.

## Resumen
Este repositorio contiene el frontend de la app (Flutter) y un archivo SQL de tablas en `db/tablas.sql`.

**Estructura principal**
- `frontend/` — proyecto Flutter (iOS / Android / web / desktop)
- `db/tablas.sql` — esquema de la base de datos

## Requisitos
- Flutter SDK (estable). Ver: https://docs.flutter.dev
- Android SDK / Android Studio (para Android)
- (Opcional) Xcode si se quiere compilar en macOS/iOS
- Java JDK (requerido por Android toolchain)

## Comprobaciones iniciales
Abre una terminal (PowerShell en Windows) y ejecuta:

```bash
flutter doctor
flutter --version
```

Corrige cualquier advertencia que `flutter doctor` reporte (instalar Android SDK, plataformas, licencias, etc.).

## Preparar el proyecto
1. Clona el repositorio si no lo has hecho:

```bash
git clone <repo-url>
cd Anahuac-Connect/frontend
```

2. Obtener dependencias:

```bash
flutter pub get
```

3. Lista dispositivos/emuladores disponibles:

```bash
flutter devices
```

## Ejecutar en Android (Windows)
1. Enciende un emulador de Android desde Android Studio o conecta un dispositivo físico (habilita Depuración USB).
2. Ejecuta:

```bash
cd Anahuac-Connect/frontend
flutter run -d <device-id>
```

Si sólo hay un emulador conectado, `flutter run` lo detectará automáticamente.

## Ejecutar en Web (Chrome)

```bash
cd Anahuac-Connect/frontend
flutter run -d chrome
```

## Ejecutar en Windows (desktop)

```bash
cd Anahuac-Connect/frontend
flutter config --enable-windows-desktop
flutter run -d windows
```

## Build para producción

- Android (APK):

```bash
cd Anahuac-Connect/frontend
flutter build apk --release
```

- Web (release):

```bash
flutter build web --release
```

## Base de datos
El esquema de la base de datos está en `db/tablas.sql`. Importa ese archivo en tu servidor de base de datos si la app requiere un backend. Este repo no incluye un backend listo para producción.

## Problemas comunes
- Si `flutter pub get` falla: verifica conexión a internet y versión de Dart/Flutter.
- Si Android no detecta dispositivos: abre Android Studio → AVD Manager y crea/arranca un emulador.
- Permisos Android: revisa `android/app/src/main/AndroidManifest.xml` si faltan permisos.

## Contribuir
- Abre un issue o PR con cambios claros.

---
Si quieres, puedo añadir pasos para compilar la APK firmada, o preparar CI/CD (GitHub Actions). ¿Deseas que lo añada?
