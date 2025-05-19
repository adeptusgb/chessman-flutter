import 'package:flutter/material.dart';
import 'package:project/pages/navigation_page.dart';
import 'home_page.dart';

class AerobicsPage extends StatefulWidget {
  const AerobicsPage({Key? key}) : super(key: key);

  @override
  State<AerobicsPage> createState() => _AerobicsPageState();
}

class _AerobicsPageState extends State<AerobicsPage> {
  final TextEditingController corridaController = TextEditingController();
  final TextEditingController natacaoController = TextEditingController();
  final TextEditingController ciclismoController = TextEditingController();

  double? result;

  void goToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => NavigationPage()),
      (route) => false,
    );
  }

  void calculateCalories() {
    final double corrida =
        double.tryParse(corridaController.text.replaceAll(',', '.')) ?? 0;
    final double natacao =
        double.tryParse(natacaoController.text.replaceAll(',', '.')) ?? 0;
    final double ciclismo =
        double.tryParse(ciclismoController.text.replaceAll(',', '.')) ?? 0;

    setState(() {
      result = corrida * 65 + natacao * 476 + ciclismo * 23;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aeróbicos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goToHomePage,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Corrida (65 kcal/km)", style: TextStyle(fontSize: 18)),
            TextField(
              controller: corridaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Distância em km'),
            ),
            const SizedBox(height: 16),
            const Text("Natação (476 kcal/km)", style: TextStyle(fontSize: 18)),
            TextField(
              controller: natacaoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Distância em km'),
            ),
            const SizedBox(height: 16),
            const Text("Ciclismo (23 kcal/km)", style: TextStyle(fontSize: 18)),
            TextField(
              controller: ciclismoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Distância em km'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: calculateCalories,
              child: const Text('CALCULAR'),
            ),
            const SizedBox(height: 32),
            if (result != null)
              Text(
                'Total de calorias queimadas: ${result!.toStringAsFixed(1)} cal',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
