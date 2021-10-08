// ignore_for_file: public_member_api_docs

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

@Deprecated('Utilizzare la TodubaListTile')
class CustomListTile extends StatelessWidget {
  @Deprecated('Utilizzare la TodubaListTile')
  const CustomListTile({
    this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.leading,
    this.isThreeLine = false,
    this.titleAutoSizeGroup,
    this.subtitleAutoSizeGroup,
    this.subtitleMaxLines = 2,
    this.titleMinFontSize = 12,
    this.subtitleMinFontSize = 12,
    this.subtitleMaxFontSize = 14,
    this.titleMaxFontSize = 15,
    this.titleColor,
    this.titlePaddingFactor = 0,
    this.subtitlePaddingFactor = 0,
    Key? key,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isThreeLine;
  final Widget? trailing;
  final Widget? leading;
  final AutoSizeGroup? titleAutoSizeGroup;
  final AutoSizeGroup? subtitleAutoSizeGroup;
  final int subtitleMaxLines;
  final double titleMinFontSize;
  final Color? titleColor;
  final double titleMaxFontSize;
  final double subtitleMinFontSize;
  final double titlePaddingFactor;
  final double subtitlePaddingFactor;
  final double subtitleMaxFontSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListTile(
      isThreeLine: isThreeLine,
      leading: leading,
      title: Container(
        padding: EdgeInsets.only(right: size.width * titlePaddingFactor),
        child: AutoSizeText(
          title!,
          style: Theme.of(context).primaryTextTheme.headline6!.copyWith(
                color: titleColor,
              ),
          maxLines: 1,
          group: titleAutoSizeGroup,
          maxFontSize: titleMaxFontSize,
          overflow: TextOverflow.ellipsis,
          minFontSize: titleMinFontSize,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Container(
              padding: EdgeInsets.only(
                right: size.width * subtitlePaddingFactor,
              ),
              child: AutoSizeText(
                subtitle!,
                style: Theme.of(context).primaryTextTheme.subtitle2,
                maxLines: subtitleMaxLines,
                group: subtitleAutoSizeGroup,
                maxFontSize: subtitleMaxFontSize,
                minFontSize: subtitleMinFontSize,
              ),
            ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
