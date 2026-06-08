import 'package:flutter/material.dart';

/// Mengatur posisi FAB agar terapung secara estetis di atas navigasi utama.
class CustomFabLocation extends FloatingActionButtonLocation {
  const CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabWidth = scaffoldGeometry.floatingActionButtonSize.width;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    final double fabX = scaffoldGeometry.scaffoldSize.width - fabWidth - 20;
    final double fabY = scaffoldGeometry.scaffoldSize.height - fabHeight - 150;
    return Offset(fabX, fabY);
  }
}
