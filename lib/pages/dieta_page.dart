import 'package:flutter/material.dart';
import 'package:project/pages/navigation_page.dart';
import 'home_page.dart';

class DietaPage extends StatefulWidget {
  const DietaPage({Key? key}) : super(key: key);

  @override
  State<DietaPage> createState() => _DietaPageState();
}

class _DietaPageState extends State<DietaPage> {
  final List<Meal> meals = [];

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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Calorias'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              onPressed: () {
                final double? calories = double.tryParse(
                  caloriesController.text.replaceAll(',', '.'),
                );
                final double? quantity = double.tryParse(
                  quantityController.text.replaceAll(',', '.'),
                );
                final String name = nameController.text.trim();

                if (calories != null && quantity != null) {
                  setState(() {
                    meals.add(
                      Meal(name: name, calories: calories, quantity: quantity),
                    );
                  });
                  Navigator.pop(context);
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
            const Text(
              'Refeições adicionadas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          return ListTile(
                            title: Text(
                              meal.name.isNotEmpty
                                  ? meal.name
                                  : 'Refeição ${index + 1}',
                            ),
                            subtitle: Text(
                              '${meal.quantity} x ${meal.calories} cal',
                            ),
                            trailing: Text(
                              '${(meal.calories * meal.quantity).toStringAsFixed(1)} cal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total de calorias: ${totalCalories.toStringAsFixed(1)} cal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Meal {
  final String name;
  final double calories;
  final double quantity;

  Meal({required this.name, required this.calories, required this.quantity});
}
