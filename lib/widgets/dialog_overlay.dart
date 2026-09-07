import 'package:flutter/material.dart';
import '../components/npc_component.dart';

/// NPC dialogue overlay.
class DialogOverlay extends StatefulWidget {
  final NpcComponent npc;
  final VoidCallback onClose;

  const DialogOverlay({
    super.key,
    required this.npc,
    required this.onClose,
  });

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  int _dialogIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dialogues = widget.npc.def.dialogues;
    final currentText = dialogues[_dialogIndex % dialogues.length];
    final isLast = _dialogIndex >= dialogues.length - 1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NPC avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 14),
              // Text and controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.npc.def.name,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: widget.onClose,
                            child: const Text(
                              '关闭',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (isLast) {
                                widget.onClose();
                              } else {
                                setState(() {
                                  _dialogIndex++;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child: Text(isLast ? '完成' : '下一句 ▶'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
