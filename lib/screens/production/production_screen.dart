// lib/screens/production/production_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../services/firestore_service.dart';
import '../../models/app_models.dart';

class ProductionScreen extends StatefulWidget {
  final String? initialLotId;
  const ProductionScreen({super.key, this.initialLotId});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final _mortaliteController = TextEditingController();
  final _consommationController = TextEditingController();
  final _oeufsController = TextEditingController();
  final _commentaireController = TextEditingController();
  bool _hasPhoto = false;
  bool _isValidating = false;
  bool _isLoading = true;

  // ✅ Données dynamiques
  List<LotModel> _lots = [];
  LotModel? _selectedLot;
  StockModel? _stockAliment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _lots = await FirestoreService.getAllLots();
      _lots = _lots.where((l) => l.statut == LotStatus.actif).toList();

      final stocks = await FirestoreService.getAllStocks();
      _stockAliment = stocks.firstWhere(
        (s) => s.nom.contains('Aliment'),
        orElse: () => stocks.isNotEmpty ? stocks.first : null as StockModel,
      );

      if (widget.initialLotId != null &&
          _lots.any((l) => l.id == widget.initialLotId)) {
        _selectedLot = _lots.firstWhere((l) => l.id == widget.initialLotId);
      } else if (_lots.isNotEmpty) {
        _selectedLot = _lots.first;
      }
    } catch (e) {
      print('Erreur chargement production: $e');
    }
    setState(() => _isLoading = false);
  }

  bool get _isPondeuse {
    return _selectedLot?.typeVolailles.toLowerCase().contains('pondeuse') ??
        false;
  }

  int get _joursElevage {
    if (_selectedLot == null) return 0;
    return DateTime.now().difference(_selectedLot!.dateArrivee).inDays;
  }

  Future<void> _handleValidate() async {
    if (_selectedLot == null) {
      _showErrorDialog('Veuillez sélectionner un lot');
      return;
    }
    if (_mortaliteController.text.isEmpty) {
      _showErrorDialog('Veuillez saisir la mortalité');
      return;
    }
    if (_consommationController.text.isEmpty) {
      _showErrorDialog('Veuillez saisir la consommation alimentaire');
      return;
    }
    if (_isPondeuse && _oeufsController.text.isEmpty) {
      _showErrorDialog('Veuillez saisir la production d\'œufs');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isValidating = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isValidating = false);

    if (mounted) {
      _showSuccessDialog();
      _mortaliteController.clear();
      _consommationController.clear();
      _oeufsController.clear();
      _commentaireController.clear();
      setState(() => _hasPhoto = false);
      await _loadData();
    }
  }

  void _showErrorDialog(String message) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Champ manquant',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              CustomButton(
                  label: 'OK', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: const Text('✅', style: TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: 12),
              Text('Production Validée !',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(
                  'Les données du lot ${_selectedLot?.nom} — Jour $_joursElevage ont été enregistrées avec succès.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              CustomButton(
                  label: 'PARFAIT', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📸', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Prendre une photo',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('Ajoutez une photo d\'observation terrain',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Ouvrir l\'appareil photo',
              onPressed: () {
                setState(() => _hasPhoto = true);
                Navigator.pop(context);
              },
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

  @override
  void dispose() {
    _mortaliteController.dispose();
    _consommationController.dispose();
    _oeufsController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMain,
        elevation: 0,
        title: Text('Production – ${_selectedLot?.nom ?? 'Sélectionner'}',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Lot selector (dynamique)
            if (_lots.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonFormField<LotModel>(
                  value: _selectedLot,
                  decoration: InputDecoration(
                    labelText: 'Changer de lot',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // ← Enlever 'const'
                    ),
                  ),
                  items: _lots.map((lot) {
                    return DropdownMenuItem(
                      value: lot,
                      child: Text('${lot.nom} - ${lot.nbInitial} sujets'),
                    );
                  }).toList(),
                  onChanged: (lot) => setState(() => _selectedLot = lot),
                ),
              ),

            _buildLotInfo(),
            const SizedBox(height: 16),
            _buildMortaliteCard(),
            const SizedBox(height: 12),
            _buildConsommationCard(),
            const SizedBox(height: 12),
            if (_isPondeuse) _buildOeufsCard(),
            if (_isPondeuse) const SizedBox(height: 12),
            _buildPhotoSection(),
            const SizedBox(height: 12),
            _buildCommentaireSection(),
            const SizedBox(height: 12),
            _buildStockIndicator(),
            const SizedBox(height: 24),
            CustomButton(
              label: 'VALIDER',
              onPressed: _handleValidate,
              isLoading: _isValidating,
              icon: Icons.check_circle,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLotInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Text('🐔', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_selectedLot?.nom ?? 'Lot'} — ${_selectedLot?.batimentNom ?? 'Bâtiment'}',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('${_selectedLot?.nbInitial ?? 0} sujets',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Jour',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.white.withOpacity(0.7))),
              Text('$_joursElevage/42',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMortaliteCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Mortalité',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700))
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _mortaliteController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.error),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'sujets',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsommationCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🌾', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Consommation alimentaire',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700))
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _consommationController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryMain),
            decoration: InputDecoration(
              hintText: '0.0',
              suffixText: 'kg',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOeufsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🥚', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Production d\'œufs',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700))
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _oeufsController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'œufs',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return CustomCard(
      child: Column(
        children: [
          Row(children: [
            const Text('📸', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Photos',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('Optionnel',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppTheme.textSecondary))
          ]),
          const SizedBox(height: 12),
          if (!_hasPhoto)
            GestureDetector(
              onTap: _showPhotoDialog,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.primaryMain.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryMain.withOpacity(0.04),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppTheme.primaryMain, size: 24),
                      const SizedBox(height: 4),
                      Text('PRENDRE UNE PHOTO',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryMain)),
                    ],
                  ),
                ),
              ),
            )
          else
            Stack(
              children: [
                Container(
                    height: 120,
                    decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                        child: Text('📷', style: TextStyle(fontSize: 40)))),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _hasPhoto = false),
                    child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppTheme.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCommentaireSection() {
    return CustomCard(
      child: Column(
        children: [
          Row(children: [
            const Text('💬', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Commentaire',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary))
          ]),
          const SizedBox(height: 12),
          TextField(
              controller: _commentaireController,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Observations, remarques particulières...')),
        ],
      ),
    );
  }

  Widget _buildStockIndicator() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.3))),
      child: Row(
        children: [
          const Text('🌾', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Stock restant: ${_stockAliment?.quantite.toStringAsFixed(0) ?? 0} ${_stockAliment?.unite ?? 'kg'}',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(
                    'Autonomie estimée: ~${((_stockAliment?.quantite ?? 0) / 150).toStringAsFixed(0)} jours',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
