// sos_button.dart
import 'package:flutter/material.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final Color color;

  const SosButton({
    Key? key,
    required this.onPressed,
    this.size = 100.0,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;
  int _pressCount = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSosPressed() {
    setState(() {
      _isPressed = true;
      _pressCount++;
    });
    
    // Reset after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
    
    // If pressed 3 times, trigger the SOS
    if (_pressCount >= 3) {
      widget.onPressed();
      _pressCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            if (_animationController.isAnimating)
              Container(
                width: widget.size * (_isPressed ? 1.5 : _scaleAnimation.value),
                height: widget.size * (_isPressed ? 1.5 : _scaleAnimation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.3 * (1 - _pulseAnimation.value)),
                ),
              ),
            
            // Main button
            GestureDetector(
              onTap: _onSosPressed,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed ? Colors.redAccent : widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            // Tap counter
            if (_pressCount > 0 && _pressCount < 3)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Tap ${3 - _pressCount} more ${_pressCount == 2 ? 'time' : 'times'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}