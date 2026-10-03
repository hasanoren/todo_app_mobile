import 'package:flutter/material.dart';

import '../../../../core/utils/color_utils.dart';

class ColorPickerGrid extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onColorSelected;

  const ColorPickerGrid({
    super.key,
    required this.selectedHex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ColorUtils.presetColors.map((color) {
        final hex = ColorUtils.toHex(color);
        final isSelected = hex.toUpperCase() == selectedHex.toUpperCase();

        return InkWell(
          onTap: () => onColorSelected(hex),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
