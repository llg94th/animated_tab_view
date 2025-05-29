import 'package:flutter/material.dart';
import 'animated_reorderable_stack.dart';
import 'rabbit_ear_container.dart';

class AnimatedReorderableStackDemo extends StatefulWidget {
  const AnimatedReorderableStackDemo({super.key});

  @override
  State<AnimatedReorderableStackDemo> createState() =>
      _AnimatedReorderableStackDemoState();
}

class _AnimatedReorderableStackDemoState
    extends State<AnimatedReorderableStackDemo> {
  late AnimatedReorderableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimatedReorderableController(
      length: 3,
      topIndex: 0,
      onReorder: (index) {
        setState(() {
          // Update UI when controller changes
        });
      },
    );
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
                      children: List.generate(4, (index) {
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
              'Current child moves to (0,0), others to (20,20), (40,40), (60,60).',
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
