# 🔑 API Keys Setup Guide

**Status**: ⚠️ **REQUIRED FOR 3D PREVIEWS**  
**Date**: October 22, 2025

---

## 🎯 **Quick Setup**

You need to add your **Gemini API key** to enable 3D image generation:

### **1. Get Gemini API Key**
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Click "Get API Key" → "Create API Key"
4. Copy the generated key

### **2. Add to .env File**
Edit `/home/rickard/MineCraftModsAIPowered/crafta/.env`:

```bash
# Replace this line:
GEMINI_API_KEY=your_gemini_api_key_here

# With your actual key:
GEMINI_API_KEY=AIzaSyC...your_actual_key_here
```

### **3. Restart the App**
```bash
cd /home/rickard/MineCraftModsAIPowered/crafta
flutter clean
flutter pub get
flutter run
```

---

## 🔧 **Current API Status**

### **✅ Already Configured:**
- **Groq API**: `gsk_1cc920fd9ea7409ea79eecb18e4717f8...` ✅
- **OpenAI API**: `your_openai_key_here` ⚠️ (placeholder)
- **HuggingFace API**: `your_huggingface_key_here` ⚠️ (placeholder)

### **❌ Missing (Required for 3D):**
- **Gemini API**: `your_gemini_api_key_here` ❌ **NEEDED**

---

## 🎨 **What Each API Does**

### **Gemini API** (Required for 3D previews)
- **Purpose**: Generates Minecraft-style 3D preview images
- **Service**: Google Generative AI
- **Cost**: Free tier available
- **Usage**: When you create a creature, it generates a 3D image

### **Groq API** (Already working)
- **Purpose**: Fast AI responses for conversations
- **Service**: Groq (Llama models)
- **Status**: ✅ **WORKING**
- **Usage**: Voice interactions and AI suggestions

### **OpenAI API** (Optional backup)
- **Purpose**: Backup AI service
- **Service**: OpenAI GPT-4o-mini
- **Status**: ⚠️ **Placeholder**
- **Usage**: Fallback when Groq fails

---

## 🚨 **Troubleshooting**

### **"Cannot see any 3D preview"**
- **Cause**: Missing Gemini API key
- **Fix**: Add your Gemini API key to `.env` file
- **Test**: Create a creature and check preview screen

### **"Pixel overload"**
- **Cause**: Image display issues (now fixed)
- **Fix**: Updated image display with proper sizing
- **Test**: Should show smooth 3D previews

### **"API key not found"**
- **Cause**: Key not properly saved in `.env`
- **Fix**: Check file path and key format
- **Test**: Restart app after saving

---

## 📱 **Testing Steps**

1. **Add Gemini API key** to `.env` file
2. **Restart the app** completely
3. **Create a creature** with voice or text
4. **Check preview screen** - should show 3D image
5. **Verify no pixel overload** - smooth display

---

## 💡 **Pro Tips**

### **Free Tier Limits:**
- **Gemini**: 15 requests/minute, 1M tokens/day
- **Groq**: 30 requests/minute, 14K tokens/day
- **OpenAI**: $5 free credit

### **Cost Optimization:**
- Use Groq for most AI responses (fastest/cheapest)
- Use Gemini only for 3D image generation
- OpenAI as backup only

### **Development:**
- Test with simple creatures first
- Check console logs for API errors
- Use debug mode to see detailed logs

---

## 🎉 **Expected Results**

After adding the Gemini API key:

✅ **3D Preview Images** - Real Minecraft-style previews  
✅ **No Pixel Overload** - Smooth, properly sized images  
✅ **Fast Generation** - Quick 3D image creation  
✅ **Error Handling** - Graceful fallbacks if generation fails  

---

**Ready to test!** Add your Gemini API key and enjoy the 3D previews! 🚀

*Following Crafta Constitution: Safe • Kind • Imaginative* 🎨✨