import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/poster_request.dart';
import '../../widgets/search_bar_widget.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

/// Back Office - Fulfilled Log Screen (Tab 2)
///
/// Purpose: Complete audit trail of all fulfilled requests
///
/// Key Features:
/// - Searchable list of all fulfilled posters
/// - Sorted alphabetically/numerically by poster number
/// - Shows poster number, sent time, and pulled time
/// - Read-only view (no action buttons)
/// - Real-time updates from Hive database
///
/// TODO: Connect to BLE service for synced fulfillment data

class FulfilledLogScreen extends StatefulWidget {
  const FulfilledLogScreen({super.key});

  @override
  State<FulfilledLogScreen> createState() => _FulfilledLogScreenState();
}

class _FulfilledLogScreenState extends State<FulfilledLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<PosterRequest> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    _loadAndFilterRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load all fulfilled requests from persistent storage and apply filter
  void _loadAndFilterRequests() {
    // Load all fulfilled requests from Hive
    final allRequests = persistenceService.getAllFulfilledRequests();

    // Apply search filter
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredRequests = List.from(allRequests);
      } else {
        _filteredRequests = allRequests
            .where((request) =>
                request.posterNumber.toUpperCase().contains(_searchQuery.toUpperCase()))
            .toList();
      }

      // Sort alphabetically/numerically by poster number
      _filteredRequests.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _loadAndFilterRequests();
  }

  /// Show confirmation dialog before clearing all fulfilled requests
  void _showClearAllConfirmation() {
    final count = persistenceService.getFulfilledCount();

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
                await _clearAllFulfilledRequests();
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

  /// Clear all fulfilled requests from persistent storage
  Future<void> _clearAllFulfilledRequests() async {
    try {
      await persistenceService.clearAllFulfilledRequests();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All fulfilled requests cleared successfully'),
          backgroundColor: Theme.of(context).colorScheme.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reload data (will show empty state)
      _loadAndFilterRequests();
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing requests: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Use ValueListenableBuilder to automatically rebuild when Hive data changes
    return ValueListenableBuilder(
      valueListenable: Hive.box<PosterRequest>('fulfilled_requests').listenable(),
      builder: (context, Box<PosterRequest> box, _) {
        // Reload data whenever box changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadAndFilterRequests();
        });

        return _buildScaffold(colorScheme, textTheme);
      },
    );
  }

  Widget _buildScaffold(ColorScheme colorScheme, TextTheme textTheme) {
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
                _showClearAllConfirmation();
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
              child: _filteredRequests.isEmpty
                  ? _buildEmptyState(textTheme, colorScheme)
                  : ListView.builder(
                      itemCount: _filteredRequests.length,
                      itemBuilder: (context, index) {
                        return _buildListItem(_filteredRequests[index], textTheme, colorScheme);
                      },
                    ),
            ),
          ],
        ),
      ),
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
