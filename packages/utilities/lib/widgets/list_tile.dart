import 'package:flutter/material.dart';
import 'package:utilities/utils/fonts.dart';

/// Wrapper della [ListTile] normale, ma degli stili
/// custom
class TodubaListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const TodubaListTile({
    required this.title,
    this.subtitle,
    this.titleTextStyle = Fonts.listTileTitleStyle,
    this.subtitleTextStyle = Fonts.listTileSubtitleStyle,
    this.trailing,
    this.leading,
    this.onTap,
    Key? key,
  }) : super(key: key);

  /// Il titolo della [TodubaListTile]
  final String title;

  /// Il sottotitolo della [TodubaListTile]
  final String? subtitle;

  /// Definisce lo stile da applicare al titolo della [TodubaListTile]
  ///
  /// Di default viene utilizzato [Fonts.listTileTitleStyle]
  final TextStyle titleTextStyle;

  /// Definisce lo stile da applicare al sottotitolo della [TodubaListTile]
  ///
  /// Di default viene utilizzato [Fonts.listTileSubtitleStyle]
  final TextStyle subtitleTextStyle;

  /// Assume lo stesso ruolo di [ListTile.trailing]
  final Widget? trailing;

  /// Assume lo stesso ruolo di [ListTile.onTap]
  final VoidCallback? onTap;

  /// Assume lo stesso ruolo di [ListTile.leading]
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: titleTextStyle),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: subtitleTextStyle,
            )
          : null,
      onTap: onTap,
      leading: leading,
      trailing: trailing,
    );
  }
}
