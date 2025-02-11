import 'package:bare/presentattion/home/widgtes/buttons.dart';
import 'package:flutter/material.dart';

// These imports are required for web-specific functionality
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// HomePage is a web-based image viewer widget that allows users to:
/// - Display images from URLs
/// - Toggle fullscreen mode
/// - Handle image positioning and scaling
/// 
/// This widget is specifically designed for web platforms and uses dart:html
/// and dart:js for web-specific functionality.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// Holds the reference to the currently displayed image element in the DOM
  html.ImageElement? _imgEle;
  
  /// Controller for the image URL input field
  final TextEditingController _imgLinkController = TextEditingController();
  
  /// Controls the visibility of the context menu
  bool _isMenuActive = false;
  
  /// Tracks the current fullscreen state
  bool _isFullscreen = false;

  /// Toggles the fullscreen mode of the application
  /// 
  /// Uses JavaScript interop to handle fullscreen API calls since Flutter web
  /// doesn't directly expose fullscreen functionality
  void _toggleFullscreen() {
    if (!_isFullscreen) {
      // Enter fullscreen mode
      js.context.callMethod('eval', [
        '''
        if (document.documentElement.requestFullscreen) {
          document.documentElement.requestFullscreen();
        }
      '''
      ]);
    } else {
      // Exit fullscreen mode
      js.context.callMethod('eval', [
        '''
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      '''
      ]);
    }
    setState(() => _isFullscreen = !_isFullscreen);
  }

  /// Builds and returns the context menu widget with fullscreen toggle option
  /// 

  Widget _contextMenu() {
    return  _isMenuActive
          ? Stack(
              children: [
                // Overlay for closing menu on outside tap
                Positioned.fill(
                  child: InkWell(
                    onTap: () => setState(() => _isMenuActive = false),
                    child: Container(color: Colors.black54),
                  ),
                ),
                // Fullscreen toggle button
                Positioned(
                  right: 16,
                  bottom: 80,
                  child: CustomButton(
                    width: 170,
                    icon: Icons.fullscreen_exit,
                    text: !_isFullscreen ? 'Enter fullscreen' : 'Exit fullscreen',
                    onTap: () {
                      _toggleFullscreen();
                      setState(() => _isMenuActive = false);
                    },
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();
    
  }

  /// Displays the image from the URL entered in the text field
  /// 
  /// Creates a new image element in the DOM with specific styling for:
  /// - Centered positioning
  /// - Maximum width and height constraints
  /// - Pointer cursor
  /// - Double-click handling for fullscreen toggle
  void displayImage() {
    String url = _imgLinkController.text.trim();
    if (url.isNotEmpty) {
      // Remove any existing image
      _imgEle?.remove();
      
      // Create and configure new image element
      _imgEle = html.ImageElement(src: url)
        ..style.position = 'absolute'
        ..style.maxHeight = '100%'
        ..style.cursor = 'pointer'
        ..style.left = '50%'
        ..style.top = '50%'
        ..style.transform = 'translate(-50%, -50%)'
        ..style.maxWidth = '100%';

      // Add double-click handler for fullscreen toggle
      _imgEle!.onDoubleClick.listen((event) => _toggleFullscreen());

      // Add image to the document body
      html.document.body?.append(_imgEle!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menu toggle button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => setState(() => _isMenuActive = !_isMenuActive),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Image container with border and background
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // URL input field and display button
                  SizedBox(
                    width: 600,
                    child: Row(
                      children: [
                        // URL input field
                        Expanded(
                          child: TextField(
                            controller: _imgLinkController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12),
                              labelText: 'Enter Image URL',
                              labelStyle: const TextStyle(color: Colors.black),
                              prefixIcon: const Icon(Icons.link, color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 0.5,
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(.4),
                            ),
                            cursorColor: Colors.black,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Display button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                          ),
                          onPressed: displayImage,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Context menu overlay
          _contextMenu(),
        ],
      ),
    );
  }
}