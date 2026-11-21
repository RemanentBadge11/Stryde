import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';

/// A compact live countdown used by the habit, quest, and daily-goal cycles.
class CycleCountdown extends StatefulWidget {
  const CycleCountdown({
    required this.endsAt,
    this.prefix = 'Resets in',
    this.onElapsed,
    super.key,
  });

  final DateTime endsAt;
  final String prefix;
  final VoidCallback? onElapsed;

  @override
  State<CycleCountdown> createState() => _CycleCountdownState();
}

class _CycleCountdownState extends State<CycleCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  var _notified = false;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(CycleCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt) {
      _notified = false;
      _remaining = _calculateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemaining() {
    final remaining = widget.endsAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _tick() {
    if (!mounted) return;
    final remaining = widget.endsAt.difference(DateTime.now());
    setState(
      () => _remaining = remaining.isNegative ? Duration.zero : remaining,
    );
    if (remaining <= Duration.zero && !_notified) {
      _notified = true;
      widget.onElapsed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.timer_outlined,
          size: 13,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.prefix} ${_formatDuration(_remaining)}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 1 << 31);
  final days = totalSeconds ~/ 86400;
  final hours = (totalSeconds % 86400) ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final clock =
      '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
  return days > 0 ? '${days}d $clock' : clock;
}
