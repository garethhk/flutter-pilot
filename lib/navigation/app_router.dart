import 'package:flutter/material.dart';

import '../features/backtesting/backtracking.dart';
import '../features/reports/demark_report.dart';
import '../features/reports/ddu_report.dart';
import '../features/gallery/photo_gallery_list.dart';
import '../features/reports/report_detail.dart';
import '../models/menu.dart';
import '../services/analysis.dart';

/// Centralizes report navigation so screens do not own business route mapping.
class AppRouter {
  const AppRouter._();

  static Future<void> openReport(
    BuildContext context,
    Menu menu, {
    AnalysisService analysisService = const AnalysisService(),
  }) async {
    final page = switch (menu.router) {
      'BackTracking' => BackTracking(reportType: menu),
      'ReportDetail' => ReportDetail(
        reportType: menu,
        analysisService: analysisService,
      ),
      'DeMarkReport' => DeMarkReport(
        reportType: menu,
        analysisService: analysisService,
      ),
      'DduReport' => DduReport(
        reportType: menu,
        dataType: DataType.ddu,
        analysisService: analysisService,
      ),
      'RpsReport' => DduReport(
        reportType: menu,
        dataType: DataType.rps,
        analysisService: analysisService,
      ),
      'StockReport' => DduReport(
        reportType: menu,
        dataType: DataType.stock,
        analysisService: analysisService,
      ),
      'PhotoGallery' => PhotoGalleryList(reportType: menu),
      _ => null,
    };
    if (page == null || !context.mounted) return;
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
