// lib/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/interventions/interventions_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import 'package:flutter/services.dart';
import '../models/app_models.dart'; // ✅ AJOUTER CET IMPORT pour UserRole

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName;
    final userEmail = authProvider.userEmail;
    final userInitials = authProvider.userInitials;
    final userRole = authProvider.userRole;

    // Récupérer le badge du rôle pour l'affichage
    final roleBadge = _getRoleBadge(userRole);

    return Drawer(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // ========== HEADER DYNAMIQUE ==========
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.primaryMain],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar dynamique
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // User info dynamique
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      // Badge rôle dynamique
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleBadge.color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: roleBadge.color.withOpacity(0.5)),
                        ),
                        child: Text(
                          roleBadge.label,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: roleBadge.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ========== MENU ITEMS ==========
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Tableau de bord',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.agriculture,
                  label: 'Mes lots',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Naviguer vers LotsScreen
                  },
                ),
                _DrawerItem(
                  icon: Icons.edit_note_rounded,
                  label: 'Interventions',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InterventionsScreen(),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_rounded,
                  label: 'Alertes',
                  badge: '3',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AlertsScreen(),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistiques',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Naviguer vers StatsScreen
                  },
                ),
                const Divider(height: 24, thickness: 1),
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Mon profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Paramètres',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Naviguer vers SettingsScreen
                  },
                ),
                const Divider(height: 24, thickness: 1),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Déconnexion',
                  isDestructive: true,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    // Déconnexion via AuthProvider
                    final auth =
                        Provider.of<AuthProvider>(context, listen: false);
                    auth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // ========== FOOTER ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(thickness: 1),
                const SizedBox(height: 12),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '© 2025 AVIBIOTECH',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  RoleBadge _getRoleBadge(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return RoleBadge(label: 'Administrateur', color: AppTheme.error);
      case UserRole.responsable:
        return RoleBadge(label: 'Responsable d\'élevage', color: AppTheme.info);
      case UserRole.technicien:
        return RoleBadge(label: 'Technicien terrain', color: AppTheme.success);
      case UserRole.veterinaire:
        return RoleBadge(label: 'Vétérinaire', color: AppTheme.warning);
      default:
        return RoleBadge(label: 'Utilisateur', color: AppTheme.textSecondary);
    }
  }
}

class RoleBadge {
  final String label;
  final Color color;
  RoleBadge({required this.label, required this.color});
}

// ============================================================================
// WIDGET ITEM DU MENU
// ============================================================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;
  final String? badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.error.withOpacity(0.1)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive ? AppTheme.error : AppTheme.primaryMain,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      trailing: badge != null
          ? Container(
              width: 28,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
