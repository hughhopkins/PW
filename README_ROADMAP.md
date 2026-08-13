# Roadmap

This is a human and AI generated file to capture the roadmap of the project. In chronological order.

[x] Add iOS V2 with support for SHA256 hashing:
    - v2 will have a tab at the top of the screen to switch between V1 and V2. It will remember the last used version.
    - v2 will have the same buttons to copy the password and the 15 character password.
    - V2 will use SHA256 hashing and inject a special character near the start of the output to improve compatibility with password policies.
    - In order to help users recognize the V2 password we will create a new text output that is three emojis in the top right corner. This is just a visual cue to help them remember if the output is correct instead of having to remember the hash.
    - V1 will retain the purple gradient background. V2 will have a new background color that is a dark blue.

## V2 Algorithm Spec

This is the definitive spec for the V2 password derivation. Once shipped, this is locked - users depend on identical output for the same inputs.

### V1 Recap (for reference)
1. Input: `service` (lowercased, spaces removed) + `password`
2. Hash: `SHA1(service + "||" + password + "||")`
3. Post-process: uppercase every character at an even index (0, 2, 4, ...)
4. Output: 40 hex characters e.g. `762b679fA17b10D6Cc2d2194542d2235738b3e33`

### V2 Algorithm
1. Input: `service` (lowercased, spaces removed) + `password`
2. Hash: `SHA256(service + "||" + password + "||")`
3. Post-process the 64-character hex output:
    a. **Uppercase** - same as V1: uppercase every character at an even index (0, 2, 4, ...)
    b. **Special character injection** - take the numeric value of the first hex digit (0-15) and map it to a special character from this fixed set of 16: `!@#$%^&*()-_=+~.`. Inject this character at position 3 (0-indexed) of the output, shifting subsequent characters right.
    c. **Truncate** to 40 characters (same length as V1 - easier to type manually when needed).
    d. **Policy compatibility** - the first 15 characters contain the injected special character; the remaining characters are deterministically derived from the transformed SHA256 hex output, so other character classes are not guaranteed.
4. Output: 40 characters

### Copy behaviour
- "Copy" button: copies the full 40-character output
- "Copy 15" button: copies the first 15 characters only (including the injected special character for improved policy compatibility)

### Emoji visual cue
- Derive 3 emoji from the hash bytes that are NOT part of the visible password
- Use the last 6 characters (indices 58–63) of the original 64-character hex string (before post-processing), read as three 2-character pairs; each pair's value mod 64 indexes a fixed 64-emoji list. (Wording corrected 2026-06-11 to match what all three platforms shipped; the derivation itself is unchanged.)
- Display the 3 emoji in the top-right corner of the output
- The emoji set and derivation method are defined in code and must not change once shipped

### Test vector
- Service: `facebook`, Password: `hackference`
- SHA256 input: `facebook||hackference||`
- Raw SHA256 hex: `ffd07fcb7c1869aca60d9d31d3c58beafc82d0146f0887dc15d209e1e71ead3c`
- After uppercase (even index): `FfD07fCb7c1869AcA60d9d31D3C58bEaFc82D0146f0887Dc15D209E1E71eAd3c`
- First hex digit: `f` = 15 → special char: `.`
- Final output (40 chars): `FfD.07fCb7c1869AcA60d9d31D3C58bEaFc82D01`
- First 15 chars: `FfD.07fCb7c1869`

[x] Add macOS V2 with support for SHA256 hashing:
    - Same as iOS V2.

[x] Add website V2 with support for SHA256 hashing:
    - V1/V2 version toggle with localStorage persistence
    - SHA256 implementation (self-contained, no external deps)
    - V2 algorithm: SHA256 + uppercase even indices + special char injection + truncate to 40
    - Emoji visual cue (3 emoji derived from hash tail)
    - Copy and Copy 15 buttons with feedback
    - Updated about page with V1 and V2 algorithm descriptions
