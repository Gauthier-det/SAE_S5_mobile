// lib/features/raids/presentation/RaidDetailView.dart
import 'package:flutter/material.dart';
import '../domain/raid.dart';
import '../domain/raid_repository.dart';

/// StatefulWidget that displays complete details of a raid
/// 
/// Takes as parameters:
/// - raidId: the ID of the raid to display
/// - repository: the repository to fetch data (follows clean architecture pattern)
class RaidDetailView extends StatefulWidget {
  final int raidId;
  final RaidRepository repository;

  const RaidDetailView({
    Key? key,
    required this.raidId,
    required this.repository,
  }) : super(key: key);

  @override
  State<RaidDetailView> createState() => _RaidDetailViewState();
}

/// State associated with RaidDetailView
/// Manages the lifecycle and state of the widget
class _RaidDetailViewState extends State<RaidDetailView> {
  /// Future that will contain the raid fetched from the repository
  /// Allows handling async states (loading, success, error)
  late Future<Raid?> _raidFuture;

  /// Method called once when the widget is created
  /// Launches the raid fetch from the repository
  @override
  void initState() {
    super.initState();
    _raidFuture = widget.repository.getRaidById(widget.raidId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(
        title: const Text('Détails du Raid'),
      ),
      
      // FutureBuilder: widget that rebuilds automatically based on Future state
      // Handles 3 states: loading (waiting), error (error), success (data available)
      body: FutureBuilder<Raid?>(
        future: _raidFuture,
        builder: (context, snapshot) {
          // State 1: LOADING - While data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: ERROR - In case of error during fetch
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  // Button to retry loading the data
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _raidFuture = widget.repository.getRaidById(widget.raidId);
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // State 3a: SUCCESS but data is null or empty
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Raid introuvable'),
            );
          }

          // State 3b: SUCCESS with data available
          final raid = snapshot.data!;
          
          // SingleChildScrollView: makes the content scrollable if it exceeds screen height
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image of the raid (if available)
                if (raid.image != null)
                  Image.network(
                    raid.image!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    // Error builder: displays placeholder if image fails to load
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      );
                    },
                  ),

                // Main content with padding
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Raid name - styled as main title
                      Text(
                        raid.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Card 1: Event dates (start and end)
                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Dates de l\'événement',
                        children: [
                          _buildInfoRow('Début', _formatDateTime(raid.timeStart)),
                          _buildInfoRow('Fin', _formatDateTime(raid.timeEnd)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Card 2: Registration information
                      _buildInfoCard(
                        context,
                        icon: Icons.app_registration,
                        title: 'Inscriptions',
                        children: [
                          _buildInfoRow('Ouverture', _formatDateTime(raid.registrationStart)),
                          _buildInfoRow('Clôture', _formatDateTime(raid.registrationEnd)),
                          // Status with dynamic color based on current date
                          _buildInfoRow(
                            'Statut',
                            _getRegistrationStatus(raid),
                            valueColor: _getRegistrationStatusColor(raid),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Card 3: Contact information (only shows available fields)
                      _buildInfoCard(
                        context,
                        icon: Icons.contact_mail,
                        title: 'Contact',
                        children: [
                          if (raid.email != null)
                            _buildInfoRow('Email', raid.email!),
                          if (raid.phoneNumber != null)
                            _buildInfoRow('Téléphone', raid.phoneNumber!),
                          if (raid.website != null)
                            _buildInfoRow('Site web', raid.website!),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Registration button
                      // Enabled only if registrations are open
                      SizedBox(
                        width: double.infinity, // Full width button
                        child: ElevatedButton.icon(
                          onPressed: () {
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RaceListView(raidId: raid.id),
                              ),
                            );*/
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chargement des courses...')),
                            );
                          },
                          icon: const Icon(Icons.directions_run),
                          label: const Text('VOIR LES COURSES'), // ← Ici pour les races/courses
                        ),
                        
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a reusable info card with icon, title and children widgets
  /// Used to display structured information sections
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header with icon and title
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Card content (list of info rows)
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds a single info row with label on the left and value on the right
  /// Optionally accepts a custom color for the value
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label (left side, grey color)
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          // Value (right side, flexible to handle long text)
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor, // Custom color if provided
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime to French readable format
  /// Example: "13 janvier 2026 à 10h30"
  String _formatDateTime(DateTime dateTime) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} à ${dateTime.hour}h${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Returns the registration status as a string
  /// Compares current date with registration start/end dates
  String _getRegistrationStatus(Raid raid) {
    final now = DateTime.now();
    if (now.isBefore(raid.registrationStart)) {
      return 'Pas encore ouvertes'; // Not yet open
    } else if (now.isAfter(raid.registrationEnd)) {
      return 'Clôturées'; // Closed
    } else {
      return 'Ouvertes'; // Open
    }
  }

  /// Returns the appropriate color for registration status
  /// Orange: not yet open, Red: closed, Green: open
  Color _getRegistrationStatusColor(Raid raid) {
    final now = DateTime.now();
    if (now.isBefore(raid.registrationStart)) {
      return Colors.orange;
    } else if (now.isAfter(raid.registrationEnd)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  /// Checks if registration is currently open
  /// Used to enable/disable the registration button
  bool _isRegistrationOpen(Raid raid) {
    final now = DateTime.now();
    return now.isAfter(raid.registrationStart) && now.isBefore(raid.registrationEnd);
  }
}
