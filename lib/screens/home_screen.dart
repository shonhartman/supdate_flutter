import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/di.dart';
import '../presentation/curator/curator_bloc.dart';
import '../presentation/curator/curator_event.dart';
import '../presentation/curator/curator_state.dart';
import '../presentation/curator/widgets/recommended_photo_card.dart';
import '../services/photo_permission_service.dart';

/// Authenticated home screen with sign-out and Photo Curator section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CuratorBloc>(
      create: (_) => getIt<CuratorBloc>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _pickAndRecommend(BuildContext context) async {
    final status = await PhotoPermissionService.instance.requestPhotoAccess();
    if (!context.mounted) return;
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo access is needed to pick images.')),
      );
      return;
    }

    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 100, limit: 10);
    if (!context.mounted || files.isEmpty) return;

    if (files.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 photos (2–10).')),
      );
      return;
    }

    final bytesList = <List<int>>[];
    for (final f in files) {
      final bytes = await f.readAsBytes();
      bytesList.add(bytes);
    }

    if (!context.mounted) return;
    context.read<CuratorBloc>().add(GetRecommendationRequested(bytesList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () => Supabase.instance.client.auth.signOut(),
            child: const Text('Log out'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'Photo Curator',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick 2–10 photos. We\'ll recommend the best one for a post.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<CuratorBloc, CuratorState>(
              builder: (context, state) {
                if (state is CuratorLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is CuratorReady) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RecommendedPhotoCard(
                        recommendation: state.recommendation,
                        onTryAgain: () => context.read<CuratorBloc>().add(
                          const CuratorCleared(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _pickAndRecommend(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Pick again'),
                      ),
                    ],
                  );
                }
                if (state is CuratorError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _pickAndRecommend(context),
                        child: const Text('Try again'),
                      ),
                    ],
                  );
                }
                // CuratorInitial
                return FilledButton.icon(
                  onPressed: () => _pickAndRecommend(context),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick photos'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
