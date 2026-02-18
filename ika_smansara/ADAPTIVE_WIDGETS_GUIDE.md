# Adaptive Widgets Quick Reference

## Quick Import
```dart
import '../../../../core/widgets/widgets.dart'; // Exports all adaptive widgets
// OR specific imports
import '../../../../core/widgets/adaptive/adaptive_container.dart';
import '../../../../core/widgets/adaptive/adaptive_spacing.dart';
import '../../../../core/widgets/adaptive/adaptive_padding.dart';
```

---

## AdaptiveContainer

### Usage Examples

#### For Forms (Login, Register)
```dart
AdaptiveContainer(
  widthType: AdaptiveWidthType.form, // Max 600px
  child: Form(
    child: Column(
      children: [
        AppTextField(...),
        AdaptiveSpacingV(multiplier: 3.0),
        AppPasswordField(...),
      ],
    ),
  ),
)
```

#### For Content Pages (News, Articles, Details)
```dart
AdaptiveContainer(
  widthType: AdaptiveWidthType.content, // Max 1200px
  child: Column(
    children: [
      TitleWidget(),
      BodyWidget(),
    ],
  ),
)
```

#### For Cards (E-KTA, Profile Cards)
```dart
AdaptiveContainer(
  widthType: AdaptiveWidthType.card, // Max 400px
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: MyCardContent(),
    ),
  ),
)
```

---

## AdaptiveSpacing

### Vertical Spacing (Most Common)
```dart
// Small spacing (was SizedBox(height: 8))
const AdaptiveSpacingV(multiplier: 1.5) // 6px/9px/12px

// Medium spacing (was SizedBox(height: 16))
const AdaptiveSpacingV(multiplier: 3.0) // 12px/18px/24px

// Large spacing (was SizedBox(height: 24))
const AdaptiveSpacingV(multiplier: 4.5) // 18px/27px/36px

// Extra large spacing (was SizedBox(height: 32))
const AdaptiveSpacingV(multiplier: 6.0) // 24px/36px/48px
```

### Horizontal Spacing
```dart
const AdaptiveSpacingH(multiplier: 2.0) // 8px/12px/16px
```

### Custom Spacing
```dart
AdaptiveSpacing(
  multiplier: 1.5,
  axis: Axis.vertical,
)
```

---

## AdaptivePadding

### All Sides
```dart
AdaptivePaddingAll(
  multiplier: 1.0, // Default 16px/24px/32px
  child: MyWidget(),
)

// Half padding
AdaptivePaddingAll(
  multiplier: 0.5, // 8px/12px/16px
  child: MyWidget(),
)
```

### Symmetric (Horizontal/Vertical)
```dart
// Horizontal only (left + right)
AdaptivePaddingSymmetric(
  horizontal: true,
  child: MyWidget(),
)

// Vertical only (top + bottom)
AdaptivePaddingSymmetric(
  vertical: true,
  child: MyWidget(),
)

// Both
AdaptivePaddingSymmetric(
  horizontal: true,
  vertical: true,
  child: MyWidget(),
)
```

### Advanced
```dart
AdaptivePadding(
  all: false,
  horizontal: true,
  vertical: false,
  top: true,
  multiplier: 1.0,
  child: MyWidget(),
)
```

---

## AdaptiveBreakpoints Helpers

### Check Screen Size
```dart
import '../../../../core/utils/adaptive/adaptive_breakpoints.dart';

// Check if compact mobile
if (AdaptiveBreakpoints.isCompact(context)) {
  return MobileLayout();
}

// Check if tablet
if (AdaptiveBreakpoints.isMedium(context)) {
  return TabletLayout();
}

// Check if desktop
if (AdaptiveBreakpoints.isExpanded(context)) {
  return DesktopLayout();
}

// Get adaptive padding
final padding = AdaptiveBreakpoints.adaptivePadding(context);
// Returns: EdgeInsets.all(16) or EdgeInsets.all(24) or EdgeInsets.all(32)

// Get adaptive spacing value
final spacing = AdaptiveBreakpoints.adaptiveSpacing(context);
// Returns: 16 or 24 or 32
```

---

## Common Patterns

### Pattern 1: Responsive Form
```dart
class MyFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form')),
      body: AdaptiveContainer(
        widthType: AdaptiveWidthType.form,
        child: AdaptivePaddingAll(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                children: [
                  TextFormField(...),
                  const AdaptiveSpacingV(multiplier: 3.0),
                  TextFormField(...),
                  const AdaptiveSpacingV(multiplier: 4.5),
                  ElevatedButton(...),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Pattern 2: Responsive Content Page
```dart
class ContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Content')),
      body: AdaptiveContainer(
        widthType: AdaptiveWidthType.content,
        child: SingleChildScrollView(
          padding: AdaptiveBreakpoints.adaptivePadding(context),
          child: Column(
            children: [
              HeaderWidget(),
              const AdaptiveSpacingV(multiplier: 4.0),
              ContentWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Pattern 3: Responsive List
```dart
class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List')),
      body: AdaptiveContainer(
        widthType: AdaptiveWidthType.content,
        child: ListView.builder(
          padding: AdaptiveBreakpoints.adaptivePadding(context),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(items[index].title),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## Spacing Multipliers Reference

| Multiplier | Mobile (4px base) | Tablet (6px base) | Desktop (8px base) | Use Case |
|------------|-------------------|-------------------|---------------------|----------|
| 0.5 | 2px | 3px | 4px | Tiny gaps |
| 1.0 | 4px | 6px | 8px | Minimal spacing |
| 1.5 | 6px | 9px | 12px | Small spacing |
| 2.0 | 8px | 12px | 16px | Standard spacing |
| 3.0 | 12px | 18px | 24px | Medium spacing |
| 4.0 | 16px | 24px | 32px | Large spacing |
| 4.5 | 18px | 27px | 36px | Form field spacing |
| 6.0 | 24px | 36px | 48px | Section spacing |
| 8.0 | 32px | 48px | 64px | Major sections |

---

## Width Constraints Reference

| WidthType | Max Width | Use Case |
|-----------|-----------|----------|
| `content` | 1200px | Articles, news, detail pages, long-form content |
| `form` | 600px | Login, register, settings, input forms |
| `card` | 400px | E-KTA, profile cards, small widgets |

---

## Migration Guide

### Before (Non-Responsive)
```dart
Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: 16),
      TextFormField(),
      SizedBox(height: 16),
      TextFormField(),
      SizedBox(height: 24),
      ElevatedButton(...),
    ],
  ),
)
```

### After (Responsive)
```dart
AdaptiveContainer(
  widthType: AdaptiveWidthType.form,
  child: AdaptivePaddingAll(
    child: Column(
      children: [
        Text('Title'),
        const AdaptiveSpacingV(multiplier: 3.0),
        TextFormField(),
        const AdaptiveSpacingV(multiplier: 3.0),
        TextFormField(),
        const AdaptiveSpacingV(multiplier: 4.5),
        ElevatedButton(...),
      ],
    ),
  ),
)
```

---

## Testing

To test responsive layouts:

1. **Run in Chrome/Edge** for desktop testing
   ```bash
   flutter run -d chrome
   ```

2. **Use DevTools** to simulate different screen sizes
   - Open DevTools
   - Click device icon in toolbar
   - Select device preset or custom dimensions

3. **Test breakpoints**:
   - Mobile: 375x667 (iPhone SE)
   - Tablet: 768x1024 (iPad)
   - Desktop: 1440x900 (MacBook)

---

## Tips & Best Practices

1. **Always wrap forms** in `AdaptiveContainer(form)`
2. **Use AdaptiveSpacing** instead of hardcoded `SizedBox`
3. **Use AdaptivePadding** for page-level padding
4. **For content pages**, use `AdaptiveContainer(content)`
5. **For cards**, use `AdaptiveContainer(card)`
6. **Import from widgets.dart** for convenience
7. **Use multipliers** consistently (3.0 for fields, 4.5 for buttons)

---

## See Also

- `lib/core/constants/app_breakpoints.dart` - Breakpoint constants
- `lib/core/constants/app_sizes.dart` - Additional size utilities
- `lib/features/home/presentation/pages/home_page.dart` - Full adaptive layout example
