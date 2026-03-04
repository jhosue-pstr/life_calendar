import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../contributions/presentation/providers/contribution_provider.dart';

class ContributionGrid extends StatelessWidget {
  const ContributionGrid({super.key});

  static const double boxSize = 16;
  static const double spacing = 6;

  Color _getColor(int level) {
    switch (level) {
      case 1:
        return Colors.green.shade300;
      case 2:
        return Colors.green.shade500;
      case 3:
        return Colors.green.shade700;
      case 4:
        return Colors.green.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final year = today.year;

    final firstDay = DateTime(year, 1, 1);
    final lastDay = DateTime(year, 12, 31);

    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    final totalDays = lastDay.difference(startDate).inDays + 1;

    final daysLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Consumer<ContributionProvider>(
      builder: (context, provider, _) {
        final contributionsMap = provider.contributionsMap;

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
                        width: boxSize + spacing,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: List.generate((totalDays / 7).ceil(), (weekIndex) {
                    final weekStart = startDate.add(
                      Duration(days: weekIndex * 7),
                    );
                    final showMonth =
                        weekStart.day <= 7 && weekStart.month <= 12;

                    return Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            showMonth ? _monthName(weekStart.month) : '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...List.generate(7, (dayIndex) {
                          final currentDate = weekStart.add(
                            Duration(days: dayIndex),
                          );

                          if (currentDate.year != year) {
                            return SizedBox(
                              width: boxSize + spacing,
                              height: boxSize + spacing,
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

                          return Container(
                            margin: EdgeInsets.all(spacing / 2),
                            width: boxSize,
                            height: boxSize,
                            decoration: BoxDecoration(
                              color: _getColor(level),
                              borderRadius: BorderRadius.circular(4),
                              border: isToday
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }
}
