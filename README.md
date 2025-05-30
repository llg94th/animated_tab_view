# AnimatedReorderableStack Widget Demo

A Flutter project showcasing the **AnimatedReorderableStack** widget - an advanced animated stack widget with reorderable tabs and smooth transitions.

## 🌟 Features

### AnimatedReorderableStack
- **Smooth Animations**: Configurable duration and curve animations (300ms with easeOutCubic by default)
- **Gesture Support**: Both tap and drag interactions
- **Circular Navigation**: Next/previous navigation maintains circular order pattern
- **Visual Feedback**: Dynamic tab width, opacity, and height animations during interactions
- **Customizable Layout**: Adjustable dimensions, spacing, and visual properties

### TabContainer with Rabbit Ear Design
- **Unique Shape**: Custom rabbit ear container using `CardPainter`
- **Gradient Support**: Customizable gradient backgrounds
- **Responsive Design**: Dynamic sizing based on content and position

## 🎮 Interactions

### Gesture Controls
- **Tap Background Cards**: Brings the tapped card to front
- **Tap Top Card**: Disabled during normal operation
- **Drag Top Card**: Only the top card can be dragged
- **Swipe Left** (>30px): Navigate to next card
- **Swipe Right** (>30px): Navigate to previous card (currently disabled)

### Visual Effects
- **Dragging Layer**: Opacity changes based on drag distance (zRatio calculation)
- **Tab Width Animation**: Smooth width transitions during reordering
- **Height Spacing**: Progressive height reduction for background cards
- **Position Animation**: Smooth movement to new positions

## 🔧 Configuration

```dart
AnimatedReorderableStack(
  controller: controller,
  childHeight: 300.0,        // Height of each card
  childWidth: 600.0,         // Width of each card
  minTabWidth: 150.0,        // Minimum tab width
  tabOverlapWidth: 10.0,     // Overlap between tabs
  tabHeightSpacing: 4.0,     // Height spacing between cards
  tabHeight: 30.0,           // Height of tab headers
  clipBehavior: Clip.hardEdge,
  children: [...],
)
```

## 🎯 Demo

**Live Demo**: [https://llg94th.github.io/animated_tab_view/](https://llg94th.github.io/animated_tab_view/)

Experience the interactive animations and gesture controls in action!

## 🏗️ Architecture

### Controller Pattern
- `AnimatedReorderableController`: Manages circular ordering logic
- Indices array maintains original sequence: `[0,1,2,3] -> [2,3,0,1]` when setting index 2
- ValueNotifier pattern for reactive updates

### Animation System
- Single `AnimationController` with `CurvedAnimation`
- `ValueNotifier<Offset>` for real-time drag feedback
- Tween animations for smooth property transitions
- Previous/current state mapping for seamless animations

### Clean Architecture
- Separation of concerns between controller, UI, and animation logic
- Customizable widget properties with sensible defaults
- Efficient hit testing with custom render objects

## 🚀 Getting Started

This project demonstrates advanced Flutter animation techniques and custom widget development. Perfect for learning:

- Custom `CustomPainter` implementations
- Complex gesture handling
- Animation coordination
- State management patterns
- Responsive UI design

## 📚 Resources

- [Flutter Animation Documentation](https://docs.flutter.dev/development/ui/animations)
- [Custom Painter Guide](https://docs.flutter.dev/development/ui/advanced/custom-paint)
- [Gesture Detection](https://docs.flutter.dev/development/ui/advanced/gestures)
