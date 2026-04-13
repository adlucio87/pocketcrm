import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideToExecuteButton extends StatefulWidget {
  final Future<void> Function() onExecute;
  final bool enabled;

  const SlideToExecuteButton({
    super.key,
    required this.onExecute,
    this.enabled = true,
  });

  @override
  State<SlideToExecuteButton> createState() => _SlideToExecuteButtonState();
}

class _SlideToExecuteButtonState extends State<SlideToExecuteButton> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isLoading = false;
  bool _isSuccess = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _isLoading || _isSuccess) return;

    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) _dragPosition = 0;
      // Assume total width is screen width - 32 for padding
      final maxWidth = MediaQuery.of(context).size.width - 32 - 56;
      if (_dragPosition > maxWidth) {
        _dragPosition = maxWidth;
      }
    });

    // HapticFeedback inside the drag loop was causing excessive vibration
    // It's removed based on review feedback.

  }

  void _onDragEnd(DragEndDetails details) async {
    if (!widget.enabled || _isLoading || _isSuccess) return;

    final maxWidth = MediaQuery.of(context).size.width - 32 - 56;
    if (_dragPosition >= maxWidth * 0.9) {
      setState(() {
        _dragPosition = maxWidth;
        _isLoading = true;
      });
      HapticFeedback.mediumImpact();

      try {
        await widget.onExecute();
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
        HapticFeedback.heavyImpact();
      } catch (e) {
        setState(() {
          _isLoading = false;
          _dragPosition = 0;
        });
        HapticFeedback.vibrate();
        _shakeController.forward(from: 0.0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossibile avviare il workflow", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _dragPosition = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 32;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset = 10 * (0.5 - (0.5 - _shakeController.value).abs());
        return Transform.translate(
          offset: Offset(offset * (_shakeController.value * 4 % 2 == 0 ? 1 : -1), 0),
          child: Container(
            height: 56,
            width: maxWidth,
            decoration: BoxDecoration(
              color: _isSuccess
                  ? Colors.green
                  : (widget.enabled ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                Center(
                  child: _isSuccess
                      ? const Text("Successo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : Text(
                          "Scorri per avviare",
                          style: TextStyle(
                            color: widget.enabled ? Theme.of(context).primaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                Positioned(
                  left: _dragPosition,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isSuccess ? Colors.green : (widget.enabled ? Theme.of(context).primaryColor : Colors.grey),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : _isSuccess
                              ? const Icon(Icons.check, color: Colors.white)
                              : const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
