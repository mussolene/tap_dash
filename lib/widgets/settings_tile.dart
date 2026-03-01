import 'package:flutter/material.dart';

/// A settings row with a switch for boolean values.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// A settings row for selecting one of several options (e.g. theme mode).
class SettingsTileSelector<T> extends StatelessWidget {
  const SettingsTileSelector({
    required this.title,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.icon,
    super.key,
  });

  final String title;
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: Text(labelBuilder(value)),
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<T>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...options.map(
              (opt) => ListTile(
                title: Text(labelBuilder(opt)),
                leading: value == opt
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  onChanged(opt);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
