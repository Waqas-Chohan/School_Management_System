import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Opens the shared monthly calendar as a bottom sheet and resolves with the
/// chosen date (or `null` when dismissed without applying).
///
/// This is the same calendar format used on the Teacher Attendance screen:
/// a month header with prev/next arrows, weekday initials, a selectable day
/// grid and an "Apply Date" action. It works on every screen of the app.
Future<DateTime?> showCalendarSheet(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AppCalendarSheet(initialDate: initialDate),
  );
}

/// Shared monthly calendar bottom-sheet content reproduced from the Figma
/// Teacher Attendance calendar (92:1330). Tapping a day selects it (the blue
/// circle), tapping "Apply Date" pops the sheet with the chosen [DateTime].
class AppCalendarSheet extends StatefulWidget {
  const AppCalendarSheet({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<AppCalendarSheet> createState() => _AppCalendarSheetState();
}

class _AppCalendarSheetState extends State<AppCalendarSheet> {
  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _visibleMonth;
  late DateTime _selected;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    _selected = base;
    _visibleMonth = DateTime(base.year, base.month);
  }

  void _confirmDay(DateTime date) {
    Navigator.of(context).pop(date);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _totalRows {
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final offset = _visibleMonth.weekday % 7;
    return ((offset + days) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final offset = _visibleMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: Color(0xFF3B5BDB),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B5BDB),
                    ),
                  ),
                  if (_selected.month == _visibleMonth.month &&
                      _selected.year == _visibleMonth.year)
                    Text(
                      'Selected: ${_selectedLabel()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF737373),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekday header
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Day grid
          for (var row = 0; row < _totalRows; row++) ...[
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(child: _dayCell(row, col, offset)),
              ],
            ),
            if (row < _totalRows - 1) const SizedBox(height: 4),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: days == 0 ? null : () => _confirmDay(_selected),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2249DC),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Apply Date',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(int row, int col, int offset) {
    final dayNum = row * 7 + col - offset + 1;
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    if (dayNum < 1 || dayNum > days) return const SizedBox.shrink();

    final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
    final isToday = _isSameDay(date, _today);
    final isSelected = _isSameDay(date, _selected);

    return InkWell(
      onTap: () => _confirmDay(date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2249DC) : null,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$dayNum',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: (isSelected || isToday)
                ? FontWeight.w700
                : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : isToday
                ? const Color(0xFF2249DC)
                : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  String _selectedLabel() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${_selected.day} ${months[_selected.month - 1]} ${_selected.year}';
  }
}
