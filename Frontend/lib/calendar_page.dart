import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/bad_habit_provider.dart';
import 'providers/contribution_provider.dart';
import 'providers/auth_provider.dart';
import 'models/activity.dart';
import 'models/goal.dart';
import 'models/bad_habit.dart';
import 'widgets/contribution_grid.dart';
import 'screens/login_screen.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final activityProvider = context.read<ActivityProvider>();
    final goalProvider = context.read<GoalProvider>();
    final badHabitProvider = context.read<BadHabitProvider>();
    final contributionProvider = context.read<ContributionProvider>();

    await Future.wait([
      activityProvider.loadActivities(),
      goalProvider.loadGoals(activeOnly: true),
      badHabitProvider.loadBadHabits(),
      contributionProvider.loadContributionsForYear(DateTime.now().year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Calendar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  _buildAddActivityButton(),
                  const SizedBox(height: 24),
                  _buildActivitiesSection(),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  _buildAddGoalButton(),
                  const SizedBox(height: 16),
                  _buildGoalsSection(),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  _buildAddBadHabitButton(),
                  const SizedBox(height: 16),
                  _buildBadHabitsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddActivityButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddActivityDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Actividad'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        final todayActivities = provider.todayActivities;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividades de Hoy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (todayActivities.isEmpty)
              const Text(
                'No hay actividades para hoy',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...todayActivities.map(
                (activity) => _buildActivityItem(activity),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          activity.isDone ? Icons.check_circle : Icons.circle_outlined,
          color: activity.isDone ? Colors.green : Colors.grey,
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            decoration: activity.isDone ? TextDecoration.lineThrough : null,
            color: activity.isDone ? Colors.grey : Colors.white,
          ),
        ),
        onTap: () => context.read<ActivityProvider>().toggleActivity(activity),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              context.read<ActivityProvider>().deleteActivity(activity.id),
        ),
      ),
    );
  }

  Widget _buildAddGoalButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(Icons.flag),
        label: const Text('Agregar Meta'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.greenAccent,
          side: const BorderSide(color: Colors.greenAccent),
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final goals = provider.activeGoals;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (goals.isEmpty) {
          return const Text(
            'No hay metas activas',
            style: TextStyle(color: Colors.grey),
          );
        }

        return Column(
          children: goals.map((goal) => _buildGoalCard(goal)).toList(),
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () =>
                    context.read<GoalProvider>().deleteGoal(goal.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(goal.goalDays.length, (index) {
              final day = goal.goalDays[index];
              return Column(
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Checkbox(
                    value: day.isCompleted,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      context.read<GoalProvider>().toggleGoalDay(
                        goal.id,
                        day.dayNumber,
                        value ?? false,
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBadHabitButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddBadHabitDialog(),
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Agregar Mal Hábito'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildBadHabitsSection() {
    return Consumer<BadHabitProvider>(
      builder: (context, provider, _) {
        final habits = provider.badHabits;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rachas (Cero Recaídas)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (habits.isEmpty)
              const Text(
                'No hay malos hábitos registrados',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...habits.map((habit) => _buildBadHabitCard(habit)),
          ],
        );
      },
    );
  }

  Widget _buildBadHabitCard(BadHabit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${habit.currentStreak} días invicto',
                  style: TextStyle(
                    color: habit.currentStreak == 0
                        ? Colors.redAccent
                        : Colors.grey,
                    fontWeight: habit.currentStreak == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<BadHabitProvider>().triggerRelapse(habit.id),
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
        ],
      ),
    );
  }

  void _showAddActivityDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Actividad'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título de la actividad',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ActivityProvider>().createActivity(
                  controller.text.trim(),
                  DateTime.now(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    int targetDays = 7;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la meta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Días: '),
                  Expanded(
                    child: Slider(
                      value: targetDays.toDouble(),
                      min: 1,
                      max: 90,
                      divisions: 89,
                      label: '$targetDays',
                      onChanged: (value) {
                        setState(() => targetDays = value.toInt());
                      },
                    ),
                  ),
                  Text('$targetDays'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  context.read<GoalProvider>().createGoal(
                    titleController.text.trim(),
                    targetDays,
                    DateTime.now(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBadHabitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Mal Hábito'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del mal hábito',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<BadHabitProvider>().createBadHabit(
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
