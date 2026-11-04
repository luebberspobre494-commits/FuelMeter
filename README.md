# FuelMeter

A small, offline fuel and service tracker for one or more cars.

## What it does

- Log every fill-up: date, odometer, liters, price per liter, full-tank flag, note.
- Overview tab with this month's spend, average consumption (L/100 km), cost per km and fill-up count.
- Two charts: consumption over time and spend per month (Swift Charts).
- Service tab for oil changes, inspections and renewals, with optional date reminders (local notifications).
- Garage tab to manage several vehicles, all stored on device with SwiftData.

No account, no network calls, no third-party SDKs.

## Requirements

- iOS 17 or later
- Xcode 16 (project generated with XcodeGen)

## Build

```sh
brew install xcodegen
xcodegen generate
open FuelMeter.xcodeproj
```

Bundle identifier: `com.luebberspobre.fuelmeter`.

## CI

`codemagic.yaml` defines three workflows:

| Workflow | Purpose |
|---|---|
| `ios-build` | Compile only, no signing (fast feedback) |
| `ios-testflight` | Archive, sign and upload to TestFlight |
| `ios-adhoc` | Archive, sign ad-hoc and publish an install page to GitHub Pages |

The signing workflows expect an environment variable group named `appstore_credentials`:

```
APP_STORE_CONNECT_PRIVATE_KEY   .p8 contents
APP_STORE_CONNECT_KEY_ID        10 character key id
APP_STORE_CONNECT_ISSUER_ID     issuer uuid
CERTIFICATE_PRIVATE_KEY         RSA private key used to create the distribution certificate
GH_PAGES_TOKEN                  GitHub token with repo scope (ad-hoc workflow only)
```

## Tests

`Tests/FuelMeterTests.swift` covers the consumption maths, partial fill-up handling, distance, cost per km and monthly bucketing.
