import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';

class ResidentVisitorsScreen extends StatefulWidget {
  const ResidentVisitorsScreen({super.key});

  @override
  State<ResidentVisitorsScreen> createState() => _ResidentVisitorsScreenState();
}

class _ResidentVisitorsScreenState extends State<ResidentVisitorsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Visitor> _getVisitorsForDay(List<Visitor> allVisitors, DateTime day) {
    return allVisitors.where((visitor) {
      return isSameDay(visitor.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: Text(
          'Visitors',
          style: AppTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Consumer<ResidentProvider>(
          builder: (context, residentProvider, _) {
            final allVisitors = residentProvider.allVisitors;
            final selectedVisitors = _getVisitorsForDay(allVisitors, _selectedDay!);

            return Column(
              children: [
                TableCalendar<Visitor>(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return _getVisitorsForDay(allVisitors, day);
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: AppTheme.textSecondary),
                    weekendTextStyle: const TextStyle(color: AppTheme.textSecondary),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.black),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonTextStyle: const TextStyle(color: AppTheme.primary),
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                    titleCentered: true,
                    titleTextStyle: AppTheme.titleMedium,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppTheme.textSecondary),
                    weekendStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: selectedVisitors.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No visitors on this day.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: selectedVisitors.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final visitor = selectedVisitors[index];
                            return _VisitorListItem(visitor: visitor);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _ResidentBottomNav(currentIndex: 1),
    );
  }
}

class _VisitorListItem extends StatelessWidget {
  final Visitor visitor;
  // PERF: Cache DateFormat to avoid repeated parsing overhead in list items.
  static final _timeFormatter = DateFormat('h:mm a');

  const _VisitorListItem({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final typeLabel = visitor.type[0].toUpperCase() + visitor.type.substring(1);
    final statusLabel =
        visitor.status[0].toUpperCase() + visitor.status.substring(1);
    final timeLabel = _timeFormatter.format(visitor.date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderDark.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderDark.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeLabel • $statusLabel • $timeLabel',
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentBottomNav extends StatelessWidget {
  final int currentIndex;

  const _ResidentBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
          activeIcon: Icon(Icons.home_filled),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          label: 'Visitors',
          activeIcon: Icon(Icons.groups),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
          activeIcon: Icon(Icons.settings),
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/resident_home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/resident_visitors');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/resident_settings');
        }
      },
    );
  }
}
