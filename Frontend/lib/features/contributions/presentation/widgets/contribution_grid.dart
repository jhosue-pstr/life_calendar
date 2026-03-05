import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../contributions/presentation/providers/contribution_provider.dart';

class ContributionGrid extends StatefulWidget {
  const ContributionGrid({super.key});

  static const double boxSize = 16;
  static const double spacing = 6;

  @override
  State<ContributionGrid> createState() => _ContributionGridState();
}

class _ContributionGridState extends State<ContributionGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(BuildContext context, int level) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (level) {
      case 1:
        return colorScheme.primary.withValues(alpha: 0.3);
      case 2:
        return colorScheme.primary.withValues(alpha: 0.5);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.7);
      case 4:
        return colorScheme.primary;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final year = today.year;
    final colorScheme = Theme.of(context).colorScheme;

    final firstDay = DateTime(year, 1, 1);
    final lastDay = DateTime(year, 12, 31);

    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    final totalDays = lastDay.difference(startDate).inDays + 1;

    const daysLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Consumer<ContributionProvider>(
      builder: (context, provider, _) {
        final contributionsMap = provider.contributionsMap;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 70),
                        ...daysLabels.map(
                          (d) => SizedBox(
                            width:
                                ContributionGrid.boxSize +
                                ContributionGrid.spacing,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate((totalDays / 7).ceil(), (
                        weekIndex,
                      ) {
                        final weekStart = startDate.add(
                          Duration(days: weekIndex * 7),
                        );
                        final showMonth =
                            weekStart.day <= 7 && weekStart.month <= 12;

                        final weekProgress =
                            (weekIndex + 1) / ((totalDays / 7).ceil());
                        final weekOpacity = (weekProgress * 1.5).clamp(
                          0.0,
                          1.0,
                        );

                        return Opacity(
                          opacity: weekOpacity,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  showMonth ? _monthName(weekStart.month) : '',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              ...List.generate(7, (dayIndex) {
                                final currentDate = weekStart.add(
                                  Duration(days: dayIndex),
                                );

                                if (currentDate.year != year) {
                                  return SizedBox(
                                    width:
                                        ContributionGrid.boxSize +
                                        ContributionGrid.spacing,
                                    height:
                                        ContributionGrid.boxSize +
                                        ContributionGrid.spacing,
                                  );
                                }

                                final dateKey =
                                    '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
                                final contribution = contributionsMap[dateKey];
                                final level = contribution?.level ?? 0;

                                final isToday =
                                    currentDate.year == today.year &&
                                    currentDate.month == today.month &&
                                    currentDate.day == today.day;

                                return _AnimatedContributionCell(
                                  level: level,
                                  isToday: isToday,
                                  colorScheme: colorScheme,
                                  getColor: _getColor,
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }
}

class _AnimatedContributionCell extends StatelessWidget {
  final int level;
  final bool isToday;
  final ColorScheme colorScheme;
  final Color Function(BuildContext, int) getColor;

  const _AnimatedContributionCell({
    required this.level,
    required this.isToday,
    required this.colorScheme,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (level * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.all(ContributionGrid.spacing / 2),
            width: ContributionGrid.boxSize,
            height: ContributionGrid.boxSize,
            decoration: BoxDecoration(
              color: getColor(context, level),
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
