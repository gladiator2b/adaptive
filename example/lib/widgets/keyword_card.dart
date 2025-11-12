import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/keyword.dart';

class KeywordCard extends StatelessWidget {
  final Keyword keyword;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const KeywordCard({
    Key? key,
    required this.keyword,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Couleur selon la difficulté
    Color getDifficultyColor() {
      switch (keyword.difficulty.toLowerCase()) {
        case 'easy':
        case 'facile':
          return Colors.green;
        case 'medium':
        case 'moyen':
          return Colors.orange;
        case 'hard':
        case 'difficile':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // Icône et couleur selon le trend
    IconData getTrendIcon() {
      switch (keyword.trend) {
        case 'up':
          return Icons.trending_up;
        case 'down':
          return Icons.trending_down;
        default:
          return Icons.trending_flat;
      }
    }

    Color getTrendColor() {
      switch (keyword.trend) {
        case 'up':
          return Colors.green;
        case 'down':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec mot clé et bouton supprimer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      keyword.keyword,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Statistiques principales
              Row(
                children: [
                  // Position actuelle
                  Expanded(
                    child: _StatCard(
                      label: 'Position',
                      value: '#${keyword.currentPosition}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Variation
                  Expanded(
                    child: _StatCard(
                      label: 'Variation',
                      value: keyword.positionDifference != 0
                          ? '${keyword.positionDifference > 0 ? '+' : ''}${keyword.positionDifference}'
                          : '=',
                      color: getTrendColor(),
                      icon: getTrendIcon(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Volume de recherche
                  Expanded(
                    child: _StatCard(
                      label: 'Volume',
                      value: keyword.searchVolume.toString(),
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bas de carte
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Difficulté
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getDifficultyColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: getDifficultyColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      keyword.difficulty,
                      style: TextStyle(
                        color: getDifficultyColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Date de mise à jour
                  Text(
                    'MAJ: ${dateFormat.format(keyword.lastUpdated)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
