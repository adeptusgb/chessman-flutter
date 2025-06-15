import 'package:cloud_firestore/cloud_firestore.dart';

class AerobicsResult {
  final String? id;
  final double corridaDistance;
  final double natacaoDistance;
  final double ciclismoDistance;
  final double totalCalories;
  final DateTime createdAt;

  AerobicsResult({
    this.id,
    required this.corridaDistance,
    required this.natacaoDistance,
    required this.ciclismoDistance,
    required this.totalCalories,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'corridaDistance': corridaDistance,
      'natacaoDistance': natacaoDistance,
      'ciclismoDistance': ciclismoDistance,
      'totalCalories': totalCalories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AerobicsResult.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return AerobicsResult(
      id: documentId,
      corridaDistance: (map['corridaDistance'] ?? 0.0).toDouble(),
      natacaoDistance: (map['natacaoDistance'] ?? 0.0).toDouble(),
      ciclismoDistance: (map['ciclismoDistance'] ?? 0.0).toDouble(),
      totalCalories: (map['totalCalories'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory AerobicsResult.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AerobicsResult.fromMap(data, documentId: doc.id);
  }

  AerobicsResult copyWith({
    String? id,
    double? corridaDistance,
    double? natacaoDistance,
    double? ciclismoDistance,
    double? totalCalories,
    DateTime? createdAt,
  }) {
    return AerobicsResult(
      id: id ?? this.id,
      corridaDistance: corridaDistance ?? this.corridaDistance,
      natacaoDistance: natacaoDistance ?? this.natacaoDistance,
      ciclismoDistance: ciclismoDistance ?? this.ciclismoDistance,
      totalCalories: totalCalories ?? this.totalCalories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AerobicsResult(id: $id, corridaDistance: $corridaDistance, natacaoDistance: $natacaoDistance, ciclismoDistance: $ciclismoDistance, totalCalories: $totalCalories, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AerobicsResult &&
        other.id == id &&
        other.corridaDistance == corridaDistance &&
        other.natacaoDistance == natacaoDistance &&
        other.ciclismoDistance == ciclismoDistance &&
        other.totalCalories == totalCalories &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        corridaDistance.hashCode ^
        natacaoDistance.hashCode ^
        ciclismoDistance.hashCode ^
        totalCalories.hashCode ^
        createdAt.hashCode;
  }
}

class AerobicsRepository {
  static const String collectionName = 'aerobics_results';
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    collectionName,
  );

  Future<String> saveResult(AerobicsResult result) async {
    try {
      final docRef = await _collection.add(result.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save aerobics result: $e');
    }
  }

  Future<AerobicsResult?> getResultById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return AerobicsResult.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get aerobics result: $e');
    }
  }

  Future<List<AerobicsResult>> getAllResults() async {
    try {
      final querySnapshot =
          await _collection.orderBy('createdAt', descending: true).get();

      return querySnapshot.docs
          .map((doc) => AerobicsResult.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all aerobics results: $e');
    }
  }

  Future<void> updateResult(String id, AerobicsResult result) async {
    try {
      await _collection.doc(id).update(result.toMap());
    } catch (e) {
      throw Exception('Failed to update aerobics result: $e');
    }
  }

  Future<void> deleteResult(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete aerobics result: $e');
    }
  }

  Stream<List<AerobicsResult>> watchAllResults() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AerobicsResult.fromDocument(doc))
                  .toList(),
        );
  }

  Future<List<AerobicsResult>> getResultsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot =
          await _collection
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => AerobicsResult.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get results in date range: $e');
    }
  }

  Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final results = await getAllResults();

      if (results.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalCalories': 0.0,
          'averageCalories': 0.0,
          'totalCorridaDistance': 0.0,
          'totalNatacaoDistance': 0.0,
          'totalCiclismoDistance': 0.0,
        };
      }

      final totalCalories = results.fold(
        0.0,
        (sum, result) => sum + result.totalCalories,
      );
      final totalCorrida = results.fold(
        0.0,
        (sum, result) => sum + result.corridaDistance,
      );
      final totalNatacao = results.fold(
        0.0,
        (sum, result) => sum + result.natacaoDistance,
      );
      final totalCiclismo = results.fold(
        0.0,
        (sum, result) => sum + result.ciclismoDistance,
      );

      return {
        'totalWorkouts': results.length,
        'totalCalories': totalCalories,
        'averageCalories': totalCalories / results.length,
        'totalCorridaDistance': totalCorrida,
        'totalNatacaoDistance': totalNatacao,
        'totalCiclismoDistance': totalCiclismo,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
