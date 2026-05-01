import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('授權與致謝')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('背景音樂'),
              const SizedBox(height: 8),
              const _PlainNote(
                '所有 BGM 來自 Pixabay，依 Pixabay Content License 授權使用'
                '（免費供商業 / 非商業用途，無需署名歸屬）。\n'
                'https://pixabay.com/music/\n'
                'https://pixabay.com/service/license-summary/',
              ),
              const SizedBox(height: 24),

              _SectionTitle('音效'),
              const SizedBox(height: 8),
              const _PlainNote(
                '所有 SFX 來自 Freesound（https://freesound.org/），'
                '依各自原始頁面所列授權條款使用。多數為 CC0 公眾領域，'
                '需要署名歸屬者列示如下：',
              ),
              const SizedBox(height: 12),
              const _AttributionCard(
                title: 'Failure 3.wav',
                author: 'FunWithSound',
                source: 'https://freesound.org/s/394898/',
                license: 'CC BY 4.0',
                licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
                modification: '重新編碼為 96 kbps MP3、副檔名由 .wav 變更為 .mp3',
                usedAs: '骰子大失敗音效（outcome_fumble）',
              ),
              const SizedBox(height: 24),

              _SectionTitle('程式碼授權'),
              const SizedBox(height: 8),
              const _PlainNote(
                '本作品原創程式碼採用 PolyForm Noncommercial License 1.0.0。\n'
                'https://polyformproject.org/licenses/noncommercial/1.0.0/',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0C770),
        letterSpacing: 2,
      ),
    );
  }
}

class _AttributionCard extends StatelessWidget {
  final String title;
  final String author;
  final String source;
  final String license;
  final String licenseUrl;
  final String modification;
  final String usedAs;

  const _AttributionCard({
    required this.title,
    required this.author,
    required this.source,
    required this.license,
    required this.licenseUrl,
    required this.modification,
    required this.usedAs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$title"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCFCFCF),
                ),
              ),
              const SizedBox(height: 8),
              _Row(label: '作者', value: author),
              _Row(label: '來源', value: source),
              _Row(label: '授權', value: '$license\n$licenseUrl'),
              _Row(label: '修改', value: modification),
              _Row(label: '使用於', value: usedAs),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFCFCFCF),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainNote extends StatelessWidget {
  final String text;
  const _PlainNote(this.text);

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFA0A0A0),
          height: 1.6,
        ),
      ),
    );
  }
}
