package jive.chart;

import jive.geom.IntDimension;

typedef ChartStatistics = {
    minX: Float,
    minY: Float,
    maxX: Float,
    maxY: Float,
    scaleX: Float,
    scaleY: Float,
    xLabelDimension: IntDimension,
    yLabelDimension: IntDimension,
    yLabelsNumber: Int,
    xLabelsNumber: Int,
    labelsNumber: Int
};
