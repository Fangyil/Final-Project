import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback onPressed;

  const TooltipButton(this.message, this.icon, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

OverlayEntry? tooltipOverlay; // 將 tooltipOverlay 移至外部
void showHelpTooltip(BuildContext context, VoidCallback onClose) {
  if (tooltipOverlay != null) {
    tooltipOverlay!.remove(); // 如果已經存在，則移除
    tooltipOverlay = null; // 重置
  } else {
    tooltipOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 0.0, // 距離底部的距離
          left: 0.0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 400, // 設定固定寬度
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // 透明背景
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '操作說明',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          tooltipOverlay!.remove(); // 關閉 tooltip
                          tooltipOverlay = null; // 重置
                          onClose(); // 呼叫關閉回調
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '1. 點擊相片按鈕選擇課表圖片。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '2. 點擊顏色按鈕選擇編輯模式和非編輯模式的顏色。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '3. 編輯模式下，您可以點擊課程卡片進行編輯。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '4. 編輯完成後，按下右方儲存按鈕即可將所有課程儲存至課程資料夾。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '5. 非編輯模式下，點選課程即可路線規劃至該系館位置。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '6. 點擊資料夾按鈕可查看已儲存的課程資料夾。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '7. 長按課程卡片可查看詳細資訊。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(tooltipOverlay!); // 顯示 tooltip
  }
}
