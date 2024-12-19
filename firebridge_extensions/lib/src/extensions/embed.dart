import 'package:firebridge/firebridge.dart';

/// Extensions on [Embed].
extension EmbedExtensions on Embed {
  /// Return an [EmbedBuilder] that can be used to construct this embed.
  EmbedBuilder toEmbedBuilder() {
    return EmbedBuilder(
      author: author?._toEmbedAuthorBuilder(),
      color: color,
      description: description,
      fields: fields?.map((field) => field._toEmbedFieldBuilder()).toList(),
      footer: footer?._toEmbedFooterBuilder(),
      image: image?._toEmbedImageBuilder(),
      thumbnail: thumbnail?._toEmbedThumbnailBuilder(),
      timestamp: timestamp,
      title: title,
      url: url,
    );
  }
}

extension on EmbedAuthor {
  EmbedAuthorBuilder _toEmbedAuthorBuilder() =>
      EmbedAuthorBuilder(name: name, iconUrl: iconUrl, url: url);
}

extension on EmbedField {
  EmbedFieldBuilder _toEmbedFieldBuilder() =>
      EmbedFieldBuilder(name: name, value: value, isInline: inline);
}

extension on EmbedFooter {
  EmbedFooterBuilder _toEmbedFooterBuilder() =>
      EmbedFooterBuilder(text: text, iconUrl: iconUrl);
}

extension on EmbedImage {
  EmbedImageBuilder _toEmbedImageBuilder() => EmbedImageBuilder(url: url);
}

extension on EmbedThumbnail {
  EmbedThumbnailBuilder _toEmbedThumbnailBuilder() =>
      EmbedThumbnailBuilder(url: url);
}
