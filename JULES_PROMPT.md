<instruction>You are an expert software engineer. You are working on a WIP branch. Please run `git status` and `git diff` to understand the changes and the current state of the code. Analyze the workspace context and complete the mission brief.</instruction>
<workspace_context>
<artifacts>
--- CURRENT TASK CHECKLIST ---
# Task: Complete Firebase Setup

- [x] Explore existing providers and services <!-- id: 0 -->
- [x] Create Firestore service for data operations <!-- id: 1 -->
- [x] Update VisitorRepository to use Firestore <!-- id: 2 -->
- [x] Update AuthRepository to use Firebase Auth + Firestore <!-- id: 3 -->
- [x] Update GuardRepository to use Firestore <!-- id: 4 -->
- [x] Update FlatRepository to use Firestore <!-- id: 5 -->
- [x] Update AdminProvider for async operations <!-- id: 6 -->
- [x] Fix AuthProvider for async guard operations <!-- id: 7 -->
- [x] Verify build and test <!-- id: 8 -->

--- IMPLEMENTATION PLAN ---
# Complete Firebase Setup Implementation Plan

I'll create Firestore services and update the existing providers to persist data to Firebase.

## Proposed Changes

### [New Firestore Services]

#### [NEW] [firestore_service.dart](file:///c:/Users/Nikhi/guardrail_1/GuardRail/lib/services/firestore_service.dart)
- Central Firestore service for CRUD operations on all collections (users, visitors, flats, guards, guardChecks)

---

### [Repository Updates]

#### [MODIFY] [visitor_repository.dart](file:///c:/Users/Nikhi/guardrail_1/GuardRail/lib/repositories/visitor_repository.dart)
- Add Firestore integration for visitor data persistence

#### [MODIFY] [flat_repository.dart](file:///c:/Users/Nikhi/guardrail_1/GuardRail/lib/repositories/flat_repository.dart)
- Add Firestore integration for flat data

#### [MODIFY] [guard_repository.dart](file:///c:/Users/Nikhi/guardrail_1/GuardRail/lib/repositories/guard_repository.dart)
- Add Firestore integration for guard data

#### [MODIFY] [auth_repository.dart](file:///c:/Users/Nikhi/guardrail_1/GuardRail/lib/repositories/auth_repository.dart)
- Add Firestore user profile storage

---

## Verification Plan

### Automated Tests
- Run `flutter analyze`
- Run `flutter build apk --debug`

### Manual Verification
- Launch app and verify Firebase operations work
</artifacts>
</workspace_context>
<mission_brief>[Describe your task here...]</mission_brief>