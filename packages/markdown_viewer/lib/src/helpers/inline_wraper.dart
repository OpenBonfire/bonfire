import 'package:flutter/widgets.dart';

/// A fake widget in order to return a list of widget from
/// [MarkdownElementBuilder.buildWidget] when it is an inline element.
class InlineWraper extends Widget {
  const InlineWraper(this.children, {Key? key}) : super(key: key);
  final List<Widget> children;

  @override
  InlineWraperElement createElement() =>
      InlineWraperElement(const SizedBox.shrink());
}

class InlineWraperElement extends Element {
  InlineWraperElement(super.widget);

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {
    super.performRebuild();
  }
}
