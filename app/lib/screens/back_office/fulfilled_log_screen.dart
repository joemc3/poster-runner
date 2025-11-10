import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/poster_request.dart';
import '../../widgets/search_bar_widget.dart';
import '../../theme/app_theme.dart';
import '../../providers/back_office_provider.dart';
import '../../providers/theme_provider.dart';

/// Back Office - Fulfilled Log Screen (Tab 2)
///
/// Purpose: Complete audit trail of all fulfilled requests
///
/// Key Features:
/// - Searchable list of all fulfilled posters
/// - Sorted alphabetically/numerically by poster number
/// - Shows poster number, sent time, and pulled time
/// - Read-only view (no action buttons)
/// - Real-time updates from provider
///
/// Phase 3 Status: IMPLEMENTED - Uses BackOfficeProvider for state management
/// Phase 4 TODO: Connect to BLE service for synced fulfillment data

class FulfilledLogScreen extends StatefulWidget {
  const FulfilledLogScreen({super.key});

  @override
  State<FulfilledLogScreen> createState() => _FulfilledLogScreenState();
}

class _FulfilledLogScreenState extends State<FulfilledLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter and sort requests based on search query
  List<PosterRequest> _filterAndSortRequests(List<PosterRequest> allRequests) {
    List<PosterRequest> filtered;

    if (_searchQuery.isEmpty) {
      filtered = List.from(allRequests);
    } else {
      filtered = allRequests
          .where((request) =>
              request.posterNumber.toUpperCase().contains(_searchQuery.toUpperCase()))
          .toList();
    }

    // Sort alphabetically/numerically by poster number
    filtered.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Show confirmation dialog before clearing all fulfilled requests
  void _showClearAllConfirmation(BackOfficeProvider provider) {
    final count = provider.getFulfilledCount();

    if (count == 0) {
      // No requests to clear
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fulfilled requests to clear'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Fulfilled Requests?'),
          content: Text(
            'This will permanently delete all $count fulfilled poster request(s) from the log.\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _clearAllFulfilledRequests(provider);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  /// Clear all fulfilled requests using provider
  Future<void> _clearAllFulfilledRequests(BackOfficeProvider provider) async {
    final success = await provider.clearAllFulfilledRequests();

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All fulfilled requests cleared successfully'),
          backgroundColor: Theme.of(context).colorScheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error clearing requests'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show theme selection dialog
  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.light,
                Icons.light_mode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.dark,
                Icons.dark_mode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.system,
                Icons.settings_suggest,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Build individual theme option radio button
  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
  ) {
    final isSelected = themeProvider.isThemeModeActive(mode);
    final displayName = themeProvider.getThemeDisplayName(mode);

    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(displayName),
        ],
      ),
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          themeProvider.setThemeMode(value);
          Navigator.of(context).pop();
        }
      },
      selected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer2<BackOfficeProvider, ThemeProvider>(
      builder: (context, backOfficeProvider, themeProvider, child) {
        // Get all fulfilled requests from provider
        final allRequests = backOfficeProvider.getFulfilledRequests();

        // Filter and sort based on search query
        final filteredRequests = _filterAndSortRequests(allRequests);

        return Scaffold(
          backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Text(
              'FULFILLED LOG',
              style: textTheme.headlineSmall,
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllConfirmation(backOfficeProvider);
                  } else if (value == 'theme') {
                    _showThemeDialog(themeProvider);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 20),
                        SizedBox(width: 8),
                        Text('Clear All Fulfilled'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(Icons.palette, size: 20),
                        SizedBox(width: 8),
                        Text('Theme'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                SearchBarWidget(
                  hintText: 'Search by Poster #',
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),

                // Sort indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '--- Sorted A-Z ---',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.neutral,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // List of fulfilled requests
                Expanded(
                  child: filteredRequests.isEmpty
                      ? _buildEmptyState(textTheme, colorScheme)
                      : ListView.builder(
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _buildListItem(
                                filteredRequests[index], textTheme, colorScheme);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build individual list item
  Widget _buildListItem(PosterRequest request, TextTheme textTheme, ColorScheme colorScheme) {
    final timeFormat = DateFormat('h:mm a');
    final sentTime = timeFormat.format(request.timestampSent);
    final pulledTime = request.timestampPulled != null
        ? timeFormat.format(request.timestampPulled!)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.fulfilledTint,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.divider,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            // Poster number (bold, large)
            Expanded(
              flex: 2,
              child: Text(
                request.posterNumber,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Sent time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sent:',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
                    ),
                  ),
                  Text(
                    sentTime,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
                    ),
                  ),
                ],
              ),
            ),
            // Pulled time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pulled:',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
                    ),
                  ),
                  Text(
                    pulledTime,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no results
  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.neutral.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No fulfilled posters yet'
                  : 'No results found for "$_searchQuery"',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.neutral,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
