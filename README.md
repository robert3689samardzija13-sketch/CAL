# Custom Calendar — temporary personal iOS build

Native SwiftUI calendar using a configurable calendar system.

Default:
- Epoch: 0001-01-07 = Year 1 / Month 1 / Day 1
- 13 months
- 28 days/month
- 364 days/year
- No Year Day
- No Leap Day

Features in v0.1:
- Regular iOS-style month grid
- Swipe-like previous/next month buttons
- Today
- Custom month names
- Custom weekday names
- Custom era name
- Editable epoch
- Add events
- Yearly celebrations
- Gregorian date conversion
- Local-only storage

## Free build strategy

The project can be built on a GitHub-hosted macOS runner. Public repositories can use standard GitHub-hosted runners free and unlimited.

The workflow in `.github/workflows/build.yml` creates an **unsigned IPA**. The IPA can then be signed/installed for personal testing using a sideloading tool such as SideStore with your Apple Account.

This is deliberately a temporary/personal build. It does not use iCloud, a server, App Store Connect, or paid developer services.

Important: Apple's free Personal Team provisioning expires after 7 days, so the app needs to be refreshed/reinstalled periodically.

## GitHub

1. Create a public GitHub repository.
2. Upload this project.
3. Push/commit the files.
4. Open Actions → "Build unsigned iOS app".
5. Download the `CustomCalendar-unsigned-ipa` artifact.

## SideStore

SideStore supports Windows for its initial installation and uses an Apple Account to sign apps for personal use. Follow its current official documentation for installation and refresh.

## Permanent version later

When you want the App Store version, keep this codebase and add:
- SwiftData or CloudKit
- iCloud sync
- widgets
- notifications
- polished event editing
- multiple calendars
- App Store signing/distribution
