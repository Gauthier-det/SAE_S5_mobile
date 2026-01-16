import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/club_provider.dart';
import '../../domain/club.dart';
import 'create_club_screen.dart';

/// Club list display screen.
///
/// A stateless widget that displays a scrollable list of all registered clubs
/// in the application with full CRUD capabilities (Create, Read, Update, Delete).
/// Uses [Provider] with [Consumer] pattern for reactive state management [web:138][web:140].
///
/// ## Features
///
/// - **Reactive List Display**: Uses [ListView.builder] for efficient rendering of club cards [web:133][web:137]
/// - **Loading State**: Shows a loading indicator while fetching data from the API
/// - **Empty State**: Displays user-friendly message when no clubs exist [web:5][web:141]
/// - **CRUD Operations**:
///   - **Create**: Floating action button navigates to club creation screen
///   - **Read**: Displays club cards with name, responsible person, and creation date
///   - **Update**: Edit option in popup menu for each club
///   - **Delete**: Delete option with confirmation dialog
/// - **State Management**: Uses [Consumer] to listen to [ClubProvider] changes [web:138][web:140]
///
/// ## State Management Pattern
///
/// This screen uses the [Consumer] widget to rebuild the UI when club data changes
/// in [ClubProvider] [web:138][web:140]. The [Consumer] pattern provides:
/// - Automatic UI updates when provider data changes [web:140]
/// - Scoped rebuilds only for the consuming widget tree [web:138]
/// - Clean separation between UI and business logic [web:140]
///
/// ## Performance Considerations
///
/// Uses [ListView.builder] constructor for efficient list rendering, which only
/// builds visible items on screen rather than building all items at once [web:133][web:135][web:137].
/// This provides optimal performance for lists of any size.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ClubListScreen(),
///   ),
/// );
/// ```
class ClubListScreen extends StatelessWidget {
  const ClubListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs'),
        backgroundColor: const Color(0xFF1B3D2F),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ClubProvider>(
        /// Uses [Consumer] to rebuild when club data changes [web:138][web:140].
        ///
        /// The [builder] callback receives:
        /// - [context]: BuildContext for this subtree
        /// - [clubProvider]: The [ClubProvider] instance with current state
        /// - [_]: Optional child widget (unused here)
        builder: (context, clubProvider, _) {
          // Loading state: Show centered loading indicator
          if (clubProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state: Show informative message when no clubs exist [web:5][web:141]
          if (clubProvider.clubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun club',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre premier club',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // List state: Display clubs using efficient builder pattern [web:133][web:137]
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubProvider.clubs.length,
            /// [itemBuilder] is called only for visible items [web:133][web:135][web:137].
            /// This provides optimal performance by building widgets on-demand
            /// as the user scrolls through the list.
            itemBuilder: (context, index) {
              final club = clubProvider.clubs[index];
              return _ClubCard(club: club);
            },
          );
        },
      ),
      // Floating action button for creating new clubs
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateClubScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Créer un club',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Private widget for displaying a single club card.
///
/// A card-based UI component that presents club information in a structured
/// format with interactive elements for editing and deleting. This widget is
/// marked private (prefix `_`) as it's only used within [ClubListScreen].
///
/// ## Display Information
///
/// - Club name (primary text)
/// - Responsible person's name
/// - Creation date in DD/MM/YYYY format
/// - Club icon avatar
///
/// ## Interactive Elements
///
/// - **Popup Menu**: Three-dot menu providing Edit and Delete options
/// - **Edit Action**: Navigates to [CreateClubScreen] with club data for editing
/// - **Delete Action**: Shows confirmation dialog before deletion
///
/// This widget encapsulates the display logic for a single club, keeping
/// the main [ClubListScreen] clean and maintainable.
class _ClubCard extends StatelessWidget {
  /// The club entity to display.
  ///
  /// Contains all club information including name, responsible person,
  /// creation date, and other metadata.
  final Club club;

  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // Club icon avatar
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B3D2F),
          radius: 28,
          child: const Icon(
            Icons.groups,
            color: Colors.white,
            size: 28,
          ),
        ),
        // Club name (primary information)
        title: Text(
          club.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        // Club details (responsible person and creation date)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Responsible person information
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Responsable: ${club.responsibleName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Creation date information
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Créé le ${_formatDate(club.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Action menu (Edit/Delete)
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              // Navigate to edit screen with existing club data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateClubScreen(club: club),
                ),
              );
            } else if (value == 'delete') {
              // Show confirmation dialog before deletion
              _showDeleteDialog(context, club);
            }
          },
          itemBuilder: (context) => [
            // Edit option
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            // Delete option (styled in red to indicate destructive action)
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a DateTime object into DD/MM/YYYY string format.
  ///
  /// Utility method for displaying dates in a user-friendly format.
  /// Pads single-digit days and months with leading zeros for consistency.
  ///
  /// **Parameters:**
  /// - [date]: The DateTime to format
  ///
  /// **Returns:** A string in DD/MM/YYYY format (e.g., "15/03/2024")
  ///
  /// **Example:**
  /// ```dart
  /// final date = DateTime(2024, 3, 5);
  /// print(_formatDate(date)); // "05/03/2024"
  /// ```
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Displays a confirmation dialog before deleting a club.
  ///
  /// Shows an [AlertDialog] asking the user to confirm the deletion action.
  /// This prevents accidental deletions by requiring explicit user confirmation.
  /// Upon confirmation, calls [ClubProvider.deleteClub] and shows a success
  /// message via [SnackBar] [web:138].
  ///
  /// **Parameters:**
  /// - [context]: BuildContext for showing dialog and accessing Provider
  /// - [club]: The club to be deleted
  ///
  /// **User Flow:**
  /// 1. User taps "Delete" in popup menu
  /// 2. Confirmation dialog appears with club name
  /// 3. User can cancel or confirm deletion
  /// 4. On confirmation: Club is deleted and success message appears
  ///
  /// **Example:**
  /// ```dart
  /// _showDeleteDialog(context, selectedClub);
  /// ```
  void _showDeleteDialog(BuildContext context, Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le club'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${club.name}" ?'),
        actions: [
          // Cancel button - dismisses dialog without action
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          // Confirm button - proceeds with deletion
          TextButton(
            onPressed: () {
              // Delete club using Provider (listen: false for non-rebuilding action) [web:138]
              context.read<ClubProvider>().deleteClub(club.id);
              Navigator.pop(context);
              // Show success feedback to user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Club supprimé'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
