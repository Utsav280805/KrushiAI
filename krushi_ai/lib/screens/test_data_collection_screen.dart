import 'package:flutter/material.dart';
import 'package:krushi_ai/services/firestore_service.dart';

/// Test Data Collection Screen
/// Allows users to manually add test predictions to Firestore

class TestDataCollectionScreen extends StatefulWidget {
  const TestDataCollectionScreen({super.key});

  @override
  State<TestDataCollectionScreen> createState() =>
      _TestDataCollectionScreenState();
}

class _TestDataCollectionScreenState extends State<TestDataCollectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _confidenceController = TextEditingController();

  String _selectedModelType = 'crop_disease';
  bool _isLoading = false;

  final List<String> _modelTypes = [
    'crop_disease',
    'soil_analysis',
    'weather_forecast',
    'pest_detection',
    'crop_recommendation',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Data Collection'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Test saving AI predictions to Firestore database',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Model Type Dropdown
              const Text(
                'Model Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedModelType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _modelTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModelType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Input Field
              const Text(
                'Input / Query',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _inputController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Yellow spots on tomato leaves',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.input),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter input';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Output Field
              const Text(
                'Model Output / Prediction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _outputController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Detected: Early Blight with 87% confidence',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.output),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter output';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confidence Field
              const Text(
                'Confidence (0-100)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confidenceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 87',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.percent),
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final confidence = int.tryParse(value);
                    if (confidence == null || confidence < 0 || confidence > 100) {
                      return 'Enter a value between 0 and 100';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveToFirestore,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? 'Saving...' : 'Save to Firestore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Fill Buttons
              const Divider(height: 32),
              const Text(
                'Quick Fill Examples',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickFillButton('Disease', _fillDiseaseExample),
                  _buildQuickFillButton('Soil', _fillSoilExample),
                  _buildQuickFillButton('Weather', _fillWeatherExample),
                  _buildQuickFillButton('Pest', _fillPestExample),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFillButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4CAF50),
        side: const BorderSide(color: Color(0xFF4CAF50)),
      ),
      child: Text(label),
    );
  }

  void _fillDiseaseExample() {
    setState(() {
      _selectedModelType = 'crop_disease';
      _inputController.text = 'Yellow and brown spots on tomato leaves';
      _outputController.text = '''Disease Detected: Early Blight (Alternaria solani)

Symptoms:
• Concentric rings pattern on leaves
• Yellow/brown discoloration
• Progressive leaf wilting

Treatment:
1. Remove infected leaves
2. Apply copper-based fungicide
3. Improve air circulation''';
      _confidenceController.text = '87';
    });
  }

  void _fillSoilExample() {
    setState(() {
      _selectedModelType = 'soil_analysis';
      _inputController.text = 'N: 45 ppm, P: 12 ppm, K: 180 ppm, pH: 6.8';
      _outputController.text = '''Soil Analysis Results:

Quality: Good
Nitrogen: Moderate (Adequate)
Phosphorus: Low (Needs supplement)
Potassium: High (Excellent)
pH: Slightly acidic (Ideal for most crops)

Recommendations:
• Add phosphorus fertilizer
• Maintain current nitrogen levels
• Suitable for vegetables and grains''';
      _confidenceController.text = '92';
    });
  }

  void _fillWeatherExample() {
    setState(() {
      _selectedModelType = 'weather_forecast';
      _inputController.text = 'Location: Gujarat, Season: Monsoon';
      _outputController.text = '''Weather-Based Recommendations:

Best Crops for Monsoon:
1. Rice - High yield potential
2. Cotton - Excellent choice
3. Groundnut - Good returns
4. Millets - Drought resistant

Planting Time: Late June to July
Expected Rainfall: 850-1000mm
Irrigation: Minimal needed''';
      _confidenceController.text = '95';
    });
  }

  void _fillPestExample() {
    setState(() {
      _selectedModelType = 'pest_detection';
      _inputController.text = 'Small green insects on cotton leaves';
      _outputController.text = '''Pest Identified: Aphids (Aphis gossypii)

Characteristics:
• Small, soft-bodied insects
• Green or yellow-green color
• Cluster on new growth

Control Measures:
1. Spray neem oil solution
2. Introduce ladybugs (natural predators)
3. Use insecticidal soap
4. Remove heavily infested plants''';
      _confidenceController.text = '89';
    });
  }

  Future<void> _saveToFirestore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare metadata
      final metadata = <String, dynamic>{};
      
      if (_confidenceController.text.isNotEmpty) {
        final confidence = int.parse(_confidenceController.text);
        metadata['confidence'] = confidence / 100.0;
      }
      
      metadata['saved_from'] = 'test_collection_screen';
      metadata['timestamp_readable'] = DateTime.now().toString();

      // Save to Firestore
      final historyId = await _firestoreService.saveHistory(
        modelType: _selectedModelType,
        input: _inputController.text.trim(),
        output: _outputController.text.trim(),
        metadata: metadata,
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data saved to Firestore successfully!'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ID: $historyId',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Check the History tab to view this entry.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearForm();
                },
                child: const Text('Add Another'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: const Text('View History'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _inputController.clear();
    _outputController.clear();
    _confidenceController.clear();
    setState(() {
      _selectedModelType = 'crop_disease';
    });
  }
}
