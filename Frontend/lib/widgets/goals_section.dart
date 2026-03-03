import 'package:flutter/material.dart';

class GoalsSection extends StatelessWidget {
  final String currentGoal;
  final List<bool> goalDays;
  final VoidCallback onAddGoal;
  final Function(int, bool) onToggleGoalDay;

  const GoalsSection({
    super.key,
    required this.currentGoal,
    required this.goalDays,
    required this.onAddGoal,
    required this.onToggleGoalDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddGoal, // Llama al Dialog
            icon: const Icon(Icons.flag),
            label: const Text('Agregar Meta Semanal'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.greenAccent,
              side: const BorderSide(color: Colors.greenAccent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meta: $currentGoal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  return Column(
                    children: [
                      Text(
                        ['L', 'M', 'M', 'J', 'V', 'S', 'D'][index],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Checkbox(
                        value: goalDays[index],
                        activeColor: Colors.green,
                        onChanged: (val) =>
                            onToggleGoalDay(index, val ?? false),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
