import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';

/// Accueil Acquéreur : mise en page alignée sur la maquette Figma.
/// Les annonces et compteurs proviennent exclusivement des repositories API.
class ProspectDashboardScreen extends ConsumerStatefulWidget {
  const ProspectDashboardScreen({super.key});

  @override
  ConsumerState<ProspectDashboardScreen> createState() =>
      _ProspectDashboardScreenState();
}

class _ProspectDashboardScreenState
    extends ConsumerState<ProspectDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(prospectDashboardProvider);
    final state = asyncState.valueOrNull;
    final user = ref.watch(authProvider).user;
    final reservations = state?.mesReservations ?? const <ReservationModel>[];
    final allItems = state?.catalogue ?? const <BienFoncierModel>[];
    final programmes = state?.programmes ?? const <ProgrammeFoncier>[];
    final searchTerm = _query.trim().toLowerCase();

    // La maquette présente des programmes et des parcelles individuelles.
    // Les lots d'un programme restent consultables depuis le détail du programme.
    final allAnnouncements = <_HomeAnnouncement>[
      for (final programme in programmes.where(
        (item) => (item.statut ?? '').trim().toUpperCase() == 'DISPONIBLE',
      ))
        _HomeAnnouncement.programme(
          programme,
          startingPrice: _startingPrice(programme, allItems),
        ),
      for (final bien in allItems.where(
        (item) => !_isLotBien(item) && _isAvailableStatus(item.statut),
      ))
        _HomeAnnouncement.bien(bien),
    ];

    final filteredAnnouncements = allAnnouncements.where((announcement) {
      if (searchTerm.isEmpty) return true;
      final searchable = announcement.searchText.toLowerCase();
      return searchable.contains(searchTerm);
    }).toList();
    final announcements = searchTerm.isEmpty
        ? filteredAnnouncements.take(4).toList()
        : filteredAnnouncements.take(10).toList();
    final hasPendingReservation = reservations.any(
      (r) => r.statut.toUpperCase() == 'EN_ATTENTE',
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.backgroundOffWhite,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async {
              await ref.read(prospectDashboardProvider.notifier).refresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    user: user,
                    controller: _searchController,
                    hasUpdates: hasPendingReservation,
                    onQueryChanged: (value) => setState(() => _query = value),
                    onSearchSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onNotificationsTap: () => context.go('/prospect/reservations'),
                    onLogout: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HeroBanner(
                    onExplore: () => context.go('/prospect/cites'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstructionCallout(
                    onTap: () => _showConstructionInfo(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      16,
                      AppSpacing.pageHorizontal,
                      18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            searchTerm.isEmpty
                                ? 'Annonces récentes'
                                : 'Résultats de recherche',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.accentCoral,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/prospect/cites'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(44, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Tout voir'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (asyncState.hasError)
                  SliverToBoxAdapter(
                    child: _InlineFeedback(
                      icon: Icons.cloud_off_outlined,
                      title: 'Impossible de charger les annonces',
                      message: 'Vérifiez votre connexion puis réessayez.',
                      actionLabel: 'Réessayer',
                      onAction: () =>
                          ref.read(prospectDashboardProvider.notifier).refresh(),
                    ),
                  )
                else if (asyncState.isLoading && state == null)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOcre,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  )
                else if (announcements.isEmpty)
                  SliverToBoxAdapter(
                    child: _InlineFeedback(
                      icon: Icons.location_searching_rounded,
                      title: searchTerm.isEmpty
                          ? 'Aucune annonce pour le moment'
                          : 'Aucun résultat',
                      message: searchTerm.isEmpty
                          ? 'Les biens publiés apparaîtront ici dès qu’ils seront disponibles.'
                          : 'Essayez une autre référence, un programme ou une localité.',
                      actionLabel: searchTerm.isEmpty ? 'Actualiser' : 'Effacer',
                      onAction: () {
                        if (searchTerm.isNotEmpty) {
                          _searchController.clear();
                          setState(() => _query = '');
                        } else {
                          ref.read(prospectDashboardProvider.notifier).refresh();
                        }
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      0,
                      AppSpacing.pageHorizontal,
                      26,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _AnnouncementCard(
                            announcement: announcements[index],
                            onTap: () => _openAnnouncement(context, announcements[index]),
                          ),
                        ),
                        childCount: announcements.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAnnouncement(BuildContext context, _HomeAnnouncement announcement) {
    final programme = announcement.programme;
    if (programme != null) {
      context.push('/prospect/programmes/${programme.id}');
      return;
    }
    context.go('/prospect/parcelles');
  }

  double? _startingPrice(
    ProgrammeFoncier programme,
    List<BienFoncierModel> catalogue,
  ) {
    final prices = catalogue.where((bien) {
      final belongsToProgramme = bien.programmeId == programme.id ||
          (bien.programmeNom != null &&
              bien.programmeNom!.trim().toLowerCase() == programme.nom.trim().toLowerCase());
      final isLot = _isLotBien(bien);
      final available = _isAvailableStatus(bien.statut);
      return belongsToProgramme && isLot && available && bien.prix > 0;
    }).map((bien) => bien.prix).toList();
    if (prices.isEmpty) return null;
    prices.sort();
    return prices.first;
  }

  void _showConstructionInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.constructionMint,
                borderRadius: AppRadius.radiusLg,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: AppColors.constructionGreen,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text('Construire sur mon terrain', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Commencez par retrouver votre terrain. Vous pourrez ensuite choisir un modèle de maison compatible et préparer votre demande de construction.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.go('/prospect/parcelles');
                },
                child: const Text('Voir les parcelles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.controller,
    required this.hasUpdates,
    required this.onQueryChanged,
    required this.onSearchSubmitted,
    required this.onNotificationsTap,
    required this.onLogout,
  });

  final AuthUser? user;
  final TextEditingController controller;
  final bool hasUpdates;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onNotificationsTap;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        8,
        AppSpacing.pageHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _FoncierBrandMark(),
              const Spacer(),
              _CircleAction(
                icon: Icons.notifications_none_rounded,
                showDot: hasUpdates,
                tooltip: 'Consulter mes réservations',
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                tooltip: 'Mon compte',
                offset: const Offset(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusLg,
                ),
                onSelected: (value) async {
                  if (value == 'logout') await onLogout();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : 'Mon compte',
                          style: AppTextStyles.h4,
                        ),
                        if (user?.telephone.isNotEmpty == true)
                          Text(user!.telephone, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded,
                            color: AppColors.errorRed, size: 18),
                        SizedBox(width: 8),
                        Text('Se déconnecter'),
                      ],
                    ),
                  ),
                ],
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryBlueAnthracite,
                  child: Text(
                    _initials(user),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user?.prenom.isNotEmpty == true
                ? 'Bonjour, ${user!.prenom}'
                : 'Bonjour',
            style: AppTextStyles.homeGreeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 47,
            child: TextField(
              controller: controller,
              onChanged: onQueryChanged,
              onSubmitted: onSearchSubmitted,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlueAnthracite,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un programme, une parcelle...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.searchIcon,
                  size: 22,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(
                    color: AppColors.primaryOcre,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 27),
        ],
      ),
    );
  }

  String _initials(AuthUser? user) {
    final first = user?.prenom.isNotEmpty == true ? user!.prenom[0] : '';
    final last = user?.nom.isNotEmpty == true ? user!.nom[0] : '';
    final initials = '$first$last'.trim().toUpperCase();
    return initials.isEmpty ? 'A' : initials;
  }
}

class _FoncierBrandMark extends StatelessWidget {
  const _FoncierBrandMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 54,
      height: 42,
      child: CustomPaint(painter: _FoncierBrandMarkPainter()),
    );
  }
}

/// Version compacte du symbole officiel : bâtiments posés sur des parcelles.
class _FoncierBrandMarkPainter extends CustomPainter {
  const _FoncierBrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 54;
    final sy = size.height / 42;
    canvas.save();
    canvas.scale(sx, sy);

    final parcelPaint = Paint()
      ..color = AppColors.brandGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final parcel = Path()
      ..moveTo(2, 27)
      ..lineTo(27, 15)
      ..lineTo(52, 27)
      ..lineTo(27, 39)
      ..close();
    canvas.drawPath(parcel, parcelPaint);

    final parcelLines = Paint()
      ..color = AppColors.brandGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final lineOne = Path()
      ..moveTo(9, 27)
      ..lineTo(27, 18)
      ..lineTo(27, 34);
    final lineTwo = Path()
      ..moveTo(45, 27)
      ..lineTo(27, 18)
      ..moveTo(27, 34)
      ..lineTo(45, 27);
    canvas.drawPath(lineOne, parcelLines);
    canvas.drawPath(lineTwo, parcelLines);
    canvas.drawLine(const Offset(16, 30), const Offset(27, 35), parcelLines);
    canvas.drawLine(const Offset(38, 30), const Offset(27, 35), parcelLines);

    void building({
      required Path outline,
      required Color color,
      required Rect body,
      required List<Rect> windows,
    }) {
      final fill = Paint()..color = color;
      canvas.drawPath(outline, fill);
      canvas.drawRect(body, Paint()..color = color.withOpacity(0.9));
      final windowPaint = Paint()..color = AppColors.white;
      for (final window in windows) {
        canvas.drawRect(window, windowPaint);
      }
    }

    // Petit bâtiment arrière gauche.
    building(
      outline: Path()
        ..moveTo(13, 14)
        ..lineTo(19, 10)
        ..lineTo(25, 14)
        ..lineTo(25, 25)
        ..lineTo(13, 25)
        ..close(),
      color: AppColors.brandGreen,
      body: const Rect.fromLTWH(13, 14, 12, 11),
      windows: const [Rect.fromLTWH(16, 16, 2, 3), Rect.fromLTWH(20, 16, 2, 3)],
    );

    // Bâtiment foncé à droite.
    building(
      outline: Path()
        ..moveTo(29, 8)
        ..lineTo(35, 4)
        ..lineTo(41, 8)
        ..lineTo(41, 23)
        ..lineTo(29, 23)
        ..close(),
      color: AppColors.primaryBlueAnthracite,
      body: const Rect.fromLTWH(29, 8, 12, 15),
      windows: const [Rect.fromLTWH(32, 11, 2, 3), Rect.fromLTWH(36, 11, 2, 3)],
    );

    // Maison mise en avant au premier plan.
    final house = Path()
      ..moveTo(20, 18)
      ..lineTo(27, 13)
      ..lineTo(34, 18)
      ..lineTo(34, 29)
      ..lineTo(20, 29)
      ..close();
    canvas.drawPath(house, Paint()..color = AppColors.brandGold);
    canvas.drawPath(
      Path()
        ..moveTo(20, 18)
        ..lineTo(27, 13)
        ..lineTo(34, 18),
      Paint()
        ..color = AppColors.brandGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 22, 4, 7),
        const Radius.circular(0.7),
      ),
      Paint()..color = AppColors.primaryBlueAnthracite,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoncierBrandMarkPainter oldDelegate) => false;
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderLight),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: AppColors.primaryBlueAnthracite, size: 20),
                if (showDot)
                  Positioned(
                    top: 7,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onExplore});
  final VoidCallback onExplore;

  // Illustration décorative de la bannière, indépendante des données métier.
  static const String _bannerImageUrl =
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueAnthracite,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.grey700.withOpacity(0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlueSoft, AppColors.primaryBlueAnthracite],
              ),
            ),
          ),
          Image.network(
            _bannerImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox.shrink(),
          ),
          const ColoredBox(color: AppColors.heroOverlay),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trouvez votre terrain idéal\npour votre projet',
                  style: AppTextStyles.heroTitle,
                ),
                const Spacer(),
                Text(
                  'Des parcelles, des lots et des programmes\nfonciers partout au Mali.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.96),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onExplore),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstructionCallout extends StatelessWidget {
  const _ConstructionCallout({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        24,
        12,
        0,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.constructionMint,
              borderRadius: AppRadius.radiusLg,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.home_outlined,
                    color: AppColors.constructionGreen,
                    size: 31,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    height: 6,
                    width: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOcre,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vous avez un terrain ?',
                  style: AppTextStyles.h4.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Construisons votre maison sur mesure',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 27,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOcre,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      minimumSize: const Size(168, 27),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Soumettre mon projet',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAnnouncement {
  const _HomeAnnouncement.programme(
    this.programme, {
    this.startingPrice,
  }) : bien = null;

  const _HomeAnnouncement.bien(this.bien)
      : programme = null,
        startingPrice = null;

  final ProgrammeFoncier? programme;
  final BienFoncierModel? bien;
  final double? startingPrice;

  bool get isProgramme => programme != null;

  String get searchText {
    final p = programme;
    if (p != null) {
      return [p.nom, p.lieu, p.description, p.societeNom]
          .whereType<String>()
          .join(' ');
    }
    final b = bien!;
    return [
      b.reference,
      b.numeroTitreFoncier,
      b.localisation,
      b.programmeNom,
      b.societeNom,
      b.superficie.toString(),
    ].whereType<String>().join(' ');
  }
}

bool _isLotBien(BienFoncierModel bien) {
  final type = (bien.typeBien ?? '').toUpperCase();
  return type.contains('LOT') ||
      bien.numeroLot != null ||
      bien.programmeId != null;
}

bool _isAvailableStatus(String status) {
  final normalized = status.trim().toUpperCase();
  return normalized == 'DISPONIBLE' ||
      normalized == 'LIBRE' ||
      normalized == 'AVAILABLE';
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, required this.onTap});
  final _HomeAnnouncement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final programme = announcement.programme;
    final bien = announcement.bien;
    final isProgramme = programme != null;

    final title = programme != null
        ? programme.nom
        : 'Parcelle ${_formatSurface(bien!.superficie)}';
    final subtitle = programme != null
        ? _firstNonEmpty([programme.lieu, programme.societeNom]) ??
            'Localisation non renseignée'
        : _firstNonEmpty([
              bien!.localisation,
              bien.societeNom,
              bien.reference.isNotEmpty ? 'Réf. ${bien.reference}' : null,
            ]) ??
            'Localisation non renseignée';
    final chipLabel = isProgramme ? 'Programme' : 'Parcelle ind.';
    final chipColor = isProgramme
        ? AppColors.successGreenSoft
        : AppColors.warningAmberSoft;
    final chipTextColor = isProgramme
        ? AppColors.successGreen
        : AppColors.primaryOcreDark;

    final displayedPrice = programme != null
        ? announcement.startingPrice
        : bien!.prix;
    final priceLabel = programme != null ? 'À partir de' : 'Prix net :';
    final fallbackInfo = programme?.totalLots;

    return Material(
      color: AppColors.white,
      borderRadius: AppRadius.radiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXl,
        child: Container(
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              _ListingArtwork(
                imageUrl: bien?.imageUrl,
                isProgramme: programme != null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        chipLabel,
                        style: TextStyle(
                          color: chipTextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (displayedPrice != null && displayedPrice > 0)
                      Row(
                        children: [
                          Icon(
                            programme != null
                                ? Icons.person_outline_rounded
                                : Icons.payments_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            priceLabel,
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_formatPrice(displayedPrice)} FCFA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.price.copyWith(
                                fontSize: 11.5,
                                color: programme != null
                                    ? AppColors.primaryBlueAnthracite
                                    : AppColors.primaryOcreDark,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (fallbackInfo != null)
                      Text(
                        '${fallbackInfo} lots',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSurface(double surface) =>
      '${NumberFormat.decimalPattern('fr_FR').format(surface)} m²';

  String _formatPrice(double price) =>
      NumberFormat.decimalPattern('fr_FR').format(price.round());

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class _ListingArtwork extends StatelessWidget {
  const _ListingArtwork({required this.imageUrl, required this.isProgramme});
  final String? imageUrl;
  final bool isProgramme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 92,
        height: 92,
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _ArtworkPlaceholder(isProgramme: isProgramme),
                errorWidget: (_, __, ___) =>
                    _ArtworkPlaceholder(isProgramme: isProgramme),
              )
            : _ArtworkPlaceholder(isProgramme: isProgramme),
      ),
    );
  }
}

/// Visuel neutre de remplacement lorsque l'API ne fournit pas de photo.
/// Il ne représente pas la géométrie réelle d'un bien.
class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.isProgramme});
  final bool isProgramme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TerrainArtworkPainter(isProgramme: isProgramme),
      child: Center(
        child: Icon(
          isProgramme ? Icons.grid_view_rounded : Icons.landscape_rounded,
          size: 27,
          color: AppColors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}

class _TerrainArtworkPainter extends CustomPainter {
  const _TerrainArtworkPainter({required this.isProgramme});
  final bool isProgramme;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isProgramme
            ? const [AppColors.mapCanvas, AppColors.mapDeepGreen]
            : const [AppColors.mapField, AppColors.successGreen],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    if (isProgramme) {
      final road = Paint()
        ..color = AppColors.mapRoad.withOpacity(0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.075;
      final roadPath = Path()
        ..moveTo(size.width * 0.02, size.height * 0.72)
        ..lineTo(size.width * 0.38, size.height * 0.48)
        ..lineTo(size.width * 0.72, size.height * 0.56)
        ..lineTo(size.width * 0.98, size.height * 0.25);
      canvas.drawPath(roadPath, road);

      final parcel = Paint()..color = AppColors.mapParcel.withOpacity(0.88);
      final line = Paint()
        ..color = AppColors.white.withOpacity(0.74)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          final rect = Rect.fromLTWH(
            size.width * (0.08 + col * 0.285),
            size.height * (0.06 + row * 0.29),
            size.width * 0.22,
            size.height * 0.21,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            parcel,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            line,
          );
        }
      }
    } else {
      final rows = Paint()
        ..color = AppColors.white.withOpacity(0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 5; i++) {
        final path = Path()
          ..moveTo(-size.width * 0.1, size.height * (0.18 + i * 0.17))
          ..quadraticBezierTo(
            size.width * 0.45,
            size.height * (0.05 + i * 0.17),
            size.width * 1.1,
            size.height * (0.2 + i * 0.17),
          );
        canvas.drawPath(path, rows);
      }
      final patch = Paint()..color = AppColors.mapFieldLight.withOpacity(0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.26, size.height * 0.27),
          width: size.width * 0.4,
          height: size.height * 0.16,
        ),
        patch,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TerrainArtworkPainter oldDelegate) =>
      oldDelegate.isProgramme != isProgramme;
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        24,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.h4, textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
