import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

/// Main application layout with sidebar and workspace
class MainLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget workspace;

  const MainLayout({
    super.key,
    required this.sidebar,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate sidebar width (18% of screen, with min/max constraints)
          double sidebarPixelWidth =
              constraints.maxWidth * AppConstants.sidebarWidth;
          sidebarPixelWidth = sidebarPixelWidth.clamp(
            AppConstants.minSidebarPixelWidth,
            AppConstants.maxSidebarPixelWidth,
          );

          return Row(
            children: [
              // Persistent Left Sidebar (18%)
              Container(
                width: sidebarPixelWidth,
                decoration: const BoxDecoration(
                  color: AppColors.deepNavy,
                  border: Border(
                    right: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: sidebar,
              ),

              // Workspace Area (82%)
              Expanded(
                child: Container(
                  color: AppColors.neutralGrey,
                  child: workspace,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Grid container for 12-column layout system
class GridContainer extends StatelessWidget {
  final List<GridColumn> children;
  final double gutter;

  const GridContainer({
    super.key,
    required this.children,
    this.gutter = AppConstants.gridGutter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGutterWidth = gutter * (AppConstants.gridColumns - 1);
        final columnWidth = (constraints.maxWidth - totalGutterWidth) /
            AppConstants.gridColumns;

        return Wrap(
          spacing: gutter,
          runSpacing: gutter,
          children: children.map((column) {
            final width =
                (columnWidth * column.span) + (gutter * (column.span - 1));
            return SizedBox(
              width: width,
              child: column.child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Grid column for 12-column layout
class GridColumn extends StatelessWidget {
  final int span; // Number of columns to span (1-12)
  final Widget child;

  const GridColumn({
    super.key,
    required this.span,
    required this.child,
  }) : assert(span >= 1 && span <= 12, 'Span must be between 1 and 12');

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
