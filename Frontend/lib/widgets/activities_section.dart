import 'package:flutter/material.dart';

class ActivitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback onAddActivity;
  final Function(int) onToggleActivity;

  const ActivitiesSection({
    super.key,
    required this.activities,
    required this.onAddActivity,
    required this.onToggleActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddActivity, // Llama al Dialog
            icon: const Icon(Icons.add),
            label: const Text('Agregar Actividad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Actividades de Hoy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(activities.length, (index) {
          final act = activities[index];
          final isDone = act['isDone'] as bool;

          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () =>
                  onToggleActivity(index), // Al tocar la celda, se marca
              leading: Icon(
                isDone ? Icons.check_circle : Icons.circle_outlined,
                color: isDone ? Colors.green : Colors.grey,
              ),
              title: Text(
                act['title'],
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : Colors.white,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
