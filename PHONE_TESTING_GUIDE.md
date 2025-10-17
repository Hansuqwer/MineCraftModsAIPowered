# 📱 Testing Crafta on Your Phone

## **🌐 Web Version (Easiest Option)**

### **Step 1: Start Web Server**
```bash
flutter run -d web-server --web-port 8080
```

### **Step 2: Access from Phone**
1. **Find your computer's IP address:**
   ```bash
   ip addr show | grep inet
   ```
   Look for something like `192.168.1.100`

2. **On your phone:**
   - Open browser (Chrome, Firefox, etc.)
   - Go to: `http://YOUR_IP_ADDRESS:8080`
   - Example: `http://192.168.1.100:8080`

### **Step 3: Test Your Cat**
1. **Create Cat:** Type "I want a cat with wings"
2. **See Results:** Your cat should appear on Complete screen
3. **Export:** Click "Send to Minecraft" to download .mcpack

## **📱 Android APK (Alternative)**

### **If you want a native app:**

1. **Fix NDK Issues:**
   - Already fixed in `android/app/build.gradle`
   - Set `ndkVersion = "25.1.8937393"`

2. **Build APK:**
   ```bash
   flutter build apk --debug
   ```

3. **Install on Phone:**
   - Transfer APK to phone
   - Enable "Install from unknown sources"
   - Install the APK

## **🎮 Testing Your Cat with Wings**

### **In the App:**
1. **Creator Screen:** Type "I want a cat with wings"
2. **Complete Screen:** See your cat rendered
3. **Export:** Download .mcpack file

### **In Minecraft:**
1. **Install:** Open .mcpack file
2. **Enable:** Turn on addon in world settings
3. **Spawn:** Use `/crafta:summon cat_with_wings`
4. **Enjoy:** Your flying cat is ready!

## **🚀 Quick Start**

**Right now, the web server should be running!**

1. **Find your IP:** `ip addr show | grep inet`
2. **On phone:** Go to `http://YOUR_IP:8080`
3. **Test:** Create your cat with wings!

**Your cat with wings is ready to test!** 🐱🪶✨

