import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../widgets/mood_face_painter.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  MoodEntry? _animatingEntry;
  int _selectedMoodIndex = -1;

  final List<Mood> moods = [
    Mood.happy,
    Mood.excited,
    Mood.neutral,
    Mood.sad,
    Mood.tired
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animatingEntry = null);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addMood(Mood mood, int index) async {
    setState(() => _selectedMoodIndex = index);
    await ref.read(moodEntriesProvider.notifier).addMood(mood); // Changed here
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _selectedMoodIndex = -1);
    });
  }

  void _animateEntry(MoodEntry entry) {
    setState(() => _animatingEntry = entry);
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(moodEntriesProvider); // Changed here
    final recentEntries = entries.take(7).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Mood Tracker',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology,
                          size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        'How are you feeling?',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your mood',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: moods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final isSelected = _selectedMoodIndex == index;
                        return AnimatedScale(
                          scale: isSelected ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: _buildMoodCard(mood, index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (entries.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entries.length} total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (recentEntries.isEmpty)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mood_bad, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No entries yet.\nTap a mood to get started!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentEntries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final entry = recentEntries[index];
                          final isAnimating = _animatingEntry == entry;

                          return GestureDetector(
                            onTap: () => _animateEntry(entry),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                double scale = 1.0;
                                double opacity = 1.0;

                                if (isAnimating) {
                                  scale = 1.0 +
                                      Curves.elasticOut.transform(
                                              _animationController.value) *
                                          0.15;
                                  opacity =
                                      1.0 - _animationController.value * 0.2;
                                }

                                return Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: _buildTimelineCard(entry),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(Mood mood, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _addMood(mood, index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: MoodFacePainter(
                    mood: mood,
                    size: 50,
                    animated: _selectedMoodIndex == index,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mood.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mood.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(MoodEntry entry) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entry.formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: entry.mood.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 55,
              height: 55,
              child: CustomPaint(
                painter: MoodFacePainter(mood: entry.mood, size: 55),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: entry.mood.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
