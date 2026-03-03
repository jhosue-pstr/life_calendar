import 'package:flutter/material.dart';

class BadHabitsSection extends StatelessWidget {
  final List<Map<String, dynamic>> badHabits;
  final VoidCallback onAddBadHabit;
  final Function(int) onResetHabit;

  const BadHabitsSection({
    super.key,
    required this.badHabits,
    required this.onAddBadHabit,
    required this.onResetHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddBadHabit, // Llama al Dialog
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Agregar Mal Hábito'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rachas (Cero Recaídas)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(badHabits.length, (index) {
          final habit = badHabits[index];
          final days = habit['days'] as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$days días invicto',
                        style: TextStyle(
                          color: days == 0 ? Colors.redAccent : Colors.grey,
                          fontWeight: days == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => onResetHabit(index), // Dispara el reinicio
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Recaí'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
