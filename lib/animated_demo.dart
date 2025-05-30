import 'package:flutter/material.dart';
import 'animated_reorderable_stack.dart';

class AnimatedReorderableStackDemo extends StatefulWidget {
  const AnimatedReorderableStackDemo({super.key});

  @override
  State<AnimatedReorderableStackDemo> createState() =>
      _AnimatedReorderableStackDemoState();
}

class _AnimatedReorderableStackDemoState
    extends State<AnimatedReorderableStackDemo> {
  late AnimatedReorderableController _controller;
  Duration _animationDuration = const Duration(milliseconds: 300);
  Curve _animationCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _controller = AnimatedReorderableController(
      length: 3,
      topIndex: 0,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
      onReorder: (index) {
        setState(() {
          // Update UI when controller changes
        });
      },
    );
  }
  
  void _updateAnimationSettings() {
    _controller.dispose();
    _controller = AnimatedReorderableController(
      length: 3,
      topIndex: _controller.topIndex,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
      onReorder: (index) {
        setState(() {
          // Update UI when controller changes
        });
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated ReorderableStack Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Current Index: ${_controller.topIndex}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        return ElevatedButton(
                          onPressed: () {
                            _controller.setTopIndex(index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _controller.topIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            foregroundColor: _controller.topIndex == index
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                          child: Text('Index $index'),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Animation settings
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Animation Settings',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Duration: '),
                              Expanded(
                                child: Slider(
                                  value: _animationDuration.inMilliseconds.toDouble(),
                                  min: 100,
                                  max: 1000,
                                  divisions: 18,
                                  label: '${_animationDuration.inMilliseconds}ms',
                                  onChanged: (value) {
                                    setState(() {
                                      _animationDuration = Duration(milliseconds: value.round());
                                    });
                                    _updateAnimationSettings();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Curve: '),
                              Expanded(
                                child: DropdownButton<Curve>(
                                  value: _animationCurve,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: Curves.linear,
                                      child: Text('Linear'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.easeIn,
                                      child: Text('Ease In'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.easeOut,
                                      child: Text('Ease Out'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.easeInOut,
                                      child: Text('Ease In Out'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.easeOutCubic,
                                      child: Text('Ease Out Cubic'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.bounceOut,
                                      child: Text('Bounce Out'),
                                    ),
                                    DropdownMenuItem(
                                      value: Curves.elasticOut,
                                      child: Text('Elastic Out'),
                                    ),
                                  ],
                                  onChanged: (curve) {
                                    if (curve != null) {
                                      setState(() {
                                        _animationCurve = curve;
                                      });
                                      _updateAnimationSettings();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // AnimatedReorderableStack demo
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedReorderableStack(
                controller: _controller,
                children: const [
                  // Child 0 - Red rabbit container
                  Center(
                    child: Text(
                      'Child 0\n🐰',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Child 1 - Blue rabbit container
                  Center(
                    child: Text('Child 1\n🐰', textAlign: TextAlign.center),
                  ),

                  // Child 2 - Green rabbit container
                  Center(
                    child: Text('Child 2\n🐰'),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Tap buttons to change current index or DRAG children to reorder!\n'
              '• Drag any child to make it the top child\n'
              '• Swipe the top child to cycle to the next one\n'
              '• Tab widths animate smoothly with configurable duration and curves\n'
              '• Adjust animation settings above to see different effects',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
