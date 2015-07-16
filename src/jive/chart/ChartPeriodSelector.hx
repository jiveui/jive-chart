package jive.chart;

import org.aswing.geom.IntPoint;
import org.aswing.geom.IntPoint;
import flash.events.MouseEvent;
import flash.display.Graphics;
import org.aswing.ASColor;
import flash.display.Sprite;
import org.aswing.AsWingUtils;
import org.aswing.graphics.Graphics2D;
import org.aswing.geom.IntRectangle;
import org.aswing.Component;
import flash.display.Shape;
import org.aswing.plaf.BaseComponentUI;

class ChartPeriodSelector  extends BaseComponentUI{

    private var shape:Shape;
    private var chart: Chart;
    private var widthWindow: Int;
    private var heightWindow: Int;

    public function new() {
        super();
    }

    private function getPropertyPrefix():String{
        return "ChartPeriosSelector.";
    }

    override public function paint(c:Component, g:Graphics2D, b:IntRectangle):Void {
        super.paint(c, g, b);

        chart = AsWingUtils.as(c, Chart);
        if (null == chart) return;

        chart.removeAll();
        if (null != shape) {
            chart.removeChild(shape);
        }

        if (null == chart.data || chart.data.length <= 0) return;

        shape = new Shape();
        chart.addChild(shape);

        widthWindow = b.width;
        heightWindow = b.height;

        drawAxises();
        drawGraph();
    }

    override public function installUI(c:Component):Void { }
    override public function uninstallUI(c:Component):Void { }

/**
    * Minimum and maximum x and y points.
    **/
    public var minPointX:Float = 0;
    public var minPointY:Float = 0;
    public var maxPointX:Float = 0;
    public var maxPointY:Float = 0;

    public var scalePointX:Float = 0;
    public var scalePointY:Float = 0;

/**
    * Offset values from the borders of the window
    **/
    public var windowIndentX:Float = 20;
    public var arrowIndentX:Float = 5;
    public var windowIndentY:Float = 20;
    public var arrowIndentY:Float = 3;

    public var xValueSize:Float = 0;
    public var yValueSize:Float = 0;


    public var newPoints:Array<Point> = [];
    public var bubbleDrawArea:Sprite;
    public var indexMin:Int = 0;
    public var circleRadius:Int = 2;

/**
    * Methods of finding the minimum and maximum points of the x and y
    **/
    public function calculateMinimumX(): Float{
        if (null == chart.data || chart.data.length <= 0) return 0;
        minPointX = chart.data[0].x;
        for (point in chart.data){
            if (minPointX > point.x)
                minPointX = point.x;
        }
        return minPointX;
    }

    public function  calculateMaximumX(): Float{
        if (null == chart.data || chart.data.length <= 0) return 0;
        maxPointX = chart.data[0].x;
        for (point in chart.data){
            if (maxPointX < point.x)
                maxPointX = point.x;
        }
        return maxPointX;
    }

    public function calculateMinimumY(): Float{
        if (null == chart.data || chart.data.length <= 0) return 0;
        minPointY = chart.data[0].y;
        for (point in chart.data){
            if (minPointY > point.y)
                minPointY = point.y;
        }
        trace("minY " + minPointY);
        return minPointY;
    }

    public function calculateMaximumY(): Float{
        if (null == chart.data || chart.data.length <= 0) return 0;
        maxPointY = chart.data[0].y;
        for (point in chart.data){
            if (maxPointY < point.y)
                maxPointY = point.y;
        }
        trace("maxY " + maxPointY);
        return maxPointY;
    }

/**
    * The scaling factor points x and y.
    **/
    public function calculateScalePointX(): Float{
        calculateMaximumX();
        calculateMinimumX();
        xValueSize = maxPointX - minPointX;
        scalePointX = (widthWindow - windowIndentX) / xValueSize ;
        trace (scalePointX);
        trace (xValueSize);
        return scalePointX;
    }

    public function calculateScalePointY(): Float {
        calculateMaximumY();
        calculateMinimumY();
        yValueSize = maxPointY - minPointY;
        scalePointY = (heightWindow - windowIndentY) / yValueSize;
        return scalePointY;
    }
    /**
    * Finding text width
    **/

    public function lineStyleAxises(){
        var g = shape.graphics;
        var thickness = 1.5;
        var color:ASColor = ASColor.BLACK;
        var alpha = 1;
        var pixelHinting = true;
        var miterLimit = 3;
        g.lineStyle(thickness, color.getRGB(), alpha, pixelHinting, miterLimit);
        return g;
    }

    public function lineStyleGrid(){
        var g = shape.graphics;
        var thickness = 0.3;
        var color = ASColor.GRAY;
        var alpha = 1;
        var pixelHinting = true;
        var miterLimit = 3;
        g.lineStyle(thickness, color.getRGB(), alpha, pixelHinting, miterLimit);
        return g;
    }

    public function lineStyleGraph(){
        var g = shape.graphics;
        var thickness = 0.5;
        var color = ASColor.RED;
        var alpha = 1;
        var pixelHinting = true;
        var miterLimit = 3;
        g.lineStyle(thickness, color.getRGB(), alpha, pixelHinting, miterLimit);
        return g;
    }

    /**
    * Draw axises x and y;
    * draw text value axises.
    **/
    public function drawAxises():Void{
        var g = shape.graphics;

        calculateMaximumX();
        calculateMaximumY();
        calculateScalePointX();
        calculateScalePointY();

        //axises
        lineStyleAxises();
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(windowIndentX, 0);
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(widthWindow, heightWindow - windowIndentY);
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow, 0);
        drawGridBorderLines(g);
    }

    private function drawGridBorderLines(g: Graphics) {
        lineStyleGrid();
        g.moveTo(windowIndentX, 0);
        g.lineTo(widthWindow, 0);
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow, 0);
    }

    private inline function calcDisplayX(x: Float) {
        return windowIndentX + (x - minPointX) * scalePointX;
    }

    private inline function calcDisplayY(y: Float) {
        return heightWindow - windowIndentY - (y - minPointY) * scalePointY;
    }

    public function drawGraph():Void{
        var data = chart.data;
        var g = shape.graphics;

        chart.removeChild(bubbleDrawArea);
        bubbleDrawArea = null;

//        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
//        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.graphics.drawRect(0, 0, widthWindow, heightWindow);

        calculateScalePointX();
        calculateScalePointY();
        lineStyleGraph();

        var x = calcDisplayX(data[0].x);
        g.moveTo(x, calcDisplayY(data[0].y));
        newPoints = [];

        for (point in data){
            var newX = calcDisplayX(point.x);
            if (Math.abs(x - newX) >= 7) {
                point.displayX = newX;
                point.displayY = calcDisplayY(point.y);
                newPoints.push(point);
                g.lineTo(point.displayX, point.displayY);
                x = newX;
            }
        }
    }
}
