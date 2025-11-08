import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/poster_request.dart';
import '../../models/mock_data.dart';
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
/// TODO: Connect to BLE service for synced fulfillment data
/// TODO: Implement data persistence and filtering

class DeliveredAuditScreen extends StatefulWidget {
  /// List of fulfilled requests
  /// TODO: Replace with actual data from BLE sync/local storage
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

  // TODO: Replace with actual data from state management/BLE service
  late List<PosterRequest> _allRequests;
  late List<PosterRequest> _filteredRequests;

  @override
  void initState() {
    super.initState();
    _initializePlaceholderData();
    _filterRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize with placeholder data from MockPosterRequests
  /// TODO: Remove when connected to actual data source
  void _initializePlaceholderData() {
    // Use centralized mock data (already sorted by posterNumber A-Z)
    _allRequests = widget.fulfilledRequests ?? MockPosterRequests.deliveredAudit;
  }

  /// Filter requests based on search query
  void _filterRequests() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredRequests = List.from(_allRequests);
      } else {
        _filteredRequests = _allRequests
            .where((request) =>
                request.posterNumber.toUpperCase().contains(_searchQuery.toUpperCase()))
            .toList();
      }

      // Sort alphabetically/numerically by poster number
      _filteredRequests.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterRequests();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '✅ DELIVERED POSTERS',
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
    final pulledTime = request.timestampPulled != null
        ? timeFormat.format(request.timestampPulled!)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.fulfilledTint,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey[300]!,
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
                color: colorScheme.neutral,
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
