import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Thème Material global : les composants natifs suivent la charte
/// sans style local (champs, boutons, feuilles, dialogues, snackbars).
class AppTheme {
  AppTheme._();

  static OutlineInputBorder _bordure(Color couleur, [double largeur = 1.2]) =>
      OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: couleur, width: largeur),
      );

  /// Icônes de champ : grises au repos, ocre au focus, rouges en erreur.
  static final WidgetStateColor _couleurIconeChamp =
      WidgetStateColor.resolveWith((states) {
    if (states.contains(WidgetState.error)) return AppColors.errorRed;
    if (states.contains(WidgetState.focused)) return AppColors.primaryOcre;
    return AppColors.searchIcon;
  });

  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundOffWhite,
      primaryColor: AppColors.primaryOcre,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOcre,
        secondary: AppColors.primaryBlueAnthracite,
        surface: AppColors.white,
        error: AppColors.errorRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        titleLarge: AppTextStyles.h3,
        titleMedium: AppTextStyles.h4,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonText,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.backgroundOffWhite,
        surfaceTintColor: AppColors.backgroundOffWhite,
        foregroundColor: AppColors.primaryBlueAnthracite,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: const IconThemeData(color: AppColors.primaryBlueAnthracite),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.borderLight),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOcre,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey600,
          elevation: 0,
          minimumSize: const Size(0, AppSizes.buttonMedium),
          textStyle: AppTextStyles.buttonLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlueAnthracite,
          backgroundColor: AppColors.white,
          minimumSize: const Size(0, AppSizes.buttonMedium),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          textStyle: AppTextStyles.buttonLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryOcre,
          textStyle: AppTextStyles.buttonText,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primaryBlueAnthracite),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.searchIcon),
        labelStyle: AppTextStyles.label,
        floatingLabelStyle: AppTextStyles.label.copyWith(color: AppColors.primaryOcre),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed),
        prefixIconColor: _couleurIconeChamp,
        suffixIconColor: _couleurIconeChamp,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + AppSpacing.xxs,
          vertical: AppSpacing.md + AppSpacing.xxs,
        ),
        border: _bordure(AppColors.borderLight),
        enabledBorder: _bordure(AppColors.borderLight),
        focusedBorder: _bordure(AppColors.primaryOcre, 1.6),
        errorBorder: _bordure(AppColors.errorRed),
        focusedErrorBorder: _bordure(AppColors.errorRed, 1.6),
        disabledBorder: _bordure(AppColors.grey200),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        modalBackgroundColor: AppColors.white,
        showDragHandle: true,
        dragHandleColor: AppColors.grey300,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusXxl),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBlueAnthracite,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 6,
        shadowColor: AppColors.primaryBlueAnthracite.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        textStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlueAnthracite),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryOcre,
        linearTrackColor: AppColors.primaryOcreSoft,
        circularTrackColor: AppColors.primaryOcreSoft,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryOcre : AppColors.white,
        ),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusXxl),
        headerBackgroundColor: AppColors.primaryBlueAnthracite,
        headerForegroundColor: AppColors.white,
        todayBorder: const BorderSide(color: AppColors.primaryOcre),
      ),
    );
  }
}
