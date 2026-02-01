import 'package:cloud_firestore/cloud_firestore.dart';

/// HistoryModel - Model for storing AI model output history
///
/// Purpose: Represents a single history entry for model predictions/outputs
/// Used for: Saving and retrieving user's AI model interaction history

class HistoryModel {
  final String id;
  final String userId;
  final String userEmail;
  final String modelType; // e.g., 'crop_disease', 'soil_analysis', 'weather'
  final String input; // User's input/query
  final String output; // Model's prediction/response
  final Map<String, dynamic>? metadata; // Additional data (confidence, image_url, etc.)
  final DateTime timestamp;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.modelType,
    required this.input,
    required this.output,
    this.metadata,
    required this.timestamp,
  });

  /// Convert HistoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'modelType': modelType,
      'input': input,
      'output': output,
      'metadata': metadata ?? {},
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create HistoryModel from Firestore DocumentSnapshot
  factory HistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      modelType: data['modelType'] ?? '',
      input: data['input'] ?? '',
      output: data['output'] ?? '',
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Create HistoryModel from Map
  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      modelType: map['modelType'] ?? '',
      input: map['input'] ?? '',
      output: map['output'] ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'modelType': modelType,
      'input': input,
      'output': output,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Copy with method for creating modified copies
  HistoryModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? modelType,
    String? input,
    String? output,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      modelType: modelType ?? this.modelType,
      input: input ?? this.input,
      output: output ?? this.output,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'HistoryModel(id: $id, modelType: $modelType, timestamp: $timestamp)';
  }
}
