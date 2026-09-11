import 'package:flutter/material.dart';

import '../features/backtesting/backtracking.dart';
import '../features/gallery/photo_gallery_list.dart';
import '../features/reports/ddu_report.dart';
import '../features/reports/demark_report.dart';
import '../features/reports/report_detail.dart';
import '../models/menu.dart';
import '../services/analysis.dart';
import '../services/api_client.dart';
import '../services/photo_gallery.dart';

/// Centralizes report navigation and uses application-owned dependencies.
class AppRouter {
  const AppRouter({
    required this.analysisService,
    required this.photoGalleryService,
    required this.apiClient,
  });

  final AnalysisService analysisService;
  final PhotoGalleryService photoGalleryService;
  final ApiClient apiClient;

  Widget? pageFor(Menu menu) => switch (menu.router) {
    'BackTracking' => BackTracking(reportType: menu, apiClient: apiClient),
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
    'PhotoGallery' => PhotoGalleryList(
      reportType: menu,
      photoGalleryService: photoGalleryService,
    ),
    _ => null,
  };

  Future<void> openReport(BuildContext context, Menu menu) async {
    final page = pageFor(menu);
    if (page == null || !context.mounted) {
      return;
    }
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
