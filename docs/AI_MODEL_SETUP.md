# AI Model Setup Guide

This guide will help you set up AI models for PokiFairy's on-device chat feature.

## Overview

PokiFairy uses GGUF format models with llama.cpp for on-device AI inference. This means:
- ✅ **Privacy**: All processing happens on your device
- ✅ **Offline**: No internet required after model download
- ✅ **Fast**: Optimized for mobile devices
- ⚠️ **Storage**: Models require 500MB-2GB of storage

## Supported Models

PokiFairy supports any GGUF format model compatible with llama.cpp. Recommended models:

### Recommended Models

| Model | Size | Description | Best For |
|-------|------|-------------|----------|
| **Gemma 2B Q4** | ~1.5GB | Google's efficient model | General chat, fast responses |
| **Gemma 7B Q4** | ~4GB | Larger Gemma variant | Better quality, slower |
| **Llama 3.2 1B Q4** | ~800MB | Meta's compact model | Quick responses, limited device |
| **Llama 3.2 3B Q4** | ~2GB | Balanced performance | Good quality/speed ratio |
| **Phi-3 Mini Q4** | ~2.3GB | Microsoft's efficient model | Instruction following |
| **TinyLlama 1.1B Q4** | ~700MB | Ultra-compact | Low-end devices |

### Quantization Levels

GGUF models come in different quantization levels (Q2, Q4, Q5, Q8):
- **Q2**: Smallest size, lowest quality (~25% original size)
- **Q4**: Good balance (recommended) (~50% original size)
- **Q5**: Better quality, larger size (~60% original size)
- **Q8**: Near-original quality, largest size (~80% original size)

**Recommendation**: Start with Q4 quantization for the best balance.

## Download Models

### Option 1: Hugging Face (Recommended)

1. Visit [Hugging Face](https://huggingface.co/models?library=gguf)
2. Search for GGUF models (e.g., "gemma gguf", "llama gguf")
3. Download the `.gguf` file to your device

**Popular Sources:**
- [TheBloke's GGUF Models](https://huggingface.co/TheBloke)
- [Google Gemma GGUF](https://huggingface.co/models?search=gemma%20gguf)
- [Meta Llama GGUF](https://huggingface.co/models?search=llama%20gguf)

### Option 2: Direct Download

Some models provide direct download links. Use a browser or download manager to save the `.gguf` file.

### Option 3: Convert Your Own

If you have a model in another format:

```bash
# Install llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make

# Convert model to GGUF
python convert.py /path/to/model --outtype q4_0 --outfile model-q4.gguf
```

## Model Placement

### Android

Place your `.gguf` model file in one of these locations:

1. **Download folder** (Recommended)
   ```
   /storage/emulated/0/Download/your-model.gguf
   ```

2. **Documents folder**
   ```
   /storage/emulated/0/Documents/your-model.gguf
   ```

3. **Custom folder**
   ```
   /storage/emulated/0/Models/your-model.gguf
   ```

**Steps:**
1. Connect your Android device to computer via USB
2. Enable "File Transfer" mode
3. Copy the `.gguf` file to Download folder
4. Disconnect device

**Alternative (On-Device):**
1. Download model directly on Android using Chrome/Firefox
2. File will be saved to Download folder automatically

### iOS

Place your `.gguf` model file in the app's Documents directory:

**Using iTunes/Finder:**
1. Connect iOS device to computer
2. Open iTunes (Windows) or Finder (Mac)
3. Select your device
4. Go to "Files" tab
5. Select "PokiFairy" app
6. Drag and drop `.gguf` file into Documents folder

**Using Files App:**
1. Download model to iCloud Drive or Files app
2. Open Files app on iOS
3. Navigate to "On My iPhone" > "PokiFairy"
4. Copy model file here

**Using AirDrop:**
1. AirDrop the `.gguf` file to your iOS device
2. Choose "Save to Files"
3. Select "PokiFairy" folder

## Model Selection in App

Once you've placed the model file:

1. **Open PokiFairy app**
2. **Grant storage permission** (Android only)
   - Tap "Allow" when prompted
   - Or go to Settings > Apps > PokiFairy > Permissions > Storage
3. **Navigate to Model Selection**
   - Tap "AI Chat" from home screen
   - If no model is loaded, you'll see "Select Model" button
   - Or go to Settings > AI Model Selection
4. **Select your model**
   - You'll see a list of detected models
   - Tap on the model you want to use
   - Wait for initialization (may take 10-30 seconds)
5. **Start chatting!**
   - Once loaded, you can start chatting with AI

## Troubleshooting

### Model Not Detected

**Problem**: Model file doesn't appear in selection screen

**Solutions:**
- ✅ Verify file has `.gguf` extension
- ✅ Check file is in correct directory (see Model Placement)
- ✅ Ensure storage permission is granted (Android)
- ✅ Restart the app
- ✅ Check file isn't corrupted (re-download if needed)

### Model Load Failed

**Problem**: Model fails to initialize

**Solutions:**
- ✅ Ensure model is GGUF format (not PyTorch, SafeTensors, etc.)
- ✅ Check device has enough RAM (2GB+ recommended)
- ✅ Try a smaller model (e.g., TinyLlama instead of Llama 7B)
- ✅ Close other apps to free memory
- ✅ Restart device

### Slow Responses

**Problem**: AI takes too long to respond

**Solutions:**
- ✅ Use a smaller model (1B-3B parameters)
- ✅ Use higher quantization (Q4 instead of Q8)
- ✅ Close background apps
- ✅ Ensure device isn't in power-saving mode
- ✅ Wait for model to "warm up" (first response is slower)

### Out of Memory

**Problem**: App crashes or shows memory error

**Solutions:**
- ✅ Use a smaller model (under 2GB)
- ✅ Use Q2 or Q4 quantization
- ✅ Close all other apps
- ✅ Restart device
- ✅ Clear app cache (Settings > Apps > PokiFairy > Clear Cache)

### Permission Denied (Android)

**Problem**: Can't access model files

**Solutions:**
- ✅ Grant storage permission in app settings
- ✅ On Android 11+, enable "All files access" permission
- ✅ Check file isn't in a restricted directory
- ✅ Move file to Download folder

## Performance Tips

### Optimize for Your Device

**Low-End Devices** (2-4GB RAM):
- Use TinyLlama 1.1B Q4 (~700MB)
- Or Llama 3.2 1B Q4 (~800MB)
- Expect 2-5 tokens/second

**Mid-Range Devices** (4-6GB RAM):
- Use Gemma 2B Q4 (~1.5GB)
- Or Llama 3.2 3B Q4 (~2GB)
- Expect 5-10 tokens/second

**High-End Devices** (8GB+ RAM):
- Use Gemma 7B Q4 (~4GB)
- Or Llama 3.2 7B Q4 (~4.5GB)
- Expect 10-20 tokens/second

### Battery Optimization

- AI inference is CPU/GPU intensive
- Expect higher battery drain during chat
- Plug in device for extended chat sessions
- Model stays loaded in memory until app is closed

### Storage Management

- Keep only 1-2 models on device
- Delete unused models to free space
- Models can be re-downloaded anytime

## Advanced Configuration

### Custom Model Paths

By default, PokiFairy scans these directories:

**Android:**
```
/storage/emulated/0/Download/
/storage/emulated/0/Documents/
/storage/emulated/0/Models/
```

**iOS:**
```
<App Documents Directory>/
<App Documents Directory>/Models/
```

### Model Metadata

PokiFairy reads model metadata from GGUF files:
- Model name
- Architecture (Llama, Gemma, etc.)
- Parameter count
- Quantization level
- Context length

### Inference Parameters

Current settings (optimized for mobile):
- **Context Length**: 2048 tokens
- **Temperature**: 0.7
- **Top-P**: 0.9
- **Top-K**: 40
- **Repeat Penalty**: 1.1

These parameters are tuned for balanced, coherent responses on mobile devices.

## Model Recommendations by Use Case

### General Chat
- **Best**: Gemma 2B Q4 or Llama 3.2 3B Q4
- **Why**: Good balance of quality and speed

### Quick Responses
- **Best**: TinyLlama 1.1B Q4 or Llama 3.2 1B Q4
- **Why**: Fastest inference, good for simple queries

### High Quality
- **Best**: Gemma 7B Q4 or Llama 3.2 7B Q4
- **Why**: Best response quality (requires high-end device)

### Instruction Following
- **Best**: Phi-3 Mini Q4
- **Why**: Trained specifically for following instructions

### Multilingual
- **Best**: Gemma 2B Q4 (supports 100+ languages)
- **Why**: Strong multilingual capabilities

## Frequently Asked Questions

### Q: Can I use multiple models?
**A:** Yes! You can have multiple models on your device and switch between them in the Model Selection screen.

### Q: Do I need internet to use AI chat?
**A:** No, once the model is downloaded, everything works offline.

### Q: How much storage do I need?
**A:** Minimum 1GB free space. Recommended 3GB+ for comfortable usage.

### Q: Can I use my own fine-tuned model?
**A:** Yes, as long as it's in GGUF format and compatible with llama.cpp.

### Q: Does this send my data to servers?
**A:** No, all processing happens on your device. Your conversations are 100% private.

### Q: Can I delete the model after loading?
**A:** No, the model needs to stay on device. It's loaded into memory but reads from the file.

### Q: Why is the first response slow?
**A:** The model needs to "warm up" - subsequent responses will be faster.

### Q: Can I use this on tablet?
**A:** Yes! Tablets often have more RAM and can handle larger models better.

## Getting Help

If you encounter issues:

1. **Check Model Debug Screen**
   - Settings > AI Model Debug
   - Shows model info, memory usage, and errors

2. **Review Logs**
   - Check app logs for detailed error messages

3. **Report Issues**
   - GitHub Issues: Include device model, Android/iOS version, model name, and error message

## Additional Resources

- [llama.cpp Documentation](https://github.com/ggerganov/llama.cpp)
- [GGUF Format Specification](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)
- [Hugging Face GGUF Models](https://huggingface.co/models?library=gguf)
- [Model Quantization Guide](https://github.com/ggerganov/llama.cpp#quantization)

---

**Happy Chatting! 🤖✨**
