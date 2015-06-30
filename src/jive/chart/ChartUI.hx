package jive.chart;


import flash.display.Graphics;
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

    public var TextFields:Array<JTextField>;
    private var shape:Shape;
    private var chart: Chart;
    private var widthWindow: Int;
    private var heightWindow: Int;

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

        chart.removeAll();
        if (null != shape) {
            chart.removeChild(shape);
        }

        if (null == chart.data || chart.data.length <= 0) return;

        shape = new Shape();
        chart.addChild(shape);

        TextFields = [];

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

    // sticks text field
    public var xValueSize:Float = 0;
    public var yValueSize:Float = 0;

    public var textMargin:Int = 10;
    public var textWidthX:Int = 0;
    public var textWidthY:Int = 0;
    public var textHeightX:Int = 0;




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
        scalePointX = (widthWindow - windowIndentX) / xValueSize;
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
    public function calculateMaxTextWidthX(): Float {
        if (null == chart.data || chart.data.length <= 0) return 0;
        calculateMinimumX();
        calculateMaximumX();
        var tf: JTextField = new JTextField(chart.data[0].xValue.getCaptionByFloatValue( if (minPointX < 0) minPointX else maxPointX));
        textWidthX = Std.int(tf.preferredSize.width);
        textHeightX = Std.int(tf.preferredSize.height);
        return textWidthX;
    }

    public function calculateMaxTextWidthY(): Float {
        if (null == chart.data || chart.data.length <= 0) return 0;
        calculateMinimumY();
        calculateMaximumY();
        var tf: JTextField = new JTextField(chart.data[0].yValue.getCaptionByFloatValue( if (minPointY < 0) minPointY else maxPointY));
        textWidthY = Std.int(tf.preferredSize.width);
        return textWidthY;
    }

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
        calculateMaximumX();
        calculateMaximumY();
        calculateScalePointX();
        calculateScalePointY();
        calculateMaxTextWidthX();
        calculateMaxTextWidthY();

        windowIndentX = textWidthY;
        windowIndentY = textHeightX + arrowIndentY;

        var g = shape.graphics;

        //axises
        lineStyleAxises();
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(windowIndentX, 0);
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(widthWindow, heightWindow - windowIndentY);

        drawGridVerticalLinesAndCaptions(g);
        drawGridHorizontalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    private function drawGridVerticalLinesAndCaptions(g: Graphics) {
        lineStyleAxises();
        var captionWidthWithMargin = textMargin + textWidthX;
        var areaWidth = widthWindow - windowIndentX;
        var sticksAmount = Std.int(areaWidth/captionWidthWithMargin) + 1;
        var y = heightWindow - windowIndentY;
        var stickSize = arrowIndentY;
        var x0 = windowIndentX;
        for (i in 0...sticksAmount) {
            var t = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(interpolateValue(i, sticksAmount, minPointX, maxPointX)));
            var insets = t.getInsets();
            TextFields.push(t);

            var x = x0 + i * captionWidthWithMargin;
            g.moveTo(x, y);
            g.lineTo(x, y + stickSize);

            trace(t.preferredSize);

            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + stickSize) + insets.top);
            chart.append(t);

            lineStyleGrid();
            g.moveTo(x, y);
            g.lineTo(x, 0);
            lineStyleAxises();
        }
    }

    private function drawGridHorizontalLinesAndCaptions(g: Graphics) {
        lineStyleAxises();
        var captionHeightWithMargin = textMargin + textWidthY;
        var areaHeight = heightWindow - windowIndentY;
        var sticksAmount = Std.int(areaHeight/captionHeightWithMargin) + 1;
        var x = windowIndentX;
        var stickSize = arrowIndentX;
        var y0 = heightWindow - windowIndentY;
        for (i in 0...sticksAmount) {
            var t = new JTextField(chart.data[0].yValue.getCaptionByFloatValue(interpolateValue(i, sticksAmount, minPointY, maxPointY)));
            var insets = t.getInsets();
            TextFields.push(t);

            var y = y0 - i * captionHeightWithMargin;
            g.moveTo(x, y);
            g.lineTo(x - stickSize, y);

            t.location = new IntPoint(insets.left, Std.int(y - t.preferredSize.height/2) + insets.top);
            chart.append(t);

            lineStyleGrid();
            g.moveTo(x, y);
            g.lineTo(widthWindow, y);
            lineStyleAxises();
        }
    }

    private function drawGridBorderLines(g: Graphics) {
        lineStyleGrid();
        g.moveTo(windowIndentX, 0);
        g.lineTo(widthWindow, 0);
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow, 0);
    }


    private function interpolateValue(index: Int, length: Int, min: Float, max: Float): Float {
        return index * ((max - min) / length) + min;
    }


    public function drawCircleOnPoint():Void{
        var data = chart.data;
        var g = shape.graphics;

        var circleRadius:Int = 3;
        calculateScalePointX();
        calculateScalePointY();
        var x = windowIndentX + (data[0].x - minPointX) * scalePointX;
        var y = heightWindow - windowIndentY - (data[0].y - minPointY) * scalePointY;
        for (point in data){
            var newX = windowIndentX + (point.x - minPointX)  * scalePointX;
            var newY = heightWindow - windowIndentY - (point.y - minPointY)  * scalePointY;
            if (Math.abs(newX - x) >= 5) {
                y = newY;
                x = newX;
                g.beginFill(0xFFFFFF, 1.0);
                g.drawCircle(x, y, circleRadius);
                g.endFill();

        }
    }

    /*public function newPoints():Void {
        var data = chart.data;*/

    }
    /**
    * Draw graph at points at axises X and Y;
    * If points y have negative value, then axis x is positive, axis y is negative;
    * If points x haxe negative valuse, then axis x is negatime, axis y is positive;
    * If points x and y have negative value, then axis x and y is negative.
    **/
    public function drawGraph():Void{

        var data = chart.data;

        var g = shape.graphics;
        calculateScalePointX();
        calculateScalePointY();
        lineStyleGraph();

        var x = windowIndentX + (data[0].x - minPointX) * scalePointX;
        var y = heightWindow - windowIndentY - (data[0].y - minPointY) * scalePointY;
        g.moveTo(x, y);
        for (point in data){
            var newX = windowIndentX + (point.x - minPointX)  * scalePointX;
            var newY = heightWindow - windowIndentY - (point.y - minPointY)  * scalePointY;
            if (Math.abs(newX - x) >= 5) {
                y = newY;
                x = newX;
                g.lineTo(x, y);
            }
        }
        drawCircleOnPoint();
    }


}
