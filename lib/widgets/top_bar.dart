import 'package:asly/screens/my_styles/text_styles.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final void Function()? onTap;
  final bool showBackButton;
  final String? title;
  final IconData? leadingIcon;
  const TopBar({
    super.key,
    this.onTap,
    this.showBackButton = true,
    this.title = "هواتفي المسجلة",
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 5, right: 5, left: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [const Color(0xff1B395B), Color.fromRGBO(27, 57, 91, 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1B395B).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const SizedBox(width: 10),
          showBackButton
              ? Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    splashRadius: 20,
                  ),
                )
              : const SizedBox.shrink(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(leadingIcon, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  title ?? "",
                  style: TextStyles.myTextStyle(
                    Colors.white,
                    24,
                    true,
                  )?.copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
