import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/poster_request.dart';
import '../../widgets/search_bar_widget.dart';
import '../../theme/app_theme.dart';

/// Front Desk - Delivered Audit Screen (Tab 2)
///
/// Purpose: Quick verification of fulfilled posters
///
/// Key Features:
/// - Searchable list of all fulfilled posters
/// - Sorted alphabetically/numerically by poster number
/// - Shows poster number and fulfillment time
/// - Read-only view (no action buttons)
///
/// Status:
/// - Persistence: IMPLEMENTED - Reads from Hive database with real-time updates
/// - BLE sync: TODO - Will populate from BLE status updates from Back Office
/// - Search & filtering: IMPLEMENTED - Live filtering by poster number

class DeliveredAuditScreen extends StatefulWidget {
  /// Optional initial list for testing only
  /// In production, data is read from Hive database
  final List<PosterRequest>? fulfilledRequests;

  const DeliveredAuditScreen({
    this.fulfilledRequests,
    super.key,
  });

  @override
  State<DeliveredAuditScreen> createState() => _DeliveredAuditScreenState();
}

class _DeliveredAuditScreenState extends State<DeliveredAuditScreen> {
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

    // Sort alphabetically/numerically by poster number (A-Z)
    filtered.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'DELIVERED POSTERS',
                style: textTheme.headlineSmall,
              ),
            ),

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

            // List of fulfilled requests - real-time updates from Hive
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<PosterRequest>('delivered_audit').listenable(),
                builder: (context, Box<PosterRequest> box, _) {
                  // Get all delivered audit entries from Hive
                  final allRequests = box.values.toList();

                  // Filter and sort based on search query
                  final filteredRequests = _filterAndSortRequests(allRequests);

                  return filteredRequests.isEmpty
                      ? _buildEmptyState(textTheme, colorScheme)
                      : ListView.builder(
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _buildListItem(filteredRequests[index], textTheme, colorScheme);
                          },
                        );
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Poster number (bold, large)
            Text(
              request.posterNumber,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // Pulled time
            Text(
              'Pulled: $pulledTime',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
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
