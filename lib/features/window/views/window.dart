import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

class WindowTopBar extends StatefulWidget {
  const WindowTopBar({super.key});

  @override
  State<WindowTopBar> createState() => _WindowTopBarState();
}

class _WindowTopBarState extends State<WindowTopBar>
    with WidgetsBindingObserver {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isMaximized = appWindow.isMaximized;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {
        isMaximized = appWindow.isMaximized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.foreground,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Text(
                "BONFIRE",
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(child: MoveWindow()),
              WindowButtons(isMaximized: isMaximized),
            ],
          ),
        ),
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  final bool isMaximized;

  const WindowButtons({super.key, required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeRestoreWindowButton(isMaximized: isMaximized),
        CloseWindowButton(),
      ],
    );
  }
}

class MinimizeWindowButton extends StatelessWidget {
  const MinimizeWindowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        color: Theme.of(context).custom.colorTheme.messageBarActivatedIcon,
        Icons.remove,
        size: 18,
      ),
      onPressed: () {
        appWindow.minimize();
      },
    );
  }
}

class MaximizeRestoreWindowButton extends StatelessWidget {
  final bool isMaximized;

  const MaximizeRestoreWindowButton({super.key, required this.isMaximized});

  @override
  Widget build(BuildContext context) {
    // isMaximized ? Icons.crop_square : Icons.filter_none,
    return IconButton(
      icon: isMaximized
          ? const Icon(
              color: Colors.white,
              Icons.crop_square_outlined,
              size: 16,
            )
          : const Icon(
              color: Colors.white,
              Icons.filter_none_outlined,
              size: 12,
            ),
      onPressed: () {
        if (isMaximized) {
          appWindow.restore();
        } else {
          appWindow.maximize();
        }
      },
    );
  }
}

class CloseWindowButton extends StatelessWidget {
  const CloseWindowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.close,
        size: 18,
        color: Theme.of(context).custom.colorTheme.messageBarActivatedIcon,
      ),
      onPressed: () {
        appWindow.close();
      },
    );
  }
}
