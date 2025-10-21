# API Debugging Test Guide - October 21, 2025

## New APK Location

**File**: `~/Crafta_DEBUG_API_20251021.apk` (65MB)

This APK has extensive debugging added to show exactly what's happening with the API calls.

---

## What Was Added

✅ **Step-by-step logging** in `enhanced_ai_service.dart`:
- Step 1: Loading API key from storage
- Step 2: Making API call to OpenAI
- Step 3: Parsing response

✅ **Detailed error messages**:
- Shows API key prefix and length
- Shows HTTP status codes
- Shows error messages from OpenAI
- Detects network vs timeout vs API errors

✅ **Timeout handling**: 30-second timeout with clear message

---

## How to Test

### Test 1: Create Something Simple

1. **Install APK** on your device
2. **Open the app**
3. **Enter your API key** (if not already saved)
4. **Try to create something**:
   - Example: "blue sword"
   - Example: "red dragon"
   - Example: "gold helmet"
5. **Connect device to computer**
6. **Run**: `adb logcat | grep "ENHANCED_AI"`

---

## What to Look For in Logs

### ✅ SUCCESS (API working):
```
🔍 [ENHANCED_AI] === API CALL START ===
🔍 [ENHANCED_AI] User request: blue sword
🔍 [ENHANCED_AI] Step 1: Loading API key...
✅ [ENHANCED_AI] Step 1: API key loaded: sk-proj...kFID
🔍 [ENHANCED_AI] Key length: 169 characters
🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...
🔍 [ENHANCED_AI] Endpoint: https://api.openai.com/v1/chat/completions
🔍 [ENHANCED_AI] Model: gpt-4o-mini
🔍 [ENHANCED_AI] Step 2: Response received
🔍 [ENHANCED_AI] Status code: 200
✅ [ENHANCED_AI] Step 3: Parsing successful response...
✅ [ENHANCED_AI] === API CALL SUCCESS ===
🤖 [ENHANCED_AI] Response preview: { "baseType": "sword", "color": "#0000FF" ...
```

### ❌ FAILURE 1: No API Key
```
🔍 [ENHANCED_AI] === API CALL START ===
🔍 [ENHANCED_AI] Step 1: Loading API key...
❌ [ENHANCED_AI] FAILED: No API key found in storage or .env
💡 [ENHANCED_AI] User needs to configure API key in settings
⚠️ [ENHANCED_AI] Falling back to offline mode (default creature)
```

**What this means**: API key not saved or not loading from storage

### ❌ FAILURE 2: Network Error
```
🔍 [ENHANCED_AI] === API CALL START ===
✅ [ENHANCED_AI] Step 1: API key loaded: sk-proj...
🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...
❌ [ENHANCED_AI] === API CALL FAILED ===
❌ [ENHANCED_AI] Error type: SocketException
💡 [ENHANCED_AI] Network error - No internet connection or can't reach OpenAI servers
⚠️ [ENHANCED_AI] Falling back to offline mode
```

**What this means**: No internet or can't reach OpenAI servers

### ❌ FAILURE 3: Timeout
```
🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...
❌ [ENHANCED_AI] FAILED: API request timed out after 30 seconds
💡 [ENHANCED_AI] This usually means slow internet connection
⚠️ [ENHANCED_AI] Falling back to offline mode
```

**What this means**: Internet is too slow or OpenAI servers are slow

### ❌ FAILURE 4: Invalid API Key
```
✅ [ENHANCED_AI] Step 1: API key loaded: sk-proj...
🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...
🔍 [ENHANCED_AI] Step 2: Response received
🔍 [ENHANCED_AI] Status code: 401
❌ [ENHANCED_AI] FAILED: OpenAI API returned error status
❌ [ENHANCED_AI] Status: 401
❌ [ENHANCED_AI] Body: {"error":{"message":"Incorrect API key provided",...}}
❌ [ENHANCED_AI] Error message: Incorrect API key provided
⚠️ [ENHANCED_AI] Falling back to offline mode
```

**What this means**: API key is wrong or expired

### ❌ FAILURE 5: Rate Limit / No Credits
```
🔍 [ENHANCED_AI] Status code: 429
❌ [ENHANCED_AI] Error message: You exceeded your current quota
```

**What this means**: API key has no credits left or rate limited

---

## Commands to View Logs

### Option 1: Live logging (real-time)
```bash
adb logcat | grep "ENHANCED_AI"
```

### Option 2: Save logs to file
```bash
adb logcat > /tmp/crafta_logs.txt
# Then search for ENHANCED_AI in the file
```

### Option 3: Filter only errors
```bash
adb logcat | grep -E "(ENHANCED_AI|ERROR)"
```

### Option 4: Clear old logs first
```bash
adb logcat -c  # Clear logs
# Then run app
adb logcat | grep "ENHANCED_AI"
```

---

## Expected Results

### If API key IS working:
- You'll see "✅ API CALL SUCCESS"
- Creature will match your request
- App will create what you asked for (sword = sword, dragon = dragon)

### If API key is NOT working:
- You'll see one of the FAILURE scenarios above
- App will fall back to offline mode
- Creature will be generic (not matching request)

---

## Important Notes

1. **This is a DEBUG build** - lots of logging to help us find the problem
2. **Check ALL the logs** - don't just look at the last line
3. **The key is shown partially** - `sk-proj...kFID` to avoid exposing full key
4. **Offline fallback is automatic** - app won't crash, just uses default creature

---

## What to Report Back

Please tell me:

1. **Did you see the ENHANCED_AI logs?** (Yes/No)
2. **Which scenario did you see?** (SUCCESS, FAILURE 1-5, or something else)
3. **What did you try to create?** (e.g., "blue sword")
4. **What did it actually create?** (e.g., "generic creature")
5. **Copy the full log output** (all lines with ENHANCED_AI)

---

## Next Steps After Testing

Based on your results:

- **If SUCCESS but wrong item created** → Issue is in AI parsing, not API
- **If FAILURE 1 (no key)** → Fix API key storage
- **If FAILURE 2 (network)** → Check internet connection
- **If FAILURE 4 (invalid key)** → Check API key is correct
- **If FAILURE 5 (quota)** → Need to add credits to OpenAI account

---

**Created**: October 21, 2025, 8:51 PM
**Build**: Crafta_DEBUG_API_20251021.apk (65MB)
**Purpose**: Diagnose why API calls aren't working
