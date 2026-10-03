import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final bool isSmall;

  const TagChip({
    super.key,
    required this.name,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final backgroundColor = isSelected
        ? primaryColor.withValues(alpha: 0.15)
        : Colors.indigo.shade50;
    final borderColor = isSelected ? primaryColor : Colors.indigo.shade200;
    final textColor = isSelected ? primaryColor : Colors.indigo.shade900;

    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final fontSize = isSmall ? 10.5 : 12.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: fontSize + 1,
                color: textColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 3),
              Text(
                name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDeleted,
                  child: Icon(
                    Icons.close,
                    size: fontSize + 2,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

