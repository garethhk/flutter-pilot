import 'package:flutter/material.dart';

import '../containers/BackTracking.dart';
import '../containers/DeMarkReport.dart';
import '../containers/DduReport.dart';
import '../containers/PhotoGalleryList.dart';
import '../containers/ReportDetail.dart';
import '../models/menu.dart';

/// Centralizes report navigation so screens do not own business route mapping.
class AppRouter {
  const AppRouter._();

  static Future<void> openReport(BuildContext context, Menu menu) async {
    final page = switch (menu.router) {
      'BackTracking' => BackTracking(reportType: menu),
      'ReportDetail' => ReportDetail(reportType: menu),
      'DeMarkReport' => DeMarkReport(reportType: menu),
      'DduReport' => DduReport(reportType: menu, dataType: DataType.ddu),
      'RpsReport' => DduReport(reportType: menu, dataType: DataType.rps),
      'StockReport' => DduReport(reportType: menu, dataType: DataType.stock),
      'PhotoGallery' => PhotoGalleryList(reportType: menu),
      _ => null,
    };
    if (page == null || !context.mounted) return;
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
