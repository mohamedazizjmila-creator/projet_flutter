// lib/screens/profile/profile_screen.dart
import 'package:avibiotech_mobile/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _offlineMode = false;
  bool _notificationsEnabled = true;
  late AnimationController _animationController;

  int _nbLotsAssignes = 0;
  int _nbInterventionsAujourdhui = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoading = true);
    try {
      final lots = await FirestoreService.getAllLots();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _nbLotsAssignes = lots.length;
        _nbInterventionsAujourdhui = 3;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Déconnexion',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MODALE À PROPOS AVEC LOGO SOTAVI
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo SOTAVI sans background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMain,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🐔',
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SOTAVI',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryMain,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Société Tunisienne d\'Aviculture',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.textHint.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(
                'AVIBIOTECH Mobile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Application de gestion avicole intelligente',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.textHint.withOpacity(0.3)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Tunisie',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.email_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'contact@sotavi.com',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '© 2025 SOTAVI - AVIBIOTECH',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textHint,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'FERMER',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ MODALE AIDE & SUPPORT AVEC LOGO SOTAVI
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo SOTAVI sans background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMain,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🐔',
                              style:
                                  TextStyle(fontSize: 35, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aide & Support',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.textHint.withOpacity(0.3)),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.article_outlined,
                title: 'Guide utilisateur',
                subtitle: 'Documentation complète',
                onTap: () {
                  // TODO: Ouvrir guide utilisateur
                  Navigator.pop(context);
                },
              ),
              _buildHelpItem(
                icon: Icons.phone_outlined,
                title: 'Service client',
                subtitle: '+216 XX XXX XXX',
                onTap: () {
                  // TODO: Appeler le service client
                },
              ),
              _buildHelpItem(
                icon: Icons.email_outlined,
                title: 'Support technique',
                subtitle: 'support@sotavi.com',
                onTap: () {
                  // TODO: Envoyer email
                },
              ),
              _buildHelpItem(
                icon: Icons.message_outlined,
                title: 'Chat en ligne',
                subtitle: 'Disponible 9h-17h',
                onTap: () {
                  // TODO: Ouvrir chat
                },
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.textHint.withOpacity(0.3)),
              const SizedBox(height: 12),
              CustomButton(
                label: 'FERMER',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryMain.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryMain, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary, size: 20),
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userData = authProvider.userData;
    final userName = userData?.nom ?? authProvider.userEmail.split('@')[0];
    final userEmail = authProvider.userEmail;
    final userInitials = authProvider.userInitials;
    final userRole = authProvider.userRole;

    String roleLabel = 'Utilisateur';
    Color roleColor = AppTheme.textSecondary;
    switch (userRole) {
      case UserRole.admin:
        roleLabel = 'Administrateur';
        roleColor = AppTheme.error;
        break;
      case UserRole.responsable:
        roleLabel = 'Responsable d\'élevage';
        roleColor = AppTheme.info;
        break;
      case UserRole.technicien:
        roleLabel = 'Technicien terrain';
        roleColor = AppTheme.success;
        break;
      case UserRole.veterinaire:
        roleLabel = 'Vétérinaire';
        roleColor = AppTheme.warning;
        break;
      default:
        roleLabel = 'Utilisateur';
        roleColor = AppTheme.textSecondary;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(
                initials: userInitials,
                name: userName,
                email: userEmail,
                role: roleLabel,
                roleColor: roleColor,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: '🐔',
                            value: _isLoading ? '...' : '$_nbLotsAssignes',
                            label: 'Lots assignés',
                            color: AppTheme.primaryMain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: '📋',
                            value: _isLoading
                                ? '...'
                                : '$_nbInterventionsAujourdhui',
                            label: 'Interventions\naujourd\'hui',
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: Column(
                        children: [
                          _SettingRow(
                            icon: Icons.wifi_off_rounded,
                            title: 'Mode hors-ligne',
                            subtitle: 'Saisie sans connexion internet',
                            trailing: Switch(
                              value: _offlineMode,
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                setState(() => _offlineMode = v);
                              },
                              activeColor: AppTheme.primaryMain,
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingRow(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            subtitle: 'Alertes et rappels',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                setState(() => _notificationsEnabled = v);
                              },
                              activeColor: AppTheme.primaryMain,
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingRow(
                            icon: Icons.settings_outlined,
                            title: 'Paramètres',
                            subtitle: 'Notifications, langue, apparence',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          _SettingRow(
                            icon: Icons.help_outline_rounded,
                            title: 'Aide & Support',
                            subtitle: 'Guide utilisateur, contact',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            onTap: _showHelpDialog,
                          ),
                          const Divider(height: 1),
                          _SettingRow(
                            icon: Icons.info_outline_rounded,
                            title: 'À propos',
                            subtitle: 'v1.0.0 — AVIBIOTECH',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            onTap: _showAboutDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showLogoutDialog,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppTheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'DÉCONNEXION',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Version 1.0.0',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String initials,
    required String name,
    required String email,
    required String role,
    required Color roleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryDark, AppTheme.primaryMain],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roleColor.withOpacity(0.5)),
                ),
                child: Text(
                  role,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// INFO CARD WIDGET
// ============================================================================

class _InfoCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SETTING ROW WIDGET
// ============================================================================

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryMain, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
