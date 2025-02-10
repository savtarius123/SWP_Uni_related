/// Displays the 3D model of a Sensor Board
///
/// Authors:
///   * Mohamed Aziz Mani
library;

import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';

class SensorBoard extends StatefulWidget {
  const SensorBoard({super.key});

  @override
  State<SensorBoard> createState() => _SensorBoardState();
}

class _SensorBoardState extends State<SensorBoard>
    with SingleTickerProviderStateMixin {
  final DiTreDiController _controller = DiTreDiController(
    rotationX: -100,
    rotationY: 1,
    rotationZ: -10,
    userScale: 2,
    translation: Offset(-0.5, -3),
  );

  late Future<Mesh3D> _meshFuture;
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _meshFuture = _loadMesh();

    _animationController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 500),
      lowerBound: 1.0,
      upperBound: 1.3,
    );

    _hoverAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Mesh3D> _loadMesh() async {
    try {
      final faces = await ObjParser()
          .loadFromResources('assets/models/sensorboard_small_green.obj');
      return Mesh3D(faces);
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Mesh3D>(
      future: _meshFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No board data available"));
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => _isHovering = true);
            _animationController.forward();
          },
          onExit: (_) {
            setState(() => _isHovering = false);
            _animationController.reverse();
          },
          child: AnimatedBuilder(
            animation: _hoverAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isHovering
                    ? _hoverAnimation.value * 1.1
                    : _hoverAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: !_isHovering ? 0.9 : 1.0,
                    child: DiTreDi(
                      controller: _controller,
                      figures: [snapshot.data!],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
