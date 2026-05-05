import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Debug-only scene id 顯示 + 複製按鈕。
///
/// 點整個 chip 即複製 sceneId 到剪貼簿並顯示 SnackBar 提示。
/// 三個入口（ScenarioScreen AppBar / EndingScreen 浮層 / Debug 瀏覽器 tile）共用。
class DebugSceneIdChip extends StatelessWidget {
  final String sceneId;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;
  final double iconSize;

  const DebugSceneIdChip({
    super.key,
    required this.sceneId,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.decoration,
    this.iconSize = 13,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: sceneId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已複製：$sceneId'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const defaultStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 11,
      color: Colors.white70,
    );
    final style = textStyle ?? defaultStyle;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: padding,
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  sceneId,
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.copy,
                size: iconSize,
                color: style.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
