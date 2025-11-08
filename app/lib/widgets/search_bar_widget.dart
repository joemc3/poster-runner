import 'package:flutter/material.dart';

/// Search Bar Widget
/// Provides a search input field for filtering poster requests
///
/// Design specs from project-theme.md:
/// - Height: 56dp
/// - Padding: 16dp horizontal, 16dp vertical
/// - Corner Radius: 8dp
/// - Border: 2dp solid (Neutral default, Primary when focused)
/// - Typography: bodyLarge (16sp), Regular (400)

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    this.hintText = 'Search by Poster #',
    this.onChanged,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 24),
          // Use theme's input decoration
        ),
      ),
    );
  }
}
