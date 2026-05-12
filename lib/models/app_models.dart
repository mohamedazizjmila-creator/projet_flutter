import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMÉRATIONS
// ─────────────────────────────────────────────────────────────────────────────

enum AlertPriority { critical, warning, resolved }

enum InterventionType {
  vaccination,
  traitement,
  nettoyage,
  desinfection,
  litiere
}

enum UserRole { admin, responsable, technicien, veterinaire }

enum LotStatus { actif, termine }

// Extension pour les conversions
extension AlertPriorityExt on AlertPriority {
  String get stringValue {
    switch (this) {
      case AlertPriority.critical:
        return 'critical';
      case AlertPriority.warning:
        return 'warning';
      case AlertPriority.resolved:
        return 'resolved';
    }
  }

  static AlertPriority fromString(String value) {
    switch (value) {
      case 'critical':
        return AlertPriority.critical;
      case 'warning':
        return AlertPriority.warning;
      case 'resolved':
        return AlertPriority.resolved;
      default:
        return AlertPriority.warning;
    }
  }
}

extension InterventionTypeExt on InterventionType {
  String get stringValue {
    switch (this) {
      case InterventionType.vaccination:
        return 'vaccination';
      case InterventionType.traitement:
        return 'traitement';
      case InterventionType.nettoyage:
        return 'nettoyage';
      case InterventionType.desinfection:
        return 'desinfection';
      case InterventionType.litiere:
        return 'litiere';
    }
  }

  static InterventionType fromString(String value) {
    switch (value) {
      case 'vaccination':
        return InterventionType.vaccination;
      case 'traitement':
        return InterventionType.traitement;
      case 'nettoyage':
        return InterventionType.nettoyage;
      case 'desinfection':
        return InterventionType.desinfection;
      case 'litiere':
        return InterventionType.litiere;
      default:
        return InterventionType.vaccination;
    }
  }

  String get displayName {
    switch (this) {
      case InterventionType.vaccination:
        return 'Vaccination';
      case InterventionType.traitement:
        return 'Traitement';
      case InterventionType.nettoyage:
        return 'Nettoyage';
      case InterventionType.desinfection:
        return 'Désinfection';
      case InterventionType.litiere:
        return 'Changement litière';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE UTILISATEUR
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String email;
  final String nom;
  final UserRole role;
  final DateTime createdAt;
  final String? phone;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.role,
    required this.createdAt,
    this.phone,
    this.photoUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      nom: data['nom'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.technicien,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phone: data['phone'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nom': nom,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE LOT
// ─────────────────────────────────────────────────────────────────────────────

class LotModel {
  final String id;
  final String nom;
  final int nbInitial;
  final String batimentId;
  final String batimentNom;
  final DateTime dateArrivee;
  final String typeVolailles;
  final LotStatus statut;
  final DateTime createdAt;

  LotModel({
    required this.id,
    required this.nom,
    required this.nbInitial,
    required this.batimentId,
    required this.batimentNom,
    required this.dateArrivee,
    required this.typeVolailles,
    required this.statut,
    required this.createdAt,
  });

  int get joursElevage {
    if (statut == LotStatus.termine) return 0;
    return DateTime.now().difference(dateArrivee).inDays;
  }

// Dans lib/models/app_models.dart
// lib/models/app_models.dart

  factory LotModel.fromFirestore(DocumentSnapshot doc, String batimentNom) {
    final data = doc.data() as Map<String, dynamic>;

    // ✅ Gérer nbInitial
    int nbInitialValue = 0;
    if (data['nbInitial'] is int) {
      nbInitialValue = data['nbInitial'];
    } else if (data['nbInitial'] is String) {
      nbInitialValue = int.tryParse(data['nbInitial'] as String) ?? 0;
    }

    // ✅ Gérer dateArrivee
    DateTime dateArriveeValue = DateTime.now();
    if (data['dateArrivee'] is Timestamp) {
      dateArriveeValue = (data['dateArrivee'] as Timestamp).toDate();
    } else if (data['dateArrivee'] is String) {
      dateArriveeValue =
          DateTime.tryParse(data['dateArrivee'] as String) ?? DateTime.now();
    }

    // ✅ Gérer createdAt
    DateTime createdAtValue = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      createdAtValue = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAtValue =
          DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    }

    // ❌ NE PAS utiliser le champ 'nom' qui n'existe pas
    // ✅ Générer un nom à partir des informations réelles
    String typeAbrev = (data['typeVolailles'] as String? ?? 'Poulet')
        .substring(0, 3)
        .toUpperCase();
    String dateAbrev = '${dateArriveeValue.day}${dateArriveeValue.month}';
    String lotNom = 'LOT${dateAbrev}-${typeAbrev}-${nbInitialValue ~/ 1000}K';

    return LotModel(
      id: doc.id,
      nom: lotNom, // Exemple: "LOT15-04-POU-5K" ou "LOT15-04-PON-3K"
      nbInitial: nbInitialValue,
      batimentId: data['batimentId'] ?? '',
      batimentNom: batimentNom,
      dateArrivee: dateArriveeValue,
      typeVolailles: data['typeVolailles'] ?? 'Poulet de chair',
      statut: data['statut'] == 'termine' ? LotStatus.termine : LotStatus.actif,
      createdAt: createdAtValue,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'nbInitial': nbInitial,
      'batimentId': batimentId,
      'dateArrivee': Timestamp.fromDate(dateArrivee),
      'typeVolailles': typeVolailles,
      'statut': statut == LotStatus.termine ? 'termine' : 'actif',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE PRODUCTION
// ─────────────────────────────────────────────────────────────────────────────

class ProductionModel {
  final String id;
  final String lotId;
  final int mortalite;
  final int consommationAliment;
  final int? productionOeufs;
  final DateTime date;
  final String saisiePar;

  ProductionModel({
    required this.id,
    required this.lotId,
    required this.mortalite,
    required this.consommationAliment,
    this.productionOeufs,
    required this.date,
    required this.saisiePar,
  });

  factory ProductionModel.fromFirestore(DocumentSnapshot doc, String lotId) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductionModel(
      id: doc.id,
      lotId: lotId,
      mortalite: data['mortalite'] ?? 0,
      consommationAliment: data['consommationAliment'] ?? 0,
      productionOeufs: data['productionOeufs'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      saisiePar: data['saisiePar'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'mortalite': mortalite,
      'consommationAliment': consommationAliment,
      'date': Timestamp.fromDate(date),
      'saisiePar': saisiePar,
    };
    // ✅ Correction: ajout conditionnel avec '!'
    if (productionOeufs != null) {
      map['productionOeufs'] = productionOeufs!;
    }
    return map;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE ALERTE
// ─────────────────────────────────────────────────────────────────────────────

class AlertModel {
  final String id;
  final String titre;
  final String description;
  final AlertPriority priorite;
  final String tempsEcoule;
  final String type;
  final String? lotId;
  final DateTime createdAt;
  bool traitee;

  AlertModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.tempsEcoule,
    required this.type,
    this.lotId,
    required this.createdAt,
    this.traitee = false,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      priorite: AlertPriorityExt.fromString(data['priorite'] ?? 'warning'),
      tempsEcoule: _getTimeAgo((data['createdAt'] as Timestamp?)?.toDate()),
      type: data['type'] ?? '',
      lotId: data['lotId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      traitee: data['traitee'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'priorite': priorite.stringValue,
      'type': type,
      'lotId': lotId,
      'createdAt': Timestamp.fromDate(createdAt),
      'traitee': traitee,
    };
  }

  static String _getTimeAgo(DateTime? date) {
    if (date == null) return 'récemment';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';
    return 'à l\'instant';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE INTERVENTION
// ─────────────────────────────────────────────────────────────────────────────

class InterventionModel {
  final String id;
  final InterventionType type;
  final DateTime date;
  final String description;
  final String responsable;
  final String lotId;
  final String lotNom;
  final String? produits;
  final String? duree;
  final String? commentaires;
  final DateTime createdAt;
  final String createdBy;

  InterventionModel({
    required this.id,
    required this.type,
    required this.date,
    required this.description,
    required this.responsable,
    required this.lotId,
    required this.lotNom,
    this.produits,
    this.duree,
    this.commentaires,
    required this.createdAt,
    required this.createdBy,
  });

  String get heureAffichee =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  factory InterventionModel.fromFirestore(DocumentSnapshot doc, String lotNom) {
    final data = doc.data() as Map<String, dynamic>;
    return InterventionModel(
      id: doc.id,
      type: InterventionTypeExt.fromString(data['type'] ?? 'vaccination'),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      responsable: data['responsable'] ?? '',
      lotId: data['lotId'] ?? '',
      lotNom: lotNom,
      produits: data['produits'],
      duree: data['duree'],
      commentaires: data['commentaires'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.stringValue,
      'date': Timestamp.fromDate(date),
      'description': description,
      'responsable': responsable,
      'lotId': lotId,
      'produits': produits,
      'duree': duree,
      'commentaires': commentaires,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLE STOCK
// ─────────────────────────────────────────────────────────────────────────────

class StockModel {
  final String id;
  final String nom;
  double quantite;
  final double seuilAlerte;
  final String unite;
  final DateTime createdAt;

  StockModel({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.seuilAlerte,
    required this.unite,
    required this.createdAt,
  });

  bool get isLowStock => quantite <= seuilAlerte;

  factory StockModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      quantite: (data['quantite'] ?? 0).toDouble(),
      seuilAlerte: (data['seuilAlerte'] ?? 0).toDouble(),
      unite: data['unite'] ?? 'kg',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'quantite': quantite,
      'seuilAlerte': seuilAlerte,
      'unite': unite,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OBSERVATION TERRAIN
// ─────────────────────────────────────────────────────────────────────────────

class ObservationModel {
  final String id;
  final String lotId;
  final String lotNom;
  final String texte;
  final List<String> photos;
  final DateTime date;
  final String technicienId;
  final String technicienNom;

  ObservationModel({
    required this.id,
    required this.lotId,
    required this.lotNom,
    required this.texte,
    required this.photos,
    required this.date,
    required this.technicienId,
    required this.technicienNom,
  });

  factory ObservationModel.fromFirestore(
      DocumentSnapshot doc, String lotNom, String technicienNom) {
    final data = doc.data() as Map<String, dynamic>;
    return ObservationModel(
      id: doc.id,
      lotId: data['lotId'] ?? '',
      lotNom: lotNom,
      texte: data['texte'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      technicienId: data['technicienId'] ?? '',
      technicienNom: technicienNom,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lotId': lotId,
      'texte': texte,
      'photos': photos,
      'date': Timestamp.fromDate(date),
      'technicienId': technicienId,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONNÉES STATIQUES POUR LE DÉVELOPPEMENT
// ─────────────────────────────────────────────────────────────────────────────

class AppData {
  // Lots pour développement (simulés)
  static final List<LotModel> lots = [
    LotModel(
      id: 'lotA',
      nom: 'Lot A',
      nbInitial: 4800,
      batimentId: 'bat1',
      batimentNom: 'Bâtiment Principal',
      dateArrivee: DateTime(2025, 4, 1),
      typeVolailles: 'Poulet de chair',
      statut: LotStatus.actif,
      createdAt: DateTime(2025, 4, 1),
    ),
    LotModel(
      id: 'lotB',
      nom: 'Lot B',
      nbInitial: 3000,
      batimentId: 'bat2',
      batimentNom: 'Bâtiment Secondaire',
      dateArrivee: DateTime(2025, 4, 10),
      typeVolailles: 'Poulet de chair',
      statut: LotStatus.actif,
      createdAt: DateTime(2025, 4, 10),
    ),
    LotModel(
      id: 'lotC',
      nom: 'Lot C',
      nbInitial: 2500,
      batimentId: 'bat3',
      batimentNom: 'Bâtiment C',
      dateArrivee: DateTime(2025, 3, 20),
      typeVolailles: 'Poule pondeuse',
      statut: LotStatus.actif,
      createdAt: DateTime(2025, 3, 20),
    ),
  ];

  static final List<AlertModel> alertes = [
    AlertModel(
      id: '1',
      titre: 'Stock aliment critique',
      description: 'Stock restant: 150 kg — Commande urgente requise',
      priorite: AlertPriority.critical,
      tempsEcoule: 'il y a 2h',
      type: 'Stock',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AlertModel(
      id: '2',
      titre: 'Température élevée Bât. A',
      description: 'Relevé de 32°C — Seuil critique à 30°C',
      priorite: AlertPriority.warning,
      tempsEcoule: 'il y a 3h',
      type: 'Température',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AlertModel(
      id: '3',
      titre: 'Mortalité anormale Lot B',
      description: '12 sujets morts en 24h',
      priorite: AlertPriority.warning,
      tempsEcoule: 'il y a 5h',
      type: 'Mortalité',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AlertModel(
      id: '4',
      titre: 'Vaccination terminée',
      description: 'Campagne complétée avec succès',
      priorite: AlertPriority.resolved,
      tempsEcoule: 'hier',
      type: 'Vaccination',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      traitee: true,
    ),
  ];

  static final List<InterventionModel> interventions = [
    InterventionModel(
      id: '1',
      type: InterventionType.vaccination,
      date: DateTime(2025, 4, 2, 8, 0),
      description: 'Vaccination Newcastle – 1ère dose',
      responsable: 'Dr. Dupont',
      lotId: 'lotA',
      lotNom: 'Lot A',
      createdAt: DateTime(2025, 4, 2),
      createdBy: 'vet1',
    ),
    InterventionModel(
      id: '2',
      type: InterventionType.nettoyage,
      date: DateTime(2025, 4, 5, 10, 30),
      description: 'Nettoyage complet bâtiment',
      responsable: 'Tech. Mohamed',
      lotId: 'lotB',
      lotNom: 'Lot B',
      createdAt: DateTime(2025, 4, 5),
      createdBy: 'tech1',
    ),
    InterventionModel(
      id: '3',
      type: InterventionType.litiere,
      date: DateTime(2025, 4, 8, 7, 45),
      description: 'Remplacement litière écologique',
      responsable: 'Resp. Ali',
      lotId: 'lotA',
      lotNom: 'Lot A',
      createdAt: DateTime(2025, 4, 8),
      createdBy: 'resp1',
      produits: 'Palmes sèches broyées',
      duree: '4h',
    ),
  ];
}
