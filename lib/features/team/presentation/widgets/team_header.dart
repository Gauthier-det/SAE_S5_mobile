// lib/features/teams/presentation/widgets/team_header.dart
import 'package:flutter/material.dart';
import '../../domain/team.dart';

/// Hero header displaying team profile with gradient background [web:232][web:236][web:239].
///
/// Shows team avatar (image or initial), name, optional dossard badge, and 
/// validation status. Uses LinearGradient for visual depth and handles network
/// image loading errors gracefully [web:238][web:241].
///
/// **Visual Elements:**
/// - Gradient background (dark green theme)
/// - Team avatar (80x80): network image with fallback to initial letter
/// - Team name: white, bold, centered
/// - Dossard badge: white badge with number (conditional)
/// - Status badge: green (validated) or orange (pending)
///
/// Example:
/// ```dart
/// TeamHeader(
///   team: Team(
///     id: 1,
///     name: 'Les Alpinistes',
///     managerId: 42,
///     image: 'https://example.com/team.jpg',
///     isValid: true,
///   ),
///   dossardNumber: 123,
/// );
/// ```
class TeamHeader extends StatelessWidget {
  final Team team;
  final int? dossardNumber;

  const TeamHeader({
    super.key,
    required this.team,
    this.dossardNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B3022),
            const Color(0xFF1B3022).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildTeamAvatar(),
          const SizedBox(height: 16),
          _buildTeamName(),
          const SizedBox(height: 8),
          if (dossardNumber != null) _buildDossardBadge(),
          const SizedBox(height: 12),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  /// Team avatar with network image and fallback [web:238][web:241].
  Widget _buildTeamAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: team.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                team.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
              ),
            )
          : _buildDefaultIcon(),
    );
  }

  /// Fallback icon showing team name's first letter [web:238].
  Widget _buildDefaultIcon() {
    return Center(
      child: Text(
        team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Team name display.
  Widget _buildTeamName() {
    return Text(
      team.name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Dossard number badge (race bib number) [web:237][web:240].
  Widget _buildDossardBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.badge, color: Color(0xFF1B3022), size: 20),
          const SizedBox(width: 8),
          Text(
            'Dossard n°$dossardNumber',
            style: const TextStyle(
              color: Color(0xFF1B3022),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Validation status badge [web:237][web:240].
  Widget _buildStatusBadge() {
    final isValid = team.isValid ?? false;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isValid ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.pending,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            isValid ? 'Équipe validée' : 'En attente de validation',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
