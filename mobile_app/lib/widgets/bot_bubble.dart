import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotBubble extends StatefulWidget {
  final String message;
  const BotBubble({super.key, required this.message});

  @override
  State<BotBubble> createState() => _BotBubbleState();
}

class _BotBubbleState extends State<BotBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 5, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: MarkdownBody(
                    data: widget.message,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      em: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      code: TextStyle(
                        fontFamily: 'monospace',
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
