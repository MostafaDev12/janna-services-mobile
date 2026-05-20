import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_colors.dart';

class AreaChip extends StatelessWidget {
  const AreaChip({super.key, required this.areaType, this.dense = false});

  final String areaType;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final inside = areaType == 'inside_compound';
    final label = AppStrings.of(
      context,
      inside ? 'inside_compound' : 'near_compound',
    );
    final icon = inside ? Icons.location_city : Icons.near_me_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 12 : 14, color: AppColors.chipFg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.chipFg,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
