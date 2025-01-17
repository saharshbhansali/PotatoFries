import 'package:flutter/material.dart';
import 'package:potato_fries/backend/extensions.dart';
import 'package:potato_fries/ui/components/separated_flex.dart';
import 'package:potato_fries/ui/components/switch.dart';

class PreferenceTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  const PreferenceTile({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 200),
      curve: decelerateEasing,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 14,
              right: 14,
              bottom: 14,
            ),
            child: SeparatedFlex(
              axis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    size: 24,
                    opacity: 1,
                  ),
                  child: leading != null
                      ? leading!
                      : const SizedBox(width: 24, height: 24),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: context.theme.textTheme.bodyLarge!.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                        child: title,
                      ),
                      if (subtitle != null)
                        DefaultTextStyle(
                          style: context.theme.textTheme.bodySmall!.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                          child: subtitle!,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
              separator: const SizedBox(width: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class SwitchPreferenceTile extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onValueChanged;
  final VoidCallback? onLongPress;
  final bool enabled;

  const SwitchPreferenceTile({
    Key? key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onValueChanged,
    this.onLongPress,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      leading: icon,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: FriesSwitch(
        value: value,
        onChanged: onValueChanged,
      ),
      onTap: () => onValueChanged?.call(!value),
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }
}

class SliderPreferenceTile<T extends num> extends StatelessWidget {
  final Widget? icon;
  final String title;
  final T value;
  final T min;
  final T max;
  final ValueChanged<T>? onValueChanged;
  final ValueChanged<T>? onValueChangeEnd;
  final VoidCallback? onLongPress;
  final bool enabled;

  const SliderPreferenceTile({
    Key? key,
    this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onValueChanged,
    this.onValueChangeEnd,
    this.onLongPress,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isInt = value is int;

    return PreferenceTile(
      leading: icon,
      title: Text(title),
      subtitle: Slider(
        value: value.toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: isInt ? (max - min).toInt() : null,
        onChanged: onValueChanged != null
            ? (value) => onValueChanged?.call(
                  isInt ? value.toInt() as T : value.toDouble() as T,
                )
            : null,
        onChangeEnd: onValueChangeEnd != null
            ? (value) => onValueChangeEnd?.call(
                  isInt ? value.toInt() as T : value.toDouble() as T,
                )
            : null,
      ),
      trailing: ShortChip(
        child: Text(isInt ? value.toString() : value.toStringAsFixed(2)),
      ),
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }
}

class DropdownPreferenceTile<T> extends StatelessWidget {
  final Widget? icon;
  final String title;
  final Map<T, String> options;
  final T selectedOption;
  final ValueChanged<T>? onValueChanged;
  final VoidCallback? onLongPress;
  final bool enabled;

  const DropdownPreferenceTile({
    Key? key,
    this.icon,
    required this.title,
    required this.options,
    required this.selectedOption,
    this.onValueChanged,
    this.onLongPress,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(options[selectedOption]!),
      trailing: const ShortChip(child: Icon(Icons.expand_more)),
      onTap: () async {
        final T? newOption = await context.showBottomSheet<T>(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((e) {
              final bool selected = selectedOption == e.key;

              return ListTile(
                title: Text(
                  e.value,
                  style: context.theme.textTheme.bodyLarge!.copyWith(
                    color: selected
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(context, e.key),
                trailing:
                    selected ? const ShortChip(child: Icon(Icons.check)) : null,
              );
            }).toList(),
          ),
        );

        if (newOption != null) {
          onValueChanged?.call(newOption);
        }
      },
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }
}

class ShortChip extends StatelessWidget {
  final Widget child;

  const ShortChip({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 24,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: context.theme.colorScheme.secondaryContainer,
      ),
      alignment: Alignment.center,
      child: IconTheme.merge(
        data: IconThemeData(
          color: context.theme.colorScheme.onSecondaryContainer,
          size: 20,
        ),
        child: DefaultTextStyle(
          style: context.theme.textTheme.labelMedium!.copyWith(
            color: context.theme.colorScheme.onSecondaryContainer,
          ),
          child: child,
        ),
      ),
    );
  }
}
