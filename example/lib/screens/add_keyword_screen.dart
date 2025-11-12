import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/keyword.dart';
import '../services/storage_service.dart';

class AddKeywordScreen extends StatefulWidget {
  const AddKeywordScreen({Key? key}) : super(key: key);

  @override
  State<AddKeywordScreen> createState() => _AddKeywordScreenState();
}

class _AddKeywordScreenState extends State<AddKeywordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keywordController = TextEditingController();
  final _positionController = TextEditingController();
  final _volumeController = TextEditingController();
  final StorageService _storageService = StorageService();

  String _difficulty = 'Medium';
  bool _isSaving = false;

  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _keywordController.dispose();
    _positionController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _saveKeyword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final keyword = Keyword(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      keyword: _keywordController.text.trim(),
      currentPosition: int.parse(_positionController.text),
      previousPosition: int.parse(_positionController.text),
      lastUpdated: DateTime.now(),
      searchVolume: int.tryParse(_volumeController.text) ?? 0,
      difficulty: _difficulty,
    );

    try {
      await _storageService.addKeyword(keyword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot clé ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un mot clé'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Information
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ajoutez un mot clé à suivre pour optimiser votre ASO sur le Play Store',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mot clé
                TextFormField(
                  controller: _keywordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot clé *',
                    hintText: 'Ex: jeu de puzzle gratuit',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un mot clé';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Position
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position actuelle *',
                    hintText: 'Ex: 42',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    helperText: 'La position dans les résultats de recherche (1 = premier)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une position';
                    }
                    final position = int.tryParse(value);
                    if (position == null || position < 1) {
                      return 'La position doit être un nombre supérieur à 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Volume de recherche
                TextFormField(
                  controller: _volumeController,
                  decoration: const InputDecoration(
                    labelText: 'Volume de recherche (optionnel)',
                    hintText: 'Ex: 5000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                    helperText: 'Nombre estimé de recherches par mois',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),

                // Difficulté
                DropdownButtonFormField<String>(
                  value: _difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulté',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bar_chart),
                    helperText: 'Difficulté estimée pour se positionner',
                  ),
                  items: _difficultyOptions.map((difficulty) {
                    IconData icon;
                    Color color;
                    switch (difficulty) {
                      case 'Easy':
                        icon = Icons.sentiment_very_satisfied;
                        color = Colors.green;
                        break;
                      case 'Medium':
                        icon = Icons.sentiment_neutral;
                        color = Colors.orange;
                        break;
                      case 'Hard':
                        icon = Icons.sentiment_very_dissatisfied;
                        color = Colors.red;
                        break;
                      default:
                        icon = Icons.help;
                        color = Colors.grey;
                    }

                    return DropdownMenuItem(
                      value: difficulty,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(difficulty),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _difficulty = value);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Conseils
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Conseils ASO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip('Choisissez des mots clés pertinents pour votre app'),
                        _buildTip('Suivez régulièrement vos positions'),
                        _buildTip('Privilégiez les mots clés avec un bon volume de recherche'),
                        _buildTip('Variez entre mots clés faciles et difficiles'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton sauvegarder
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveKeyword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Ajouter le mot clé',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
