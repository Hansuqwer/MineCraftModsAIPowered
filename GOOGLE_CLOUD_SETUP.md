# Google Cloud OAuth Setup for Vertex AI Imagen

## 🎯 Goal
Enable real 3D image generation using Vertex AI Imagen API with OAuth 2.0 authentication.

## 📋 Prerequisites
- Google account
- Access to Google Cloud Console
- Android device/emulator for testing

## 🔧 Step-by-Step Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Project name: `crafta-minecraft-ai` (or your preferred name)
4. Click "Create"
5. Note your **Project ID** (e.g., `crafta-minecraft-ai-123456`)

### 2. Enable Required APIs
1. In Google Cloud Console, go to "APIs & Services" → "Library"
2. Search and enable these APIs:
   - **Vertex AI API**
   - **Cloud Resource Manager API**
   - **Service Usage API**

### 3. OAuth 2.0 Client ID (Already Created!)
✅ **Your OAuth Client is already configured!**

**Client Details:**
- **Client ID:** `80309731075-j184cbi2pddojfo6vdioaipm13j0vqlt.apps.googleusercontent.com`
- **Project ID:** `unified-ruler-475913-r5`
- **Package name:** `com.example.crafta` (current app package)
- **SHA-1 fingerprint:** `97:10:54:5D:AE:8A:68:13:BE:07:83:64:52:95:02:AC:FD:EB:E7:A2`

**Note:** You may need to add the SHA-1 fingerprint to your existing OAuth client in Google Cloud Console.

### 4. Get SHA-1 Fingerprint
Run this command to get your SHA-1 fingerprint:
```bash
# For debug keystore (development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore (production)
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

### 5. Environment Variables (Already Updated!)
✅ **Your .env file has been updated with real values:**

```env
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT_ID=unified-ruler-475913-r5
GOOGLE_CLOUD_CLIENT_ID=80309731075-j184cbi2pddojfo6vdioaipm13j0vqlt.apps.googleusercontent.com

# Keep existing keys
OPENAI_API_KEY=sk-proj-placeholder-key-needs-real-key
GROQ_API_KEY=gsk_1cc920fd9ea7409ea79eecb18e4717f8.eMxPRRsSJJ9FSuGTLRDFCHFK
GEMINI_API_KEY=AIzaSyCak_qZxS99-sZZAHe3GQlapgHtXSv76sM
```

## 🔐 Authentication Flow

The app will use OAuth 2.0 to authenticate with Google Cloud:
1. User opens app
2. App requests Google Cloud authentication
3. User grants permissions
4. App receives access token
5. App uses token for Vertex AI Imagen API calls

## 🧪 Testing

### Test OAuth Setup:
1. Build and install APK
2. Open app and go to 3D preview
3. Should prompt for Google sign-in
4. After authentication, 3D images should generate

### Fallback Behavior:
- If OAuth fails: Shows beautiful fallback icons
- If API fails: Shows error message with retry option
- If timeout: Shows loading then fallback

## 🚨 Troubleshooting

### Common Issues:
1. **"OAuth client not found"**
   - Check package name matches exactly
   - Verify SHA-1 fingerprint is correct

2. **"Project not found"**
   - Verify project ID is correct
   - Check project has Vertex AI API enabled

3. **"Insufficient permissions"**
   - Add required scopes to OAuth consent screen
   - Ensure service account has Vertex AI permissions

### Debug Commands:
```bash
# Check if APIs are enabled
gcloud services list --enabled --filter="name:aiplatform.googleapis.com"

# Test authentication
gcloud auth application-default login
```

## 📱 App Configuration

The app is already configured to use OAuth. Key files:
- `lib/services/firebase_image_service.dart` - Vertex AI integration
- `lib/main.dart` - OAuth initialization
- `.env` - Environment variables

## 🎉 Success Indicators

When working correctly:
- ✅ User sees Google sign-in prompt
- ✅ 3D preview generates real AI images
- ✅ No "Generating 3D preview..." stuck state
- ✅ Beautiful fallback if generation fails

## 📞 Support

If you encounter issues:
1. Check Google Cloud Console for error logs
2. Verify all APIs are enabled
3. Confirm OAuth client configuration
4. Test with debug keystore first