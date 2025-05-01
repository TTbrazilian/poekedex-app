import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/theme/theme_manager.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Switch(
      value: themeManager.isDark,
      onChanged: (value) {
        themeManager.toggleTheme(value);
      },
      activeColor: Colors.grey,
      inactiveThumbColor: Colors.white,
    );
  }
}
