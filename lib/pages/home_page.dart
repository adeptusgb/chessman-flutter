import 'package:flutter/material.dart';
import 'navigation_page.dart';

// Solution 1: Use a static method to handle tab switching
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Início")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "O que você gostaria de calcular hoje?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Switch to BMI tab index
                NavigationController.switchToTab(1);
              },
              child: const Text("IMC"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Switch to Dieta tab index
                NavigationController.switchToTab(2);
              },
              child: const Text("Dieta"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Switch to Aerobics tab index
                NavigationController.switchToTab(3);
              },
              child: const Text("Aeróbicos"),
            ),
          ],
        ),
      ),
    );
  }
}
