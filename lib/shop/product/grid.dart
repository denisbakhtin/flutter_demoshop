import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter/rendering.dart';

const int _childrenPerBlock = 8;
const int _rowsPerBlock = 5;

int _minIndexInRow(int rowIndex) {
  final int blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[0, 2, 4, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _maxIndexInRow(int rowIndex) {
  final int blockIndex = rowIndex ~/ _rowsPerBlock;
  return const <int>[1, 3, 5, 6, 7][rowIndex % _rowsPerBlock] +
      blockIndex * _childrenPerBlock;
}

int _rowAtIndex(int index) {
  final int blockCount = index ~/ _childrenPerBlock;
  return const <int>[
        0,
        0,
        1,
        1,
        2,
        2,
        3,
        4,
      ][index - blockCount * _childrenPerBlock] +
      blockCount * _rowsPerBlock;
}

int _columnAtIndex(int index) {
  return const <int>[0, 1, 0, 1, 0, 1, 0, 0][index % _childrenPerBlock];
}

int _columnSpanAtIndex(int index) {
  return const <int>[1, 1, 1, 1, 1, 1, 2, 2][index % _childrenPerBlock];
}

// The Shrine home page arranges the product cards into two columns. The card
// on every 4th and 5th row spans two columns.
class _ShrineGridLayout extends SliverGridLayout {
  const _ShrineGridLayout({
    @required this.rowStride,
    @required this.columnStride,
    @required this.tileHeight,
    @required this.tileWidth,
  });

  final double rowStride;
  final double columnStride;
  final double tileHeight;
  final double tileWidth;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return _minIndexInRow(scrollOffset ~/ rowStride);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return _maxIndexInRow(scrollOffset ~/ rowStride);
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int row = _rowAtIndex(index);
    final int column = _columnAtIndex(index);
    final int columnSpan = _columnSpanAtIndex(index);
    return new SliverGridGeometry(
      scrollOffset: row * rowStride,
      crossAxisOffset: column * columnStride,
      mainAxisExtent: tileHeight,
      crossAxisExtent: tileWidth + (columnSpan - 1) * columnStride,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) return 0.0;
    final int rowCount = _rowAtIndex(childCount - 1) + 1;
    final double rowSpacing = rowStride - tileHeight;
    return rowStride * rowCount - rowSpacing;
  }
}

class ShrineGridDelegate extends SliverGridDelegate {
  static const double _kSpacing = 8.0;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = (constraints.crossAxisExtent - _kSpacing) / 2.0;
    final double tileHeight = 40.0 + 144.0 + 40.0;
    return new _ShrineGridLayout(
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      rowStride: tileHeight + _kSpacing,
      columnStride: tileWidth + _kSpacing,
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) => false;
}
