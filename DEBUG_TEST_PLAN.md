# 🔍 **Debug Test Plan: Red Dragon 3D Preview Issue**

## **Problem**
User reports: "still getting the blocky red dragon" instead of the detailed dragon model.

## **Debug Steps**

### **Step 1: Test the Complete Flow**
1. Install the new APK: `build/app/outputs/flutter-apk/app-debug.apk`
2. Open the app
3. Go to Creator screen (text input)
4. Type: "red dragon"
5. Hit "Create"
6. Check the debug logs in the console

### **Step 2: Expected Debug Output**
When you type "red dragon" and hit create, you should see:

```
🔍 [CREATOR] User requested: "red dragon"
🔍 [CREATOR] Item type: [selected type]
🤖 [CREATOR] Calling AI with prompt...
✅ [CREATOR] AI returned response
🔍 [CREATOR] Base type: dragon
🔍 [CREATOR] Custom name: Red Dragon
🔍 [CREATOR] Primary color: Color(0xffff0000)
🔍 [CREATOR] Mapped creatureType: dragon
🔍 [CREATOR] Mapped color: red
🔍 [CREATOR] Full _currentItem map: {creatureType: dragon, color: red, ...}
🔍 [BABYLON] Received creatureAttributes: {creatureType: dragon, color: red, ...}
🔍 [BABYLON] Extracted - type: dragon, color: red, size: medium
```

### **Step 3: JavaScript Debug Output**
In the WebView console, you should see:

```
🔍 [BABYLON] JavaScript received:
   itemType: dragon
   itemColor: red
   itemGlow: none
   itemSize: medium
   Type contains dragon: true
🐉 [BABYLON] Creating detailed dragon model
   - Color: red
   - Glow: none
   - Scale: 1
```

### **Step 4: Expected Result**
The 3D preview should show:
- Detailed dragon with wings, tail, legs
- Red color (not blocky)
- Glowing red eyes
- Proper dragon proportions

## **Possible Issues**

### **Issue 1: AI Service Not Working**
If you see:
```
❌ [ENHANCED_AI] No API key found - internet connection required
🤖 [ENHANCED_AI] Using AI model generator as fallback...
```
**Solution**: The AI service is falling back to the offline generator, which might not be working correctly.

### **Issue 2: Attribute Mapping Wrong**
If you see:
```
🔍 [BABYLON] Extracted - type: cube, color: blue, size: medium
```
**Solution**: The attributes aren't being passed correctly from Flutter to the 3D preview.

### **Issue 3: JavaScript Not Detecting Dragon**
If you see:
```
   Type contains dragon: false
```
**Solution**: The JavaScript string interpolation is broken or the type isn't being passed correctly.

### **Issue 4: Dragon Model Not Detailed**
If you see:
```
🐉 [BABYLON] Creating detailed dragon model
```
But still see a blocky model, the issue is in the JavaScript `createDragon` function.

## **Next Steps**

1. **Test the APK** and check the debug output
2. **Report the exact debug logs** you see
3. **Take a screenshot** of the 3D preview
4. **Identify which step is failing**

## **Quick Fixes**

### **If AI Service Fails:**
- Check if you have an OpenAI API key configured
- The fallback should still work for "red dragon"

### **If Attributes Wrong:**
- Check the `_currentItem` map in the debug output
- Verify `creatureType: dragon` and `color: red`

### **If JavaScript Fails:**
- Check the JavaScript console logs
- Verify the string interpolation is working

### **If Dragon Model Wrong:**
- The `createDragon` function needs to be fixed
- Should create detailed geometry, not basic shapes

## **Expected Timeline**
- **5 minutes**: Install APK and test
- **2 minutes**: Check debug logs
- **3 minutes**: Identify the issue
- **5 minutes**: Apply the fix
- **Total**: ~15 minutes to identify and fix the issue
