import 'package:flutter/material.dart';
import 'package:project/models/meal.dart';
import 'package:project/db/meal_db.dart';
import 'package:project/pages/navigation_page.dart';

class DietaPage extends StatefulWidget {
  const DietaPage({super.key});

  @override
  State<DietaPage> createState() => _DietaPageState();
}

class _DietaPageState extends State<DietaPage> {
  List<Meal> meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final data = await MealDatabase.getMeals();
      setState(() {
        meals = data;
      });
    } catch (e) {
      print('Error loading meals: $e');
    }
  }

  Future<void> _saveMeal(Meal meal) async {
    try {
      await MealDatabase.insertMeal(meal);
      await _loadMeals();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição salva com sucesso!')),
      );
    } catch (e) {
      print('Error saving meal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar refeição: $e')));
    }
  }

  Future<void> _deleteMeal(int id) async {
    try {
      await MealDatabase.deleteMeal(id);
      await _loadMeals();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Refeição removida!')));
    } catch (e) {
      print('Error deleting meal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover refeição: $e')));
    }
  }

  void goToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => NavigationPage()),
      (route) => false,
    );
  }

  void showAddMealDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Refeição'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome (opcional)'),
              ),
              TextField(
                controller: caloriesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Calorias por porção',
                ),
              ),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                final double? calories = double.tryParse(
                  caloriesController.text.replaceAll(',', '.'),
                );
                final double? quantity = double.tryParse(
                  quantityController.text.replaceAll(',', '.'),
                );
                final String name = nameController.text.trim();

                if (calories != null && quantity != null) {
                  final meal = Meal(
                    name: name,
                    calories: calories,
                    quantity: quantity,
                    createdAt: DateTime.now(),
                  );

                  Navigator.pop(context);
                  await _saveMeal(meal);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, insira valores válidos.'),
                    ),
                  );
                }
              },
              child: const Text('ADICIONAR'),
            ),
          ],
        );
      },
    );
  }

  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + (meal.calories * meal.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dieta'),
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
            ElevatedButton(
              onPressed: showAddMealDialog,
              child: const Text('Adicionar Refeição'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Refeições salvas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${meals.length} itens',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  meals.isEmpty
                      ? const Center(
                        child: Text('Nenhuma refeição adicionada.'),
                      )
                      : ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final meal = meals[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                meal.name.isNotEmpty
                                    ? meal.name
                                    : 'Refeição ${index + 1}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${meal.quantity} x ${meal.calories} cal',
                                  ),
                                  if (meal.createdAt != null)
                                    Text(
                                      'Adicionado: ${meal.createdAt!.day}/${meal.createdAt!.month}/${meal.createdAt!.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(meal.calories * meal.quantity).toStringAsFixed(1)} cal',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (meal.id != null) {
                                        _deleteMeal(meal.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                'Total de calorias: ${totalCalories.toStringAsFixed(1)} cal',
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

  @override
  void dispose() {
    MealDatabase.closeDatabase();
    super.dispose();
  }
}
