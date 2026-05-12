// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../production/production_screen.dart';
import '../alerts/alerts_screen.dart';
import '../interventions/interventions_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // ✅ Données dynamiques
  bool _isLoading = true;
  int _lotsActifs = 0;
  double _stockTotal = 0;
  int _alertesCount = 0;
  String _userName = 'Utilisateur';
  String _userRole = 'Utilisateur';
  String _userInitials = 'U';

  // Pour la saisie rapide (dynamique aussi)
  String _selectedLotId = '';
  final _mortaliteController = TextEditingController();
  final _consommationController = TextEditingController();
  bool _isSaving = false;
  List<LotModel> _lots = [];

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  // Liste statique pour l'affichage (sera remplacée par les données dynamiques)
  final List<String> _staticLots = [
    'Lot A - 4800 sujets',
    'Lot B - 3000 sujets',
    'Lot C - 2500 sujets',
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
    );
    _headerAnim.forward();

    // ✅ Charger les données dynamiques
    _loadUserData();
    _loadDashboardData();
  }

  // ✅ Charger les infos utilisateur
  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserData(authProvider.user!.uid);
    setState(() {
      _userName = authProvider.userName.split(' ')[0];
      _userInitials = authProvider.userInitials;
      switch (authProvider.userRole) {
        case UserRole.admin:
          _userRole = 'Administrateur';
          break;
        case UserRole.responsable:
          _userRole = 'Responsable d\'élevage';
          break;
        case UserRole.technicien:
          _userRole = 'Technicien terrain';
          break;
        case UserRole.veterinaire:
          _userRole = 'Vétérinaire';
          break;
        default:
          _userRole = 'Utilisateur';
      }
    });
  }

  // ✅ Charger les statistiques dashboard
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await FirestoreService.getDashboardStats();
      final allLots = await FirestoreService.getAllLots();

      _lots = allLots.where((l) => l.statut == LotStatus.actif).toList();
      _lotsActifs = _lots.length;
      _stockTotal = stats['stockTotal'] ?? 0;
      _alertesCount = stats['alertesCount'] ?? 0;

      // Sélectionner le premier lot pour la saisie rapide
      if (_lots.isNotEmpty && _selectedLotId.isEmpty) {
        _selectedLotId = _lots.first.id;
      }
    } catch (e) {
      print('Erreur chargement dashboard: $e');
    }
    setState(() => _isLoading = false);
  }

  // ✅ Sauvegarde rapide
  Future<void> _handleSave() async {
    if (_selectedLotId.isEmpty) {
      _showSnackBar('Veuillez sélectionner un lot');
      return;
    }
    if (_mortaliteController.text.isEmpty) {
      _showSnackBar('Veuillez saisir la mortalité');
      return;
    }
    if (_consommationController.text.isEmpty) {
      _showSnackBar('Veuillez saisir la consommation');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));

    _mortaliteController.clear();
    _consommationController.clear();
    setState(() => _isSaving = false);

    _showSnackBar('Production enregistrée !', isError: false);
    await _loadDashboardData();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPhotoDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📸', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Prendre une photo',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez une photo d\'observation terrain',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Ouvrir l\'appareil photo',
              onPressed: () => Navigator.pop(context),
              icon: Icons.camera_alt,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler',
                  style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Enregistré !',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Les données de production ont été sauvegardées avec succès.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              CustomButton(
                  label: 'OK', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _mortaliteController.dispose();
    _consommationController.dispose();
    super.dispose();
  }

  // ==================== BUILD WELCOME BANNER (DYNAMIQUE) ====================
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $_userName 👋',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _userRole,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🐔', style: TextStyle(fontSize: 32)),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi'
    ];
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${days[now.weekday % 7]} ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ==================== BUILD STAT CARDS (DYNAMIQUE) ====================
  Widget _buildStatCards() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '📊 VUE D\'ENSEMBLE'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'LOTS ACTIFS',
                value: '$_lotsActifs',
                icon: Icons.agriculture,
                color: AppTheme.primaryMain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'STOCK ALIMENT',
                value: '${_stockTotal.toStringAsFixed(0)} kg',
                icon: Icons.grass,
                color: AppTheme.accentGold,
                progress:
                    _stockTotal > 0 ? (_stockTotal / 3000).clamp(0.0, 1.0) : 0,
                subtitle:
                    '${(_stockTotal / 3000 * 100).toStringAsFixed(0)}% restant',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'MORTALITÉ',
                value: '0.2%',
                icon: Icons.trending_down,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'ALERTES',
                value: '$_alertesCount',
                icon: Icons.notifications_active,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== BUILD QUICK INPUT CARD (DYNAMIQUE) ====================
  Widget _buildQuickInputCard() {
    // Si pas de lots, afficher un message
    if (_lots.isEmpty && !_isLoading) {
      return CustomCard(
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('Aucun lot actif disponible'),
          ),
        ),
      );
    }

    // Construction des items du dropdown dynamique
    final dropdownItems = _lots.map((lot) {
      return DropdownMenuItem<String>(
        value: lot.id,
        child: Text('${lot.nom} - ${lot.nbInitial} sujets'),
      );
    }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'SAISIE RAPIDE',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lot selector (dynamique)
          DropdownButtonFormField<String>(
            value: _selectedLotId.isNotEmpty ? _selectedLotId : null,
            hint: const Text('Sélectionner un lot'),
            decoration: const InputDecoration(
              labelText: 'Sélectionner un lot',
              prefixIcon: Icon(Icons.layers_outlined,
                  color: AppTheme.primaryMain, size: 20),
            ),
            items: dropdownItems,
            onChanged: (v) => setState(() => _selectedLotId = v!),
            style:
                GoogleFonts.poppins(fontSize: 13, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _mortaliteController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mortalité du jour',
              prefixIcon:
                  Icon(Icons.trending_down, color: AppTheme.error, size: 20),
              suffixText: 'sujets',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _consommationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Consommation alimentaire',
              prefixIcon: Icon(Icons.grass_outlined,
                  color: AppTheme.accentGold, size: 20),
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showPhotoDialog();
                  },
                  icon: const Text('📸', style: TextStyle(fontSize: 16)),
                  label: Text('Photo',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppTheme.primaryMain)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryMain),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  label: 'ENREGISTRER',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ALERTS CARD (DYNAMIQUE) ====================
  Widget _buildAlertsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '🔴 ALERTES EN COURS',
            actionText: 'Voir tout',
            onAction: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AlertsScreen())),
          ),
          const SizedBox(height: 12),
          if (_alertesCount == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Aucune alerte pour le moment')),
            )
          else
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.warning, color: AppTheme.warning),
                  title: const Text('Stock aliment faible'),
                  subtitle:
                      Text('${_stockTotal.toStringAsFixed(0)} kg restants'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AlertsScreen())),
                ),
                if (_alertesCount > 1)
                  ListTile(
                    leading: const Icon(Icons.notifications_active,
                        color: AppTheme.error),
                    title: const Text('Plusieurs alertes actives'),
                    subtitle: Text('$_alertesCount alertes non traitées'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AlertsScreen())),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ==================== BUILD INTERVENTIONS CARD ====================
  Widget _buildInterventionsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '📋 INTERVENTIONS AUJOURD\'HUI',
            actionText: 'Voir tout',
            onAction: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const InterventionsScreen())),
          ),
          const SizedBox(height: 12),
          const _TimelineItem(
            heure: '08:00',
            description: 'Vaccination (Lot A)',
            responsable: 'Dr. Dupont',
            isFirst: true,
          ),
          const _TimelineItem(
            heure: '10:30',
            description: 'Nettoyage (Lot B)',
            responsable: 'Tech. Mohamed',
            isFirst: false,
          ),
          const _TimelineItem(
            heure: '14:00',
            description: 'Changement litière (Lot A)',
            responsable: 'Resp. Ali',
            isFirst: false,
          ),
        ],
      ),
    );
  }

  // ==================== BUILD BOTTOM NAV ====================
  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Accueil'},
      {'icon': Icons.edit_note_rounded, 'label': 'Saisie'},
      {'icon': Icons.notifications_rounded, 'label': 'Alertes'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.secondary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i]['icon'] as IconData,
                          color: isActive
                              ? AppTheme.secondary
                              : AppTheme.textSecondary,
                          size: 24),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? AppTheme.secondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ==================== BUILD DASHBOARD BODY ====================
  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _headerFade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(),
              const SizedBox(height: 20),
              _buildStatCards(),
              const SizedBox(height: 20),
              _buildQuickInputCard(),
              const SizedBox(height: 20),
              _buildAlertsCard(),
              const SizedBox(height: 20),
              _buildInterventionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardBody(),
      const ProductionScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMain,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'SOTAVI',
          style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 4),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen())),
              ),
              if (_alertesCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '$_alertesCount',
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: Center(
              child: Text(
                _userInitials,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

// ============================================================================
// TIMELINE ITEM WIDGET (inchangé)
// ============================================================================

class _TimelineItem extends StatelessWidget {
  final String heure;
  final String description;
  final String responsable;
  final bool isFirst;

  const _TimelineItem({
    required this.heure,
    required this.description,
    required this.responsable,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(width: 2, height: 12, color: AppTheme.dividerColor),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryMain,
                border: Border.all(color: AppTheme.primaryLight, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isFirst ? 12 : 0),
            child: Row(
              children: [
                Text(heure,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryMain)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                      Text(responsable,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
