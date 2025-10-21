# Session Summary - API Debugging (October 21, 2025)

## User's Issue

**Problem**: "I can enter and save the API key but I don't think it's using it"

**Expected Behavior**:
- User says: "Create a blue sword with diamonds in the handle"
- OpenAI API parses this request
- App creates exactly what was requested
- 3D preview shows the blue sword with diamond handle
- Export to Minecraft works

**Actual Behavior**:
- API key is saved
- But app appears to be offline or not using API
- Creates wrong items (e.g., blue sword → purple creature)
- User says: "i dont think the ai creates correctly"

---

## What We Discovered

### Discovery 1: Two AI Services Exist

The codebase has **TWO different AI services**:

1. **`lib/services/ai_service.dart`**
   - Multi-provider fallback (OpenAI → Groq → HF → Ollama → Offline)
   - Used for conversations and some features
   - Has fallback chain that silently catches errors

2. **`lib/services/enhanced_ai_service.dart`** ⚠️ **THIS IS THE IMPORTANT ONE**
   - Directly calls OpenAI API
   - Used for creature/item creation (the main feature)
   - Called from `creature_preview_approval_screen.dart` line 509

### Discovery 2: Silent Failure

Both services were **silently falling back to offline mode** without telling the user:

```dart
try {
  // Try to call OpenAI API
  final response = await api.call();
  return response;
} catch (e) {
  // ERROR: Just falls back silently!
  return _getDefaultAttributes(); // Uses offline mode
}
```

User never sees:
- Why API call failed
- What error occurred
- That it's using offline mode

---

## What We Fixed

### Fix 1: Added Extensive Debugging to `enhanced_ai_service.dart`

Added step-by-step logging:

**Step 1: Loading API key**
```
🔍 [ENHANCED_AI] Step 1: Loading API key...
✅ [ENHANCED_AI] Step 1: API key loaded: sk-proj...kFID
🔍 [ENHANCED_AI] Key length: 169 characters
```

**Step 2: Making API call**
```
🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...
🔍 [ENHANCED_AI] Endpoint: https://api.openai.com/v1/chat/completions
🔍 [ENHANCED_AI] Model: gpt-4o-mini
🔍 [ENHANCED_AI] Message length: 42 chars
```

**Step 3: Parsing response**
```
🔍 [ENHANCED_AI] Step 2: Response received
🔍 [ENHANCED_AI] Status code: 200
✅ [ENHANCED_AI] Step 3: Parsing successful response...
✅ [ENHANCED_AI] === API CALL SUCCESS ===
```

### Fix 2: Added Timeout Handling

```dart
.timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    print('❌ [ENHANCED_AI] FAILED: API request timed out after 30 seconds');
    throw Exception('OpenAI API timeout - Check your internet connection');
  },
)
```

### Fix 3: Added Error Type Detection

Now detects:
- **Network errors** (SocketException)
- **Timeouts** (>30 seconds)
- **API errors** (401 invalid key, 429 rate limit, etc.)
- **No API key** (not found in storage)

### Fix 4: Clear Error Messages

Instead of generic "error occurred", shows:
- `❌ No internet connection or can't reach OpenAI servers`
- `❌ API request timed out after 30 seconds`
- `❌ Incorrect API key provided`
- `❌ You exceeded your current quota`

---

## New APK Built

**File**: `~/Crafta_DEBUG_API_20251021.apk` (65MB)

**Contains**:
- All the debugging added to `enhanced_ai_service.dart`
- Step-by-step logging for API calls
- Clear error messages
- Ready for device testing

---

## Next Steps

### STEP 1: Test on Device

1. Install `Crafta_DEBUG_API_20251021.apk`
2. Connect device to computer
3. Run: `adb logcat | grep "ENHANCED_AI"`
4. Try to create something: "blue sword with diamonds in handle"
5. Watch the logs

### STEP 2: Analyze Results

The logs will tell us:

**Option A: API is working**
```
✅ [ENHANCED_AI] === API CALL SUCCESS ===
```
→ Problem is in AI parsing or preview rendering

**Option B: API key not loading**
```
❌ [ENHANCED_AI] FAILED: No API key found
```
→ Problem is in ApiKeyService storage

**Option C: Network error**
```
❌ [ENHANCED_AI] Network error - No internet connection
```
→ Problem is internet or firewall

**Option D: Invalid API key**
```
❌ [ENHANCED_AI] Status: 401
❌ [ENHANCED_AI] Error message: Incorrect API key provided
```
→ Problem is wrong API key

**Option E: Rate limit / no credits**
```
❌ [ENHANCED_AI] Status: 429
❌ [ENHANCED_AI] Error message: You exceeded your current quota
```
→ Problem is OpenAI account needs credits

### STEP 3: Fix Based on Results

Once we know which scenario happens, we can fix:

- **If Option A** → Fix AI prompt or parsing logic
- **If Option B** → Fix API key storage
- **If Option C** → Check internet/permissions
- **If Option D** → Check API key is correct
- **If Option E** → Add credits to OpenAI account

---

## Important Context from User

User clarified:

> "if its connected to the openai api, and i call the ai to create a blue sword with diamonds in the handle. the ai should be able to create that. if i ask chatgpt to do it in a chat i will make the blue sword with diamonds in handle and preview it in 3d for me"

This means:
- ChatGPT CAN create these items correctly
- Crafta app should do the same
- Should create EXACTLY what user asks for
- Not just creatures - ANY item (swords, tools, blocks, etc.)

Current issue: "the ai creates wrong items" might mean:
1. API isn't being called at all (falls back to offline)
2. OR API is called but response isn't parsed correctly
3. OR prompt doesn't ask for the right thing

The debugging will tell us which one it is.

---

## Files Modified

1. **`lib/services/enhanced_ai_service.dart`**
   - Added extensive step-by-step logging (lines 44-149)
   - Added timeout handling (30 seconds)
   - Added error type detection
   - Added clear error messages

2. **`lib/services/ai_service.dart`**
   - Also added debugging (but this service isn't used for creation)
   - For completeness

---

## Files Created

1. **`API_DEBUG_TEST_GUIDE.md`** - Complete testing instructions
2. **`SESSION_SUMMARY_API_DEBUG.md`** - This file
3. **`~/Crafta_DEBUG_API_20251021.apk`** - Debug build

---

## Git Commit Ready

Changes ready to commit:
- ✅ `enhanced_ai_service.dart` modified
- ✅ `ai_service.dart` modified
- ✅ Documentation created
- ✅ APK built and tested (compiles)

**Commit message**:
```
debug: Add extensive API debugging to enhanced_ai_service

ISSUE: User reports API key saved but not being used
ISSUE: AI creates wrong items (blue sword → purple creature)

SOLUTION: Add step-by-step debugging to see exactly what's happening

Changes:
- Add detailed logging to parseEnhancedCreatureRequest()
- Log Step 1: Loading API key (with key preview)
- Log Step 2: Making API call (endpoint, model, status)
- Log Step 3: Parsing response
- Add 30-second timeout with clear error message
- Add error type detection (network, timeout, API, no key)
- Add user-friendly error messages

Output shows:
- ✅ API CALL SUCCESS (if working)
- ❌ No API key found (if storage issue)
- ❌ Network error (if connectivity issue)
- ❌ Invalid API key (if key wrong)
- ❌ Rate limit (if quota exceeded)
- ❌ Timeout (if slow connection)

Testing:
- APK builds successfully (65MB)
- Run `adb logcat | grep "ENHANCED_AI"` to see logs
- Try creating items to see which scenario occurs

Next: User tests on device, reports logs, we fix root cause

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Timeline

- **8:30 PM** - User reported API key not working
- **8:35 PM** - Discovered two AI services exist
- **8:40 PM** - Added debugging to enhanced_ai_service.dart
- **8:45 PM** - Built APK successfully
- **8:51 PM** - Created test guide and summary
- **Next** - User tests, reports logs, we continue

---

**Status**: ✅ Debugging added, APK ready for testing

**Waiting for**: User to test on device and report log output

**Then**: Fix the actual root cause based on logs
