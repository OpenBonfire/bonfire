import 'package:bonfire/shared/components/buttons/no_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_expandable/sliver_expandable.dart';

class ChannelCategorySliver extends StatefulWidget {
  final String name;
  final List<Widget> channels;
  final Widget? paginatedSliver;
  const ChannelCategorySliver({
    super.key,
    required this.name,
    required this.channels,
    this.paginatedSliver,
  });

  @override
  State<ChannelCategorySliver> createState() => _ChannelCategorySliverState();
}

class _ChannelCategorySliverState extends State<ChannelCategorySliver> {
  bool _expanded = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSliverExpandable(
      duration: Duration(milliseconds: 150),
      headerBuilder: (context, animation) {
        return Padding(
          padding: const .only(left: 5),
          child: NoSplashButton(
            backgroundColor: Colors.transparent,
            borderRadius: .circular(5),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const .only(left: 6, top: 3, bottom: 3),
              child: Row(
                children: [
                  Text(
                    widget.name,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.0 : -0.25,
                    duration: Duration(milliseconds: 150),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      expanded: _expanded,
      sliver: widget.paginatedSliver != null && widget.channels.isNotEmpty
          ? SliverMainAxisGroup(
              slivers: [
                SliverList.separated(
                  itemCount: widget.channels.length,
                  separatorBuilder: (context, index) => SizedBox(height: 4),
                  itemBuilder: (context, index) => widget.channels[index],
                ),
                SliverToBoxAdapter(child: SizedBox(height: 4)),
                widget.paginatedSliver!,
              ],
            )
          : widget.paginatedSliver ??
                SliverList.separated(
                  itemCount: widget.channels.length,
                  separatorBuilder: (context, index) => SizedBox(height: 4),
                  itemBuilder: (context, index) => widget.channels[index],
                ),
    );
  }
}
