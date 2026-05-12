// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ UTILISATEURS ============
  static Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ============ LOTS ============
  static Stream<List<LotModel>> getUserLots(String userId) {
    return _firestore
        .collection('lots')
        .where('statut', isEqualTo: 'actif')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final batimentId = data['batimentId'] as String? ?? '';
        return LotModel.fromFirestore(doc, batimentId);
      }).toList();
    });
  }

  static Future<List<LotModel>> getAllLots() async {
    try {
      final snapshot = await _firestore.collection('lots').get();
      final List<LotModel> lots = [];

      // Récupérer tous les bâtiments pour les noms
      final batimentsSnapshot = await _firestore.collection('batiments').get();
      final Map<String, String> batimentNoms = {};
      for (final doc in batimentsSnapshot.docs) {
        batimentNoms[doc.id] = doc.data()['nom'] ?? 'Bâtiment inconnu';
      }

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final batimentId = data['batimentId'] as String? ?? '';
        final batimentNom = batimentNoms[batimentId] ?? 'Bâtiment inconnu';
        lots.add(LotModel.fromFirestore(doc, batimentNom));
      }
      return lots;
    } catch (e) {
      print('❌ Erreur getAllLots: $e');
      return [];
    }
  }

  static Future<void> addLot(LotModel lot) async {
    try {
      await _firestore.collection('lots').add(lot.toFirestore());
      print('✅ Lot ajouté');
    } catch (e) {
      print('❌ Erreur addLot: $e');
      throw e;
    }
  }

  static Future<void> updateLot(String lotId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('lots').doc(lotId).update(data);
      print('✅ Lot mis à jour: $lotId');
    } catch (e) {
      print('❌ Erreur updateLot: $e');
      throw e;
    }
  }

  static Future<void> deleteLot(String lotId) async {
    try {
      await _firestore.collection('lots').doc(lotId).delete();
      print('✅ Lot supprimé: $lotId');
    } catch (e) {
      print('❌ Erreur deleteLot: $e');
      throw e;
    }
  }

  // ============ PRODUCTION ============
  static Stream<List<ProductionModel>> getProductionByLot(String lotId) {
    return _firestore
        .collection('lots')
        .doc(lotId)
        .collection('production')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductionModel.fromFirestore(doc, lotId))
          .toList();
    });
  }

  static Future<List<ProductionModel>> getProductionHistory(
      String lotId) async {
    try {
      final snapshot = await _firestore
          .collection('lots')
          .doc(lotId)
          .collection('production')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snapshot.docs
          .map((doc) => ProductionModel.fromFirestore(doc, lotId))
          .toList();
    } catch (e) {
      print('❌ Erreur getProductionHistory: $e');
      return [];
    }
  }

  static Future<void> addProduction(
      String lotId, ProductionModel production) async {
    try {
      await _firestore
          .collection('lots')
          .doc(lotId)
          .collection('production')
          .add(production.toFirestore());
      print('✅ Production ajoutée pour le lot $lotId');
    } catch (e) {
      print('❌ Erreur addProduction: $e');
      throw e;
    }
  }

  // ============ INTERVENTIONS ============
  static Stream<List<InterventionModel>> getInterventionsByLot(String lotId) {
    return _firestore
        .collection('lots')
        .doc(lotId)
        .collection('interventions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InterventionModel.fromFirestore(
            doc, 'Lot ${lotId.substring(0, 4)}');
      }).toList();
    });
  }

  static Future<List<InterventionModel>> getAllInterventions() async {
    try {
      final lotsSnapshot = await _firestore.collection('lots').get();
      final List<InterventionModel> allInterventions = [];

      for (final lotDoc in lotsSnapshot.docs) {
        final interventionsSnapshot = await _firestore
            .collection('lots')
            .doc(lotDoc.id)
            .collection('interventions')
            .get();

        final lotNom =
            lotDoc.data()['nom'] ?? 'Lot ${lotDoc.id.substring(0, 4)}';
        for (final interventionDoc in interventionsSnapshot.docs) {
          allInterventions.add(InterventionModel.fromFirestore(
            interventionDoc,
            lotNom,
          ));
        }
      }

      allInterventions.sort((a, b) => b.date.compareTo(a.date));
      return allInterventions;
    } catch (e) {
      print('❌ Erreur getAllInterventions: $e');
      return [];
    }
  }

  static Future<void> addIntervention(
      String lotId, InterventionModel intervention) async {
    try {
      await _firestore
          .collection('lots')
          .doc(lotId)
          .collection('interventions')
          .add(intervention.toFirestore());
      print('✅ Intervention ajoutée pour le lot $lotId');
    } catch (e) {
      print('❌ Erreur addIntervention: $e');
      throw e;
    }
  }

  // ============ ALERTES ============
  static Stream<List<AlertModel>> getAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
    });
  }

  static Future<List<AlertModel>> getAllAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Erreur getAllAlerts: $e');
      return [];
    }
  }

  static Future<void> addAlert(AlertModel alert) async {
    try {
      await _firestore.collection('alerts').add(alert.toFirestore());
      print('✅ Alerte ajoutée');
    } catch (e) {
      print('❌ Erreur addAlert: $e');
      throw e;
    }
  }

  static Future<void> markAlertAsTreated(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'traitee': true,
      });
      print('✅ Alerte marquée comme traitée: $alertId');
    } catch (e) {
      print('❌ Erreur markAlertAsTreated: $e');
      throw e;
    }
  }

  // ============ STOCKS ============
  static Stream<List<StockModel>> getStocks() {
    return _firestore.collection('stocks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StockModel.fromFirestore(doc)).toList();
    });
  }

  static Future<List<StockModel>> getAllStocks() async {
    try {
      final snapshot = await _firestore.collection('stocks').get();
      return snapshot.docs.map((doc) => StockModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Erreur getAllStocks: $e');
      return [];
    }
  }

  static Future<void> addStock(StockModel stock) async {
    try {
      await _firestore.collection('stocks').add(stock.toFirestore());
      print('✅ Stock ajouté: ${stock.nom}');
    } catch (e) {
      print('❌ Erreur addStock: $e');
      throw e;
    }
  }

  static Future<void> updateStock(
      String stockId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('stocks').doc(stockId).update(data);
      print('✅ Stock mis à jour: $stockId');
    } catch (e) {
      print('❌ Erreur updateStock: $e');
      throw e;
    }
  }

  static Future<void> deleteStock(String stockId) async {
    try {
      await _firestore.collection('stocks').doc(stockId).delete();
      print('✅ Stock supprimé: $stockId');
    } catch (e) {
      print('❌ Erreur deleteStock: $e');
      throw e;
    }
  }

  // ============ BÂTIMENTS ============
  static Future<List<BatimentModel>> getAllBatiments() async {
    try {
      final snapshot = await _firestore.collection('batiments').get();
      return snapshot.docs
          .map((doc) => BatimentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erreur getAllBatiments: $e');
      return [];
    }
  }

  static Future<void> addBatiment(BatimentModel batiment) async {
    try {
      await _firestore.collection('batiments').add(batiment.toFirestore());
      print('✅ Bâtiment ajouté: ${batiment.nom}');
    } catch (e) {
      print('❌ Erreur addBatiment: $e');
      throw e;
    }
  }

  static Future<void> updateBatiment(
      String batimentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('batiments').doc(batimentId).update(data);
      print('✅ Bâtiment mis à jour: $batimentId');
    } catch (e) {
      print('❌ Erreur updateBatiment: $e');
      throw e;
    }
  }

  static Future<void> deleteBatiment(String batimentId) async {
    try {
      await _firestore.collection('batiments').doc(batimentId).delete();
      print('✅ Bâtiment supprimé: $batimentId');
    } catch (e) {
      print('❌ Erreur deleteBatiment: $e');
      throw e;
    }
  }

  // ============ OBSERVATIONS ============
  static Future<void> addObservation(ObservationModel observation) async {
    try {
      await _firestore
          .collection('observations')
          .add(observation.toFirestore());
      print('✅ Observation ajoutée');
    } catch (e) {
      print('❌ Erreur addObservation: $e');
      throw e;
    }
  }

  static Stream<List<ObservationModel>> getObservationsByLot(String lotId) {
    return _firestore
        .collection('observations')
        .where('lotId', isEqualTo: lotId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ObservationModel.fromFirestore(
          doc,
          data['lotNom'] ?? '',
          data['technicienNom'] ?? '',
        );
      }).toList();
    });
  }

  // ============ STATISTIQUES DASHBOARD ============
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final lots = await _firestore
          .collection('lots')
          .where('statut', isEqualTo: 'actif')
          .get();
      final stocks = await _firestore.collection('stocks').get();
      final alerts = await _firestore
          .collection('alerts')
          .where('traitee', isEqualTo: false)
          .get();

      final stockTotal = stocks.docs.fold<double>(0, (sum, doc) {
        final quantite = doc.data()['quantite'] as num? ?? 0;
        return sum + quantite.toDouble();
      });

      return {
        'lotsActifs': lots.docs.length,
        'stockTotal': stockTotal,
        'alertesCount': alerts.docs.length,
      };
    } catch (e) {
      print('❌ Erreur getDashboardStats: $e');
      return {
        'lotsActifs': 0,
        'stockTotal': 0.0,
        'alertesCount': 0,
      };
    }
  }
}

// ============================================================================
// MODÈLE BÂTIMENT (à ajouter dans app_models.dart)
// ============================================================================

class BatimentModel {
  final String id;
  final String nom;
  final int capacite;
  final double surface;
  final String typeElevage;
  final DateTime createdAt;

  BatimentModel({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.surface,
    required this.typeElevage,
    required this.createdAt,
  });

  factory BatimentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BatimentModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      capacite: data['capacite'] ?? 0,
      surface: (data['surface'] ?? 0).toDouble(),
      typeElevage: data['typeElevage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'capacite': capacite,
      'surface': surface,
      'typeElevage': typeElevage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
