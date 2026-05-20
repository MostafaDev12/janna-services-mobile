import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/i18n/locale_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/launch_helpers.dart';
import '../../shared/models/important_number.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import 'important_numbers_repository.dart';

class ImportantNumbersScreen extends StatefulWidget {
  const ImportantNumbersScreen({super.key});

  @override
  State<ImportantNumbersScreen> createState() => _ImportantNumbersScreenState();
}

class _ImportantNumbersScreenState extends State<ImportantNumbersScreen> {
  final _repo = ImportantNumbersRepository();
  late Future<List<ImportantNumber>> _future = _repo.all();

  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() => _future = _repo.all());
  }

  Future<void> _refresh() async {
    setState(() => _future = _repo.all());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'important_numbers'))),
      body: FutureBuilder<List<ImportantNumber>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error, onRetry: _refresh);
          }
          final numbers = snapshot.data ?? const <ImportantNumber>[];
          if (numbers.isEmpty) {
            return EmptyView(
              title: AppStrings.of(context, 'no_numbers_yet'),
              icon: Icons.phone_disabled_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: numbers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NumberTile(number: numbers[i]),
            ),
          );
        },
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.number});
  final ImportantNumber number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone_in_talk_rounded,
                color: AppColors.chipFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((number.description ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      number.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => LaunchHelpers.dial(number.phone),
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: Text(number.phone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              if ((number.whatsapp ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => LaunchHelpers.openWhatsApp(number.whatsapp!),
                  icon: const Icon(Icons.chat_rounded, size: 14),
                  label: Text(AppStrings.of(context, 'whatsapp')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.whatsapp,
                    side: const BorderSide(color: AppColors.whatsapp),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
