import 'package:flutter/material.dart';
import 'package:krushi_ai/models/history_model.dart';
import 'package:krushi_ai/services/firestore_service.dart';
import 'package:intl/intl.dart';

/// HistoryScreen - Display model output history
///
/// Purpose: Shows user's AI model interaction history
/// Features: List view, filter by model type, delete options

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedModelType;
  
  final List<String> _modelTypes = [
    'All',
    'crop_disease',
    'soil_analysis',
    'weather_forecast',
    'pest_detection',
    'crop_recommendation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedModelType = value == 'All' ? null : value;
              });
            },
            itemBuilder: (context) {
              return _modelTypes.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All History',
            onPressed: _confirmClearHistory,
          ),
        ],
      ),
      body: StreamBuilder<List<HistoryModel>>(
        stream: _firestoreService.getHistoryStream(
          limit: 100,
          modelType: _selectedModelType,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final historyList = snapshot.data ?? [];

          if (historyList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No History Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your model predictions will appear here',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return _buildHistoryCard(history);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(HistoryModel history) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showHistoryDetails(history),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getModelIcon(history.modelType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatModelType(history.modelType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(history.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF4CAF50)),
                        tooltip: 'Edit',
                        onPressed: () => _showEditDialog(history),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(history),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Input:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                history.input,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Output:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                history.output,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getModelIcon(String modelType) {
    IconData icon;
    Color color;

    switch (modelType) {
      case 'crop_disease':
        icon = Icons.bug_report;
        color = Colors.red;
        break;
      case 'soil_analysis':
        icon = Icons.terrain;
        color = Colors.brown;
        break;
      case 'weather_forecast':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'pest_detection':
        icon = Icons.pest_control;
        color = Colors.purple;
        break;
      case 'crop_recommendation':
        icon = Icons.grass;
        color = Colors.green;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  String _formatModelType(String modelType) {
    return modelType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _showHistoryDetails(HistoryModel history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatModelType(history.modelType)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Timestamp:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(DateFormat('MMMM dd, yyyy • hh:mm:ss a')
                  .format(history.timestamp)),
              const SizedBox(height: 16),
              Text(
                'Input:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(history.input),
              const SizedBox(height: 16),
              Text(
                'Output:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(history.output),
              if (history.metadata != null && history.metadata!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Additional Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                ...history.metadata!.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${e.key}: ${e.value}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(HistoryModel history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteHistory(history.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistory(String id) async {
    try {
      await _firestoreService.deleteHistory(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all history records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllHistory() async {
    try {
      await _firestoreService.clearUserHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All history cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEditDialog(HistoryModel history) {
    final inputController = TextEditingController(text: history.input);
    final outputController = TextEditingController(text: history.output);
    final confidenceController = TextEditingController(
      text: history.metadata?['confidence'] != null
          ? (history.metadata!['confidence'] * 100).toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit History'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatModelType(history.modelType),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: inputController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Input',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: outputController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Output',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confidenceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confidence (%)',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateHistory(
                history.id,
                inputController.text,
                outputController.text,
                confidenceController.text,
                history.metadata,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers after dialog is fully closed
      inputController.dispose();
      outputController.dispose();
      confidenceController.dispose();
    });
  }

  Future<void> _updateHistory(
    String historyId,
    String input,
    String output,
    String confidenceText,
    Map<String, dynamic>? existingMetadata,
  ) async {
    try {
      final metadata = Map<String, dynamic>.from(existingMetadata ?? {});
      
      if (confidenceText.isNotEmpty) {
        final confidence = double.tryParse(confidenceText);
        if (confidence != null && confidence >= 0 && confidence <= 100) {
          metadata['confidence'] = confidence / 100.0;
        }
      }

      await _firestoreService.updateHistory(
        historyId: historyId,
        input: input,
        output: output,
        metadata: metadata,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History updated successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
