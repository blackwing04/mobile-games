import 'package:flutter/material.dart';

/// 場景插圖 widget。
///
/// - 為 null 時：直接 return 空 widget，UI 不佔位
/// - 圖片載入失敗時：fallback 為深色漸層佔位 + icon
/// - 永遠維持 16:9 比例（橫向插圖）
class SceneImage extends StatelessWidget {
  final String? assetPath;

  const SceneImage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    if (assetPath == null || assetPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            child: Image.asset(
              assetPath!,
              key: ValueKey(assetPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Placeholder(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF0D0D0D)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
