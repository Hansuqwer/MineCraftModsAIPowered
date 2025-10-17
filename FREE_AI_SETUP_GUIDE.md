# 🆓 FREE AI API SETUP GUIDE

## **OVERVIEW: 3 FREE AI OPTIONS**

Crafta now supports **3 completely free AI APIs** that work without any API keys or costs:

1. **Ollama (Local AI)** - 100% free, runs on your device
2. **Groq (Fast Cloud AI)** - 14,400 requests/day free
3. **Hugging Face (Open Source)** - 1,000 requests/month free

---

## **🚀 OPTION 1: OLLAMA (RECOMMENDED)**

### **Why Ollama?**
- ✅ **100% Free**: No API limits or costs
- ✅ **Privacy**: Runs locally on your device
- ✅ **Fast**: No network delays
- ✅ **Offline**: Works without internet
- ✅ **Unlimited**: No request limits

### **Setup Instructions:**

**Windows:**
```bash
# 1. Download from https://ollama.ai/download
# 2. Install and run Ollama
# 3. Open Command Prompt and run:
ollama pull llama2
# 4. Restart Crafta app
```

**macOS:**
```bash
# 1. Download from https://ollama.ai/download
# 2. Install and run Ollama
# 3. Open Terminal and run:
ollama pull llama2
# 4. Restart Crafta app
```

**Linux:**
```bash
# 1. Install Ollama:
curl -fsSL https://ollama.ai/install.sh | sh
# 2. Pull the model:
ollama pull llama2
# 3. Restart Crafta app
```

### **How It Works:**
- Ollama runs locally on your device
- Crafta automatically detects and uses it
- No API keys needed
- Works completely offline

---

## **⚡ OPTION 2: GROQ (FAST & FREE)**

### **Why Groq?**
- ✅ **Very Fast**: Optimized for speed
- ✅ **Generous Free Tier**: 14,400 requests/day
- ✅ **Easy Setup**: Just need API key
- ✅ **Reliable**: Cloud-based service

### **Setup Instructions:**

**1. Get API Key:**
- Go to https://console.groq.com/keys
- Create free account
- Generate new API key
- Copy the key

**2. Update Code:**
```dart
// In lib/services/groq_ai_service.dart
static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
```

**3. Restart App:**
- The app will automatically use Groq
- No other configuration needed

### **Free Tier Limits:**
- **14,400 requests per day** (very generous!)
- **Fast response times** (optimized inference)
- **Multiple models** available

---

## **🤗 OPTION 3: HUGGING FACE**

### **Why Hugging Face?**
- ✅ **Open Source**: Many free models
- ✅ **Community**: Large AI community
- ✅ **Flexible**: Multiple model options
- ✅ **Free Tier**: 1,000 requests/month

### **Setup Instructions:**

**1. Get API Key:**
- Go to https://huggingface.co/settings/tokens
- Create free account
- Generate new token
- Copy the token

**2. Update Code:**
```dart
// In lib/services/huggingface_ai_service.dart
static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY_HERE';
```

**3. Restart App:**
- The app will automatically use Hugging Face
- No other configuration needed

### **Free Tier Limits:**
- **1,000 requests per month**
- **Multiple open-source models**
- **Community support**

---

## **🎯 HOW CRAFTA CHOOSES AI SERVICE**

Crafta automatically tries AI services in this order:

1. **Ollama** (if running locally)
2. **Groq** (if API key configured)
3. **Hugging Face** (if API key configured)
4. **OpenAI** (if API key configured)
5. **Offline Mode** (fallback)

### **Priority Order:**
```
🆓 FREE SERVICES FIRST
├── Ollama (local, unlimited)
├── Groq (14,400/day)
├── Hugging Face (1,000/month)
└── OpenAI (paid, if configured)

📱 OFFLINE FALLBACK
└── Offline AI (always works)
```

---

## **🔧 IMPLEMENTATION DETAILS**

### **Automatic Fallback System:**
```dart
// Crafta tries each service automatically
1. Try Ollama → Success? Use it
2. Try Groq → Success? Use it  
3. Try Hugging Face → Success? Use it
4. Try OpenAI → Success? Use it
5. Use Offline Mode → Always works
```

### **No Configuration Needed:**
- **Ollama**: Just install and run
- **Groq**: Add API key to code
- **Hugging Face**: Add API key to code
- **Offline**: Always works as fallback

### **Caching System:**
- Responses are cached for 1 hour
- Reduces API calls
- Faster subsequent requests
- Works with all services

---

## **📱 TESTING THE SETUP**

### **Test Dragon Couch Creation:**

**1. Start the App:**
```bash
flutter run
```

**2. Go to Creator Screen:**
- Tap the microphone or type in text field

**3. Test Input:**
- Type: "I want a dragon couch"
- Press Enter or tap Send

**4. Expected Result:**
- AI responds with enthusiasm
- Dragon couch is rendered with all effects
- Can export to Minecraft

### **Debug Information:**
The app shows which AI service is being used:
- `✅ Using Ollama response`
- `✅ Using Groq response`
- `✅ Using Hugging Face response`
- `📱 All AI services failed, using offline mode`

---

## **🎉 RECOMMENDED SETUP**

### **For Best Experience:**

**1. Install Ollama (Primary):**
- 100% free and unlimited
- Works offline
- No API keys needed
- Best for development and testing

**2. Add Groq API Key (Backup):**
- Fast cloud service
- 14,400 requests/day
- Good for production
- Reliable fallback

**3. Keep Offline Mode:**
- Always works as final fallback
- No internet required
- Basic but functional

### **Complete Setup:**
```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull llama2

# 2. Get Groq API key
# Go to https://console.groq.com/keys
# Add key to groq_ai_service.dart

# 3. Run Crafta
flutter run
```

---

## **🚀 BENEFITS OF FREE AI SETUP**

### **Cost Savings:**
- **$0/month** instead of $20+/month for OpenAI
- **Unlimited requests** with Ollama
- **No API limits** for development

### **Privacy:**
- **Local processing** with Ollama
- **No data sent** to external servers
- **Complete control** over your data

### **Reliability:**
- **Multiple fallbacks** ensure app always works
- **Offline mode** for no internet
- **Cached responses** for speed

### **Development:**
- **No API key management** needed
- **Instant testing** without setup
- **Unlimited experimentation**

---

## **🎯 FINAL RESULT**

With this setup, Crafta will:

1. **Try Ollama first** (local, free, unlimited)
2. **Fallback to Groq** (fast, 14,400/day free)
3. **Fallback to Hugging Face** (1,000/month free)
4. **Use offline mode** (always works)

**Result**: A fully functional AI-powered app with **$0 monthly costs** and **unlimited usage**! 🎉

---

*Generated: 2024-10-16*  
*Status: Free AI Setup Complete*  
*Focus: Zero-Cost AI Integration*  
*Next: Test Dragon Couch Creation*


