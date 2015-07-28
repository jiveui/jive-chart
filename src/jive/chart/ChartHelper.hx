package jive.chart;

import org.aswing.graphics.IPen;
import org.aswing.JLabel;
import org.aswing.geom.IntDimension;
import org.aswing.graphics.IBrush;
import org.aswing.graphics.Graphics2D;
import org.aswing.graphics.Pen;
import org.aswing.geom.IntRectangle;

class ChartHelper {

    public static function calculateDisplayCoordinates(points: Array<Point>, bounds: IntRectangle, stats: ChartStatistics) {
        for (p in points) {
            p.displayX = bounds.x + (p.x - stats.minX) * stats.scaleX;
            p.displayY = bounds.height + bounds.y - (p.y - stats.minY) * stats.scaleY;
        }
    }

    public static function getPointsNeededToDraw(points: Array<Point>, bounds: IntRectangle, minDistantion: Int): Array<Point> {
        var result = [];

        if (null == points || points.length <= 0) return result;

        var prevX = Math.POSITIVE_INFINITY;
        for (p in points){
            var curX = p.displayX;
            if (Math.abs(prevX - curX) >= minDistantion) {
                result.push(p);
                prevX = curX;
            }
        }

        return result;
    }

    public static function drawPolyline(g: Graphics2D, points: Array<Point>, pen: IPen) {
        g.beginDraw(pen);
        var first = true;
        for (point in points){
            if (first) {
                g.moveTo(point.displayX, point.displayY);
                first = false;
            } else {
                g.lineTo(point.displayX, point.displayY);
            }
        }
        g.moveTo(points[0].displayX, points[0].displayY);
        g.endDraw();
    }

    public static function fillSpaceUnderPolyline(graphics: Graphics2D, points: Array<Point>, brush: IBrush) {

    }

    public static function calcStatistics(points: Array<Point>, bounds: IntRectangle): ChartStatistics {
        var r: ChartStatistics = {
            minX: 0,
            minY: 0,
            maxX: 0,
            maxY: 0,
            scaleX: 0,
            scaleY: 0,
            xLabelDimension: null,
            yLabelDimension: null
        };

        if (null == points || points.length <= 0) return r;

        //***************************************************************//
        // Calculate min and max
        //***************************************************************//

        r.minX = points[0].x;
        r.maxX = points[0].x;
        r.minY = points[0].y;
        r.maxY = points[0].y;

        for (p in points){
            if (r.minX > p.x) r.minX = p.x;
            if (r.maxX < p.x) r.maxX = p.x;
            if (r.minY > p.y) r.minY = p.y;
            if (r.maxY < p.y) r.maxY = p.y;
        }
        //***************************************************************//

        r.scaleX = bounds.width / (r.maxX - r.minX);
        r.scaleY = bounds.height / (r.maxY - r.minY);

        r.xLabelDimension = calcMaxLabelsDimesionForX(points, r);
        r.yLabelDimension = calcMaxLabelsDimesionForY(points, r);

        return r;
    }

    public static function calcMaxLabelsDimesionForX(points: Array<Point>, stats: ChartStatistics): IntDimension {
        if (null == points || points.length <= 0) return new IntDimension(0,0);

        return calcMaxLabelDimensionForValue(points[0].xValue, stats.minX, stats.maxX);
    }

    public static function calcMaxLabelsDimesionForY(points: Array<Point>, stats: ChartStatistics): IntDimension {
        if (null == points || points.length <= 0) return new IntDimension(0,0);

        return calcMaxLabelDimensionForValue(points[0].yValue, stats.minY, stats.maxY);
    }

    private static inline function calcMaxLabelDimensionForValue(value: ChartValue, min: Float, max: Float): IntDimension {
        return (new JLabel(value.getCaptionByFloatValue( if (min < 0) min else max))).preferredSize;
    }

}
