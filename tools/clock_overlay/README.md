# 23:47 時鐘合成素材

`clock_2347_hands_only.png` 是透明背景的 23:47 時針 / 分針 / 秒針 PNG。

## 為什麼存在

AI 出圖（Gemini / Imagen）畫時鐘指針位置常常不準，但 23:47 是 IP signature 時刻必須精確。

工作流：
1. 跟 Gemini 要「**空白鐘面**」（沒有指針 / 指針位置不重要）
2. 在 Photoshop / GIMP / 手機修圖 app 把此 PNG 疊上去，對齊 + 縮放
3. 輸出合成後的場景圖

## 為什麼放這裡（不放 assets/）

`assets/` 下的檔案會被 Flutter 打包進 APK / Web build。這張是**製圖階段的素材**，不是遊戲執行期要用的資源，放在 `tools/` 讓它不會被 bundle 進去。

## 未來如果要 batch 合成

需要 user 提供每張場景圖的對齊參數（x, y, scale, rotation），才能寫 Python 腳本批次處理。各場景時鐘位置差太多，無法自動偵測。
