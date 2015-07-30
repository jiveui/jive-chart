package jive.chart;


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

    private var pointsToDraw: Array<Point>;
    private var stats: ChartStatistics;
    private var graphBounds: IntRectangle;

    public var labels:Array<JLabel>;
    public var titleLabel:JLabel;

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

        calcStatisticsAndGraphBounds(b);

        createLabels(stats.labelsNumber);

        drawAxises(g);
        drawGraph(g);
        clearBubble();
    }

    private inline function calcStatisticsAndGraphBounds(b: IntRectangle) {
        stats = ChartHelper.calcStatistics(chart.data, b, chart);
        var verticalMarginForTopMostLabel = Std.int(stats.yLabelDimension.height/2)+1;
        var horizontalMarginForRightMostLabel = Std.int(stats.xLabelDimension.width/2)+1;
        graphBounds = b.clone();
        graphBounds.move(stats.yLabelDimension.width + chart.tickSize, verticalMarginForTopMostLabel + Std.int(titleLabel.preferredSize.height));
        graphBounds.resize(-stats.yLabelDimension.width - chart.tickSize - horizontalMarginForRightMostLabel,
                            -stats.xLabelDimension.height - chart.tickSize - verticalMarginForTopMostLabel - Std.int(titleLabel.preferredSize.height));
        stats = ChartHelper.calcStatistics(chart.data, graphBounds, chart);
    }

    override public function installUI(c:Component):Void {
        chart = AsWingUtils.as(c, Chart);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        titleLabel = new JLabel();
        titleLabel.location = new IntPoint(0,0);
        chart.append(titleLabel);
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
            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + chart.tickSize) + insets.top);
            chart.labelsLayer.append(t);

            g.drawLine(chart.axisPen, x, y, x, y + chart.tickSize);
            g.drawLine(chart.gridPen, x, y, x, graphBounds.y);
        }
    }

    private function createLabels(n: Int) {
        if (n > labels.length) {
            for (i in 0...n-labels.length) {
                labels.push(new JLabel());
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
            t.location = new IntPoint(insets.left, Std.int(y - t.preferredSize.height/2) + insets.top);
            chart.labelsLayer.append(t);

            g.drawLine(chart.axisPen, x, y, x - chart.tickSize, y);
            g.drawLine(chart.gridPen, x, y, graphBounds.x + graphBounds.width, y);
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
        var index = calculateNearesPointIndex(e.localX);
        drawBubble(index);
    }

    private function clearBubble() {
        chart.interactionLayer.removeAll();
        chart.interactionLayer.graphics.clear();
    }

    public function drawBubble(index: Int) {

        var g: Graphics2D = new Graphics2D(chart.interactionLayer.graphics);
        g.clear();

        var label = new JLabel(pointsToDraw[index].xCaption + "\n" + pointsToDraw[index].yCaption);
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
        var data = chart.data;

        g.fillRectangle(new SolidBrush(ASColor.WHITE.changeAlpha(0.0)), graphBounds.x, graphBounds.y, graphBounds.width, graphBounds.height);

        ChartHelper.calculateDisplayCoordinates(chart.data, graphBounds, stats);
        pointsToDraw = ChartHelper.getPointsNeededToDraw(chart.data, graphBounds, chart.minPointDistantion);

        ChartHelper.drawPolyline(g, pointsToDraw, chart.graphPen);

        for (point in pointsToDraw){
            g.fillCircle(chart.markBrush, point.displayX, point.displayY, chart.markSize);
            g.drawCircle(chart.markPen, point.displayX, point.displayY, chart.markSize);
        }
    }

}