# How to Check if API Key is Working

## Quick Test

Add this temporary code to see what's happening:

### Option 1: Check in First-Run Setup (after saving key)

In `lib/screens/first_run_setup_screen.dart`, after line where you save the key, add:

```dart
// After saving key
await _apiKeyService.saveApiKey(key);

// ADD THIS TEST:
final savedKey = await _apiKeyService.getApiKey();
print('🔍 TEST: Key after save: ${savedKey?.substring(0, 7)}...');
print('🔍 TEST: Key matches: ${savedKey == key}');
```

### Option 2: Check when app creates something

The app should be printing these logs when you try to create something:

```
🔑 [AI_SERVICE] API Keys loaded:
  - OpenAI: ✅

🚀 [AI_SERVICE] Using OpenAI API with key: sk-proj...
```

If you see:
- `OpenAI: ❌` → Key not saved or not loading
- `OpenAI: ✅` but no "Using OpenAI" message → Failing before API call
- Error message after "Using OpenAI" → API call failing

### Option 3: Quick fix - Bypass and hardcode for testing

**TEMPORARY TEST ONLY** - Add to `lib/services/ai_service.dart` line 232:

```dart
// OLD:
final apiKey = await _apiKeyService.getApiKey();

// REPLACE WITH (TEMPORARY!):
final savedKey = await _apiKeyService.getApiKey();
print('🔍 [DEBUG] Saved key: ${savedKey?.substring(0, 20)}');
print('🔍 [DEBUG] Key exists: ${savedKey != null}');

// Use saved key OR hardcode for testing
final apiKey = savedKey ?? 'YOUR_ACTUAL_KEY_HERE_FOR_TESTING';
print('🔍 [DEBUG] Using key: ${apiKey.substring(0, 20)}');
```

This will show you:
1. If the key is being saved/loaded
2. If the API call is actually being made
3. If it's the key that's the problem or something else

---

## What to Look For

### If API key IS loading but still offline:
- Check internet connection
- Check if API key is valid (try it on platform.openai.com)
- Check if you have credits left
- Look for error messages in logs

### If API key is NOT loading:
- Key might not be saving to secure storage
- Permissions issue with flutter_secure_storage
- Different app instance/reinstall cleared storage

---

## Most Likely Issue

Based on the code, I think it's **failing silently and falling back to offline mode** without telling you.

The flow is:
1. Try OpenAI → Fail for some reason
2. Catch exception
3. Try Groq → Returns offline mode
4. Try HuggingFace → Returns offline mode
5. Try Ollama → Returns offline mode
6. Return offline mode

You never see error messages because it catches them all.

---

## Proper Fix Needed

The AI service should:
1. Show a clear error message when API fails
2. Tell user it's falling back to offline mode
3. Give user option to retry or check settings
4. Not silently hide failures

This needs to be fixed in `getCraftaResponse()` to properly surface errors to the user.
