import 'package:flutter/material.dart';
import 'package:project/pages/navigation_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'home_page.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double? bmiResult;
  List<Map<String, dynamic>> savedRecords = [];

  @override
  void initState() {
    super.initState();
    // Load saved records when the page initializes
    loadSavedRecords();
  }

  void calculateBMI() {
    final double? weight = double.tryParse(
      weightController.text.replaceAll(',', '.'),
    );
    final double? height = double.tryParse(
      heightController.text.replaceAll(',', '.'),
    );

    if (weight != null && height != null && height > 0) {
      setState(() {
        bmiResult = weight / (height * height);
      });
    } else {
      setState(() {
        bmiResult = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos.')),
      );
    }
  }

  void goToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => NavigationPage()),
      (route) => false,
    );
  }

  // Get the local documents directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get reference to the BMI records file
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/bmi_records.json');
  }

  // Save the current BMI calculation
  Future<void> saveBMIRecord() async {
    if (bmiResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calcule o IMC primeiro antes de salvar!'),
        ),
      );
      return;
    }

    try {
      // Create a new record
      final newRecord = {
        'weight': weightController.text,
        'height': heightController.text,
        'bmi': bmiResult,
        'date': DateTime.now().toIso8601String(),
      };

      // Add to local list
      setState(() {
        savedRecords.add(newRecord);
      });

      // Save to file
      final file = await _localFile;
      await file.writeAsString(jsonEncode(savedRecords));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  // Load all saved BMI records from file
  Future<void> loadSavedRecords() async {
    try {
      final file = await _localFile;

      // Check if file exists
      if (!await file.exists()) {
        return;
      }

      // Read the file
      final contents = await file.readAsString();

      // Parse JSON
      final List<dynamic> jsonData = jsonDecode(contents);

      setState(() {
        savedRecords =
            jsonData
                .map((record) => Map<String, dynamic>.from(record))
                .toList();
      });
    } catch (e) {
      print('Error loading records: $e');
      // Initialize with empty list if there's an error
      setState(() {
        savedRecords = [];
      });
    }
  }

  // Show dialog to select a saved record
  void showSavedRecordsDialog() {
    if (savedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há registros salvos ainda.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registros Salvos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: savedRecords.length,
              itemBuilder: (context, index) {
                final record = savedRecords[index];
                final date = DateTime.parse(record['date']);
                final formattedDate =
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

                return ListTile(
                  title: Text('IMC: ${record['bmi'].toStringAsFixed(2)}'),
                  subtitle: Text(formattedDate),
                  onTap: () {
                    loadRecord(record);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Load a specific record into the form
  void loadRecord(Map<String, dynamic> record) {
    setState(() {
      weightController.text = record['weight'];
      heightController.text = record['height'];
      bmiResult = record['bmi'];
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registro carregado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de IMC'),
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
            const Text("Qual é o seu peso?", style: TextStyle(fontSize: 18)),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: "Ex: 70.5"),
            ),
            const SizedBox(height: 20),
            const Text("Qual é a sua altura?", style: TextStyle(fontSize: 18)),
            TextField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: "Ex: 1.75"),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '< 18,5   Abaixo do peso\n'
                '18,5 - 24,9   Peso normal\n'
                '25 - 29,9   Sobrepeso\n'
                '>= 30   Obesidade',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBMI,
              child: const Text("CALCULAR"),
            ),
            const SizedBox(height: 15),
            // Row with Save and Load buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("SALVAR"),
                    onPressed: saveBMIRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: const Text("CARREGAR"),
                    onPressed: showSavedRecordsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (bmiResult != null)
              Center(
                child: Text(
                  "IMC: ${bmiResult!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
