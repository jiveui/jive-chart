package jive.chart;


import flash.Lib;
import flash.display.Stage;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.Capabilities;

import jive.Color;
import jive.Component;
// import jive.geom.Metric;
// import jive.geom.MetricInsets;
// import jive.geom.Insets;
// import jive.geom.IntDimension;
// import jive.geom.IntPoint;
// import jive.geom.IntRectangle;
// import jive.geom.MetricHelper;
import jive.geom.*;
import jive.graphics.Graphics2D;
import jive.graphics.SolidBrush;
import jive.events.TransformGestureEvent;
import jive.tools.*;

import jive.chart.ChartHelper;


class ChartUI {
    private var chart: Chart;

    private var pointsToDraw: Array<DisplayPoint>;
    private var stats: ChartStatistics;
    private var graphBounds: IntRectangle;
    private var extentBounds: IntRectangle;

    public var labels: Array<Label>;
    public var titleLabel: Label;
    public var xAxisLabel: Label;
    public var yAxisLabel: Label;

    public var graphScaleX(get, set): Float;
    private var _graphScaleX: Float = 1.0;
    private function get_graphScaleX(): Float { return _graphScaleX; }
    private function set_graphScaleX(v: Float): Float {
        _graphScaleX = v;
        if (_graphScaleX < 1.0) _graphScaleX = 1.0;

        calcGraphBounds();
        pointsToDraw = ChartHelper.getPointsNeededToDraw(chart.data, graphBounds, chart.minPointDistantion);

        ChartHelper.fillMainStatistics(stats, Lambda.array(Lambda.map(pointsToDraw, function(p) { return cast(p, Point);})), graphBounds, chart);
        ChartHelper.fillLabelsNumber(extentBounds, stats);
        ChartHelper.calculateDisplayCoordinates(pointsToDraw, graphBounds, stats);
        drawGraph(new Graphics2D(chart.graphComponent.graphics));

        return v;
    }

    public function new(c: Chart) {
        labels = [];

        chart = TypeTools.as(c, Chart);
        chart.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        chart.graphComponent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);

        // TODO
        // chart.graphScroll.addStateListener(function(e) {
        //     drawAxisesWithoutRemovingLabels(new Graphics2D(chart.sprite.graphics));
        // });

        titleLabel = new Label("titleLabel");
        xAxisLabel = new Label("xAxisLabel");
        yAxisLabel = new Label("yAxisLabel");

        titleLabel.name = "titleLabel";
        xAxisLabel.name = "xAxisLabel";
        yAxisLabel.name = "yAxisLabel";

        chart.labelsLayer.append(titleLabel);
        chart.labelsLayer.append(xAxisLabel);
        chart.labelsLayer.append(yAxisLabel);
    }

    private function getPropertyPrefix():String{
        return "Chart.";
    }

    public function paint(b: IntDimension):Void {
        // trace("paint");
        // trace(haxe.CallStack.toString(haxe.CallStack.callStack()));

        // if (null == chart || null == xAxisLabel || null == yAxisLabel) return; // Not installed yet

        if (null == chart || null == chart.data || chart.data.length <= 0 || null == titleLabel) return;

        titleLabel.text = chart.title;
        titleLabel.font = chart.titleFont;
        // titleLabel.pack();

    //     updateAxisTitlesTextAndVisibility();

        calcStatisticsAndGraphBounds(new IntRectangle(0, 0, b.width, b.height));
        ChartHelper.calculateDisplayCoordinates(pointsToDraw, graphBounds, stats);

        updateAxisTitlesPositions();
        createLabels(stats.labelsNumber);

        drawAxises(new Graphics2D(chart.sprite.graphics));
        drawGraph(new Graphics2D(chart.graphComponent.graphics));
        clearBubble();

        // trace(chart.graphScroll.x + " " + chart.graphScroll.y);
        // trace(chart.graphScroll.displayObject.x + " " + chart.graphScroll.displayObject.y);
        // trace(chart.graphComponent.x + " " + chart.graphComponent.y);
    }

    // TODO
    private function updateAxisTitlesTextAndVisibility() {

        xAxisLabel.text = if (null != chart.xAxis && chart.xAxisTitleVisible) chart.xAxis.axisUnit else null;
        xAxisLabel.font = chart.font;
        // xAxisLabel.pack();

        yAxisLabel.text = if (null != chart.yAxis && chart.yAxisTitleVisible) chart.yAxis.axisUnit else null;
        yAxisLabel.font = chart.font;
        if (chart.yAxisTitlePosition == YAxisTitlePosition.left) {
            yAxisLabel.rotationAngle = -90;
        }
        // yAxisLabel.pack();
    }

    // TODO
    private function updateAxisTitlesPositions() {
        // xAxisLabel.location = new IntPoint(
        //     Std.int(graphBounds.x + (graphBounds.width-xAxisLabel.preferredSize.width)/2),
        //     Std.int(graphBounds.leftBottom().y + stats.xLabelDimension.height + chart.axisMarginBetweenLabelsAndAxis));
        xAxisLabel.margin = new MetricInsets(
            Metric.absolute(Std.int(graphBounds.x + (graphBounds.width - xAxisLabel.getPreferredSize().width) / 2)),
            Metric.absolute(Std.int(graphBounds.leftBottom().y + stats.xLabelDimension.height + chart.axisMarginBetweenLabelsAndAxis))
        );

        // yAxisLabel.location =
        //     if (chart.yAxisTitlePosition == YAxisTitlePosition.left)
        //         new IntPoint(
        //             graphBounds.x - getYAxisTitleMargin() - stats.yLabelDimension.width,
        //             Std.int(graphBounds.y + graphBounds.height/2 + yAxisLabel.preferredSize.width))
        //     else
        //         new IntPoint(
        //             graphBounds.x - stats.yLabelDimension.width,
        //             Std.int(graphBounds.y - getYAxisTitleMargin()));
        if (chart.yAxisTitlePosition == YAxisTitlePosition.left) {
            yAxisLabel.margin = new MetricInsets(
                Metric.absolute(Std.int(graphBounds.y + graphBounds.height / 2 + yAxisLabel.getPreferredSize().width)), // y
                Metric.absolute(graphBounds.x - getYAxisTitleMargin() - stats.yLabelDimension.width) // x
            );
        } else {
            yAxisLabel.margin = new MetricInsets(
                Metric.absolute(Std.int(graphBounds.y - getYAxisTitleMargin())),
                Metric.absolute(graphBounds.x - stats.yLabelDimension.width)
            );
        }
    }

    private function calcStatisticsAndGraphBounds(b: IntRectangle) {
        stats = ChartHelper.calcStatistics(chart.data, b, chart);
        trace(stats);
        calcBounds(b);
        pointsToDraw = ChartHelper.getPointsNeededToDraw(chart.data, graphBounds, chart.minPointDistantion);
        stats = ChartHelper.calcStatistics(Lambda.array(Lambda.map(pointsToDraw, function(p) { return cast(p, Point);})), graphBounds, chart);
        trace(stats);
        ChartHelper.fillLabelsNumber(extentBounds, stats);
    }

    private function getXAxisTitleMargin(): Int {
        return if (chart.xAxisTitleVisible && xAxisLabel.text != null && xAxisLabel.text != "") {
            xAxisLabel.getPreferredSize().height + chart.axisMarginBetweenLabelsAndAxis;
        } else 0;
    }

    private function getYAxisTitleMargin(): Int {
        return if (chart.yAxisTitleVisible && yAxisLabel.text != null && yAxisLabel.text != "") {
            yAxisLabel.getPreferredSize().height  + chart.axisMarginBetweenLabelsAndAxis;
        } else 0;
    }

    private function calcBounds(b: IntRectangle) {
        calcExtentBounds(b);
        calcGraphBounds();
    }

    private function calcExtentBounds(b: IntRectangle) {
        // trace(titleLabel.text);
        // trace(titleLabel.getPreferredSize().width);
        // trace(titleLabel.getPreferredSize().height);

        var xAxisTitleMargin = getXAxisTitleMargin();
        var yAxisTitleMargin = getYAxisTitleMargin();
        extentBounds = b.clone();

        var dx = stats.yLabelDimension.width + chart.tickSize + (if (chart.yAxisTitlePosition == YAxisTitlePosition.left) yAxisTitleMargin else 0);
        var dy = Std.int(chart.selectorSize + 1) + titleLabel.getPreferredSize().height + (if (chart.yAxisTitlePosition != YAxisTitlePosition.left) yAxisTitleMargin else 0);
        extentBounds.move(dx, dy);
        
        var dw = -stats.yLabelDimension.width - chart.tickSize  - (if (chart.yAxisTitlePosition == YAxisTitlePosition.left) yAxisTitleMargin else 0);
        var dh = -stats.xLabelDimension.height - chart.tickSize - titleLabel.getPreferredSize().height - xAxisTitleMargin - (if (chart.yAxisTitlePosition != YAxisTitlePosition.left) yAxisTitleMargin else 0);
        extentBounds.resize(dw, dh);

        // trace(-stats.xLabelDimension.height);
        // trace(chart.tickSize);
        // trace(titleLabel.getPreferredSize().height);
        // trace(xAxisTitleMargin);
        // trace(if (chart.yAxisTitlePosition != YAxisTitlePosition.left) yAxisTitleMargin else 0);
        // trace(extentBounds);
                
        chart.graphScroll.width = Metric.absolute(extentBounds.width);
        chart.graphScroll.height = Metric.absolute(extentBounds.height);
        chart.graphScroll.margin = new MetricInsets(Metric.absolute(extentBounds.y), Metric.absolute(extentBounds.x));

        chart.labelsLayer.width = chart.width;
        chart.labelsLayer.height = chart.height;
    }

    private function calcGraphBounds() {
        graphBounds = extentBounds.clone();
        graphBounds.width = Std.int(graphScaleX * graphBounds.width);

        chart.graphContainer.width = Metric.absolute(graphBounds.width);
        chart.graphContainer.height = Metric.absolute(graphBounds.height);
    }

    // TODO do we need it? and where?
    // override public function uninstallUI(c:Component):Void {
    //     chart.graphComponent.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    //     chart.graphComponent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    //     chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    //     chart.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
    // }
    public function clear() {
        labels = [];
        chart.labelsLayer.removeAll();
        chart.graphComponent.graphics.clear();
        chart.graphics.clear();

        trace(labels);
        trace(chart.labelsLayer.sprite.numChildren);
    }

    /**
    * Draw axises x and y;
    * draw text value axises.
    **/
    public function drawAxises(g: Graphics2D) {
        chart.labelsLayer.removeAll();
        drawAxisesWithoutRemovingLabels(g);
    }

    private function drawAxisesWithoutRemovingLabels(g: Graphics2D) {
        g.clear();
        g.drawLine(chart.axisPen, extentBounds.x, extentBounds.y, extentBounds.x, extentBounds.y + extentBounds.height);
        g.drawLine(chart.axisPen, extentBounds.x, extentBounds.y + extentBounds.height, extentBounds.x + extentBounds.width, extentBounds.y + extentBounds.height);
        drawGridVerticalLinesAndCaptions(g);
        drawGridHorizontalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    private function getGridPoints(n: Int, min: Float, max: Float) {
        var draftStep = (max-min)/n;
        var power = Math.log(draftStep)/Math.log(10);
        var flooredPower = Math.ffloor(power);
        var low = Math.pow(10, flooredPower) ;
        var high = 10 * low;
        var half = high/2;
        var step = if (draftStep <= half) half else high;
        var first = Math.ffloor(min/step)*step;
        return [for (i in 0...n) first + i*step].filter(function(x) { return x - max < step && min <= x; });
    }

    // Draw vertical lines and labels on axis X
    private function drawGridVerticalLinesAndCaptions(g: Graphics2D) {
        var captionWidthWithMargin = stats.xLabelDimension.width;
        var ticksAmount = Std.int(extentBounds.width/captionWidthWithMargin)+1;
        var y = extentBounds.leftBottom().y;
        var x0 = extentBounds.x;

        for (i in 0...ticksAmount) {
            var x = x0 + i * captionWidthWithMargin;

            var t = labels[i];

            var minX = interpolateValue(/*chart.graphScroll.getViewPosition().x*/ MetricHelper.toAbsolute(chart.graphScroll.x), graphBounds.width, stats.minX, stats.maxX);
            var maxX = interpolateValue(/*chart.graphScroll.getViewPosition().x*/ MetricHelper.toAbsolute(chart.graphScroll.x) + extentBounds.width, graphBounds.width, stats.minX, stats.maxX);

            updateLabelForInterpolatedValue(t, chart.data[0].xValue, i, extentBounds.width/captionWidthWithMargin, minX, maxX, chart.xAxis);

            var margin = t.margin;
            
            trace(y);
            trace(margin);
            trace(chart.axisMarginBetweenLabelsAndAxis);
            trace(stats.xLabelDimension.width);
            trace(t.getPreferredSize().width);

            t.margin = new MetricInsets(
                Metric.absolute(Std.int(y + chart.tickSize) + MetricHelper.getAbsolute(margin.top) + chart.axisMarginBetweenLabelsAndAxis),
                Metric.absolute(Std.int(x - t.getPreferredSize().width / 2) + MetricHelper.getAbsolute(margin.left))
            );

            trace(t.text);
            trace(t.margin);

            if (MetricHelper.getAbsolute(t.margin.left) + t.getPreferredSize().width <= extentBounds.rightBottom().x) {
                chart.labelsLayer.append(t);
                g.drawLine(chart.axisPen, x, y, x, y + chart.tickSize);
                g.drawLine(chart.gridPen, x, y, x, extentBounds.y);
            }
        }
    }

    // Draw horizontal lines and labels on axis Y
    private function drawGridHorizontalLinesAndCaptions(g: Graphics2D) {
        var captionHeightWithMargin = stats.yLabelDimension.height;
        var ticksAmount = Std.int(extentBounds.height/captionHeightWithMargin)+1;
        var x = extentBounds.x;
        var y0 = extentBounds.height + extentBounds.y;

        var i = 0;

        // TODO
        for (p in getGridPoints(ticksAmount, stats.minY, stats.maxY)) {
            var y = y0 - extentBounds.height * (p - stats.minY) / (stats.maxY - stats.minY);
            var t = labels[i + stats.xLabelsNumber];
            updateLabel(t, chart.data[0].yValue, p, chart.yAxis);

            var margin = t.margin;
            t.margin = new MetricInsets(
                Metric.absolute(Std.int(y - t.getPreferredSize().height/2) + MetricHelper.getAbsolute(margin.top)),
                Metric.absolute(x - stats.yLabelDimension.width)
            );
          
            if (MetricHelper.getAbsolute(t.margin.top) >= extentBounds.y) {
                t.name = t.text;
                
                chart.labelsLayer.append(t);
                g.drawLine(chart.axisPen, x, y, x - chart.tickSize, y);
                g.drawLine(chart.gridPen, x, y, extentBounds.x + extentBounds.width, y);
            }
            i += 1;
        }
    }

    private function createLabels(n: Int) {
        if (n > labels.length) {
            for (i in 0...n-labels.length) {
                var l = new Label();
                l.font = chart.font;
                labels.push(l);
            }
        } else {
            for (i in 0...labels.length-n) {
                chart.labelsLayer.remove(labels.pop());
            }
        }
    }

    // TODO
    private function updateLabelForInterpolatedValue(label: Label, valueTranslator: ChartValue, index: Int, amount: Float, min: Float, max: Float, axis: Axis) {
        var value = interpolateValue(index, amount, min, max);
        updateLabel(label, valueTranslator, value, axis);
    }

    private function updateLabel(label: Label, valueTranslator: ChartValue, value: Float, axis: Axis) {
        label.text = if (null != axis) axis.getValueString(valueTranslator.getChartValueByFloatValue(value))
        else valueTranslator.getCaptionByFloatValue(value);
        // label.foreground = chart.axisLabelColor;
        // label.pack();
    } 

    private function drawGridBorderLines(g: Graphics2D) {
        g.drawLine(chart.gridPen, extentBounds.x, extentBounds.y, extentBounds.x + extentBounds.width, extentBounds.y);
        g.drawLine(chart.gridPen, extentBounds.x + extentBounds.width, extentBounds.y + extentBounds.height, extentBounds.x + extentBounds.width, extentBounds.y);
    }

    private function interpolateValue(index: Float, length: Float, min: Float, max: Float): Float {
        return index * ((max - min) / length) + min;
    }

    // private var shouldBubbleBeShowed: Bool;
    // private var mouseDownPoint: IntPoint;

    // public function onMouseDown(e:MouseEvent):Void {
    //     shouldBubbleBeShowed = true;
    //     mouseDownPoint = new IntPoint(Std.int(e.stageX), Std.int(e.stageY));
    // }

    // public function onMouseMove(e:MouseEvent):Void {
    //     if (shouldBubbleBeShowed == true && mouseDownPoint.distance(new IntPoint(Std.int(e.stageX), Std.int(e.stageY))) > Capabilities.screenDPI/10) {
    //         shouldBubbleBeShowed = false;
    //         clearBubble();
    //     }
    // }

    public function onMouseUp(e:MouseEvent):Void {
        if (shouldBubbleBeShowed) {
            var index = calculateNearesPointIndex(ComponentTools.globalToLocal(chart.graphComponent, new IntPoint(Std.int(e.stageX), 0)).x);
            drawBubble(index);
        }
    }

    private function clearBubble() {
        chart.interactionLayer.removeAll();
        chart.interactionLayer.sprite.graphics.clear();
    }

    // TODO LABEL
    public function drawBubble(index: Int) {
        var p = pointsToDraw[index];
        var g: Graphics2D = new Graphics2D(chart.interactionLayer.sprite.graphics);
        g.clear();


        var text =
            chart.xAxis.getLabelValueString(p.minX.xValue, p.maxX.xValue) +
            "\n" +
            chart.yAxis.getLabelValueString(p.minY.yValue, p.maxY.yValue);

        var label = new Label(text);
        label.font = chart.font;
        // label.border = new EmptyBorder(null, Insets.createIdentic(chart.selectorBubblePadding));

        var pX: Float = pointsToDraw[index].displayX;
        var pY: Float = pointsToDraw[index].displayY;

        var pointLocationAtExtent = ComponentTools.globalToLocal(chart, ComponentTools.localToGlobal(chart.graphComponent, new IntPoint(Std.int(pX), Std.int(pY))));

        var cornerRadius = chart.selectorBubbleCornerRadius;
        var tailSize: Float = chart.selectorBubbleTailSize;
        var contentDimension = label.getPreferredSize();
        var incline: Float = tailSize*0.5;

        var dx = 1.0;
        if (pointLocationAtExtent.x < extentBounds.x + extentBounds.width/2) {
            dx = 1.0;
        } else {
            dx = -1.0;
        }

        var dy = 1.0;
        if (pointLocationAtExtent.y > extentBounds.y + extentBounds.height / 2){
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

        // label.foreground = chart.axisLabelColor;
        // label.pack();

        if (dy > 0) {
            if (dx > 0) {
                label.x = Metric.absolute(corner2.x);
                label.y = Metric.absolute(corner2.y);
            } else {
                label.x = Metric.absolute(corner3.x);
                label.y = Metric.absolute(corner3.y);
            }
        } else {
            if (dx > 0) {
                label.x = Metric.absolute(corner1.x);
                label.y = Metric.absolute(corner1.y);
            } else {
                label.x = Metric.absolute(corner4.x);
                label.y = Metric.absolute(corner4.y);
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
    public function drawGraph(g: Graphics2D):Void {
        g.clear();

        g.fillRectangle(new SolidBrush(Color.WHITE.changeAlpha(0.0)), 0, 0, graphBounds.width, graphBounds.height);

        if (chart.fillSpaceUnderPolyline) {
            ChartHelper.fillSpaceUnderPolyline(g, pointsToDraw, chart.areaUnderLineBrush, graphBounds);
        }

        ChartHelper.drawPolyline(g, pointsToDraw, chart.graphPen);

        if (chart.markPoints) {
            for (point in pointsToDraw){
                g.fillCircle(chart.markBrush, point.displayX, point.displayY, chart.markSize);
                g.drawCircle(chart.markPen, point.displayX, point.displayY, chart.markSize);
            }
        }
    }

    private function onZoom(e: TransformGestureEvent) {
        var width = graphBounds.width;
        graphScaleX *= e.scaleX;
        // graphBounds is changed so scroll to the same place
        // TODO
        // chart.graphScroll.scrollHorizontal(-Std.int((width - graphBounds.width)/2));
    }

}