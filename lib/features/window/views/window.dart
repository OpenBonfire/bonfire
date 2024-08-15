import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

class WindowTopBar extends StatelessWidget {
  const WindowTopBar({super.key});

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
              const WindowButtons(),
            ],
          ),
        ),
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        MinimizeWindowButton(),
        MaximizeRestoreWindowButton(),
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
          Icons.minimize,
          size: 18),
      onPressed: () {
        appWindow.minimize();
      },
    );
  }
}

class MaximizeRestoreWindowButton extends StatelessWidget {
  const MaximizeRestoreWindowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        color: Theme.of(context).custom.colorTheme.messageBarActivatedIcon,
        appWindow.isMaximized ? Icons.restore : Icons.crop_square,
        size: 18,
      ),
      onPressed: () {
        if (appWindow.isMaximized) {
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
