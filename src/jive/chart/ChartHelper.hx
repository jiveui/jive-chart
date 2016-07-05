package jive.chart;

import jive.Color;
import jive.chart.Point;
import jive.graphics.IPen;
import jive.geom.*;
import jive.graphics.IBrush;
import jive.graphics.Graphics2D;
import jive.graphics.Pen;

using Lambda;
using Math;

typedef ControlPointsOneDimension = { p1: Array<Float>, p2: Array<Float> };
typedef ControlPoints = { p1: flash.geom.Point, p2: flash.geom.Point };

class ChartHelper {

    public static function calculateDisplayCoordinates(points: Array<DisplayPoint>, bounds: IntRectangle, stats: ChartStatistics) {
        for (p in points) {
            p.displayX = (p.x - stats.minX) * stats.scaleX;
            p.displayY = bounds.height - (p.y - stats.minY) * stats.scaleY;
        }
    }

    public static function getPointsNeededToDraw(points: Array<Point>, bounds: IntRectangle, minDistantion: Int): Array<DisplayPoint> {
        var result = [];

        if (null == points || points.length <= 0) return result;


        var intervalLength = Std.int(Math.max(1,Math.floor(points.length/Math.floor(bounds.width/minDistantion))));

        var left = 0;
        var right = Std.int(Math.min(intervalLength, points.length));

        while (left < points.length) {
            var s = calcPointsStatistics(points, left, right);
            result.push(new DisplayPoint(s.minX, s.maxX, s.minY, s.maxY));
            left += intervalLength;
            right += intervalLength;
            right = Std.int(Math.min(right, points.length));
        }

        return result;
    }

    public static function drawPolyline(g: Graphics2D, points: Array<DisplayPoint>, pen: IPen) {
        g.beginDraw(pen);
        var first = true;
        for (point in points) {
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

    public static function drawPolycurve(g: Graphics2D, points: Array<DisplayPoint>, pen: IPen) {
        g.beginDraw(pen);
        var controlPoints = calculateControlPoints(points);
        var first = true;
        var controlPointIndex = 0;
        for (point in points){
            if (first) {
                g.moveTo(point.displayX, point.displayY);
                first = false;
            } else {
                var cp = controlPoints[controlPointIndex];
                g.cubicCurveTo(cp.p1.x, cp.p1.y, cp.p2.x, cp.p2.y, point.displayX, point.displayY);
                controlPointIndex += 1;
            }
        }
        g.moveTo(points[0].displayX, points[0].displayY);
        g.endDraw();
    }

    /* For more info see:
    * http://www.particleincell.com/2012/bezier-splines/
    *
    * Lubos Brieda, Particle In Cell Consulting LLC, 2012
    * you may freely use this algorithm in your codes however where feasible
    * please include a link/reference to the source article
    */

    private static function calculateControlPointsOneDimension(K: Array<Float>): ControlPointsOneDimension {
        var p1: Array<Float> = [];
        var p2: Array<Float> = [];
        var n = K.length-1;

        /*rhs vector*/
        var a: Array<Float> = [];
        var b: Array<Float> = [];
        var c: Array<Float> = [];
        var r: Array<Float> = [];

        /*left most segment*/
        a[0]=0;
        b[0]=2;
        c[0]=1;
        r[0] = K[0]+2*K[1];

        /*internal segments*/
        for (i in 1...n - 1) {
            a[i]=1;
            b[i]=4;
            c[i]=1;
            r[i] = 4 * K[i] + 2 * K[i+1];
        }

        /*right segment*/
        a[n-1]=2;
        b[n-1]=7;
        c[n-1]=0;
        r[n-1] = 8*K[n-1]+K[n];

        /*solves Ax=b with the Thomas algorithm (from Wikipedia)*/
        for (i in 1...n) {
            var m = a[i]/b[i-1];
            b[i] = b[i] - m * c[i - 1];
            r[i] = r[i] - m*r[i-1];
        }

        p1[n-1] = r[n-1]/b[n-1];
        var i = n-2;
        while (i >= 0) {
            p1[i] = (r[i] - c[i] * p1[i+1]) / b[i];
            i -= 1;
        }

        /*we have p1, now compute p2*/
        for (i in 0...n-1) {
            p2[i]=2*K[i+1]-p1[i+1];
        }

        p2[n-1]=0.5*(K[n]+p1[n-1]);

        return { p1:p1, p2:p2 };
    }

    private static function calculateControlPoints(points: Array<DisplayPoint>): Array<ControlPoints> {
        var controlPointsX = calculateControlPointsOneDimension(points.map(function(p) { return p.displayX;}).array());
        var controlPointsY = calculateControlPointsOneDimension(points.map(function(p) { return p.displayY;}).array());

        var result = [];

        for (i in 0...controlPointsX.p1.length) {
            result.push({ p1: new flash.geom.Point(controlPointsX.p1[i], controlPointsY.p1[i]), p2: new flash.geom.Point(controlPointsX.p2[i], controlPointsY.p2[i])});
        }

        return result;
    }

    public static function fillSpaceUnderPolyline(g: Graphics2D, points: Array<DisplayPoint>, brush: IBrush, bounds: IntRectangle) {
        for (i in 0...points.length-1){
            g.beginFill(brush);
            g.moveTo(points[i].displayX, bounds.y + bounds.height + 2);
            g.lineTo(points[i].displayX, points[i].displayY);
            g.lineTo(points[i+1].displayX, points[i+1].displayY);
            g.lineTo(points[i+1].displayX, bounds.y + bounds.height + 2);
            g.endFill();
        }
    }

    public static function calcStatistics(points: Array<Point>, bounds: IntRectangle, chart: Chart): ChartStatistics {
        var r: ChartStatistics = {
            minX: 0,
            minY: 0,
            maxX: 0,
            maxY: 0,
            scaleX: 0,
            scaleY: 0,
            xLabelDimension: null,
            yLabelDimension: null,
            xLabelsNumber: 0,
            yLabelsNumber: 0,
            labelsNumber: 0
        };

        if (null == points || points.length <= 0) return r;

        r.xLabelDimension = calcMaxLabelsDimesionForX(points, r, chart);
        r.yLabelDimension = calcMaxLabelsDimesionForY(points, r, chart);

        fillMainStatistics(r, points, bounds, chart);
        fillLabelsNumber(bounds, r);

        return r;
    }

    public static function fillMainStatistics(r: ChartStatistics, points: Array<Point>, bounds: IntRectangle, chart: Chart) {
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
    }

    public static function fillLabelsNumber(bounds: IntRectangle, stats: ChartStatistics) {
        stats.xLabelsNumber = Std.int(bounds.width/stats.xLabelDimension.width) + 1;
        stats.yLabelsNumber = Std.int(bounds.height/stats.yLabelDimension.height) + 1;
        stats.labelsNumber = stats.xLabelsNumber + stats.yLabelsNumber;
    }

    public static function calcMaxLabelsDimesionForX(points: Array<Point>, stats: ChartStatistics, chart: Chart): IntDimension {
        trace(null == points || points.length <= 0);
        if (null == points || points.length <= 0) 
			return new IntDimension(0,0);

        return calcMaxLabelDimensionForValue(
            points[0].xValue,
            stats.minX,
            stats.maxX,
            new MetricInsets(
                Metric.absolute(Std.int(chart.axisMarginBetweenLabelsAndAxis)), 
                Metric.absolute(Std.int(chart.axisMarginBetweenLabels/2)), 
                Metric.absolute(0), 
                Metric.absolute(Std.int(chart.axisMarginBetweenLabels/2))
            ),
            chart
        );
    }

    public static function calcMaxLabelsDimesionForY(points: Array<Point>, stats: ChartStatistics, chart: Chart): IntDimension {
        trace(null == points || points.length <= 0);
        if (null == points || points.length <= 0) 
			return new IntDimension(0,0);

        return calcMaxLabelDimensionForValue(
			points[0].yValue,
			stats.minY,
			stats.maxY,
            new MetricInsets(
                Metric.absolute(Std.int(chart.axisMarginBetweenLabels/2)), 
                Metric.absolute(0), 
                Metric.absolute(Std.int(chart.axisMarginBetweenLabels/2)), 
                Metric.absolute(chart.axisMarginBetweenLabelsAndAxis)
            ),
			chart
		);
    }

    // TODO
    private static inline function calcMaxLabelDimensionForValue(value: ChartValue, min: Float, max: Float, insets: MetricInsets, chart: Chart): IntDimension {
        var label = new Label(value.getCaptionByFloatValue( if (min < 0) min else max));
        trace(label.text);
        label.font = chart.font;
        label.margin = insets;
        return label.getPreferredSize();
    }

    public static function calcPointsStatistics(points: Array<Point>, left: Int, right: Int): PointsStatistics {
        if (null == points || points.length <= 0) return null;

        var minX: Point = points[left];
        var maxX: Point = points[left];
        var minY: Point = points[left];
        var maxY: Point = points[left];

        var sumX: Float = 0;
        var sumY: Float = 0;
        for (i in left...right) {
            var p = points[i];
            if (minY.y > p.y) minY = p;
            if (maxY.y < p.y) maxY = p;
            if (minX.x > p.x) minX = p;
            if (maxX.x < p.x) maxX = p;
            sumX += p.x;
            sumY += p.y;
        }

        return {
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY
        }
    }
}
