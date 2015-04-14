package jive.chart;

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

    public var tf:Array<JTextField>;
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
        trace("paint");

        super.paint(c, g, b);

        trace("paint");

        chart = AsWingUtils.as(c, Chart);
        if (null == chart) return;

        chart.removeAll();
        if (null != shape) {
            chart.removeChild(shape);
        }

        shape = new Shape();
        chart.addChild(shape);

        tf = [];

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

    /**
    * Greatest and lowest points.
    **/
    public var maxPoint:Float = 0;
    public var minPoint:Float = 0;

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
    public var lengthWidth:Float = 0;
    public var lengthHeight:Float = 0;

    public var textMargin:Int = 3;
    public var textWidth:Int = 0;

    public var maxDate:Date = Date.now();

    public function calculateMinDate(){

    }


/**
    * Methods of finding the minimum and maximum points of the x and y
    **/
    public function calculateMinimumX(){
        minPointX = chart.data[0].x;
        for (point in chart.data){
            if (minPointX > point.x)
                minPointX = point.x;
        }
        trace("minX " + minPointX);
        return minPointX;
    }

    public function  calculateMaximumX(){
        for (point in chart.data){
            if (maxPointX < point.x)
                maxPointX = point.x;
        }
        trace("maxX " + maxPointX);
        return maxPointX;
    }

    public function calculateMinimumY(){
        minPointY = chart.data[0].y;
        for (point in chart.data){
            if (minPointY > point.y)
                minPointY = point.y;
        }
        trace("minY " + minPointY);
        return minPointY;
    }

    public function calculateMaximumY(){
        for (point in chart.data){
            if (maxPointY < point.y)
                maxPointY = point.y;
        }
        trace("maxY " + maxPointY);
        return maxPointY;
    }
    /**
    * Finding greatest and lowest points
    **/
    public function calculateMaximumPoint(){
        calculateMaximumX();
        calculateMaximumY();
        if (maxPointX > maxPointY)
            maxPoint = maxPointX;
        else
            maxPoint = maxPointY;
        trace("max " + maxPoint);
        return maxPoint;
    }

    public function calculateMinimumPoint(){
        calculateMinimumX();
        calculateMinimumY();
        if (minPointX < minPointY)
            minPoint = minPointX;
        else
            minPoint = minPointY;
        trace("min " + minPoint);
        return minPoint;
    }

/**
    * The scaling factor points x and y.
    **/
    public function calculateScalePointX(){
        calculateMaximumX();
        calculateMinimumX();
        lengthWidth = maxPointX - minPointX;
        scalePointX = (widthWindow - windowIndentX) / lengthWidth;
        return scalePointX;
    }

    public function calculateScalePointY(){
        calculateMaximumY();
        calculateMinimumY();
        lengthHeight = maxPointY - minPointY;
        scalePointY = (heightWindow - windowIndentY) / lengthHeight;
        return scalePointY;
    }
    /**
    * Finding text width
    **/
    public function calculateMaxTextWidth(){
        calculateMinimumX();
        calculateMaximumX();
        if (minPointX < 0){
            var tf = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(minPointX));
            textWidth = Std.int(tf.preferredSize.width);
        }
        else if (minPointX >= 0){
            var tf = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(maxPointX));
            textWidth = Std.int(tf.preferredSize.width);
        }
        trace(textWidth);
        return textWidth;
    }

    public function lineStyleAxises(){
        var g = shape.graphics;
        var thickness = 1.2;
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
        var thickness = 2;
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
        calculateMaximumPoint();
        calculateMinimumPoint();
        calculateScalePointX();
        calculateScalePointY();
        calculateMaxTextWidth();
        var g = shape.graphics;
//line style
        lineStyleAxises();
        windowIndentX = textWidth;

//axises
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(windowIndentX, 0);
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(widthWindow, heightWindow - windowIndentY);

// arrows oy
        g.moveTo(windowIndentX, 0);
        g.lineTo(windowIndentX - 2, 3);
        g.moveTo(windowIndentX, 0);
        g.lineTo(windowIndentX + 2, 3);

// arrows ox
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow - 3, heightWindow - windowIndentY - 2);
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow - 3, heightWindow - windowIndentY + 2);


//      draw sticks and text value
        var stick: Int = Std.int((widthWindow - windowIndentX) / (textMargin + textWidth));
        trace("stick:" + stick);
        trace("textWidth:" + textWidth);
        var ox:Int = 0;
/*var plength = Std.int(data.length);
        var nn1 = Std.int((widthWindow - windowIndentX) / (plength));
        trace(plength);
        if (plength < stick)
            while (ox <= plength){
                var t = new JTextField(Std.string(Std.int(ox * ((maxPointX - minPointX) / plength) + minPointX)));
                tf.push(t);
                var stopStickX: Int = Std.int(ox * nn1);
                if (stopStickX < widthWindow - windowIndentX - arrowIndentX){
                    g.moveTo((ox * nn1) + windowIndentX, heightWindow - windowIndentY);
                    g.lineTo((ox * nn1) + windowIndentX, heightWindow - windowIndentY + arrowIndentY);
                }
                else if (stopStickX >= widthWindow - windowIndentX) break;
                if (ox < plength){
                    var xx = Std.int(windowIndentX +arrowIndentX + (ox * nn1) - t.preferredSize.width / 2);
                    var yy = Std.int(heightWindow - windowIndentY + arrowIndentY);
                    t.location = new IntPoint(xx, yy);
                }
                else if (ox == plength){
                    var xx = Std.int(windowIndentX + (ox * nn1) - t.preferredSize.width + 2 * arrowIndentX);
                    var yy = Std.int(heightWindow - windowIndentY + arrowIndentY);
                    t.location = new IntPoint(xx, yy);
                }

                append(t);
                ox += 2;
                *//*lineStyleGrid();
                g.moveTo((ox * (textMargin + textWidth)) + windowIndentX, heightWindow - windowIndentY);
                g.lineTo((ox * (textMargin + textWidth)) + windowIndentX, 0);*//*
                lineStyleAxises();
            }

        else*/
        while (ox <= stick){
            var t = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(ox * ((maxPointX - minPointX) / stick) + minPointX));
            tf.push(t);
            var stopStickX: Int = Std.int(ox * (textMargin + textWidth));
            if (stopStickX >= widthWindow - windowIndentX){break;}
            g.moveTo((ox * (textMargin + textWidth)) + windowIndentX, heightWindow - windowIndentY);
            g.lineTo((ox * (textMargin + textWidth)) + windowIndentX, heightWindow - windowIndentY + arrowIndentY);
/*var xx = 0;
            var yy = 0;
            if (ox < stick){
                xx = Std.int(windowIndentX + arrowIndentX + (ox * (textMargin + textWidth)) - t.preferredSize.width / 2);
                yy = Std.int(heightWindow - windowIndentY + arrowIndentY);
                }
            else if (ox == stick){
                xx = Std.int(windowIndentX + (ox * (textMargin + textWidth)) - t.preferredSize.width / 2);
                yy = Std.int(heightWindow - windowIndentY + arrowIndentY);
            }*/
            var xx = Std.int(windowIndentX + arrowIndentX + (ox * (textMargin + textWidth)) - t.preferredSize.width / 2);
            trace(t.preferredSize.width);
            var yy = Std.int(heightWindow - windowIndentY + arrowIndentY);
            t.location = new IntPoint(xx, yy);
            chart.append(t);
            ox += 1;
            lineStyleGrid();
            g.moveTo((ox * (textMargin + textWidth)) + windowIndentX, heightWindow - windowIndentY);
            g.lineTo((ox * (textMargin + textWidth)) + windowIndentX, 0);
            lineStyleAxises();

        }

        lineStyleAxises();
        var stick: Int = Std.int((heightWindow - windowIndentY) / (textMargin + textWidth));
        trace("stick:" + stick);
        trace("textWidth:" + textWidth);
        var oy:Int = 0;
        while (oy <= stick){
            var t = new JTextField(chart.data[0].yValue.getCaptionByFloatValue(oy * ((maxPointY - minPointY) / stick) + minPointY));
            tf.push(t);
            var stopStickY: Int = Std.int(oy * (textMargin + textWidth));
            if (stopStickY >= heightWindow - windowIndentY){break;}
            g.moveTo(windowIndentX, heightWindow - windowIndentY - (oy * (textMargin + textWidth)));
            g.lineTo(windowIndentX - arrowIndentX, heightWindow - windowIndentY - (oy * (textMargin + textWidth)));
            var xx = Std.int(0);
            var yy = Std.int(heightWindow - windowIndentY - (oy * (textMargin + textWidth)) - (t.preferredSize.height / 2) );
            t.location = new IntPoint(xx, yy);
            chart.append(t);
            oy += 1;
            lineStyleGrid();
            g.moveTo(windowIndentX, heightWindow - windowIndentY - (oy * (textMargin + textWidth)));
            g.lineTo(widthWindow, heightWindow - windowIndentY - (oy * (textMargin + textWidth)));
            lineStyleAxises();
        }

        lineStyleGrid();
        g.moveTo(windowIndentX, 0);
        g.lineTo(widthWindow, 0);
        g.moveTo(widthWindow, heightWindow - windowIndentY);
        g.lineTo(widthWindow, 0);
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
        calculateMaximumPoint();
        calculateScalePointX();
        calculateScalePointY();
        lineStyleGraph();
        if (((maxPointX > widthWindow) || (maxPointY > heightWindow)) || ((maxPointX < widthWindow) || (maxPointY < heightWindow))){
            g.moveTo(windowIndentX + (data[0].x - minPointX) * scalePointX, heightWindow - windowIndentY - (data[0].y - minPointY)  * scalePointY);
            for (point in data){
                trace(point);
                g.lineTo(windowIndentX + (point.x - minPointX)  * scalePointX, heightWindow - windowIndentY - (point.y - minPointY)  * scalePointY);
            }
        }
        else if ((minPointX < 0) && (minPointY < 0)){
            g.moveTo(windowIndentX + (data[0].x + minPointX) * scalePointX, heightWindow - windowIndentY - (data[0].y - minPointY)  * scalePointY);
            for (point in data){
                trace(point);
                g.lineTo(windowIndentX + (point.x + minPointX)  * scalePointX, heightWindow - windowIndentY - (point.y + minPointY)  * scalePointY);
            }
        }
        else if ((minPointX > 0) && (minPointY < 0)){
            g.moveTo(windowIndentX + (data[0].x - minPointX) * scalePointX, heightWindow - windowIndentY - (data[0].y + minPointY)  * scalePointY);
            for (point in data){
                trace(point);
                g.lineTo(windowIndentX + (point.x - minPointX)  * scalePointX, heightWindow - windowIndentY - (point.y + minPointY)  * scalePointY);
            }
        }
        else if ((minPointX < 0) && (minPointY > 0)){
            g.moveTo(windowIndentX + (data[0].x + minPointX) * scalePointX, heightWindow - windowIndentY - (data[0].y - minPointY)  * scalePointY);
            for (point in data){
                trace(point);
                g.lineTo(windowIndentX + (point.x + minPointX)  * scalePointX, heightWindow - windowIndentY - (point.y - minPointY)  * scalePointY);
            }
        }
        else if((maxPointX == widthWindow) && (maxPointY == heightWindow)){
            g.moveTo(data[0].x + windowIndentX, heightWindow - data[0].y - windowIndentY);
            for (point in data){
                trace(point);
                g.lineTo(point.x + windowIndentX, heightWindow - point.y - windowIndentY);
            }
        }
    }
}
