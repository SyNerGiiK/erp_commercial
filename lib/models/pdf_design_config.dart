import 'package:decimal/decimal.dart';
import 'enums/entreprise_enums.dart';

class PdfDesignConfig {
  final String? id;
  final String entrepriseId;
  final String? headerBannerUrl;
  final String? watermarkText;
  final String? watermarkImageUrl;
  final Decimal watermarkOpacity;
  final PdfFontPairing fontPairing;
  final PdfTableStyle tableStyle;
  final PdfLayoutVariant layoutVariant;
  final String primaryColor;
  final String secondaryColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PdfDesignConfig({
    this.id,
    required this.entrepriseId,
    this.headerBannerUrl,
    this.watermarkText,
    this.watermarkImageUrl,
    Decimal? watermarkOpacity,
    this.fontPairing = PdfFontPairing.modern,
    this.tableStyle = PdfTableStyle.minimal,
    this.layoutVariant = PdfLayoutVariant.standard,
    this.primaryColor = '#4F46E5',
    this.secondaryColor = '#F9FAFB',
    this.createdAt,
    this.updatedAt,
  }) : watermarkOpacity = watermarkOpacity ?? Decimal.parse('0.1');

  factory PdfDesignConfig.fromJson(Map<String, dynamic> json) {
    return PdfDesignConfig(
      id: json['id'] as String?,
      entrepriseId: json['entreprise_id'] as String,
      headerBannerUrl: json['header_banner_url'] as String?,
      watermarkText: json['watermark_text'] as String?,
      watermarkImageUrl: json['watermark_image_url'] as String?,
      watermarkOpacity: json['watermark_opacity'] != null
          ? Decimal.parse(json['watermark_opacity'].toString())
          : null,
      fontPairing: PdfFontPairing.values.firstWhere(
        (e) => e.name == json['font_pairing'],
        orElse: () => PdfFontPairing.modern,
      ),
      tableStyle:
          PdfTableStyleExtension.fromDbValue(json['table_style'] as String?),
      layoutVariant: PdfLayoutVariantExtension.fromDbValue(
          json['layout_variant'] as String?),
      primaryColor: json['primary_color'] as String? ?? '#4F46E5',
      secondaryColor: json['secondary_color'] as String? ?? '#F9FAFB',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'entreprise_id': entrepriseId,
      'header_banner_url': headerBannerUrl,
      'watermark_text': watermarkText,
      'watermark_image_url': watermarkImageUrl,
      'watermark_opacity': watermarkOpacity.toString(),
      'font_pairing': fontPairing.dbValue,
      'table_style': tableStyle.dbValue,
      'layout_variant': layoutVariant.dbValue,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PdfDesignConfig copyWith({
    String? id,
    String? entrepriseId,
    String? headerBannerUrl,
    String? watermarkText,
    String? watermarkImageUrl,
    Decimal? watermarkOpacity,
    PdfFontPairing? fontPairing,
    PdfTableStyle? tableStyle,
    PdfLayoutVariant? layoutVariant,
    String? primaryColor,
    String? secondaryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PdfDesignConfig(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      headerBannerUrl: headerBannerUrl ?? this.headerBannerUrl,
      watermarkText: watermarkText ?? this.watermarkText,
      watermarkImageUrl: watermarkImageUrl ?? this.watermarkImageUrl,
      watermarkOpacity: watermarkOpacity ?? this.watermarkOpacity,
      fontPairing: fontPairing ?? this.fontPairing,
      tableStyle: tableStyle ?? this.tableStyle,
      layoutVariant: layoutVariant ?? this.layoutVariant,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static PdfDesignConfig defaultConfig(String entrepriseId) {
    return PdfDesignConfig(entrepriseId: entrepriseId);
  }
}
