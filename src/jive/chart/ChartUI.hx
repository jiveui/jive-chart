package jive.chart;


import org.aswing.JPanel;
import org.aswing.VectorListModel;
import org.aswing.Insets;
import org.aswing.border.EmptyBorder;
import org.aswing.graphics.SolidBrush;
import org.aswing.ASColor;
import org.aswing.graphics.SolidBrush;
import org.aswing.plaf.basic.BasicGraphicsUtils;
import org.aswing.geom.IntDimension;
import org.aswing.JLabel;
import flash.Lib;
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.display.Shape;
import org.aswing.geom.IntPoint;
import org.aswing.JTextField;
import org.aswing.ASColor;
import org.aswing.AsWingUtils;
import org.aswing.geom.IntRectangle;
import org.aswing.graphics.Graphics2D;
import org.aswing.Component;
import org.aswing.plaf.BaseComponentUI;

class ChartUI extends BaseComponentUI {


    private var chart: Chart;

    private var pointsToDraw: Array<DisplayPoint>;
    private var stats: ChartStatistics;
    private var graphBounds: IntRectangle;

    public var labels:Array<JLabel>;
    public var titleLabel:JLabel;
    public var xAxisLabel: JLabel;
    public var yAxisLabel: JLabel;

    public function new() {
        super();
        labels = [];
    }

    private function getPropertyPrefix():String{
        return "Chart.";
    }

    override public function paint(c:Component, g:Graphics2D, b:IntRectangle):Void {
        super.paint(c, g, b);

        if (null == chart || null == chart.data || chart.data.length <= 0 || null == titleLabel) return;

        titleLabel.text = chart.title;
        titleLabel.font = chart.titleFont;
        titleLabel.pack();

        updateAxisTitlesTextAndVisibility();

        calcStatisticsAndGraphBounds(b);
        ChartHelper.calculateDisplayCoordinates(pointsToDraw, graphBounds, stats);

        updateAxisTitlesPositions();

        createLabels(stats.labelsNumber);

        drawAxises(g);
        drawGraph(g);
        clearBubble();
    }

    private function updateAxisTitlesTextAndVisibility() {
        xAxisLabel.text = if (null != chart.xAxis && chart.xAxisTitleVisible) chart.xAxis.axisUnit else null;
        xAxisLabel.font = chart.font;
        xAxisLabel.pack();

        yAxisLabel.text = if (null != chart.yAxis && chart.yAxisTitleVisible) chart.yAxis.axisUnit else null;
        yAxisLabel.font = chart.font;
        yAxisLabel.rotation = -90;
        yAxisLabel.pack();
    }

    private function updateAxisTitlesPositions() {
        xAxisLabel.location = new IntPoint(
            Std.int(graphBounds.x + (graphBounds.width-xAxisLabel.preferredSize.width)/2),
            Std.int(graphBounds.leftBottom().y + stats.xLabelDimension.height + chart.axisMarginBetweenLabelsAndAxis));
        yAxisLabel.location = new IntPoint(
            graphBounds.x - getYAxisTitleMargin() - stats.yLabelDimension.width,
            Std.int(graphBounds.y + graphBounds.height/2 + yAxisLabel.preferredSize.width));
    }

    private inline function calcStatisticsAndGraphBounds(b: IntRectangle) {
        stats = ChartHelper.calcStatistics(chart.data, b, chart);
        calcGraphBounds(b);
        pointsToDraw = ChartHelper.getPointsNeededToDraw(chart.data, graphBounds, chart.minPointDistantion);
        stats = ChartHelper.calcStatistics(Lambda.array(Lambda.map(pointsToDraw, function(p) { return cast(p, Point);})), graphBounds, chart);
    }

    private inline function getXAxisTitleMargin(): Int {
        return if (chart.xAxisTitleVisible && xAxisLabel.text != null && xAxisLabel.text != "") {
            xAxisLabel.preferredSize.height + chart.axisMarginBetweenLabelsAndAxis;
        } else 0;
    }

    private inline function getYAxisTitleMargin(): Int {
        return if (chart.yAxisTitleVisible && yAxisLabel.text != null && yAxisLabel.text != "") {
            yAxisLabel.preferredSize.height + chart.axisMarginBetweenLabelsAndAxis;
        } else 0;
    }

    private inline function calcGraphBounds(b: IntRectangle) {

        var xAxisTitleMargin = getXAxisTitleMargin();
        var yAxisTitleMargin = getYAxisTitleMargin();

        graphBounds = b.clone();
        graphBounds.move(
            stats.yLabelDimension.width + chart.tickSize + yAxisTitleMargin,
            Std.int(chart.selectorSize+1) + Std.int(titleLabel.preferredSize.height));
        graphBounds.resize(
            -stats.yLabelDimension.width - chart.tickSize - Std.int(chart.selectorSize+1) - yAxisTitleMargin,
            -stats.xLabelDimension.height - chart.tickSize - Std.int(chart.selectorSize+1) - Std.int(titleLabel.preferredSize.height) - xAxisTitleMargin);
    }

    override public function installUI(c:Component):Void {
        chart = AsWingUtils.as(c, Chart);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

        titleLabel = new JLabel();
        titleLabel.location = new IntPoint(0,0);

        xAxisLabel = new JLabel();
        yAxisLabel = new JLabel();

        chart.append(titleLabel);
        chart.append(xAxisLabel);
        chart.append(yAxisLabel);
    }

    override public function uninstallUI(c:Component):Void {
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }


    /**
    * Draw axises x and y;
    * draw text value axises.
    **/
    public function drawAxises(g: Graphics2D) {

        g.drawLine(chart.axisPen, graphBounds.x, graphBounds.y, graphBounds.x, graphBounds.y + graphBounds.height);
        g.drawLine(chart.axisPen, graphBounds.x, graphBounds.y + graphBounds.height, graphBounds.x + graphBounds.width, graphBounds.y + graphBounds.height);

        chart.labelsLayer.removeAll();
        
        drawGridVerticalLinesAndCaptions(g);
        drawGridHorizontalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    private function drawGridVerticalLinesAndCaptions(g: Graphics2D) {
        var captionWidthWithMargin = stats.xLabelDimension.width;
        var ticksAmount = Std.int(graphBounds.width/captionWidthWithMargin)+1;
        var y = graphBounds.leftBottom().y;
        var x0 = graphBounds.x;
        for (i in 0...ticksAmount) {
            var x = x0 + i * captionWidthWithMargin;

            var t = labels[i];
            updateLabelForInterpolatedValue(t, chart.data[0].xValue, i, graphBounds.width/captionWidthWithMargin, stats.minX, stats.maxX);
            var insets = t.getInsets();
            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + chart.tickSize) + insets.top + chart.axisMarginBetweenLabelsAndAxis);
            if (t.location.x + t.preferredSize.width <= graphBounds.rightBottom().x) {
                chart.labelsLayer.append(t);
                g.drawLine(chart.axisPen, x, y, x, y + chart.tickSize);
                g.drawLine(chart.gridPen, x, y, x, graphBounds.y);
            }
        }
    }

    private function createLabels(n: Int) {
        if (n > labels.length) {
            for (i in 0...n-labels.length) {
                var l = new JLabel();
                l.font = chart.font;
                labels.push(l);
            }
        } else {
            for (i in 0...labels.length-n) {
                chart.labelsLayer.remove(labels.pop());
            }
        }
    }

    private function updateLabelForInterpolatedValue(label: JLabel, valueTranslator: ChartValue, index: Int, amount: Float, min: Float, max: Float) {
        label.text = valueTranslator.getCaptionByFloatValue(interpolateValue(index, amount, min, max));
        label.foreground = chart.axisLabelColor;
        label.pack();
    }

    private function drawGridHorizontalLinesAndCaptions(g: Graphics2D) {
        var captionHeightWithMargin = stats.yLabelDimension.height;
        var ticksAmount = Std.int(graphBounds.height/captionHeightWithMargin)+1;
        var x = graphBounds.x;
        var y0 = graphBounds.height + graphBounds.y;
        for (i in 0...ticksAmount) {
            var y = y0 - i * captionHeightWithMargin;

            var t = labels[i + stats.xLabelsNumber];
            updateLabelForInterpolatedValue(t, chart.data[0].yValue, i, graphBounds.height/captionHeightWithMargin, stats.minY, stats.maxY);
            var insets = t.getInsets();
            t.location = new IntPoint(x - stats.yLabelDimension.width, Std.int(y - t.preferredSize.height/2) + insets.top);
            if (t.location.y >= graphBounds.y) {
                chart.labelsLayer.append(t);
                g.drawLine(chart.axisPen, x, y, x - chart.tickSize, y);
                g.drawLine(chart.gridPen, x, y, graphBounds.x + graphBounds.width, y);
            }
        }
    }

    private function drawGridBorderLines(g: Graphics2D) {
        g.drawLine(chart.gridPen, graphBounds.x, graphBounds.y, graphBounds.x + graphBounds.width, graphBounds.y);
        g.drawLine(chart.gridPen, graphBounds.x + graphBounds.width, graphBounds.y + graphBounds.height, graphBounds.x + graphBounds.width, graphBounds.y);
    }

    private function interpolateValue(index: Float, length: Float, min: Float, max: Float): Float {
        return index * ((max - min) / length) + min;
    }

    /**
    * Mouse coordinats.
    **/
    public function onMouseMove(e:MouseEvent):Void {

        var index = calculateNearesPointIndex(chart.globalToComponent(new IntPoint(Std.int(e.stageX), 0)).x);
        drawBubble(index);
    }

    private function clearBubble() {
        chart.interactionLayer.removeAll();
        chart.interactionLayer.graphics.clear();
    }

    public function drawBubble(index: Int) {
        var p = pointsToDraw[index];
        var g: Graphics2D = new Graphics2D(chart.interactionLayer.graphics);
        g.clear();


        var text =
            chart.xAxis.getLabelValueString(p.minX.xValue, p.maxX.xValue) +
            "\n" +
            chart.yAxis.getLabelValueString(p.minY.yValue, p.maxY.yValue);

        var label = new JLabel(text);
        label.font = chart.font;
        label.border = new EmptyBorder(null, Insets.createIdentic(chart.selectorBubblePadding));

        var pX: Float = pointsToDraw[index].displayX;
        var pY: Float = pointsToDraw[index].displayY;
        var cornerRadius = chart.selectorBubbleCornerRadius;
        var tailSize: Float = chart.selectorBubbleTailSize;
        var contentDimension = label.preferredSize;
        var incline: Float = tailSize*0.5;

        var dx = 1.0;
        if (pX < graphBounds.x + graphBounds.width/2) {
            dx = 1.0;
        } else {
            dx = -1.0;
        }

        var dy = 1.0;
        if (pY > graphBounds.y + graphBounds.height / 2){
            dy = 1.0;
        } else {
            dy = -1.0;
        }

        var corner1 = new IntPoint(Std.int(pX + dx * (tailSize/2)), Std.int(pY - dy * (tailSize + incline)));
        var corner2 = new IntPoint(Std.int(pX + dx * tailSize/2), Std.int(pY -  dy *(tailSize + contentDimension.height + incline)));
        var corner3 = new IntPoint(Std.int(pX + dx * (tailSize/2 + contentDimension.width)), Std.int(pY - dy * (tailSize + contentDimension.height + incline)));
        var corner4 = new IntPoint(Std.int(pX + dx * (tailSize/2 + contentDimension.width)), Std.int(pY - dy * (tailSize + incline)));

        g.beginDraw(chart.selectorBubbleBorder);
        g.beginFill(chart.selectorBubbleBackground);
        g.moveTo(pX, pY);
        g.lineTo(pX + dx * (tailSize/2 + cornerRadius*2), pY - dy * (tailSize + incline));
        g.lineTo(pX + dx * (tailSize/2 + cornerRadius), pY - dy * (tailSize + incline));
        g.curveTo(corner1.x, corner1.y, corner1.x, pY - dy * (tailSize + cornerRadius + incline));
        g.lineTo(pX + dx * tailSize/2, pY - dy * (tailSize + contentDimension.height - cornerRadius + incline));
        g.curveTo(corner2.x, corner2.y,
                    pX + dx * (tailSize/2 + cornerRadius), pY - dy * (tailSize + contentDimension.height + incline));
        g.lineTo(pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - dy * (tailSize + contentDimension.height + incline));
        g.curveTo(corner3.x, corner3.y,
                    pX + dx * (tailSize/2 + contentDimension.width), pY - dy * (tailSize + contentDimension.height - cornerRadius + incline));
        g.lineTo(pX + dx * (tailSize/2 + contentDimension.width), pY - dy * (tailSize + cornerRadius + incline));
        g.curveTo(corner4.x, corner4.y,
                    pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - dy * (tailSize + incline));
        g.lineTo(pX + dx * (tailSize*1.25 + cornerRadius*2), pY - dy * (tailSize + incline));
        g.lineTo(pX, pY);
        g.endDraw();
        g.endFill();

        g.fillCircle(chart.selectorBrush, pX, pY, chart.selectorSize);

        label.foreground = chart.axisLabelColor;
        label.pack();

        if (dy > 0) {
            if (dx > 0) {
                label.location = corner2;
            } else {
                label.location = corner3;
            }
        } else {
            if (dx > 0) {
                label.location = corner1;
            } else {
                label.location = corner4;
            }
        }

        chart.interactionLayer.removeAll();
        chart.interactionLayer.append(label);

    }

    public function calculateNearesPointIndex(x:Float):Int {
        var i: Int = 0;
        var result = 0;
        for (point in pointsToDraw){
            if (Math.abs(x - pointsToDraw[result].displayX) > Math.abs(x - pointsToDraw[i].displayX)){
                result = i;
            }
            i++;
        }
        return result;
    }

    /**
    * Draw graph at points at axises X and Y;
    * If points y have negative value, then axis x is positive, axis y is negative;
    * If points x haxe negative valuse, then axis x is negative, axis y is positive;
    * If points x and y have negative value, then axis x and y is negative.
    **/
    public function drawGraph(g: Graphics2D):Void{
        g.fillRectangle(new SolidBrush(ASColor.WHITE.changeAlpha(0.0)), graphBounds.x, graphBounds.y, graphBounds.width, graphBounds.height);

//        if (pointsToDraw.length >= 3) {
//            ChartHelper.drawPolycurve(g, pointsToDraw, chart.graphPen);
//        } else {
            ChartHelper.drawPolyline(g, pointsToDraw, chart.graphPen);
//
//        }

        for (point in pointsToDraw){
            g.fillCircle(chart.markBrush, point.displayX, point.displayY, chart.markSize);
            g.drawCircle(chart.markPen, point.displayX, point.displayY, chart.markSize);
        }
    }

}