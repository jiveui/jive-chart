package jive.chart;

import jive.*;
import jive.geom.*;
import jive.graphics.*;
import jive.events.TransformGestureEvent;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.Capabilities;
import Array;

class Chart extends Container {

    public var xAxis(get, set): Axis;
    private var _xAxis: Axis;
    private function get_xAxis(): Axis { return _xAxis; }
    private function set_xAxis(v: Axis): Axis {
        _xAxis = v;
        if (null == _xAxis) _xAxis = new Axis();
        repaint();
        return v;
    }

    public var xAxisTitleVisible = false;
    public var yAxisTitleVisible = false;
    public var yAxisTitlePosition = YAxisTitlePosition.left;

    public var yAxis(get, set): Axis;
    private var _yAxis: Axis;
    private function get_yAxis(): Axis { return _yAxis; }
    private function set_yAxis(v: Axis): Axis {
        _yAxis = v;
        if (null == _yAxis) _yAxis = new Axis();
        repaint();
        return v;
    }

    public var title(default, set): String;
    private var _title: String;
    // private function get_title(): String { return _title; }
    private function set_title(v: String): String {
        _title = v;
        repaint();
        return v;
    }

    public var tickSize: Int = 5;
    public var axisPen: IPen;
    public var axisLabelColor: Color;
    public var axisMarginBetweenLabels: Int = Std.int(Jive.theme.margin / 2);
    public var axisMarginBetweenLabelsAndAxis: Int = Std.int(Jive.theme.margin / 3);
    public var graphPen: IPen;
    public var selectorPen: IPen;
    public var selectorBrush: IBrush;
    public var selectorBubbleBorder: IPen;
    public var selectorBubbleBackground: IBrush;
    public var selectorBubblePadding: Int = Std.int(Jive.theme.margin / 5);
    public var selectorBubbleTailSize: Int = Std.int(Jive.theme.margin / 2);
    public var selectorBubbleCornerRadius: Int = Jive.theme.cornerSize;

    public var selectorSize: Int = Std.int(Jive.theme.margin / 10);
    public var gridPen: IPen;
    public var areaUnderLineBrush: IBrush;

    public var titleFont: Font;

    public var markBrush: IBrush;
    public var markPen: IPen;
    public var markSize: Int = Std.int(Jive.theme.margin / 12);

    public var minPointDistantion: Int = Std.int(Jive.theme.margin / 4);

    public var data(get, set):Array<Point>;
    private var _data: Array<Point>;
    private function get_data(): Array<Point> { return _data; }
    private function set_data(v: Array<Point>): Array<Point> {
        if (null == v) v = [];
        _data = Lambda.array(Lambda.map(v, function(p) { return p.clone();}));
        _data.sort(function(a,b) { return if (a.x < b.x) -1 else 1; });
        repaint();
        return _data;
    }

    public var fillSpaceUnderPolyline: Bool = false;
    public var markPoints: Bool = true;
    public var unselectedAreaBrush: IBrush;

    public var labelsLayer: Container;
    public var interactionLayer: Container;
    public var graphViewport: Scroll;
    public var graphComponent: Component;
    public var axisComponent: Component;

    private var pointsToDraw: Array<DisplayPoint>;
    private var stats: ChartStatistics;
    private var graphBounds: IntRectangle;
    private var extentBounds: IntRectangle;

    // Label not implemented
    // public var labels:Array<JLabel>;
    // public var titleLabel: JLabel;
    // public var xAxisLabel: JLabel;
    // public var yAxisLabel: JLabel;

    public var graphScaleX(default, set): Float;
    private var _graphScaleX: Float = 1.0;
    private function set_graphScaleX(v: Float): Float {
        _graphScaleX = v;
        if (_graphScaleX < 1.0) _graphScaleX = 1.0;

        calcGraphBounds();
        pointsToDraw = ChartHelper.getPointsNeededToDraw(data, graphBounds, minPointDistantion);
        ChartHelper.fillMainStatistics(stats, Lambda.array(Lambda.map(pointsToDraw, function(p) { return cast(p, Point);})), graphBounds, this);
        ChartHelper.fillLabelsNumber(extentBounds, stats);
        ChartHelper.calculateDisplayCoordinates(pointsToDraw, graphBounds, stats);
        drawGraph(new Graphics2D(graphComponent.displayObject.graphics));

        return v;
    }


    public function new(title = ""){
        super();

        _xAxis = new Axis();
        _yAxis = new Axis();

        data = [];

        var dpiScale: Float = Jive.theme.dpiScale / 3;

        axisPen = new Pen(Color.BLACK, 1.5 * dpiScale, true);
        graphPen = new Pen(Color.RED, 2.5 * dpiScale, true);
        unselectedAreaBrush = new SolidBrush(Color.RED.changeAlpha(0.5));
        gridPen = new Pen(Color.GRAY, 0.3 * dpiScale, true);
        selectorPen = new Pen(Color.RED, 1 * dpiScale, true);
        selectorBrush = new SolidBrush(Color.RED);
        markPen = new Pen(Color.RED, 0.7 * dpiScale, true);
        markBrush = new SolidBrush(Color.WHITE);
        selectorBubbleBorder = new Pen(Color.DARK_GRAY, 0.7 * dpiScale);
        selectorBubbleBackground = new SolidBrush(new Color(0xe5e5e5,0.8));
        labelsLayer = new Container();
        interactionLayer = new Container();
        axisLabelColor = Color.GRAY;
        areaUnderLineBrush = new SolidBrush(Color.RED.changeAlpha(0.3));

        titleFont = Jive.theme.controlHeaderFont;

        graphComponent = new Component();
        axisComponent = new Component();
        graphViewport = new Scroll();
        {
            var container = new Container();
            container.append(graphComponent);
            container.append(interactionLayer);
            graphViewport.append(container);
            // graphViewport.setViewPosition(new IntPoint(0,0)); Not implemented
        }

        append(axisComponent);
        append(graphViewport);
        append(labelsLayer);

        initUI();

        // doLayout(); Not implemented
    }

    function initUI() {
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
        graphComponent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        // graphViewport.addStateListener(function(e) {
        //     drawAxisesWithoutRemovingLabels(new Graphics2D(graphics));
        // });

        // titleLabel = new JLabel();
        // titleLabel.location = new IntPoint(0,0);

        // xAxisLabel = new JLabel();
        // yAxisLabel = new JLabel();

        // append(titleLabel);
        // append(xAxisLabel);
        // append(yAxisLabel);
    }

    /**
    * Events
    **/

    private var shouldBubbleBeShowed: Bool;
    private var mouseDownPoint: IntPoint;

    public function onMouseDown(e:MouseEvent):Void {
        shouldBubbleBeShowed = true;
        mouseDownPoint = new IntPoint(Std.int(e.stageX), Std.int(e.stageY));
    }

    public function onMouseMove(e:MouseEvent):Void {
        if (shouldBubbleBeShowed == true && mouseDownPoint.distance(new IntPoint(Std.int(e.stageX), Std.int(e.stageY))) > Capabilities.screenDPI/10) {
            shouldBubbleBeShowed = false;
            clearBubble();
        }
    }

    public function onMouseUp(e:MouseEvent):Void {
        if (shouldBubbleBeShowed) {
            var index = calculateNearesPointIndex(graphComponent.globalToComponent(new IntPoint(Std.int(e.stageX), 0)).x);
            drawBubble(index);
        }
    }

    private function calcStatisticsAndGraphBounds(b: IntRectangle) {
        stats = ChartHelper.calcStatistics(data, b, this);
        calcBounds(b);
        pointsToDraw = ChartHelper.getPointsNeededToDraw(data, graphBounds, minPointDistantion);
        stats = ChartHelper.calcStatistics(Lambda.array(Lambda.map(pointsToDraw, function(p) { return cast(p, Point);})), graphBounds, this);
        ChartHelper.fillLabelsNumber(extentBounds, stats);
    }

    private function calcBounds(b: IntRectangle) {
        calcExtentBounds(b);
        calcGraphBounds();
    }

    private function calcExtentBounds(b: IntRectangle) {
        var xAxisTitleMargin = getXAxisTitleMargin();
        var yAxisTitleMargin = getYAxisTitleMargin();
        extentBounds = b.clone();
        extentBounds.move(
            stats.yLabelDimension.width + tickSize + (if (yAxisTitlePosition == YAxisTitlePosition.left) yAxisTitleMargin else 0),
            Std.int(selectorSize+1) + Std.int(titleLabel.preferredSize.height) + (if (yAxisTitlePosition != YAxisTitlePosition.left) yAxisTitleMargin else 0));
        extentBounds.resize(
            -stats.yLabelDimension.width - tickSize  - (if (yAxisTitlePosition == YAxisTitlePosition.left) yAxisTitleMargin else 0),
            -stats.xLabelDimension.height - tickSize - Std.int(titleLabel.preferredSize.height) - xAxisTitleMargin - (if (yAxisTitlePosition != YAxisTitlePosition.left) yAxisTitleMargin else 0));

        graphViewport.preferredSize = new IntDimension(extentBounds.width, extentBounds.height);
        graphViewport.setSize(graphViewport.preferredSize);
        graphViewport.location = new IntPoint(extentBounds.x, extentBounds.y);
    }

    private function calcGraphBounds() {
        graphBounds = extentBounds.clone();
        graphBounds.width = Std.int(graphScaleX * graphBounds.width);

        // graphViewport.view.preferredSize = new IntDimension(graphBounds.width, graphBounds.height);
        // graphViewport.view.setSize(graphComponent.preferredSize);
    }

    /**
    * Draw axises x and y;
    * draw text value axises.
    **/

    override public function paint(b:IntDimension):Void {

        // if (null == xAxisLabel || null == yAxisLabel) return; // Not installed yet

        super.paint(b);

        if (null == data || data.length <= 0 || null == titleLabel) return;

        // titleLabel.text = title;
        // titleLabel.font = titleFont;
        // titleLabel.pack();

        updateAxisTitlesTextAndVisibility();

        calcStatisticsAndGraphBounds(b);
        ChartHelper.calculateDisplayCoordinates(pointsToDraw, graphBounds, stats);

        updateAxisTitlesPositions();

        createLabels(stats.labelsNumber);

        drawAxises(new Graphics2D(axisComponent.graphics));
        drawGraph(new Graphics2D(graphComponent.graphics));
        clearBubble();
    } 

    public function drawAxises(g: Graphics2D) {
        labelsLayer.removeAll();
        drawAxisesWithoutRemovingLabels(g);
    }

    private function drawAxisesWithoutRemovingLabels(g: Graphics2D) {
        g.clear();
        g.drawLine(axisPen, extentBounds.x, extentBounds.y, extentBounds.x, extentBounds.y + extentBounds.height);
        g.drawLine(axisPen, extentBounds.x, extentBounds.y + extentBounds.height, extentBounds.x + extentBounds.width, extentBounds.y + extentBounds.height);
        drawGridVerticalLinesAndCaptions(g);
        drawGridHorizontalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    private function drawGridVerticalLinesAndCaptions(g: Graphics2D) {
        var captionWidthWithMargin = stats.xLabelDimension.width;
        var ticksAmount = Std.int(extentBounds.width/captionWidthWithMargin)+1;
        var y = extentBounds.leftBottom().y;
        var x0 = extentBounds.x;

        for (i in 0...ticksAmount) {
            var x = x0 + i * captionWidthWithMargin;

            // var t = labels[i];

            // var minX = interpolateValue(graphViewport.getViewPosition().x, graphBounds.width, stats.minX, stats.maxX);
            // var maxX = interpolateValue(graphViewport.getViewPosition().x + extentBounds.width, graphBounds.width, stats.minX, stats.maxX);

            // updateLabelForInterpolatedValue(t, data[0].xValue, i, extentBounds.width/captionWidthWithMargin, minX, maxX, xAxis);

            // var insets = t.getInsets();
            // t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + tickSize) + insets.top + axisMarginBetweenLabelsAndAxis);
            // if (t.location.x + t.preferredSize.width <= extentBounds.rightBottom().x) {
            //     labelsLayer.append(t);
                g.drawLine(axisPen, x, y, x, y + tickSize);
                g.drawLine(gridPen, x, y, x, extentBounds.y);
            // }
        }
    }

    private function drawGridHorizontalLinesAndCaptions(g: Graphics2D) {
        var captionHeightWithMargin = stats.yLabelDimension.height;
        var ticksAmount = Std.int(extentBounds.height/captionHeightWithMargin)+1;
        var x = extentBounds.x;
        var y0 = extentBounds.height + extentBounds.y;

        var i = 0;
        for (p in getGridPoints(ticksAmount, stats.minY, stats.maxY)) {
            var y = y0 - extentBounds.height * (p - stats.minY) / (stats.maxY - stats.minY);
            var t = labels[i + stats.xLabelsNumber];
            updateLabel(t, data[0].yValue, p, yAxis);
            var insets = t.getInsets();
            t.location = new IntPoint(x - stats.yLabelDimension.width, Std.int(y - t.preferredSize.height/2) + insets.top);
            if (t.location.y >= extentBounds.y) {
                labelsLayer.append(t);
                g.drawLine(axisPen, x, y, x - tickSize, y);
                g.drawLine(gridPen, x, y, extentBounds.x + extentBounds.width, y);
            }
            i += 1;
        }
    }

    private function drawGridBorderLines(g: Graphics2D) {
        g.drawLine(gridPen, extentBounds.x, extentBounds.y, extentBounds.x + extentBounds.width, extentBounds.y);
        g.drawLine(gridPen, extentBounds.x + extentBounds.width, extentBounds.y + extentBounds.height, extentBounds.x + extentBounds.width, extentBounds.y);
    }

    private function clearBubble() {
        interactionLayer.removeAll();
        interactionLayer.displayObjectContainer.graphics.clear();
    }

    public function drawBubble(index: Int) {
        // This function require a lot of work

        // var p = pointsToDraw[index];
        // var g: Graphics2D = new Graphics2D(interactionLayer.displayObjectContainer.graphics);
        // g.clear();


        // var text =
        //     xAxis.getLabelValueString(p.minX.xValue, p.maxX.xValue) +
        //     "\n" +
        //     yAxis.getLabelValueString(p.minY.yValue, p.maxY.yValue);

        // var label = new JLabel(text);
        // label.font = font;
        // label.border = new EmptyBorder(null, Insets.createIdentic(selectorBubblePadding));

        // var pX: Float = pointsToDraw[index].displayX;
        // var pY: Float = pointsToDraw[index].displayY;

        // var pointLocationAtExtent = globalToComponent(graphComponent.componentToGlobal(new IntPoint(Std.int(pX), Std.int(pY))));

        // var cornerRadius = selectorBubbleCornerRadius;
        // var tailSize: Float = selectorBubbleTailSize;
        // var contentDimension = label.preferredSize;
        // var incline: Float = tailSize*0.5;

        // var dx = 1.0;
        // if (pointLocationAtExtent.x < extentBounds.x + extentBounds.width/2) {
        //     dx = 1.0;
        // } else {
        //     dx = -1.0;
        // }

        // var dy = 1.0;
        // if (pointLocationAtExtent.y > extentBounds.y + extentBounds.height / 2){
        //     dy = 1.0;
        // } else {
        //     dy = -1.0;
        // }

        // var corner1 = new IntPoint(Std.int(pX + dx * (tailSize/2)), Std.int(pY - dy * (tailSize + incline)));
        // var corner2 = new IntPoint(Std.int(pX + dx * tailSize/2), Std.int(pY -  dy *(tailSize + contentDimension.height + incline)));
        // var corner3 = new IntPoint(Std.int(pX + dx * (tailSize/2 + contentDimension.width)), Std.int(pY - dy * (tailSize + contentDimension.height + incline)));
        // var corner4 = new IntPoint(Std.int(pX + dx * (tailSize/2 + contentDimension.width)), Std.int(pY - dy * (tailSize + incline)));

        // g.beginDraw(selectorBubbleBorder);
        // g.beginFill(selectorBubbleBackground);
        // g.moveTo(pX, pY);
        // g.lineTo(pX + dx * (tailSize/2 + cornerRadius*2), pY - dy * (tailSize + incline));
        // g.lineTo(pX + dx * (tailSize/2 + cornerRadius), pY - dy * (tailSize + incline));
        // g.curveTo(corner1.x, corner1.y, corner1.x, pY - dy * (tailSize + cornerRadius + incline));
        // g.lineTo(pX + dx * tailSize/2, pY - dy * (tailSize + contentDimension.height - cornerRadius + incline));
        // g.curveTo(corner2.x, corner2.y,
        //             pX + dx * (tailSize/2 + cornerRadius), pY - dy * (tailSize + contentDimension.height + incline));
        // g.lineTo(pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - dy * (tailSize + contentDimension.height + incline));
        // g.curveTo(corner3.x, corner3.y,
        //             pX + dx * (tailSize/2 + contentDimension.width), pY - dy * (tailSize + contentDimension.height - cornerRadius + incline));
        // g.lineTo(pX + dx * (tailSize/2 + contentDimension.width), pY - dy * (tailSize + cornerRadius + incline));
        // g.curveTo(corner4.x, corner4.y,
        //             pX + dx * (tailSize/2 + contentDimension.width - cornerRadius), pY - dy * (tailSize + incline));
        // g.lineTo(pX + dx * (tailSize*1.25 + cornerRadius*2), pY - dy * (tailSize + incline));
        // g.lineTo(pX, pY);
        // g.endDraw();
        // g.endFill();

        // g.fillCircle(selectorBrush, pX, pY, selectorSize);

        // label.foreground = axisLabelColor;
        // label.pack();

        // if (dy > 0) {
        //     if (dx > 0) {
        //         label.location = corner2;
        //     } else {
        //         label.location = corner3;
        //     }
        // } else {
        //     if (dx > 0) {
        //         label.location = corner1;
        //     } else {
        //         label.location = corner4;
        //     }
        // }

        // interactionLayer.removeAll();
        // interactionLayer.append(label);
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

        if (fillSpaceUnderPolyline) {
            ChartHelper.fillSpaceUnderPolyline(g, pointsToDraw, areaUnderLineBrush, graphBounds);
        }

        ChartHelper.drawPolyline(g, pointsToDraw, graphPen);

        if (markPoints) {
            for (point in pointsToDraw){
                g.fillCircle(markBrush, point.displayX, point.displayY, markSize);
                g.drawCircle(markPen, point.displayX, point.displayY, markSize);
            }
        }
    }

    private function onZoom(e: TransformGestureEvent) {
        var width = graphBounds.width;
        graphScaleX *= e.scaleX;
        // graphBounds is changed so scroll to the same place
        // graphViewport.scrollHorizontal(-Std.int((width - graphBounds.width)/2)); Not implemented
    }
}


