package jive.chart;


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

    public var textLabel:Array<JTextField>;

    public function new() {
        super();
    }

    private function getPropertyPrefix():String{
        return "Chart.";
    }

    override public function paint(c:Component, g:Graphics2D, b:IntRectangle):Void {
        super.paint(c, g, b);
        chart = AsWingUtils.as(c, Chart);

        if (null == chart) return;
        if (null == chart.data || chart.data.length <= 0) return;

        calcStatisticsAndGraphBounds(b);

        drawAxises(g);
        drawGraph(g);
    }

    private inline function calcStatisticsAndGraphBounds(b: IntRectangle) {
        stats = ChartHelper.calcStatistics(chart.data, b);
        graphBounds = b.clone();
        graphBounds.move(stats.yLabelDimension.width, 0);
        graphBounds.resize(-stats.yLabelDimension.width, -stats.xLabelDimension.height - chart.tickSize);
        stats = ChartHelper.calcStatistics(chart.data, graphBounds);
    }

    override public function installUI(c:Component):Void { }
    override public function uninstallUI(c:Component):Void { }



    public var xValueSize:Float = 0;
    public var yValueSize:Float = 0;

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

            var t = createLabelForInterpolatedValue(chart.data[0].xValue, i, graphBounds.width/captionWidthWithMargin, stats.minX, stats.maxX);
            var insets = t.getInsets();
            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + chart.tickSize) + insets.top);
            chart.labelsLayer.append(t);

            g.drawLine(chart.axisPen, x, y, x, y + chart.tickSize);
            g.drawLine(chart.gridPen, x, y, x, graphBounds.y);
        }
    }

    private function createLabelForInterpolatedValue(valueTranslator: ChartValue, index: Int, amount: Float, min: Float, max: Float): JLabel {
        var label = new JLabel(valueTranslator.getCaptionByFloatValue(interpolateValue(index, amount, min, max)));
        label.invalidate();
        label.repaint();
        return label;
    }

    private function drawGridHorizontalLinesAndCaptions(g: Graphics2D) {
        var captionHeightWithMargin = stats.yLabelDimension.height;
        var ticksAmount = Std.int(graphBounds.height/captionHeightWithMargin)+1;
        var x = graphBounds.x;
        var y0 = graphBounds.height + graphBounds.y;
        for (i in 0...ticksAmount) {
            var y = y0 - i * captionHeightWithMargin;

            var t = createLabelForInterpolatedValue(chart.data[0].yValue, i, graphBounds.height/captionHeightWithMargin, stats.minY, stats.maxY);
            var insets = t.getInsets();
            t.location = new IntPoint(insets.left, Std.int(y - t.preferredSize.height/2) + insets.top);
            chart.labelsLayer.append(t);

            g.drawLine(chart.axisPen, x, y, x - chart.tickSize, y);
            g.drawLine(chart.gridPen, x, y, graphBounds.x + graphBounds.width, y);
        }
    }

    private function drawGridBorderLines(g: Graphics2D) {
        g.drawLine(chart.gridPen, graphBounds.x, 0, graphBounds.x + graphBounds.width, 0);
        g.drawLine(chart.gridPen, graphBounds.x + graphBounds.width, graphBounds.y + graphBounds.height, graphBounds.x + graphBounds.width, 0);
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

    public function drawBubble(index: Int) {

        chart.interactionLayer.removeAll();
        var g: Graphics2D = new Graphics2D(chart.interactionLayer.graphics);
//        chart.interactionLayer.graphics;
        g.clear();

//        var label = new JLabel(pointsToDraw[index].xCaption + "\n" + pointsToDraw[index].yCaption);
//        chart.interactionLayer.append(label);

        var pX = pointsToDraw[index].displayX;
        var pY = pointsToDraw[index].displayY;
        var cornerRadius = 10;
        var padding = 4;
        var tailSize = 25;
        var contentDimension = new IntDimension(200, 100);

        var incline = tailSize*0.5;


        var dx = 1;
        if (pX < graphBounds.x + graphBounds.width/2) {
            dx = 1;
        } else {
            dx = -1;
        }


        g.beginDraw(chart.selectorBubbleBorder);
        g.beginFill(chart.selectorBubbleBackground);
        g.moveTo(pX, pY);
        g.lineTo(pX + dx * (tailSize/2 + cornerRadius*2), pY - tailSize - incline );
        g.lineTo(pX + dx * (tailSize/2 + cornerRadius), pY - tailSize - incline);
        g.curveTo(pX + dx * (tailSize/2), pY - tailSize - incline, pX + dx * tailSize/2, pY - tailSize - cornerRadius - incline);
        g.lineTo(pX + dx * tailSize/2, pY - tailSize - contentDimension.height + cornerRadius - incline);
        g.curveTo(pX + dx * tailSize/2, pY - tailSize - contentDimension.height - incline,
                    pX + dx * (tailSize/2 + cornerRadius), pY - tailSize - contentDimension.height - incline);
        g.lineTo(pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - tailSize - contentDimension.height - incline);
        g.curveTo(pX + dx * (tailSize/2 + contentDimension.width), pY - tailSize - contentDimension.height - incline,
                    pX + dx * (tailSize/2 + contentDimension.width), pY - tailSize - contentDimension.height + cornerRadius - incline);
        g.lineTo(pX + dx * (tailSize/2 + contentDimension.width), pY - tailSize - cornerRadius - incline);
        g.curveTo(pX + dx * (tailSize/2 + contentDimension.width), pY - tailSize - incline,
                    pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - tailSize - incline);
        g.lineTo(pX + dx * (tailSize*1.25 + cornerRadius*2), pY - tailSize - incline);
        g.lineTo(pX, pY);
        g.endDraw();
        g.endFill();

        g.fillCircle(chart.selectorBrush, pX, pY, chart.selectorSize);

/*        if (pointsToDraw.length / 2 < index){
            if (graphBounds.height / 3 < pointsToDraw[index].displayY){
                label.location = new IntPoint(Std.int(pointsToDraw[index].displayX) + 16, Std.int(pointsToDraw[index].displayY - 60));
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX + 15, pointsToDraw[index].displayY - 55);
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX + 16, pointsToDraw[index].displayY - 72 + label.preferredSize.height);
                g.beginFill(0xFFFFFF, 0.5);
                g.drawRoundRect(pointsToDraw[index].displayX + 15, pointsToDraw[index].displayY - 60, label.preferredSize.width - 20, label.preferredSize.height - 10, 15);
                g.endFill();
                }
            else if (graphBounds.height / 3 > pointsToDraw[index].displayY){
                label.location = new IntPoint(Std.int(pointsToDraw[index].displayX) + 16, Std.int(pointsToDraw[index].displayY + 19));
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX + 15, pointsToDraw[index].displayY + 55);
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX + 16, pointsToDraw[index].displayY + 72 - label.preferredSize.height);
                g.beginFill(0xFFFFFF, 0.5);
                g.drawRoundRect(pointsToDraw[index].displayX + 15, pointsToDraw[index].displayY +19, label.preferredSize.width - 20, label.preferredSize.height - 10, 15);
                g.endFill();
            }
        }
        else if(pointsToDraw.length / 2 >= index){
            if (graphBounds.height / 3 < pointsToDraw[index].displayY){
                label.location = new IntPoint(Std.int(pointsToDraw[index].displayX) - label.preferredSize.width + 5, Std.int(pointsToDraw[index].displayY - 60));
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX - 15, pointsToDraw[index].displayY - 55);
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX - 16, pointsToDraw[index].displayY - 72 + label.preferredSize.height);
                g.beginFill(0xFFFFFF, 0.5);
                g.drawRoundRect(pointsToDraw[index].displayX - label.preferredSize.width + 5, pointsToDraw[index].displayY - 60, label.preferredSize.width - 18, label.preferredSize.height - 10, 15);
                g.endFill();
                }
            else if (graphBounds.height / 3 > pointsToDraw[index].displayY)
            {
                label.location = new IntPoint(Std.int(pointsToDraw[index].displayX) - label.preferredSize.width + 5, Std.int(pointsToDraw[index].displayY + 19));
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX - 15, pointsToDraw[index].displayY + 55);
                g.moveTo(pointsToDraw[index].displayX, pointsToDraw[index].displayY);
                g.lineTo(pointsToDraw[index].displayX - 16, pointsToDraw[index].displayY + 72 - label.preferredSize.height);
                g.beginFill(0xFFFFFF, 0.5);
                g.drawRoundRect(pointsToDraw[index].displayX - label.preferredSize.width + 5, pointsToDraw[index].displayY + 19, label.preferredSize.width - 20, label.preferredSize.height - 10, 15);
                g.endFill();
            }
        }
//        index = 0;*/
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

        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

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