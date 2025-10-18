# 📱 Phone Testing Guide

**Date**: 2024-10-18  
**Status**: ✅ **READY FOR TESTING**  
**APK**: `build/app/outputs/flutter-apk/app-debug.apk`  

---

## 🚀 **Quick Setup**

### **1. Install APK**
```bash
# Copy APK to your phone, then install
adb install build/app/outputs/flutter-apk/app-debug.apk
# OR
# Transfer APK file to phone and install manually
```

### **2. Grant Permissions**
- **Microphone**: For voice interaction
- **Storage**: For Minecraft export files
- **Internet**: For AI services (optional - offline mode works too)

---

## 🧪 **Core Features to Test**

### **🎤 Voice Interaction**
1. **Launch app** → Welcome screen
2. **Tap "Start Creating"** → Creator screen
3. **Tap and hold microphone** → Speak "Create a dragon"
4. **Verify**: Speech converts to text, Crafta responds with voice

### **🌍 Language Switching**
1. **Find language option** (usually in settings or menu)
2. **Switch to Swedish** → UI changes to Swedish
3. **Test voice**: "Skapa en katt" (Create a cat)
4. **Verify**: Crafta responds in Swedish

### **📱 Offline Mode**
1. **Enable Airplane Mode** → Disconnect internet
2. **Request creatures**: "Create a robot", "Create a cat"
3. **Verify**: Fast responses from 60+ cached creatures
4. **Test export**: Generate .mcpack file offline

### **🎮 Minecraft Export**
1. **Create a creature** → Any creature type
2. **Find export button** → Usually in creature preview
3. **Tap export** → Generate .mcpack file
4. **Verify**: File saved to Downloads folder

### **🎨 3D Rendering**
1. **Create creatures** → Different types (dragon, cat, robot)
2. **Verify**: 3D creatures render correctly
3. **Test interactions**: Touch to rotate, zoom
4. **Check performance**: Smooth 60fps rendering

---

## 🔍 **What to Look For**

### **✅ Should Work**
- **App launches** without crashes
- **Voice recognition** converts speech to text
- **AI responses** generate creatures
- **3D rendering** shows creatures
- **Language switching** changes UI
- **Offline mode** works without internet
- **Minecraft export** creates .mcpack files

### **⚠️ Potential Issues**
- **Microphone permission** - May need manual grant
- **TTS language** - May need device language settings
- **Storage permission** - May need for file exports
- **Network timeout** - May need retry for AI services

### **🚨 Report Issues**
- **Crashes** - Any app crashes or freezes
- **Performance** - Slow rendering or response times
- **Permissions** - Any permission-related problems
- **Features** - Any features not working as expected

---

## 📊 **Test Results Template**

### **Basic Functionality**
- [ ] **App Launch**: ✅/❌
- [ ] **Navigation**: ✅/❌
- [ ] **Voice Input**: ✅/❌
- [ ] **AI Response**: ✅/❌
- [ ] **3D Rendering**: ✅/❌

### **Advanced Features**
- [ ] **Language Switching**: ✅/❌
- [ ] **Offline Mode**: ✅/❌
- [ ] **Minecraft Export**: ✅/❌
- [ ] **Creature Sharing**: ✅/❌
- [ ] **Performance**: ✅/❌

### **Issues Found**
- **Issue 1**: [Description]
- **Issue 2**: [Description]
- **Issue 3**: [Description]

---

## 🎯 **Success Criteria**

### **Must Pass (Critical)**
- App launches without crashes
- Voice interaction works
- AI generates creatures
- 3D rendering displays creatures
- Basic navigation works

### **Should Pass (Important)**
- Language switching works
- Offline mode functions
- Minecraft export works
- Performance is smooth
- No major bugs

### **Nice to Have (Optional)**
- All advanced features work
- Perfect performance
- No minor issues
- Excellent user experience

---

## 📝 **Quick Test Checklist**

### **5-Minute Test**
1. **Launch app** → Should see welcome screen
2. **Tap "Start Creating"** → Should see creator screen
3. **Speak "Create a dragon"** → Should get AI response
4. **Check 3D creature** → Should see rendered creature
5. **Test export** → Should generate .mcpack file

### **10-Minute Test**
- All of the above, plus:
- **Test language switching**
- **Test offline mode**
- **Test different creature types**
- **Check performance and stability**

### **15-Minute Test**
- All of the above, plus:
- **Test all navigation paths**
- **Test error handling**
- **Test edge cases**
- **Verify all features work**

---

## 🚀 **Ready for Testing!**

**APK Location**: `build/app/outputs/flutter-apk/app-debug.apk`  
**Size**: ~50MB  
**Status**: ✅ Production ready  
**Features**: All core functionality implemented  

**Happy Testing!** 🎉

---

*Following Crafta Constitution: Safe • Kind • Imaginative* 🎨✨

**Generated**: 2024-10-18  
**Status**: 🟢 **READY FOR PHONE TESTING**