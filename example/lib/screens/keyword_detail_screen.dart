import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/keyword.dart';
import '../models/keyword_tracking.dart';
import '../services/storage_service.dart';
import '../widgets/position_chart.dart';

class KeywordDetailScreen extends StatefulWidget {
  final Keyword keyword;

  const KeywordDetailScreen({
    Key? key,
    required this.keyword,
  }) : super(key: key);

  @override
  State<KeywordDetailScreen> createState() => _KeywordDetailScreenState();
}

class _KeywordDetailScreenState extends State<KeywordDetailScreen> {
  final StorageService _storageService = StorageService();
  List<KeywordTracking> _trackings = [];
  late Keyword _currentKeyword;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentKeyword = widget.keyword;
    _loadTrackings();
  }

  Future<void> _loadTrackings() async {
    setState(() => _isLoading = true);
    final trackings = await _storageService.loadTrackingsForKeyword(widget.keyword.id);
    setState(() {
      _trackings = trackings;
      _isLoading = false;
    });
  }

  Future<void> _updatePosition() async {
    final controller = TextEditingController();

    final newPosition = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour la position'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Position actuelle: #${_currentKeyword.currentPosition}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nouvelle position',
                hintText: 'Ex: 25',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final position = int.tryParse(controller.text);
              if (position != null && position > 0) {
                Navigator.pop(context, position);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (newPosition != null) {
      final updatedKeyword = _currentKeyword.copyWith(
        currentPosition: newPosition,
        lastUpdated: DateTime.now(),
      );

      await _storageService.updateKeyword(updatedKeyword);

      setState(() => _currentKeyword = updatedKeyword);
      _loadTrackings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentKeyword.keyword),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updatePosition,
            tooltip: 'Mettre à jour la position',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildStats(),
                  const Divider(height: 32),
                  if (_trackings.isNotEmpty) ...[
                    PositionChart(trackings: _trackings),
                    const Divider(height: 32),
                    _buildHistory(),
                  ] else
                    _buildEmptyHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentKeyword.keyword,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDifficultyBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour: ${dateFormat.format(_currentKeyword.lastUpdated)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    switch (_currentKeyword.difficulty.toLowerCase()) {
      case 'easy':
      case 'facile':
        color = Colors.green;
        break;
      case 'medium':
      case 'moyen':
        color = Colors.orange;
        break;
      case 'hard':
      case 'difficile':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        _currentKeyword.difficulty,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStats() {
    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (_currentKeyword.trend) {
      case 'up':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        trendText = 'En progression';
        break;
      case 'down':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        trendText = 'En baisse';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.grey;
        trendText = 'Stable';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Position actuelle',
              '#${_currentKeyword.currentPosition}',
              Colors.blue,
              Icons.star,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Tendance',
              _currentKeyword.positionDifference != 0
                  ? '${_currentKeyword.positionDifference > 0 ? '+' : ''}${_currentKeyword.positionDifference}'
                  : trendText,
              trendColor,
              trendIcon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Volume',
              _currentKeyword.searchVolume.toString(),
              Colors.purple,
              Icons.search,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    final sortedTrackings = List<KeywordTracking>.from(_trackings)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique des positions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedTrackings.length,
            itemBuilder: (context, index) {
              final tracking = sortedTrackings[index];
              final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

              // Calculer la variation par rapport au tracking précédent
              String variation = '';
              Color? variationColor;
              if (index < sortedTrackings.length - 1) {
                final previousTracking = sortedTrackings[index + 1];
                final diff = previousTracking.position - tracking.position;
                if (diff > 0) {
                  variation = '+$diff';
                  variationColor = Colors.green;
                } else if (diff < 0) {
                  variation = '$diff';
                  variationColor = Colors.red;
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '#${tracking.position}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(dateFormat.format(tracking.date)),
                  subtitle: tracking.searchVolume > 0
                      ? Text('Volume: ${tracking.searchVolume}')
                      : null,
                  trailing: variation.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: variationColor!.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            variation,
                            style: TextStyle(
                              color: variationColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun historique',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mettez à jour la position pour commencer le tracking',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
