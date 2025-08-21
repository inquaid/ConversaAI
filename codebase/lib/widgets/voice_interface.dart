import 'package:flutter/material.dart';
import '../providers/voice_provider.dart';
import 'voice_visualizer.dart';

class VoiceInterface extends StatefulWidget {
  final VoiceState voiceState;
  final double volumeLevel;
  final VoidCallback onMicPressed;
  final bool isRecording;

  const VoiceInterface({
    super.key,
    required this.voiceState,
    required this.volumeLevel,
    required this.onMicPressed,
    required this.isRecording,
  });

  @override
  State<VoiceInterface> createState() => _VoiceInterfaceState();
}

class _VoiceInterfaceState extends State<VoiceInterface>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceInterface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.voiceState != oldWidget.voiceState) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    switch (widget.voiceState) {
      case VoiceState.listening:
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
        break;
      case VoiceState.speaking:
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
        break;
      case VoiceState.processing:
        _pulseController.repeat(reverse: true);
        _waveController.stop();
        break;
      case VoiceState.idle:
      case VoiceState.error:
        _pulseController.stop();
        _waveController.stop();
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice visualizer
          if (widget.voiceState != VoiceState.idle)
            SizedBox(
              height: 150,
              child: VoiceVisualizer(
                voiceState: widget.voiceState,
                volumeLevel: widget.volumeLevel,
                waveController: _waveController,
              ),
            ),

          SizedBox(height: widget.voiceState != VoiceState.idle ? 20 : 40),

          // Main microphone button
          _buildMicrophoneButton(context),

          const SizedBox(height: 24),

          // Instruction text
          _buildInstructionText(context),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton(BuildContext context) {
    Color primaryColor = _getMicrophoneColor(context);
    bool isActive = widget.voiceState != VoiceState.idle;

    return GestureDetector(
      onTap: widget.onMicPressed,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: primaryColor.withOpacity(
                      0.3 * _pulseAnimation.value,
                    ),
                    blurRadius: 30 + (20 * _pulseAnimation.value),
                    spreadRadius: 5 + (10 * _pulseAnimation.value),
                  ),
              ],
            ),
            child: AnimatedScale(
              scale: isActive ? _scaleAnimation.value : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  border: Border.all(
                    color: isActive
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _getMicrophoneIcon(),
                      key: ValueKey(widget.voiceState),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    String instructionText = _getInstructionText();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        instructionText,
        key: ValueKey(instructionText),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getMicrophoneColor(BuildContext context) {
    switch (widget.voiceState) {
      case VoiceState.idle:
        return Theme.of(context).colorScheme.primary;
      case VoiceState.listening:
        return const Color(0xFF007AFF); // iOS blue
      case VoiceState.speaking:
        return const Color(0xFF34C759); // iOS green
      case VoiceState.processing:
        return const Color(0xFFFF9500); // iOS orange
      case VoiceState.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData _getMicrophoneIcon() {
    switch (widget.voiceState) {
      case VoiceState.idle:
        return Icons.mic;
      case VoiceState.listening:
        return Icons.mic;
      case VoiceState.speaking:
        return Icons.volume_up;
      case VoiceState.processing:
        return Icons.psychology;
      case VoiceState.error:
        return Icons.refresh;
    }
  }

  String _getInstructionText() {
    switch (widget.voiceState) {
      case VoiceState.idle:
        return "Tap to start speaking";
      case VoiceState.listening:
        return "Speak now... Tap to stop";
      case VoiceState.speaking:
        return "AI is responding...";
      case VoiceState.processing:
        return "Processing your message...";
      case VoiceState.error:
        return "Tap to try again";
    }
  }
}
