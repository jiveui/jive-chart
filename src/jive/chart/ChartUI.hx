package jive.chart;


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

    public var TextFields:Array<JTextField>;
    private var shape:Shape;
    private var chart: Chart;
    private var widthWindow: Int;
    private var heightWindow: Int;
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

    public var xValueSize:Float = 0;
    public var yValueSize:Float = 0;

    public var textMargin:Int = 10;
    public var textWidthX:Int = 0;
    public var textWidthY:Int = 0;
    public var textHeightX:Int = 0;
    public var textHeightY:Int = 0;

    public var newPoints:Array<Point> = [];
    public var bubbleDrawArea:Sprite;
    public var indexMin:Int = 0;
    public var circleRadius:Int = 2;
    public var tf:JTextField;

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
    public function calculateMaxTextWidthX(): Float {
        if (null == chart.data || chart.data.length <= 0) return 0;
        calculateMinimumX();
        calculateMaximumX();
        var tf: JTextField = new JTextField(chart.data[0].xValue.getCaptionByFloatValue( if (minPointX < 0) minPointX else maxPointX));
        textWidthX = Std.int(tf.preferredSize.width);
        textHeightX = Std.int(tf.preferredSize.height);
        trace("text width X:" + textWidthX);
        return textWidthX;
    }

    public function calculateMaxTextWidthY(): Float {
        if (null == chart.data || chart.data.length <= 0) return 0;
        calculateMinimumY();
        calculateMaximumY();
        var tf: JTextField = new JTextField(chart.data[0].yValue.getCaptionByFloatValue( if (minPointY < 0) minPointY else maxPointY));
        textWidthY = Std.int(tf.preferredSize.width);
        trace("text width Y:" + textWidthY);
        return textWidthY;
    }

    public function calculateMaxTextHeightY():Float {
        if (null == chart.data || chart.data.length <= 0) return 0;
        calculateMinimumY;
        calculateMaximumX;
        var tf: JTextField = new JTextField(chart.data[0].yValue.getCaptionByFloatValue( if (minPointY < 0) minPointY else maxPointY));
        textHeightY = Std.int(tf.preferredSize.height);
        trace("text height Y:" + textHeightY);
        return textHeightY;
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
        var g = shape.graphics;

        calculateMaximumX();
        calculateMaximumY();
        calculateScalePointX();
        calculateScalePointY();
        calculateMaxTextWidthX();
        calculateMaxTextWidthY();
        calculateMaxTextHeightY();

        windowIndentX = textWidthY;
        windowIndentY = textHeightX + arrowIndentY;

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
        var captionWidthWithMargin = textWidthX;
        var areaWidth = widthWindow - windowIndentX;
        var sticksAmount = Std.int(areaWidth/captionWidthWithMargin)+1;
        var y = heightWindow - windowIndentY;
        var stickSize = arrowIndentY;
        var x0 = windowIndentX;
        trace("areaWidth " + areaWidth);
        for (i in 0...sticksAmount) {
            var t = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(interpolateValue(i, areaWidth/captionWidthWithMargin, minPointX, maxPointX)));
            var insets = t.getInsets();
            TextFields.push(t);
            var x = x0 + i * captionWidthWithMargin;
            g.moveTo(x, y);
            g.lineTo(x, y + stickSize);
            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + stickSize) + insets.top);
            chart.append(t);
            trace(t.text);
            lineStyleGrid();
            g.moveTo(x, y);
            g.lineTo(x, 0);
            lineStyleAxises();
        }
    }

    private function drawGridHorizontalLinesAndCaptions(g: Graphics) {
        lineStyleAxises();
        var captionHeightWithMargin = textHeightY;
        var areaHeight = heightWindow - windowIndentY;
        var sticksAmount = Std.int(areaHeight/captionHeightWithMargin)+1;
        var x = windowIndentX;
        var stickSize = arrowIndentX;
        var y0 = heightWindow - windowIndentY;
        for (i in 0...sticksAmount) {
            var t = new JTextField(chart.data[0].yValue.getCaptionByFloatValue(interpolateValue(i, areaHeight/captionHeightWithMargin, minPointY, maxPointY)));
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

    private function interpolateValue(index: Float, length: Float, min: Float, max: Float): Float {
        return index * ((max - min) / length) + min;
    }

    /**
    * Mouse coordinats.
    **/
    public function onMouseMove(e:MouseEvent):Void {
        calculateNearesPointIndex(e.localX);
        drawBubble();
    }

    public function roundPointValue(x:Float):Float {
        var xx:Float = Math.pow(10, 2);
        return Math.round(x * xx) / xx;
    }

    public function drawBubble():Void {
        var gr:Graphics;

        if (bubbleDrawArea == null){
            bubbleDrawArea = new Sprite();
            chart.addChild(bubbleDrawArea);
            trace("Create Layout");
            tf = new JTextField();
            chart.append(tf);
        }
        gr = bubbleDrawArea.graphics;
        gr.clear();
        gr.drawRect(0, 0, widthWindow, heightWindow);
        gr.beginFill(0xff0000, 1.0);
        gr.drawCircle(newPoints[indexMin].displayX, newPoints[indexMin].displayY, circleRadius);
        gr.endFill();

        tf.text = (Std.string(newPoints[indexMin].xCaption + "\n" + newPoints[indexMin].yCaption));

        var thickness = 0.7;
        var color = ASColor.RED;
        var alpha = 1;
        var pixelHinting = true;
        var miterLimit = 3;
        gr.lineStyle(thickness, color.getRGB(), alpha, pixelHinting, miterLimit);
        if (newPoints.length / 2 < indexMin){
            if (heightWindow / 3 < newPoints[indexMin].displayY){
                tf.location = new IntPoint(Std.int(newPoints[indexMin].displayX) + 16, Std.int(newPoints[indexMin].displayY - 60));
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX + 15, newPoints[indexMin].displayY - 55);
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX + 16, newPoints[indexMin].displayY - 72 + tf.preferredSize.height);
                gr.beginFill(0xFFFFFF, 0.5);
                gr.drawRoundRect(newPoints[indexMin].displayX + 15, newPoints[indexMin].displayY - 60, tf.preferredSize.width - 20, tf.preferredSize.height - 10, 15);
                gr.endFill();
                }
            else if (heightWindow / 3 > newPoints[indexMin].displayY){
                tf.location = new IntPoint(Std.int(newPoints[indexMin].displayX) + 16, Std.int(newPoints[indexMin].displayY + 19));
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX + 15, newPoints[indexMin].displayY + 55);
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX + 16, newPoints[indexMin].displayY + 72 - tf.preferredSize.height);
                gr.beginFill(0xFFFFFF, 0.5);
                gr.drawRoundRect(newPoints[indexMin].displayX + 15, newPoints[indexMin].displayY +19, tf.preferredSize.width - 20, tf.preferredSize.height - 10, 15);
                gr.endFill();
            }
        }
        else if(newPoints.length / 2 >= indexMin){
            if (heightWindow / 3 < newPoints[indexMin].displayY){
                tf.location = new IntPoint(Std.int(newPoints[indexMin].displayX) - tf.preferredSize.width + 5, Std.int(newPoints[indexMin].displayY - 60));
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX - 15, newPoints[indexMin].displayY - 55);
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX - 16, newPoints[indexMin].displayY - 72 + tf.preferredSize.height);
                gr.beginFill(0xFFFFFF, 0.5);
                gr.drawRoundRect(newPoints[indexMin].displayX - tf.preferredSize.width + 5, newPoints[indexMin].displayY - 60, tf.preferredSize.width - 18, tf.preferredSize.height - 10, 15);
                gr.endFill();
                }
            else if (heightWindow / 3 > newPoints[indexMin].displayY)
            {
                tf.location = new IntPoint(Std.int(newPoints[indexMin].displayX) - tf.preferredSize.width + 5, Std.int(newPoints[indexMin].displayY + 19));
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX - 15, newPoints[indexMin].displayY + 55);
                gr.moveTo(newPoints[indexMin].displayX, newPoints[indexMin].displayY);
                gr.lineTo(newPoints[indexMin].displayX - 16, newPoints[indexMin].displayY + 72 - tf.preferredSize.height);
                gr.beginFill(0xFFFFFF, 0.5);
                gr.drawRoundRect(newPoints[indexMin].displayX - tf.preferredSize.width + 5, newPoints[indexMin].displayY + 19, tf.preferredSize.width - 20, tf.preferredSize.height - 10, 15);
                gr.endFill();
            }
        }
        indexMin = 0;
    }

    public function calculateNearesPointIndex(x:Float):Int {
        var i: Int = 0;
        for (point in newPoints){
            if (Math.abs(x - newPoints[indexMin].displayX) > Math.abs(x - newPoints[i].displayX)){
                indexMin = i;
            }
            i++;
        }
        return indexMin;
    }

    private inline function calcDisplayX(x: Float) {
        return windowIndentX + (x - minPointX) * scalePointX;
    }

    private inline function calcDisplayY(y: Float) {
        return heightWindow - windowIndentY - (y - minPointY) * scalePointY;
    }

    /**
    * Draw graph at points at axises X and Y;
    * If points y have negative value, then axis x is positive, axis y is negative;
    * If points x haxe negative valuse, then axis x is negative, axis y is positive;
    * If points x and y have negative value, then axis x and y is negative.
    **/
    public function drawGraph():Void{
        var data = chart.data;
        var g = shape.graphics;

        chart.removeChild(bubbleDrawArea);
        bubbleDrawArea = null;

        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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

        for (point in newPoints){
                g.beginFill(0xFFFFFF, 1.0);
                g.drawCircle(point.displayX, point.displayY, circleRadius);
                g.endFill();
        }
    }
}