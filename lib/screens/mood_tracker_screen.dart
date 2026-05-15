import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../widgets/mood_button.dart';
import '../widgets/mood_timeline_card.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  MoodEntry? _animatingEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingEntry = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addMood(Mood mood) {
    ref.read(moodProvider.notifier).addMood(mood);
  }

  void _animateEntry(MoodEntry entry) {
    setState(() {
      _animatingEntry = entry;
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(moodProvider);
    final recentEntries = entries.reversed.take(7).toList().reversed.toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Title
              const Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              // Mood selection buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoodButton(
                    mood: Mood.happy,
                    onTap: () => _addMood(Mood.happy),
                  ),
                  const SizedBox(width: 20),
                  MoodButton(
                    mood: Mood.neutral,
                    onTap: () => _addMood(Mood.neutral),
                  ),
                  const SizedBox(width: 20),
                  MoodButton(
                    mood: Mood.sad,
                    onTap: () => _addMood(Mood.sad),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Timeline header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      'Past 7 days',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal scrollable timeline
              SizedBox(
                height: 160,
                child: recentEntries.isEmpty
                    ? Center(
                        child: Text(
                          'No entries yet.\nTap a mood to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                if (isAnimating) {
                                  scale = 1.0 +
                                      Tween(begin: 0.0, end: 0.15)
                                          .animate(CurvedAnimation(
                                            parent: _animationController,
                                            curve: Curves.elasticOut,
                                          ))
                                          .value;
                                }
                                return Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: isAnimating
                                        ? 1.0 - _animationController.value * 0.3
                                        : 1.0,
                                    child: MoodTimelineCard(entry: entry),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              const Spacer(),
              // Footer note
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Tap any past entry to see it animate',
                  style: TextStyle(
                    color: Colors.deepPurple.shade300,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
