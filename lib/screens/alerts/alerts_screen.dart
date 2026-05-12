// lib/screens/alerts/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/custom_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late List<AlertModel> _alerts;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _alerts = List.from(AppData.alertes);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<AlertModel> get _criticalAlerts => _alerts
      .where((a) => a.priorite == AlertPriority.critical && !a.traitee)
      .toList();

  List<AlertModel> get _warningAlerts => _alerts
      .where((a) => a.priorite == AlertPriority.warning && !a.traitee)
      .toList();

  List<AlertModel> get _resolvedAlerts =>
      _alerts.where((a) => a.traitee).toList();

  List<AlertModel> get _currentList {
    switch (_selectedTab) {
      case 0:
        return _criticalAlerts;
      case 1:
        return _warningAlerts;
      case 2:
        return _resolvedAlerts;
      default:
        return [];
    }
  }

  void _handleTraiter(AlertModel alert) {
    HapticFeedback.mediumImpact();
    setState(() {
      alert.traitee = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alerte "${alert.titre}" marquée comme traitée',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleResolvedAll() {
    if (_currentList.isEmpty) return;

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Marquer toutes comme traitées',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir marquer toutes les alertes comme traitées ?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (var alert in _currentList) {
                  alert.traitee = true;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Toutes les alertes ont été marquées comme traitées'),
                  backgroundColor: AppTheme.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Confirmer',
              style: GoogleFonts.poppins(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalActive = _criticalAlerts.length + _warningAlerts.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMain,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alertes',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalActive',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          if (_selectedTab != 2 && _currentList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              onPressed: _handleResolvedAll,
              tooltip: 'Tout marquer comme traité',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _currentList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _currentList.length,
                      itemBuilder: (context, index) {
                        final alert = _currentList[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + index * 80),
                          curve: Curves.easeOut,
                          builder: (_, opacity, child) => Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(0, (1 - opacity) * 20),
                              child: child,
                            ),
                          ),
                          child: AlertCard(
                            alert: alert,
                            onTraiter: alert.traitee
                                ? null
                                : () => _handleTraiter(alert),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': '🔴', 'label': 'Critiques', 'count': _criticalAlerts.length},
      {'icon': '🟠', 'label': 'Alertes', 'count': _warningAlerts.length},
      {'icon': '🟢', 'label': 'Résolues', 'count': _resolvedAlerts.length},
    ];

    return Container(
      color: AppTheme.primaryMain,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = _selectedTab == i;
            final String icon =
                tabs[i]['icon'] as String; // ← Conversion explicite
            final String label =
                tabs[i]['label'] as String; // ← Conversion explicite
            final int count = tabs[i]['count'] as int; // ← Conversion explicite

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppTheme.primaryMain
                              : Colors.white.withOpacity(0.85),
                        ),
                      ),
                      Text(
                        '($count)',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppTheme.primaryMain
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: const Text('🎉', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 2
                ? 'Aucune alerte résolue'
                : 'Aucune alerte dans cette catégorie',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTab == 2
                ? 'Les alertes traitées apparaîtront ici'
                : 'Tout est sous contrôle ! 🐔',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
