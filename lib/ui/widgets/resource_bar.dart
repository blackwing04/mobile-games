import 'package:flutter/material.dart';

import '../../engine/models/resource.dart';

class ResourceBar extends StatelessWidget {
  final List<ResourceDef> defs;
  final Map<String, int> values;

  const ResourceBar({super.key, required this.defs, required this.values});

  @override
  Widget build(BuildContext context) {
    final visibleDefs = defs.where((d) => !d.hidden).toList(growable: false);
    if (visibleDefs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: visibleDefs.map((def) {
          final value = values[def.id] ?? 0;
          final maxText = def.max != null ? '/${def.max}' : '';
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(def.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${def.name}: $value$maxText',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCFCFCF),
                ),
              ),
            ],
          );
        }).toList(growable: false),
      ),
    );
  }
}
