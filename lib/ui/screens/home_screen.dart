import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_provider.dart';
import 'scenario_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('異聞錄')),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('載入劇本失敗：$e'),
          ),
        ),
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const Center(child: Text('沒有可玩的劇本'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: scenarios.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = scenarios[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScenarioScreen(scenario: s),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (s.estimatedMinutes != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Color(0xFFA0A0A0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '約 ${s.estimatedMinutes} 分鐘',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFA0A0A0),
                                ),
                              ),
                              if (s.author != null) ...[
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Color(0xFFA0A0A0),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  s.author!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFA0A0A0),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
