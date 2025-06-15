import 'package:flutter/material.dart';
import 'package:project/pages/navigation_page.dart';
import 'package:project/models/aerobics.dart';

class AerobicsPage extends StatefulWidget {
  const AerobicsPage({super.key});

  @override
  State<AerobicsPage> createState() => _AerobicsPageState();
}

class _AerobicsPageState extends State<AerobicsPage> {
  // For storing fetched results
  final List<AerobicsResult> _allResults = [];

  Future<void> _showHistory() async {
    try {
      final results = await _aerobicsRepository.getAllResults();
      final lastFive = results.take(5).toList();
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Últimos 5 resultados'),
              content: SizedBox(
                width: double.maxFinite,
                child:
                    lastFive.isEmpty
                        ? const Text('Nenhum resultado encontrado')
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: lastFive.length,
                          itemBuilder: (context, index) {
                            final result = lastFive[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Calorias: ${result.totalCalories.toStringAsFixed(1)} cal',
                                ),
                                subtitle: Text(
                                  'Data: ${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                                ),
                                onTap: () => _showResultDetails(result),
                              ),
                            );
                          },
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            ),
      );
    } catch (e) {
      _showSnackBar('Erro ao buscar resultados: $e', isError: true);
    }
  }

  void _showResultDetails(AerobicsResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalhes do Resultado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Corrida: ${result.corridaDistance} km'),
                Text('Natação: ${result.natacaoDistance} km'),
                Text('Ciclismo: ${result.ciclismoDistance} km'),
                Text(
                  'Total de calorias: ${result.totalCalories.toStringAsFixed(1)} cal',
                ),
                Text(
                  'Data: ${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fechar'),
              ),
            ],
          ),
    );
  }

  final TextEditingController corridaController = TextEditingController();
  final TextEditingController natacaoController = TextEditingController();
  final TextEditingController ciclismoController = TextEditingController();

  final AerobicsRepository _aerobicsRepository = AerobicsRepository();

  double? result;
  bool _isLoading = false;
  bool _isSaving = false;

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

  Future<void> saveResult() async {
    if (result == null) {
      _showSnackBar('Calcule as calorias primeiro!', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double corrida =
          double.tryParse(corridaController.text.replaceAll(',', '.')) ?? 0;
      final double natacao =
          double.tryParse(natacaoController.text.replaceAll(',', '.')) ?? 0;
      final double ciclismo =
          double.tryParse(ciclismoController.text.replaceAll(',', '.')) ?? 0;

      // Create AerobicsResult object
      final aerobicsResult = AerobicsResult(
        corridaDistance: corrida,
        natacaoDistance: natacao,
        ciclismoDistance: ciclismo,
        totalCalories: result!,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final savedId = await _aerobicsRepository.saveResult(aerobicsResult);

      _showSnackBar('Resultado salvo com sucesso!');

      // Optionally clear the form after saving
      _clearForm();
    } catch (e) {
      _showSnackBar('Erro ao salvar resultado: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearForm() {
    corridaController.clear();
    natacaoController.clear();
    ciclismoController.clear();
    setState(() {
      result = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showResultHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _aerobicsRepository.getAllResults();

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Histórico de Exercícios'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child:
                    results.isEmpty
                        ? Center(child: Text('Nenhum resultado encontrado'))
                        : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(
                                  '${result.totalCalories.toStringAsFixed(1)} cal',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Corrida: ${result.corridaDistance}km',
                                    ),
                                    Text(
                                      'Natação: ${result.natacaoDistance}km',
                                    ),
                                    Text(
                                      'Ciclismo: ${result.ciclismoDistance}km',
                                    ),
                                    Text(
                                      'Data: ${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed:
                                      () => _deleteResult(result.id!, index),
                                ),
                              ),
                            );
                          },
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar'),
                ),
              ],
            ),
      );
    } catch (e) {
      _showSnackBar('Erro ao carregar histórico: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResult(String resultId, int index) async {
    try {
      await _aerobicsRepository.deleteResult(resultId);
      Navigator.pop(context); // Close dialog
      _showSnackBar('Resultado excluído com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao excluir resultado: $e', isError: true);
    }
  }

  @override
  void dispose() {
    corridaController.dispose();
    natacaoController.dispose();
    ciclismoController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _isLoading ? null : _showResultHistory,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text('Histórico'),
                      onPressed: _showHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_allResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Últimos 5 resultados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        constraints: BoxConstraints(maxHeight: 220),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _allResults.length,
                            itemBuilder: (context, index) {
                              final result = _allResults[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    'Calorias: ${result.totalCalories.toStringAsFixed(1)} cal',
                                  ),
                                  subtitle: Text(
                                    'Data: ${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                                  ),
                                  onTap: () => _showResultDetails(result),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    const Text(
                      "Corrida (65 kcal/km)",
                      style: TextStyle(fontSize: 18),
                    ),
                    TextField(
                      controller: corridaController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Distância em km',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Natação (476 kcal/km)",
                      style: TextStyle(fontSize: 18),
                    ),
                    TextField(
                      controller: natacaoController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Distância em km',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Ciclismo (23 kcal/km)",
                      style: TextStyle(fontSize: 18),
                    ),
                    TextField(
                      controller: ciclismoController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Distância em km',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: calculateCalories,
                      child: const Text('CALCULAR'),
                    ),
                    if (result != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSaving ? null : saveResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isSaving
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('SALVANDO...'),
                                  ],
                                )
                                : const Text('SALVAR RESULTADO'),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (result != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Total de calorias queimadas: ${result!.toStringAsFixed(1)} cal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
