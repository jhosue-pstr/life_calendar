import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widgets/contribution_grid.dart'; // Asegúrate de que esta ruta sea correcta

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Variables visuales para los checkbox de la meta (7 días)
  List<bool> goalDays = List.generate(7, (index) => false);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Life Calendar'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === LADO IZQUIERDO: TU CALENDARIO ===
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(child: ContributionGrid()),
                ],
              ),
            ),

            const SizedBox(
              width: 24,
            ), // Espacio entre el calendario y el panel derecho
            // === LADO DERECHO: BOTONES, LISTA, METAS Y MALOS HÁBITOS ===
            Expanded(
              flex: 2,
              // Usamos ListView aquí para que el lado derecho pueda hacer scroll si se llena
              child: ListView(
                children: [
                  // 1. BOTÓN AGREGAR ACTIVIDAD
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Aquí abriremos el popup más adelante xd
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Actividad'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. LISTA DE ACTIVIDADES DEL DÍA
                  const Text(
                    'Actividades de Hoy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Usamos Column en vez de ListView dentro del ListView principal
                  Column(
                    children: [
                      _buildActivityItem(
                        'Programar Life Calendar en Flutter',
                        true,
                      ),
                      _buildActivityItem('Tomar 2 litros de agua', false),
                      _buildActivityItem('Hacer ejercicio', false),
                    ],
                  ),

                  // 3. BOTÓN AGREGAR META Y TARJETA DE META
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
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

                  // Tarjeta de la meta
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
                        const Text(
                          'Meta: Leer un libro (30 mins)',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                                  onChanged: (bool? value) {
                                    setState(() {
                                      goalDays[index] = value ?? false;
                                    });
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // 4. ZONA ROJA: MALOS HÁBITOS Y RACHAS
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
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

                  // Aquí llamamos a nuestro nuevo widget para cada hábito
                  const BadHabitTracker(
                    habitName: 'Comer comida chatarra',
                    initialDays: 15,
                  ),
                  const BadHabitTracker(
                    habitName: 'Procrastinar',
                    initialDays: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personalizado para la lista de actividades
  Widget _buildActivityItem(String title, bool isDone) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isDone ? Icons.check_circle : Icons.circle_outlined,
          color: isDone ? Colors.green : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.white,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// NUEVO WIDGET: Controla los días del mal hábito y el botón de recaída
// =====================================================================
class BadHabitTracker extends StatefulWidget {
  final String habitName;
  final int initialDays;

  const BadHabitTracker({
    super.key,
    required this.habitName,
    required this.initialDays,
  });

  @override
  State<BadHabitTracker> createState() => _BadHabitTrackerState();
}

class _BadHabitTrackerState extends State<BadHabitTracker> {
  late int currentDays;

  @override
  void initState() {
    super.initState();
    currentDays = widget.initialDays; // Iniciamos con los días configurados
  }

  void _recaida() {
    setState(() {
      currentDays = 0; // Se reinicia a 0 al fallar
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.habitName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentDays días invicto',
                  style: TextStyle(
                    color: currentDays == 0 ? Colors.redAccent : Colors.grey,
                    fontWeight: currentDays == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _recaida,
            icon: const Icon(Icons.refresh, size: 16), // Ícono de recargar
            label: const Text('Recaí'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
