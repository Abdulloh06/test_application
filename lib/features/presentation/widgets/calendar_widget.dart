import 'dart:math' as math;

import 'package:calendar_app/core/utils/date_format_utils.dart';
import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _dayPickerRowHeight = 42.0;
const int _maxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// One extra row for the day-of-week header.
const double _maxDayPickerHeight =
    _dayPickerRowHeight * (_maxDayPickerRowCount + 1);
const double _monthPickerHorizontalPadding = 8.0;

const int _yearPickerColumnCount = 3;
const double _yearPickerPadding = 16.0;
const double _yearPickerRowHeight = 52.0;
const double _yearPickerRowSpacing = 8.0;

const double _subHeaderHeight = 52.0;
const double _monthNavButtonsWidth = 108.0;

class CalendarWidget extends StatefulWidget {
  CalendarWidget({
    super.key,
    required DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.events,
    DateTime? currentDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
  })  : initialDate =
            initialDate == null ? null : DateUtils.dateOnly(initialDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now());

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  final DateTime currentDate;

  final ValueChanged<DateTime> onDateChanged;

  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  final DatePickerMode initialCalendarMode;

  final SelectableDayPredicate? selectableDayPredicate;

  final List<EventModel> events;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  late DateTime _currentDisplayedMonthDate;
  DateTime? _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late MaterialLocalizations _localizations;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    final DateTime currentDisplayedDate =
        widget.initialDate ?? widget.currentDate;
    _currentDisplayedMonthDate =
        DateTime(currentDisplayedDate.year, currentDisplayedDate.month);
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate && widget.initialDate != null) {
      assert(_selectedDate != null);
      _announcedInitialDate = true;
      final bool isToday =
          DateUtils.isSameDay(widget.currentDate, _selectedDate);
      final String semanticLabelSuffix =
          isToday ? ', ${_localizations.currentDateLabel}' : '';
      SemanticsService.announce(
        '${_localizations.formatFullDate(_selectedDate!)}$semanticLabelSuffix',
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_selectedDate != null) {
        if (_mode == DatePickerMode.day) {
          SemanticsService.announce(
            _localizations.formatMonthYear(_selectedDate!),
            _textDirection,
          );
        } else {
          SemanticsService.announce(
            _localizations.formatYear(_selectedDate!),
            _textDirection,
          );
        }
      }
    });
  }

  void _handleMonthChanged(DateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = DateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleYearChanged(DateTime value) {
    _vibrate();

    final int daysInMonth = DateUtils.getDaysInMonth(value.year, value.month);
    final int preferredDay = math.min(_selectedDate?.day ?? 1, daysInMonth);
    value = value.copyWith(day: preferredDay);

    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(value);

      if (_isSelectable(value)) {
        _selectedDate = value;
        widget.onDateChanged(_selectedDate!);
      }
    });
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate!);
      switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          final bool isToday =
              DateUtils.isSameDay(widget.currentDate, _selectedDate);
          final String semanticLabelSuffix =
              isToday ? ', ${_localizations.currentDateLabel}' : '';
          SemanticsService.announce(
            '${_localizations.selectedDateLabel} ${_localizations.formatFullDate(_selectedDate!)}$semanticLabelSuffix',
            _textDirection,
          );
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          break;
      }
    });
  }

  bool _isSelectable(DateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate!.call(date);
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return _MonthPicker(
          events: widget.events,
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: _subHeaderHeight),
          child: YearPicker(
            key: _yearPickerKey,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            selectedDate: _currentDisplayedMonthDate,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Column(
              children: [
                Text(
                  DateFormatUtils.weekDay(_currentDisplayedMonthDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _handleModeChanged(_mode == DatePickerMode.day
                        ? DatePickerMode.year
                        : DatePickerMode.day);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormatUtils.formatDate(),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 15),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: SvgPicture.asset('assets/icons/notification.svg'),
                onPressed: () {},
              ),
            ),
          ],
        ),
        Stack(
          children: <Widget>[
            SizedBox(
              height: _subHeaderHeight + _maxDayPickerHeight,
              child: _buildPicker(),
            ),
            _DatePickerModeToggleButton(
              mode: _mode,
              title: DateFormatUtils.monthFormat(_currentDisplayedMonthDate),
              onTitlePressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
  });

  final DatePickerMode mode;

  final String title;

  final VoidCallback onTitlePressed;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: _subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: MaterialLocalizations.of(context).selectYearSemanticsLabel,
              excludeSemantics: true,
              button: true,
              container: true,
              child: SizedBox(
                height: _subHeaderHeight,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8)
                              .copyWith(top: 15),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day)
            // Give space for the prev/next month buttons that are underneath this row
            const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  _MonthPicker({
    super.key,
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    required this.events,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate == null || !selectedDate.isBefore(firstDate)),
        assert(selectedDate == null || !selectedDate.isAfter(lastDate));

  final DateTime initialMonth;
  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;

  final DateTime? selectedDate;

  final ValueChanged<DateTime> onChanged;

  final ValueChanged<DateTime> onDisplayedMonthChanged;

  final SelectableDayPredicate? selectableDayPredicate;

  final List<EventModel> events;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  late DateTime _currentMonth;
  late PageController _pageController;
  late MaterialLocalizations _localizations;
  late TextDirection _textDirection;
  Map<ShortcutActivator, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _pageController = PageController(
        initialPage: DateUtils.monthDelta(widget.firstDate, _currentMonth));
    _shortcutMap = const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowLeft):
          DirectionalFocusIntent(TraversalDirection.left),
      SingleActivator(LogicalKeyboardKey.arrowRight):
          DirectionalFocusIntent(TraversalDirection.right),
      SingleActivator(LogicalKeyboardKey.arrowDown):
          DirectionalFocusIntent(TraversalDirection.down),
      SingleActivator(LogicalKeyboardKey.arrowUp):
          DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final DateTime monthDate =
          DateUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          // We have navigated to a new month with the grid focused, but the
          // focused day is not in this month. Choose a new one trying to keep
          // the same day of the month.
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
        SemanticsService.announce(
          _localizations.formatMonthYear(_currentMonth),
          _textDirection,
        );
      }
    });
  }

  DateTime? _focusableDayForMonth(DateTime month, int preferredDay) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    if (preferredDay <= daysInMonth) {
      final DateTime newFocus = DateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime newFocus = DateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }
    return null;
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _showMonth(DateTime month, {bool jump = false}) {
    final int monthPage = DateUtils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      DateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (DateUtils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (DateUtils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay =
              _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final DateTime? nextDate =
          _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    DateTime nextDate = DateUtils.addDaysToDate(
        date, _dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = DateUtils.addDaysToDate(
          nextDate, _dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate!.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month =
        DateUtils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
      events: widget.events,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: _subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : _localizations.previousMonthTooltip,
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: SvgPicture.asset('assets/icons/arrow_right.svg'),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : _localizations.nextMonthTooltip,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: _FocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: PageView.builder(
                  key: _pageViewKey,
                  controller: _pageController,
                  itemBuilder: _buildItems,
                  itemCount:
                      DateUtils.monthDelta(widget.firstDate, widget.lastDate) +
                          1,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the [_MonthPicker] to let its children [_DayPicker]s know
/// what the currently focused date (if any) should be.
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    required super.child,
    this.date,
  });

  final DateTime? date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static DateTime? maybeOf(BuildContext context) {
    final _FocusedDate? focusedDate =
        context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _DayPicker extends StatefulWidget {
  /// Creates a day picker.
  _DayPicker({
    super.key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.events,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate == null || !selectedDate.isBefore(firstDate)),
        assert(selectedDate == null || !selectedDate.isAfter(lastDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  final List<EventModel> events;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = _FocusedDate.maybeOf(context);
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  ///     ┌ Sunday is the first day of week in the US (en_US)
  ///     |
  ///     S M T W T F S  ← the returned list contains these widgets
  ///     _ _ _ _ _ 1 2
  ///     3 4 5 6 7 8 9
  ///
  ///     ┌ But it's Monday in the UK (en_GB)
  ///     |
  ///     M T W T F S S  ← the returned list contains these widgets
  ///     _ _ _ _ 1 2 3
  ///     4 5 6 7 8 9 10
  ///
  List<Widget> _dayHeaders(
      TextStyle? headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex;
        result.length < DateTime.daysPerWeek;
        i = (i + 1) % DateTime.daysPerWeek) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final TextStyle? weekdayStyle =
        datePickerTheme.weekdayStyle ?? defaults.weekdayStyle;

    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);

    final List<Widget> dayItems = _dayHeaders(weekdayStyle, localizations);
    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        final bool isSelectedDay =
            DateUtils.isSameDay(widget.selectedDate, dayToBuild);
        final bool isToday =
            DateUtils.isSameDay(widget.currentDate, dayToBuild);

        dayItems.add(
          _Day(
            dayToBuild,
            key: ValueKey<DateTime>(dayToBuild),
            isDisabled: isDisabled,
            isSelectedDay: isSelectedDay,
            isToday: isToday,
            onChanged: widget.onChanged,
            focusNode: _dayFocusNodes[day - 1],
            events: widget.events,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _Day extends StatefulWidget {
  const _Day(
    this.day, {
    super.key,
    required this.isDisabled,
    required this.isSelectedDay,
    required this.isToday,
    required this.onChanged,
    required this.focusNode,
    required this.events,
  });

  final DateTime day;
  final bool isDisabled;
  final bool isSelectedDay;
  final bool isToday;
  final ValueChanged<DateTime> onChanged;
  final FocusNode? focusNode;
  final List<EventModel> events;

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final TextStyle? dayStyle = datePickerTheme.dayStyle ?? defaults.dayStyle;
    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    T? resolve<T>(
        WidgetStateProperty<T>? Function(DatePickerThemeData? theme)
            getProperty,
        Set<WidgetState> states) {
      return effectiveValue(
        (DatePickerThemeData? theme) {
          return getProperty(theme)?.resolve(states);
        },
      );
    }

    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String semanticLabelSuffix =
        widget.isToday ? ', ${localizations.currentDateLabel}' : '';

    final Set<WidgetState> states = <WidgetState>{
      if (widget.isDisabled) WidgetState.disabled,
      if (widget.isSelectedDay) WidgetState.selected,
    };

    _statesController.value = states;

    final Color? dayForegroundColor = resolve<Color?>(
        (DatePickerThemeData? theme) => widget.isToday
            ? theme?.todayForegroundColor
            : theme?.dayForegroundColor,
        states);
    final Color? dayBackgroundColor = resolve<Color?>(
        (DatePickerThemeData? theme) => widget.isToday
            ? const WidgetStatePropertyAll(Colors.blue)
            : theme?.dayBackgroundColor,
        states);
    final WidgetStateProperty<Color?> dayOverlayColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => effectiveValue(
          (DatePickerThemeData? theme) =>
              theme?.dayOverlayColor?.resolve(states)),
    );
    final OutlinedBorder dayShape = resolve<OutlinedBorder?>(
        (DatePickerThemeData? theme) => theme?.dayShape, states)!;
    final ShapeDecoration decoration = widget.isToday
        ? ShapeDecoration(
            color: dayBackgroundColor,
            shape: dayShape.copyWith(
              side: (datePickerTheme.todayBorder ?? defaults.todayBorder!)
                  .copyWith(color: dayForegroundColor),
            ),
          )
        : ShapeDecoration(
            color: dayBackgroundColor,
            shape: dayShape,
          );

    Widget eventIndicator(DateTime day) {
      bool show = false;
      List<EventModel> list = [];
      for(var data in widget.events) {
        if(DateFormatUtils.parseString(data.date) == day) {
          show = true;
          list.add(data);
        }
      }
      return Visibility(
        visible: show,
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  list.length,
                      (i) => Container(
                    margin: i != list.length -1  ? const EdgeInsets.only(right: 4) : null,
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${list[i].priority}')),
                      shape: BoxShape.circle,
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    Widget dayWidget = Column(
      children: [
        DecoratedBox(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Text(localizations.formatDecimal(widget.day.day),
                  style: dayStyle?.apply(color: dayForegroundColor)),
            ),
          ),
        ),
        eventIndicator(widget.day),
      ],
    );

    if (widget.isDisabled) {
      dayWidget = ExcludeSemantics(
        child: dayWidget,
      );
    } else {
      dayWidget = InkResponse(
        focusNode: widget.focusNode,
        onTap: () => widget.onChanged(widget.day),
        statesController: _statesController,
        overlayColor: dayOverlayColor,
        customBorder: dayShape,
        containedInkWell: true,
        child: Semantics(
          label:
              '${localizations.formatDecimal(widget.day.day)}, ${localizations.formatFullDate(widget.day)}$semanticLabelSuffix',
          // Set button to true to make the date selectable.
          button: true,
          selected: widget.isSelectedDay,
          excludeSemantics: true,
          child: dayWidget,
        ),
      );
    }

    return dayWidget;
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();

class YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [lastDate] must be after the [firstDate].
  YearPicker({
    super.key,
    DateTime? currentDate,
    required this.firstDate,
    required this.lastDate,
    @Deprecated(
        'This parameter has no effect and can be removed. Previously it controlled '
        'the month that was used in "onChanged" when a new year was selected, but '
        'now that role is filled by "selectedDate" instead. '
        'This feature was deprecated after v3.13.0-0.3.pre.')
    DateTime? initialDate,
    required this.selectedDate,
    required this.onChanged,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(!firstDate.isAfter(lastDate)),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now());

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  State<YearPicker> createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  ScrollController? _scrollController;
  final WidgetStatesController _statesController = WidgetStatesController();

  // The approximate number of years necessary to fill the available space.
  static const int minYears = 18;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
        initialScrollOffset:
            _scrollOffsetForYear(widget.selectedDate ?? widget.firstDate));
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _statesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(YearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate &&
        widget.selectedDate != null) {
      _scrollController!.jumpTo(_scrollOffsetForYear(widget.selectedDate!));
    }
  }

  double _scrollOffsetForYear(DateTime date) {
    final int initialYearIndex = date.year - widget.firstDate.year;
    final int initialYearRow = initialYearIndex ~/ _yearPickerColumnCount;
    // Move the offset down by 2 rows to approximately center it.
    final int centeredYearRow = initialYearRow - 2;
    return _itemCount < minYears ? 0 : centeredYearRow * _yearPickerRowHeight;
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    T? resolve<T>(
        WidgetStateProperty<T>? Function(DatePickerThemeData? theme)
            getProperty,
        Set<WidgetState> states) {
      return effectiveValue(
        (DatePickerThemeData? theme) {
          return getProperty(theme)?.resolve(states);
        },
      );
    }

    final int offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final int year = widget.firstDate.year + index - offset;
    final bool isSelected = year == widget.selectedDate?.year;
    final bool isCurrentYear = year == widget.currentDate.year;
    final bool isDisabled =
        year < widget.firstDate.year || year > widget.lastDate.year;
    const double decorationHeight = 36.0;
    const double decorationWidth = 72.0;

    final Set<WidgetState> states = <WidgetState>{
      if (isDisabled) WidgetState.disabled,
      if (isSelected) WidgetState.selected,
    };

    final Color? textColor = resolve<Color?>(
        (DatePickerThemeData? theme) => isCurrentYear
            ? theme?.todayForegroundColor
            : theme?.yearForegroundColor,
        states);
    final Color? background = resolve<Color?>(
        (DatePickerThemeData? theme) => isCurrentYear
            ? theme?.todayBackgroundColor
            : theme?.yearBackgroundColor,
        states);
    final WidgetStateProperty<Color?> overlayColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => effectiveValue(
          (DatePickerThemeData? theme) =>
              theme?.yearOverlayColor?.resolve(states)),
    );

    BoxBorder? border;
    if (isCurrentYear) {
      final BorderSide? todayBorder =
          datePickerTheme.todayBorder ?? defaults.todayBorder;
      if (todayBorder != null) {
        border = Border.fromBorderSide(todayBorder.copyWith(color: textColor));
      }
    }
    final BoxDecoration decoration = BoxDecoration(
      border: border,
      color: background,
      borderRadius: BorderRadius.circular(decorationHeight / 2),
    );

    final TextStyle? itemStyle =
        (datePickerTheme.yearStyle ?? defaults.yearStyle)
            ?.apply(color: textColor);
    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            button: true,
            child: Text(year.toString(), style: itemStyle),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(
        child: yearItem,
      );
    } else {
      DateTime date =
          DateTime(year, widget.selectedDate?.month ?? DateTime.january);
      if (date
          .isBefore(DateTime(widget.firstDate.year, widget.firstDate.month))) {
        // Ignore firstDate.day because we're just working in years and months here.
        assert(date.year == widget.firstDate.year);
        date = DateTime(year, widget.firstDate.month);
      } else if (date.isAfter(widget.lastDate)) {
        // No need to ignore the day here because it can only be bigger than what we care about.
        assert(date.year == widget.lastDate.year);
        date = DateTime(year, widget.lastDate.month);
      }
      _statesController.value = states;
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () => widget.onChanged(date),
        statesController: _statesController,
        overlayColor: overlayColor,
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Column(
      children: <Widget>[
        const Divider(),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            dragStartBehavior: widget.dragStartBehavior,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: _yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = (constraints.crossAxisExtent -
            (_yearPickerColumnCount - 1) * _yearPickerRowSpacing) /
        _yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: _yearPickerRowHeight,
      crossAxisCount: _yearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: _yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate =
    _YearPickerGridDelegate();
