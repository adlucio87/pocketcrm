import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/presentation/contact_detail/voice_note_provider.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class VoiceNoteSheet extends ConsumerStatefulWidget {
  final String contactId;

  const VoiceNoteSheet({super.key, required this.contactId});

  @override
  ConsumerState<VoiceNoteSheet> createState() => _VoiceNoteSheetState();
}

class _VoiceNoteSheetState extends ConsumerState<VoiceNoteSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceNoteNotifierProvider);

    ref.listen<VoiceNoteState>(voiceNoteNotifierProvider, (previous, next) {
      if (next.status == VoiceNoteStatus.review &&
          previous?.status != VoiceNoteStatus.review) {
        _textController.text = next.transcribedText;
      }

      if (next.status == VoiceNoteStatus.error &&
          previous?.status != VoiceNoteStatus.error) {
        if (next.errorMessage != null) {
           SnackbarHelper.showError(context, next.errorMessage!);
        }
      }

      if (next.status == VoiceNoteStatus.idle && previous?.status == VoiceNoteStatus.transcribing) {
         if (mounted) {
            Navigator.of(context).pop();
            SnackbarHelper.showSuccess(context, 'Voice note saved');
         }
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoiceNoteState state) {
    switch (state.status) {
      case VoiceNoteStatus.idle:
      case VoiceNoteStatus.error:
        return _buildIdleState(context);
      case VoiceNoteStatus.recording:
        return _buildRecordingState(context, state);
      case VoiceNoteStatus.transcribing:
        return _buildTranscribingState(context);
      case VoiceNoteStatus.review:
        return _buildReviewState(context, state);
    }
  }

  Widget _buildIdleState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.mic,
            size: 64,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            ref.read(voiceNoteNotifierProvider.notifier).startRecording();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Start recording', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Transcription is done on device',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecordingState(BuildContext context, VoiceNoteState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Listening...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildPulseCircle(0.0),
            _buildPulseCircle(0.2),
            _buildPulseCircle(0.4),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.stop, size: 40, color: Colors.white),
                onPressed: () {
                  ref.read(voiceNoteNotifierProvider.notifier).stopRecording();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          _formatDuration(state.recordingSeconds),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () {
             ref.read(voiceNoteNotifierProvider.notifier).reset();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Widget _buildPulseCircle(double delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final t = (_animationController.value - delay) % 1.0;
        final value = t < 0 ? t + 1.0 : t;
        final scale = 1.0 + (value * 1.5);
        final opacity = 1.0 - value;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(opacity * 0.5),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTranscribingState(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 64),
        CircularProgressIndicator(),
        SizedBox(height: 32),
        Text(
          'Transcribing...',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 64),
      ],
    );
  }

  Widget _buildReviewState(BuildContext context, VoiceNoteState state) {
    if (state.transcribedText.isEmpty && _textController.text.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Could not recognize speech. Please try again in a quieter environment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(voiceNoteNotifierProvider.notifier).reset();
            },
            child: const Text('Rerecord'),
          )
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Transcribed voice note — edit if necessary',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: 8,
          minLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            return Text(
              '${value.text.length} characters',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            if (!await DemoUtils.checkDemoAction(context, ref)) return;
            ref
                .read(voiceNoteNotifierProvider.notifier)
                .saveNote(widget.contactId, _textController.text.trim());
          },
          style: ElevatedButton.styleFrom(
             padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save as note'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            ref.read(voiceNoteNotifierProvider.notifier).reset();
          },
          child: const Text('Rerecord'),
        ),
      ],
    );
  }
}
