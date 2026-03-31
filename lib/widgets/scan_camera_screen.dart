import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:my_perfect_quran/services/ai_service.dart';

import 'package:my_perfect_quran/helpers/quran_navigation_helper.dart';
import 'package:my_perfect_quran/core/services/quran_api_service.dart';

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  bool _isProcessing = false;
  
  // Crop area percentages as state
  double _cropTop = 0.35;
  double _cropLeft = 0.1;
  double _cropWidth = 0.8;
  double _cropHeight = 0.2;
  final double _minCropSize = 0.05;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], 
          ResolutionPreset.medium, // Medium is better for MVP stability on Android
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      // ignore empty catch
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      // PAUSE preview immediately to stop the BufferQueue log flood
      await _controller!.pausePreview(); 
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      // ignore empty catch
    }
  }

  Future<void> _processAndAnalyze() async {
    if (_capturedImage == null || _isProcessing) return;
    
    setState(() => _isProcessing = true);

    try {
      // 1. Load image bytes
      final bytes = await File(_capturedImage!.path).readAsBytes();
      
      // 2. Decode and Crop 
      // This is CPU-heavy; pausing the camera (done in _takePicture) is vital here
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception("Failed to decode image");

      int x = (originalImage.width * _cropLeft).toInt();
      int y = (originalImage.height * _cropTop).toInt();
      int w = (originalImage.width * _cropWidth).toInt();
      int h = (originalImage.height * _cropHeight).toInt();

      img.Image cropped = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
      Uint8List pngBytes = Uint8List.fromList(img.encodePng(cropped));

      // 3. Call Gemini
      final result = await AIService().recognizeAyah(pngBytes);

      final int surah = result['surah']!;
      final int ayah = result['ayah']!;
      final String surahName = QuranApiService.getSurahName(surah);
      

      
      if (mounted) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Detected Surah $surahName ($surah), Ayah $ayah"),
            backgroundColor: Colors.green.shade900,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: "OK", textColor: Colors.white, onPressed: () {}),
          ),
        );

        // Dispose before popping to free up camera hardware
        await _controller?.dispose();
        _controller = null;
        
        Navigator.pop(context); 
        
        // Use the integrated navigation and highlight method
        jumpToAyah(surah, ayah);
      }
    } catch (e) {

      if (mounted) {
        String errorMessage = e.toString().contains('Exception:') 
            ? e.toString().split('Exception: ')[1] 
            : e.toString();
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Try again: $errorMessage"),
            backgroundColor: Colors.red.shade900,
          ),
        );
        // Resume preview so user can try again
        await _controller?.resumePreview();
        setState(() => _capturedImage = null);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black, 
        body: Center(child: CircularProgressIndicator(color: Colors.white))
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _capturedImage == null 
              ? CameraPreview(_controller!)
              : Image.file(File(_capturedImage!.path), fit: BoxFit.contain),
          ),

          if (_capturedImage != null) _buildResizableCropOverlay(),

          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 20.h),
                    const Text(
                      "AI is analyzingMushaf... Please wait", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 50.h,
            left: 20.w,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: _capturedImage == null 
              ? Center(child: GestureDetector(onTap: _takePicture, child: _buildShutterIcon()))
              : _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: () async {
                await _controller?.resumePreview();
                setState(() => _capturedImage = null);
              },
              child: const Text("RETAKE", style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: _isProcessing ? null : _processAndAnalyze,
              child: const Text("SCAN AYAH", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizableCropOverlay() {
    return Stack(
      children: [
        // The main draggable box
        Positioned(
          top: _cropTop * ScreenUtil().screenHeight,
          left: _cropLeft * ScreenUtil().screenWidth,
          width: _cropWidth * ScreenUtil().screenWidth,
          height: _cropHeight * ScreenUtil().screenHeight,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _cropTop = (_cropTop + details.delta.dy / ScreenUtil().screenHeight).clamp(0.0, 1.0 - _cropHeight);
                _cropLeft = (_cropLeft + details.delta.dx / ScreenUtil().screenWidth).clamp(0.0, 1.0 - _cropWidth);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        
        // Corner handles
        _buildHandle(alignment: Alignment.topLeft, onUpdate: (dx, dy) {
          setState(() {
            double oldWidth = _cropWidth;
            double oldHeight = _cropHeight;
            _cropWidth = (_cropWidth - dx).clamp(_minCropSize, _cropLeft + _cropWidth);
            _cropHeight = (_cropHeight - dy).clamp(_minCropSize, _cropTop + _cropHeight);
            _cropLeft += (oldWidth - _cropWidth);
            _cropTop += (oldHeight - _cropHeight);
          });
        }),
        _buildHandle(alignment: Alignment.topRight, onUpdate: (dx, dy) {
          setState(() {
            _cropWidth = (_cropWidth + dx).clamp(_minCropSize, 1.0 - _cropLeft);
            double oldHeight = _cropHeight;
            _cropHeight = (_cropHeight - dy).clamp(_minCropSize, _cropTop + _cropHeight);
            _cropTop += (oldHeight - _cropHeight);
          });
        }),
        _buildHandle(alignment: Alignment.bottomLeft, onUpdate: (dx, dy) {
          setState(() {
            double oldWidth = _cropWidth;
            _cropWidth = (_cropWidth - dx).clamp(_minCropSize, _cropLeft + _cropWidth);
            _cropLeft += (oldWidth - _cropWidth);
            _cropHeight = (_cropHeight + dy).clamp(_minCropSize, 1.0 - _cropTop);
          });
        }),
        _buildHandle(alignment: Alignment.bottomRight, onUpdate: (dx, dy) {
          setState(() {
            _cropWidth = (_cropWidth + dx).clamp(_minCropSize, 1.0 - _cropLeft);
            _cropHeight = (_cropHeight + dy).clamp(_minCropSize, 1.0 - _cropTop);
          });
        }),
      ],
    );
  }

  Widget _buildHandle({required Alignment alignment, required Function(double dx, double dy) onUpdate}) {
    return Positioned(
      top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) 
          ? _cropTop * ScreenUtil().screenHeight - 15
          : (_cropTop + _cropHeight) * ScreenUtil().screenHeight - 15,
      left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
          ? _cropLeft * ScreenUtil().screenWidth - 15
          : (_cropLeft + _cropWidth) * ScreenUtil().screenWidth - 15,
      child: GestureDetector(
        onPanUpdate: (details) {
          onUpdate(details.delta.dx / ScreenUtil().screenWidth, details.delta.dy / ScreenUtil().screenHeight);
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildShutterIcon() {
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
      child: Container(
        width: 60.r,
        height: 60.r,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}