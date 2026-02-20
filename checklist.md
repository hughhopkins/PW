# App Store Submission Checklist — PW 2.0.0

## Pre-submission

### Code
- [x] All three platforms (iOS, macOS, web) produce identical V1 and V2 outputs
- [x] Emoji cues match across all platforms
- [ ] Copy and Copy 15 work correctly
- [ ] Version toggle persists across app relaunch
- [ ] V1 output unchanged from previous release (no regression)

### iOS
- [ ] Build succeeds with no warnings (Release config)
- [ ] Test on physical device
- [ ] Test on smallest supported screen (iPhone SE)
- [ ] Test on largest screen (iPhone 15 Pro Max / iPad)
- [ ] Deployment target set correctly (iOS 13.0)
- [ ] Version: 2.0.0, Build: 1
- [ ] App icon displays correctly (new sunset gradient)
- [ ] No crashes on launch

### macOS
- [ ] Build succeeds with no warnings (Release config)
- [ ] Test on physical Mac
- [ ] Deployment target set correctly (macOS 10.15)
- [ ] Version: 2.0.0
- [ ] App icon displays correctly (new sunset gradient)
- [ ] Keyboard shortcuts work (⌘1, ⌘2, ⇧⌘C)
- [ ] Auto-copy toggle works
- [ ] No crashes on launch

### Website
- [ ] Deployed and working at production URL
- [ ] V1/V2 toggle works
- [ ] Copy buttons work (requires HTTPS)
- [ ] Responsive layout on mobile
- [ ] Open source link points to mono repo

## App Store Connect — iOS

### App Information
- [ ] App name: PW
- [ ] Subtitle updated (mention V2 / SHA256 if desired)
- [ ] Privacy policy URL set
- [ ] Category: Utilities

### Version Information
- [ ] What's New text written
- [ ] Description updated to mention V2
- [ ] Keywords updated
- [ ] Screenshots uploaded for required device sizes:
  - [ ] 6.7" (iPhone 15 Pro Max)
  - [ ] 6.5" (iPhone 11 Pro Max) — if still required
  - [ ] 5.5" (iPhone 8 Plus)
  - [ ] iPad Pro 12.9" (if universal)
- [ ] App preview video (optional)

### Build
- [ ] Archive created in Xcode (Product > Archive)
- [ ] Uploaded to App Store Connect via Xcode or Transporter
- [ ] Build appears in App Store Connect
- [ ] Build selected for submission

### Review
- [ ] Export compliance (uses encryption: Yes — SHA256 is exempt under standard encryption exemptions)
- [ ] Content rights: no third-party content
- [ ] Advertising identifier: No
- [ ] Submit for review

## App Store Connect — macOS

### Version Information
- [ ] What's New text written
- [ ] Description updated to mention V2
- [ ] Keywords updated
- [ ] Screenshots uploaded:
  - [ ] Mac screenshot (1280x800 or 1440x900)
- [ ] App preview video (optional)

### Build
- [ ] Archive created in Xcode (Product > Archive)
- [ ] Uploaded to App Store Connect
- [ ] Build appears in App Store Connect
- [ ] Build selected for submission

### Review
- [ ] Export compliance (same as iOS)
- [ ] Sandbox entitlements correct
- [ ] Submit for review

## Post-submission
- [ ] Monitor review status
- [ ] Verify live listings once approved
- [ ] Tag release in git (`git tag v2.0.0`)
