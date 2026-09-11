import 'package:flutter/material.dart';

import '../features/backtesting/backtracking.dart';
import '../features/reports/demark_report.dart';
import '../features/reports/ddu_report.dart';
import '../features/gallery/photo_gallery_list.dart';
import '../features/reports/report_detail.dart';
import '../models/menu.dart';
import '../services/analysis.dart';
import '../services/photoGallery.dart';
import '../services/api_client.dart';

/// Centralizes report navigation so screens do not own business route mapping.
class AppRouter {
  const AppRouter._();

  static Future<void> openReport(
    BuildContext context,
    Menu menu, {
    AnalysisService? analysisService,
    PhotoGalleryService? photoGalleryService,
    ApiClient? apiClient,
  }) async {
    final service = analysisService ?? AnalysisService();
    final galleryService = photoGalleryService ?? PhotoGalleryService();
    final client = apiClient ?? ApiClient();
    final page = switch (menu.router) {
      'BackTracking' => BackTracking(reportType: menu, apiClient: client),
      'ReportDetail' => ReportDetail(
        reportType: menu,
        analysisService: service,
      ),
      'DeMarkReport' => DeMarkReport(
        reportType: menu,
        analysisService: service,
      ),
      'DduReport' => DduReport(
        reportType: menu,
        dataType: DataType.ddu,
        analysisService: service,
      ),
      'RpsReport' => DduReport(
        reportType: menu,
        dataType: DataType.rps,
        analysisService: service,
      ),
      'StockReport' => DduReport(
        reportType: menu,
        dataType: DataType.stock,
        analysisService: service,
      ),
      'PhotoGallery' => PhotoGalleryList(
        reportType: menu,
        photoGalleryService: galleryService,
      ),
      _ => null,
    };
    if (page == null || !context.mounted) return;
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
