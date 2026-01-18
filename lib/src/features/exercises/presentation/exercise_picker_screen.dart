import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/exercise.dart';
import 'providers/exercise_providers.dart';

/// Exercise picker screen for adding exercises to a workout
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(exerciseListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged() {
    ref.read(exerciseSearchQueryProvider.notifier).state = _searchController.text;
  }

  void _selectExercise(Exercise exercise) {
    context.pop(exercise);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  void _clearFilters() {
    ref.read(exerciseCategoryFilterProvider.notifier).state = null;
    ref.read(exerciseMuscleFilterProvider.notifier).state = null;
    ref.read(exerciseEquipmentFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);
    final hasFilters = ref.watch(exerciseCategoryFilterProvider) != null ||
        ref.watch(exerciseMuscleFilterProvider) != null ||
        ref.watch(exerciseEquipmentFilterProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        actions: [
          if (hasFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear'),
            ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Active filters chips
          if (hasFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ActiveFiltersRow(),
            ),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return _EmptySearchState(
                    query: _searchController.text,
                    hasFilters: hasFilters,
                    onClearFilters: _clearFilters,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index == exercises.length) {
                      final notifier = ref.read(exerciseListProvider.notifier);
                      if (notifier.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox(height: 16);
                    }

                    return _ExerciseListTile(
                      exercise: exercises[index],
                      onTap: () => _selectExercise(exercises[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(exerciseListProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create custom exercise
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create custom exercise coming soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Custom'),
      ),
    );
  }
}

/// Single exercise list tile
class _ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${exercise.primaryMuscle} • ${exercise.equipment}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (exercise.isCustom)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Custom',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Active filters row
class _ActiveFiltersRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(exerciseCategoryFilterProvider);
    final muscle = ref.watch(exerciseMuscleFilterProvider);
    final equipment = ref.watch(exerciseEquipmentFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (category != null)
            _FilterChip(
              label: category,
              onRemove: () =>
                  ref.read(exerciseCategoryFilterProvider.notifier).state = null,
            ),
          if (muscle != null)
            _FilterChip(
              label: muscle,
              onRemove: () =>
                  ref.read(exerciseMuscleFilterProvider.notifier).state = null,
            ),
          if (equipment != null)
            _FilterChip(
              label: equipment,
              onRemove: () =>
                  ref.read(exerciseEquipmentFilterProvider.notifier).state = null,
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InputChip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(exerciseCategoryFilterProvider);
    final selectedMuscle = ref.watch(exerciseMuscleFilterProvider);
    final selectedEquipment = ref.watch(exerciseEquipmentFilterProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(exerciseCategoryFilterProvider.notifier).state = null;
                      ref.read(exerciseMuscleFilterProvider.notifier).state = null;
                      ref.read(exerciseEquipmentFilterProvider.notifier).state = null;
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Filter options
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Category
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exerciseCategories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(exerciseCategoryFilterProvider.notifier).state =
                              selected ? cat : null;
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Muscle Group
                  Text(
                    'Muscle Group',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: muscleGroups.map((muscle) {
                      final isSelected = selectedMuscle == muscle;
                      return FilterChip(
                        label: Text(muscle),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(exerciseMuscleFilterProvider.notifier).state =
                              selected ? muscle : null;
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Equipment
                  Text(
                    'Equipment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: equipmentTypes.map((equip) {
                      final isSelected = selectedEquipment == equip;
                      return FilterChip(
                        label: Text(equip),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(exerciseEquipmentFilterProvider.notifier).state =
                              selected ? equip : null;
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Empty search state
class _EmptySearchState extends StatelessWidget {
  final String query;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptySearchState({
    required this.query,
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              query.isNotEmpty ? 'No exercises found' : 'No matching exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Try a different search term'
                  : 'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
