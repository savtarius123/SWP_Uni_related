/// Displays a 3D quarter cut model of the hab with buttons for rotating and zooming
///
/// Authors:
///   * Cem Igci
///   * Mohamed Aziz Mani
library;

import 'dart:async';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';

/// A Flutter widget to load and display 3D models with interactive controls
class Habitat extends StatefulWidget {
  const Habitat({super.key});

  @override
  State<Habitat> createState() => _HabitatState();
}

class _HabitatState extends State<Habitat> {
  // Controls the 3D view, like rotation, zoom, and panning
  final DiTreDiController _controller = DiTreDiController(
    rotationX: -115, // Start with a 90-degree rotation on the X-axis
    rotationY: 0, // No initial rotation on the Y-axis
    rotationZ: 50, // Slight tilt on the Z-axis for better view
    userScale: 1.2, // Default zoom level
    translation: const Offset(0, -50),
  );

  // Future that loads the 3D model data
  late Future<Mesh3D> _meshFuture;

  // Timer to allow repeated actions (like holding a button to rotate)
  Timer? _actionTimer;

  @override
  void initState() {
    super.initState();
    // Load the 3D model from the provided path when the widget is initialized
    _meshFuture = _loadMesh();
  }

  /// Loads the 3D model from the given file path
  Future<Mesh3D> _loadMesh() async {
    try {
      final faces =
          await ObjParser().loadFromResources("assets/models/module_small.obj");
      return Mesh3D(
          faces); // Convert the model into a format the library can use
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  @override
  void dispose() {
    _actionTimer
        ?.cancel(); // Stop any ongoing timer when the widget is disposed
    super.dispose();
  }

  /// Resets the 3D view to its default position and zoom level
  void _resetView() {
    setState(() {
      _controller.update(
        rotationX: -115,
        rotationY: 0,
        rotationZ: 50,
        userScale: 1.2,
        translation: const Offset(0, -50),
      );
    });
  }

  // Starts a timer to repeatedly perform an action
  void _startActionLoop(VoidCallback action) {
    _actionTimer?.cancel(); // Cancel any existing timer
    _actionTimer = Timer.periodic(
      const Duration(milliseconds: 50), // Run the action every 50ms
      (timer) {
        setState(action); // Perform the action and update the view
      },
    );
  }

  /// Stops any ongoing action loop
  void _stopActionLoop() {
    _actionTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Rotate the model using drag gestures
      onPanUpdate: (details) {
        setState(() {
          const double rotationScale = 0.3; // Sensitivity for rotation
          _controller.update(
            rotationX: _controller.rotationX - details.delta.dy * rotationScale,
            rotationZ: _controller.rotationZ - details.delta.dx * rotationScale,
          );
        });
      },
      child: FutureBuilder<Mesh3D>(
        future: _meshFuture, // Wait for the 3D model to load
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while the model is being loaded
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if loading fails
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // Display the 3D model along with controls
            return Stack(
              children: [
                DiTreDi(
                  controller: _controller,
                  figures: [snapshot.data!], // Show the loaded 3D model
                ),
                // Add buttons for rotation, zoom, and reset at the bottom
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: _buildControls(),
                ),
              ],
            );
          } else {
            // Fallback message if there's no data
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  /// Creates the rotation, zoom, and reset control buttons
  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Row for rotation buttons (left, up, down, right)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(
              'Rotate Left',
              Icons.arrow_left_rounded,
              () => _controller.update(rotationZ: _controller.rotationZ + 3),
              onLongPress: () => _startActionLoop(() {
                _controller.update(rotationZ: _controller.rotationZ + 2);
              }),
            ),
            Column(
              children: [
                _controlButton(
                  'Rotate Up',
                  Icons.arrow_drop_up_rounded,
                  () =>
                      _controller.update(rotationX: _controller.rotationX + 3),
                  onLongPress: () => _startActionLoop(() {
                    _controller.update(rotationX: _controller.rotationX + 2);
                  }),
                ),
                const SizedBox(
                    height: 5), // Spacing between up and down buttons
                _controlButton(
                  'Rotate Down',
                  Icons.arrow_drop_down_rounded,
                  () =>
                      _controller.update(rotationX: _controller.rotationX - 3),
                  onLongPress: () => _startActionLoop(() {
                    _controller.update(rotationX: _controller.rotationX - 2);
                  }),
                ),
              ],
            ),
            _controlButton(
              'Rotate Right',
              Icons.arrow_right_rounded,
              () => _controller.update(rotationZ: _controller.rotationZ - 3),
              onLongPress: () => _startActionLoop(() {
                _controller.update(rotationZ: _controller.rotationZ - 2);
              }),
            ),
          ],
        ),
        const SizedBox(height: 10), // Spacing between rows
        // Row for zoom and reset buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(
              'Zoom In',
              Icons.zoom_in,
              () => _controller.update(
                userScale: (_controller.userScale * 1.2)
                    .clamp(_controller.minUserScale, _controller.maxUserScale),
              ),
              onLongPress: () => _startActionLoop(() {
                _controller.update(
                  userScale: (_controller.userScale * 1.02).clamp(
                      _controller.minUserScale, _controller.maxUserScale),
                );
              }),
            ),
            const SizedBox(width: 10), // Spacing between buttons
            _controlButton(
              'Zoom Out',
              Icons.zoom_out,
              () => _controller.update(
                userScale: (_controller.userScale / 1.2)
                    .clamp(_controller.minUserScale, _controller.maxUserScale),
              ),
              onLongPress: () => _startActionLoop(() {
                _controller.update(
                  userScale: (_controller.userScale / 1.02).clamp(
                      _controller.minUserScale, _controller.maxUserScale),
                );
              }),
            ),
            const SizedBox(width: 10), // Spacing in between
            _controlButton('Reset View', Icons.refresh, _resetView),
          ],
        ),
      ],
    );
  }

  /// Helper method to create a control button with optional long-press functionality
  Widget _controlButton(String tooltip, IconData icon, VoidCallback onPressed,
      {VoidCallback? onLongPress}) {
    return Tooltip(
      message: tooltip, // Show tooltip while hovering
      child: GestureDetector(
        onLongPressStart: (_) => onLongPress?.call(), // Start action loop
        onLongPressEnd: (_) => _stopActionLoop(), // Stop when released
        child: ElevatedButton(
          onPressed: () {
            setState(onPressed); // Perform the button's action
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(5), // Button size
            shape: const CircleBorder(), // Make it circular
            backgroundColor: Colors.grey[800], //  color
            minimumSize: const Size(35, 35), // size
          ),
          child: Icon(icon, size: 18), // Display the icon
        ),
      ),
    );
  }
}
