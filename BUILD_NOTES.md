# Build notes

The project intentionally has no third-party dependencies and no backend.

The GitHub Actions workflow builds an unsigned IPA on a standard macOS runner.
Public GitHub repositories can use standard GitHub-hosted runners free of charge.

After obtaining the IPA, use your chosen iOS sideloading/signing method with your own Apple Account.
Apple's free Personal Team provisioning is limited to 7 days, so a temporary personal install must be refreshed/reinstalled periodically.

The calendar engine has been checked against the requested examples:
- 19 May 1991 -> Year 1998 / Month 3 / Day 1
- 13 Oct 2001 -> Year 2008 / Month 8 / Day 21
- 5 Aug 1995 -> Year 2002 / Month 5 / Day 28
- 6 Aug 1995 -> Year 2002 / Month 6 / Day 1
- 7 Aug 1995 -> Year 2002 / Month 6 / Day 2
