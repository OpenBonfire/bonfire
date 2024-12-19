## 0.6.2
- Update `dart_markdown` dependency to 3.1.7.

## 0.6.1

- Fix a CopyButton issue.

## 0.6.0

- Update `dart_markdown` dependency to 3.1.6.
- Remove custom selection feature.
- Add scrollable feature to table.

## 0.5.0

- Fix an error in Flutter 3.7

## 0.4.10

- Add `copyIconColor` to `MarkdownStyle`.
- Add an optional parameter `context` to `MarkdownRenderer`.
- Improve the default style in dark mode.

## 0.4.9

- Fix a `mergeRichText` issue.

## 0.4.8

- Improve the default style of code blocks.

## 0.4.7

- Catch and handle Markdown parsing exception.

## 0.4.6

- Add a `copyIconBuilder` option for `MarkdownViewer` and `MarkdownRenderer` to
  customise the copy icon.

## 0.4.5

- Update to `dart_markdown` 3.1.3.

## 0.4.4

- Update to `dart_markdown` 3.1.2.

## 0.4.3

- Update to `dart_markdown` 3.1.1.

## 0.4.2

- Update to `dart_markdown` 3.1.0.

## 0.4.1

- Update to `dart_markdown` 3.0.0.

## 0.4.0

- Add a `position` attribute to `MarkdownNode`.
- **Breaking change** Change the parameters of some `Builder` methods.
- Improve the paddings of paragraph, blockquote and list blocks.
- Improve some default styles.

## 0.3.0+2

- Update to `dart_markdown` 2.1.3.

## 0.3.0+1

- Fix README.md screenshot url.

## 0.3.0

- **Breaking chang**: Change return type of `MarkdownHighlightBuilder` from
  `TextSpan` to `List<TextSpan>`.
- **Breaking chang**: Remove `selectable` option from `MarkdownViewer` and
  `MarkdownRenderer`.
- **Breaking chang**: Remove `MarkdownStyle.fromTheme`.
- Add a new optional parameter `selectionColor` to `MarkdownViewer`, with a
  default value `Color(0x4a006ff8)`, the text will become unselectable when the
  value is `null`.
- Add optional parameters `selectionRegistrar` and `selectionColor` to
  `MarkdownRenderer`.
- Add a _copy to clipboard_ button for code block.
- Big improvement on default style.

## 0.2.1

- Add `enableAutolinkExtension` option to widget
- Add `nodesFilter` option to widget
- Add `selectable` option to widget
- Update to `dart_markdown` 2.1.0

## 0.2.0+2

- Fix an issue on `highlightBuilder`
  [PR 22](https://github.com/chenzhiguang/markdown_viewer/pull/22)

## 0.2.0+1

- Update README.
- Fix a minor mistake.

## 0.2.0

- Update `dart_markdown` dependency to 2.0.0.
- Set default value for `MarkdownElementBuilder.isBlock`.

## 0.1.0

- First stable version.

## 0.0.1

- Initial release.
