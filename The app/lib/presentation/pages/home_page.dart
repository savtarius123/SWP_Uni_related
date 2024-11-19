import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String title = context.routeData.title(context);
    return (Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(width: 300, child: Placeholder()),
          ),
        ],
      ),
    ));
  }
}
