// lib/screens/interventions/interventions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/custom_widgets.dart';

class InterventionsScreen extends StatefulWidget {
  const InterventionsScreen({super.key});

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  String _searchQuery = '';
  late List<InterventionModel> _interventions;

  @override
  void initState() {
    super.initState();
    _interventions = List.from(AppData.interventions);
  }

  List<InterventionModel> get _filtered => _interventions
      .where((i) =>
          i.type.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          i.lotNom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.responsable.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _showAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddInterventionDialog(
        onSave: (intervention) {
          setState(() => _interventions.insert(0, intervention));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Intervention "${intervention.type.displayName}" ajoutée'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMain,
        elevation: 0,
        title: Text(
          'Interventions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 26),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddDialog();
        },
        backgroundColor: AppTheme.secondary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Rechercher une intervention...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primaryMain,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune intervention trouvée',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Appuyez sur + pour en ajouter',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 250 + index * 60),
                        curve: Curves.easeOut,
                        builder: (_, v, child) => Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, (1 - v) * 16),
                            child: child,
                          ),
                        ),
                        child: _InterventionItem(intervention: item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INTERVENTION ITEM WIDGET
// ============================================================================

class _InterventionItem extends StatelessWidget {
  final InterventionModel intervention;

  const _InterventionItem({required this.intervention});

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return '💉';
      case 'traitement médical':
        return '💊';
      case 'traitement':
        return '💊';
      case 'nettoyage':
        return '🧹';
      case 'désinfection':
        return '🧴';
      case 'changement litière':
        return '🌿';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMain.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getTypeIcon(intervention.type.displayName),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TypeBadge(type: intervention.type.displayName),
                      const SizedBox(width: 8),
                      Text(
                        intervention.lotNom,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intervention.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        intervention.responsable,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${intervention.date.day.toString().padLeft(2, '0')}/${intervention.date.month.toString().padLeft(2, '0')}/${intervention.date.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                intervention.heureAffichee,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ADD INTERVENTION DIALOG
// ============================================================================

class _AddInterventionDialog extends StatefulWidget {
  final void Function(InterventionModel) onSave;

  const _AddInterventionDialog({required this.onSave});

  @override
  State<_AddInterventionDialog> createState() => _AddInterventionDialogState();
}

class _AddInterventionDialogState extends State<_AddInterventionDialog> {
  String _selectedLot = 'Lot A';
  String _selectedType = 'Vaccination';
  DateTime _selectedDate = DateTime.now();
  final _descController = TextEditingController();
  final _respController = TextEditingController();

  final List<String> _lots = ['Lot A', 'Lot B', 'Lot C'];
  final List<String> _types = [
    'Vaccination',
    'Traitement médical',
    'Nettoyage',
    'Désinfection',
    'Changement de litière'
  ];

  @override
  void dispose() {
    _descController.dispose();
    _respController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('➕', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nouvelle Intervention',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lot selector
              DropdownButtonFormField<String>(
                initialValue: _selectedLot,
                decoration: const InputDecoration(
                  labelText: 'Lot concerné',
                  prefixIcon: Icon(Icons.agriculture, size: 20),
                ),
                items: _lots.map((l) {
                  return DropdownMenuItem(value: l, child: Text(l));
                }).toList(),
                onChanged: (v) => setState(() => _selectedLot = v!),
              ),
              const SizedBox(height: 12),

              // Type selector
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Type d'intervention",
                  prefixIcon: Icon(Icons.label_outline, size: 20),
                ),
                items: _types.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 12),

              // Date picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppTheme.textHint.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppTheme.primaryMain,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description field
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description détaillée de l\'intervention...',
                ),
              ),
              const SizedBox(height: 12),

              // Responsable field
              TextField(
                controller: _respController,
                decoration: const InputDecoration(
                  labelText: 'Responsable',
                  hintText: 'Nom de la personne responsable',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppTheme.textHint.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Enregistrer',
                      onPressed: () {
                        final typeEnum = InterventionType.values.firstWhere(
                          (e) => e.displayName == _selectedType,
                          orElse: () => InterventionType.vaccination,
                        );

                        final intervention = InterventionModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          type: typeEnum,
                          date: _selectedDate,
                          description: _descController.text.isNotEmpty
                              ? _descController.text
                              : '$_selectedType - Intervention de routine',
                          responsable: _respController.text.isNotEmpty
                              ? _respController.text
                              : 'Technicien',
                          lotId: 'lot${_selectedLot.replaceAll(' ', '')}',
                          lotNom: _selectedLot,
                          createdAt: DateTime.now(),
                          createdBy: 'current_user',
                        );

                        widget.onSave(intervention);
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
