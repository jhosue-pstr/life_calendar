import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../activities/presentation/providers/activity_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../bad_habits/presentation/providers/bad_habit_provider.dart';
import '../../../contributions/presentation/providers/contribution_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../activities/domain/models/activity.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../bad_habits/domain/models/bad_habit.dart';
import '../../../contributions/presentation/widgets/contribution_grid.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        child: Text(today.toUpperCase()),
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
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 100),
                        child: _buildAddActivityButton(colorScheme),
                      ),
                      const SizedBox(height: 24),
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 200),
                        child: _buildActivitiesSection(),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 300),
                        child: _buildAddGoalButton(colorScheme),
                      ),
                      const SizedBox(height: 16),
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 400),
                        child: _buildGoalsSection(),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 500),
                        child: _buildAddBadHabitButton(colorScheme),
                      ),
                      const SizedBox(height: 16),
                      _AnimatedSection(
                        delay: const Duration(milliseconds: 600),
                        child: _buildBadHabitsSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddActivityButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _showAddActivityDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Actividad'),
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
            Text(
              'Actividades de Hoy',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (todayActivities.isEmpty)
              Text(
                'No hay actividades para hoy',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...todayActivities.map(
                (activity) => _AnimatedListItem(
                  index: todayActivities.indexOf(activity),
                  child: _buildActivityItem(activity),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              activity.isDone ? Icons.check_circle : Icons.circle_outlined,
              key: ValueKey(activity.isDone),
              color: activity.isDone
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              decoration: activity.isDone ? TextDecoration.lineThrough : null,
              color: activity.isDone
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(activity.title),
          ),
          onTap: () =>
              context.read<ActivityProvider>().toggleActivity(activity),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () =>
                context.read<ActivityProvider>().deleteActivity(activity.id),
          ),
        ),
      ),
    );
  }

  Widget _buildAddGoalButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Agregar Meta'),
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
          return Text(
            'No hay metas activas',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          children: goals.asMap().entries.map((entry) {
            return _AnimatedListItem(
              index: entry.key,
              child: _buildGoalCard(entry.value),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                iconSize: 20,
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  FilterChip(
                    label: Text('${index + 1}'),
                    selected: day.isCompleted,
                    onSelected: (value) {
                      context.read<GoalProvider>().toggleGoalDay(
                        goal.id,
                        day.dayNumber,
                        value,
                      );
                    },
                    selectedColor: colorScheme.primaryContainer,
                    checkmarkColor: colorScheme.onPrimaryContainer,
                    showCheckmark: false,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBadHabitButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddBadHabitDialog(),
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Agregar Mal Hábito'),
      ),
    );
  }

  Widget _buildBadHabitsSection() {
    return Consumer<BadHabitProvider>(
      builder: (context, provider, _) {
        final habits = provider.badHabits;
        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rachas (Cero Recaídas)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: colorScheme.tertiary),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (habits.isEmpty)
              Text(
                'No hay malos hábitos registrados',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...habits.asMap().entries.map((entry) {
                return _AnimatedListItem(
                  index: entry.key,
                  child: _buildBadHabitCard(entry.value),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildBadHabitCard(BadHabit habit) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = habit.currentStreak > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
            : colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? colorScheme.tertiary.withValues(alpha: 0.5)
              : colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isActive ? colorScheme.tertiary : colorScheme.error,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text('${habit.currentStreak} días invicto'),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () =>
                context.read<BadHabitProvider>().triggerRelapse(habit.id),
            child: const Text('Recaí'),
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
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
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
                ),
                textCapitalization: TextCapitalization.sentences,
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
            FilledButton(
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
          decoration: const InputDecoration(labelText: 'Nombre del mal hábito'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
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

class _AnimatedSection extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _AnimatedSection({required this.delay, required this.child});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
