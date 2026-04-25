# Project Gap Analysis: Flutter ShopEase Ecommerce

## Purpose

This document highlights the remaining pre-submission risks after the major SEA606 gaps were addressed.

## Priority Summary

| Priority | Area | Current Status | Why It Matters |
|---|---|---|---|
| 1 | Android/Web manual screenshots | Pending | Cross-platform evidence should still be visible in the final PDF/report |
| 2 | Full seeded integration execution | Environment-dependent | Full business-flow suites still need Firebase emulator availability |
| 3 | Session persistence at app entry | Partial | Splash routing still weakens the automatic-login story |
| 4 | Submission ZIP hygiene | Pending | Clean packaging still matters for instructor review |

## Detailed Gap Table

| Gap | Evidence | Why It Matters | Impact | Effort | Priority |
|---|---|---|---|---|---|
| Android screenshots still pending | Android smoke log exists, but screenshots are not yet collected | Final report quality and visible proof | Medium | Low | Must Fix |
| Web screenshots still pending | Web screenshot pack is still manual/pending | Final report quality and visible proof | Medium | Low | Must Fix |
| Full seeded integration suites remain environment-dependent | Android smoke passed, but full seeded suites were not fully execution-verified in this audit | Limits how strongly full end-to-end coverage can be claimed | Medium | Medium | Should Fix |
| Chrome integration still needs WebDriver | `flutter drive` is blocked without WebDriver on port `4444` | Prevents automatic web integration verification | Medium | Medium | Should Fix |
| Splash screen is not auth-aware | Startup still routes through landing | Weakens session persistence narrative | Medium | Medium | Should Fix |
| Build/cache folders can still pollute ZIP | `build/`, `.dart_tool/`, `.idea/` exist locally | Submission can look messy if not cleaned | Low | Low | Must Fix |

## Requirement-by-Requirement View

### R1. Firebase Authentication

**Completed**

- login
- signup
- logout
- validation
- Firebase Auth integration
- admin login path

**Residual limitation**

- startup session restoration is still only partially evidenced

### R2. Application Pages and Navigation

**Completed**

- clearly more than five functional pages
- customer and admin flows
- named-route structure

### R3. Cross-Platform Execution and Testing

**Completed / evidenced**

- Android toolchain available
- Chrome available
- Android integration smoke passed on `emulator-5554`

**Still pending**

- manual Android screenshots
- manual Web screenshots
- Web integration automation depends on WebDriver

### R4. Data Storage Requirements

**Completed**

- Firestore-backed cloud data
- local persistent storage implemented with `shared_preferences`
- cart persistence stores `productId`, `quantity`, `updatedAt`

### R5. Testing and Test Scripts

**Completed / evidenced**

- `flutter analyze`: passed
- unit tests: passed, 244
- widget tests: passed, 241
- integration harness fixed
- Android integration smoke passed

**Residual limitation**

- full seeded integration suites remain environment-dependent

## Recommended Final Actions

1. Capture Android screenshots listed in the manual evidence guide.
2. Capture Web screenshots listed in the manual evidence guide.
3. Run `flutter clean` before creating the ZIP.
4. Exclude `build/`, `.dart_tool/`, and IDE caches from the final archive.
5. Keep the report language honest: Android smoke is verified, full seeded suites remain environment-dependent.

## Auditor Conclusion

The earlier critical gaps are now closed:

- local persistent storage implemented
- `flutter analyze` clean
- unit tests passing
- widget tests passing
- Android integration smoke passing

The remaining work is mostly submission evidence collection and packaging, not core implementation repair.
