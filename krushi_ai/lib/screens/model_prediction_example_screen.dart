import 'package:flutter/material.dart';
import 'package:krushi_ai/services/firestore_service.dart';

/// Example Model Prediction Screen
/// 
/// This demonstrates how to integrate Firestore to save model predictions
/// You can copy this pattern to your actual AI model screens

class ModelPredictionExampleScreen extends StatefulWidget {
  const ModelPredictionExampleScreen({super.key});

  @override
  State<ModelPredictionExampleScreen> createState() =>
      _ModelPredictionExampleScreenState();
}

class _ModelPredictionExampleScreenState
    extends State<ModelPredictionExampleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _inputController = TextEditingController();
  
  String _prediction = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Disease Detection'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How to Use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Enter crop symptoms or upload image\n'
                      '2. Click "Analyze" to get AI prediction\n'
                      '3. Results are automatically saved to history',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Section
            const Text(
              'Describe Symptoms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., Yellow spots on leaves, wilting stems...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),

            // Analyze Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzeCrop,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.analytics),
              label: Text(_isLoading ? 'Analyzing...' : 'Analyze Crop'),
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
            const SizedBox(height: 24),

            // Results Section
            if (_prediction.isNotEmpty) ...[
              const Text(
                'Prediction Results',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Analysis Complete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _prediction,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.save, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Result saved to your history',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Simulate AI model prediction and save to Firestore
  Future<void> _analyzeCrop() async {
    final input = _inputController.text.trim();
    
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter symptoms')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _prediction = '';
    });

    try {
      // ============================================
      // STEP 1: Call your AI model API here
      // ============================================
      // Example: final response = await http.post(...)
      
      // Simulated AI prediction (replace with actual API call)
      await Future.delayed(const Duration(seconds: 2));
      
      final mockPrediction = '''
Disease Detected: Early Blight (Alternaria solani)

Confidence: 87%

Symptoms Identified:
• Yellow/brown spots on leaves
• Concentric rings pattern
• Progressive leaf wilting

Recommended Treatment:
1. Remove infected leaves immediately
2. Apply copper-based fungicide
3. Ensure proper plant spacing
4. Avoid overhead watering

Prevention Tips:
• Rotate crops annually
• Maintain soil health
• Monitor regularly
''';

      // ============================================
      // STEP 2: Save prediction to Firestore
      // ============================================
      final historyId = await _firestoreService.saveHistory(
        modelType: 'crop_disease', // Type of AI model
        input: input, // User's input
        output: mockPrediction, // Model's prediction
        metadata: {
          // Optional: Add any additional information
          'confidence': 0.87,
          'disease_name': 'Early Blight',
          'treatment_priority': 'high',
          'timestamp_readable': DateTime.now().toString(),
        },
      );

      print('✅ History saved with ID: $historyId');

      // ============================================
      // STEP 3: Display results to user
      // ============================================
      setState(() {
        _prediction = mockPrediction;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis complete! Result saved to history.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================
// HOW TO INTEGRATE IN YOUR ACTUAL SCREENS
// ============================================

/*
EXAMPLE 1: Crop Disease Detection Screen
----------------------------------------

void analyzeDiseaseFromImage() async {
  try {
    // 1. Upload image to your AI model
    final response = await http.post(
      Uri.parse('YOUR_AI_MODEL_API_URL'),
      body: {'image': base64Image},
    );
    
    // 2. Parse the response
    final prediction = json.decode(response.body);
    
    // 3. Save to Firestore
    await _firestoreService.saveHistory(
      modelType: 'crop_disease',
      input: 'Image uploaded: ${imageName}',
      output: prediction['disease_name'],
      metadata: {
        'confidence': prediction['confidence'],
        'image_url': uploadedImageUrl,
        'treatments': prediction['treatments'],
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}

EXAMPLE 2: Soil Analysis Screen
--------------------------------

void analyzeSoilData() async {
  try {
    // 1. Send soil data to API
    final response = await http.post(
      Uri.parse('YOUR_SOIL_API_URL'),
      body: {
        'nitrogen': nitrogenValue,
        'phosphorus': phosphorusValue,
        'potassium': potassiumValue,
        'ph': phValue,
      },
    );
    
    // 2. Parse recommendations
    final analysis = json.decode(response.body);
    
    // 3. Save to Firestore
    await _firestoreService.saveHistory(
      modelType: 'soil_analysis',
      input: 'N:$nitrogenValue P:$phosphorusValue K:$potassiumValue pH:$phValue',
      output: analysis['recommendation'],
      metadata: {
        'soil_quality': analysis['quality_score'],
        'crop_recommendations': analysis['suitable_crops'],
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}

EXAMPLE 3: Weather-Based Crop Recommendation
---------------------------------------------

void getWeatherBasedRecommendation() async {
  try {
    // 1. Get weather and location data
    final weatherData = await fetchWeatherData();
    
    // 2. Call your recommendation API
    final response = await http.post(
      Uri.parse('YOUR_RECOMMENDATION_API'),
      body: {
        'temperature': weatherData['temp'],
        'humidity': weatherData['humidity'],
        'rainfall': weatherData['rainfall'],
        'location': userLocation,
      },
    );
    
    // 3. Parse and save
    final recommendation = json.decode(response.body);
    
    await _firestoreService.saveHistory(
      modelType: 'crop_recommendation',
      input: 'Location: $userLocation, Season: $currentSeason',
      output: recommendation['suggested_crops'].join(', '),
      metadata: {
        'weather_conditions': weatherData,
        'best_planting_time': recommendation['timing'],
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}

*/
