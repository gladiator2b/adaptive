import 'package:flutter/material.dart';
import '../models/keyword.dart';
import '../services/storage_service.dart';
import '../widgets/keyword_card.dart';
import 'add_keyword_screen.dart';
import 'keyword_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Keyword> _keywords = [];
  bool _isLoading = true;
  String _sortBy = 'position'; // position, keyword, date

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    setState(() => _isLoading = true);
    final keywords = await _storageService.loadKeywords();
    setState(() {
      _keywords = keywords;
      _isLoading = false;
    });
    _sortKeywords();
  }

  void _sortKeywords() {
    setState(() {
      switch (_sortBy) {
        case 'position':
          _keywords.sort((a, b) => a.currentPosition.compareTo(b.currentPosition));
          break;
        case 'keyword':
          _keywords.sort((a, b) => a.keyword.compareTo(b.keyword));
          break;
        case 'date':
          _keywords.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
          break;
      }
    });
  }

  Future<void> _deleteKeyword(Keyword keyword) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le mot clé "${keyword.keyword}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteKeyword(keyword.id);
      _loadKeywords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mot clé "${keyword.keyword}" supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddKeyword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddKeywordScreen()),
    );

    if (result == true) {
      _loadKeywords();
    }
  }

  Future<void> _navigateToDetail(Keyword keyword) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeywordDetailScreen(keyword: keyword),
      ),
    );

    if (result == true) {
      _loadKeywords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASO - Suivi de Mots Clés'),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _sortKeywords();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'position',
                child: Text('Trier par position'),
              ),
              const PopupMenuItem(
                value: 'keyword',
                child: Text('Trier par mot clé'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Trier par date'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _keywords.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadKeywords,
                  child: Column(
                    children: [
                      _buildSummary(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _keywords.length,
                          itemBuilder: (context, index) {
                            final keyword = _keywords[index];
                            return KeywordCard(
                              keyword: keyword,
                              onTap: () => _navigateToDetail(keyword),
                              onDelete: () => _deleteKeyword(keyword),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddKeyword,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun mot clé',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier mot clé pour commencer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddKeyword,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un mot clé'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (_keywords.isEmpty) return const SizedBox.shrink();

    final improving = _keywords.where((k) => k.trend == 'up').length;
    final declining = _keywords.where((k) => k.trend == 'down').length;
    final avgPosition = _keywords.isEmpty
        ? 0
        : _keywords.map((k) => k.currentPosition).reduce((a, b) => a + b) /
            _keywords.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Total',
              _keywords.length.toString(),
              Colors.blue,
              Icons.label,
            ),
            _buildSummaryItem(
              'En progression',
              improving.toString(),
              Colors.green,
              Icons.trending_up,
            ),
            _buildSummaryItem(
              'En baisse',
              declining.toString(),
              Colors.red,
              Icons.trending_down,
            ),
            _buildSummaryItem(
              'Position moy.',
              avgPosition.toStringAsFixed(1),
              Colors.orange,
              Icons.analytics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
