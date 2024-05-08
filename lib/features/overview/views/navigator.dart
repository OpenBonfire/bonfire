import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopUpNavigationBar extends StatefulWidget {
  final OverlappingPanels panel;
  const PopUpNavigationBar({Key? key, required this.panel}) : super(key: key);

  @override
  _PopUpNavigationBarState createState() => _PopUpNavigationBarState();
}

class _PopUpNavigationBarState extends State<PopUpNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.panel,
        BarWidget(
          panel: widget.panel,
        )
      ],
    );
  }
}

class BarWidget extends ConsumerStatefulWidget {
  final OverlappingPanels panel;
  const BarWidget({Key? key, required this.panel}) : super(key: key);

  @override
  ConsumerState<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<BarWidget> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(navigationBarProvider);

    if (state == RevealSide.left) {
      visible = true;
    } else {
      visible = false;
    }
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: visible ? 0 : -80,
      left: 0,
      right: 0,
      curve: Curves.easeInOutExpo,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        )),
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.cardSelected,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).custom.colorTheme.brightestGray,
                  width: 0.5,
                ),
              ),
            ),
            height: 75,
            child: const Padding(
              padding: EdgeInsets.only(top: 16, left: 18, right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavigatorIcon(icon: Icons.home_rounded, label: 'Home'),
                  NavigatorIcon(icon: Icons.message_rounded, label: 'Messages'),
                  NavigatorIcon(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications'),
                  NavigatorIcon(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications'),
                ],
              ),
            )),
      ),
    );
  }
}

class NavigatorIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  const NavigatorIcon({super.key, required this.icon, required this.label});

  @override
  State<NavigatorIcon> createState() => NavigatorIconState();
}

class NavigatorIconState extends State<NavigatorIcon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Icon(
            widget.icon,
            grade: 50,
            weight: 50,
            size: 25,
            color: Theme.of(context).custom.colorTheme.selectedIconColor,
          ),
          Text(widget.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).custom.textTheme.subtitle2.copyWith(
                    fontSize: 9,
                    color:
                        Theme.of(context).custom.colorTheme.selectedIconColor,
                  ))
        ],
      ),
    );
  }
}
