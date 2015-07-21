package jive.chart;

import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.display.Graphics;
import org.aswing.JTextField;
import org.aswing.geom.IntPoint;
import org.aswing.AsWingUtils;
import org.aswing.graphics.Graphics2D;
import org.aswing.geom.IntRectangle;
import org.aswing.Component;
import flash.display.Shape;

class ChartPeriodSelector extends ChartUI{

    public var selectorArea:Sprite;

    public function new() {
        super();
    }

    override private function getPropertyPrefix():String{
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

    override private function drawGridVerticalLinesAndCaptions(g: Graphics) {
        lineStyleAxises();
        var captionWidthWithMargin = textWidthX;
        var areaWidth = widthWindow - windowIndentX;
        var sticksAmount = Std.int(areaWidth/captionWidthWithMargin)+1;
        var y = heightWindow - windowIndentY;
        var stickSize = arrowIndentY;
        var x0 = windowIndentX;
        for (i in 0...sticksAmount) {
            var t = new JTextField(chart.data[0].xValue.getCaptionByFloatValue(interpolateValue(i, areaWidth/captionWidthWithMargin, minPointX, maxPointX)));
            var insets = t.getInsets();
            TextFields.push(t);
            var x = x0 + i * captionWidthWithMargin;
            g.moveTo(x, y);
            g.lineTo(x, y + stickSize);
            t.location = new IntPoint(Std.int(x - t.preferredSize.width/2) + insets.left, Std.int(y + stickSize) + insets.top);
            chart.append(t);
            lineStyleGrid();
            g.moveTo(x, y);
            g.lineTo(x, 0);
            lineStyleAxises();
        }
    }

    override public function drawAxises():Void{
        var g = shape.graphics;
        calculateMaximumX();
        calculateMaximumY();
        calculateScalePointX();
        calculateScalePointY();
        calculateMaxTextWidthX();
        calculateMaxTextWidthY();
        calculateMaxTextHeightY();
        windowIndentX = windowIndentX + arrowIndentX;
        windowIndentY = textHeightX + arrowIndentY;
        lineStyleAxises();
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(windowIndentX, 0);
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(widthWindow, heightWindow - windowIndentY);
        drawGridVerticalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    override public function drawGraph():Void{
        var data = chart.data;
        var g = shape.graphics;

        chart.removeChild(selectorArea);
        selectorArea = null;

        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.graphics.drawRect(windowIndentX, 0, widthWindow, heightWindow - windowIndentY);

        var resX:Float;
        var resY:Float;
        calculateScalePointX();
        calculateScalePointY();
        var x = calcDisplayX(data[0].x);
        var y = calcDisplayY(data[0].y);
        g.moveTo(x, y);
        lineStyleGraph();
        newPoints = [];
        var resX:Float = x;
        var resY:Float = y;
        for (point in data){
            var newX = calcDisplayX(point.x);
            if (Math.abs(x - newX) >= 7) {
                point.displayX = newX;
                point.displayY = calcDisplayY(point.y);
                newPoints.push(point);

                g.beginFill(0xff0000, 0.5);
                lineStyleSelector();
                g.moveTo(point.displayX, point.displayY);
                g.lineTo(point.displayX, heightWindow - windowIndentY);
                g.lineTo(resX, heightWindow - windowIndentY);
                g.lineTo(resX, resY);
                lineStyleGraph();
                g.lineTo(point.displayX, point.displayY);
                g.endFill();

                x = newX;
                resX = x;
                resY = calcDisplayY(point.y);
            }
        }
    }

    override public function onMouseMove(e:MouseEvent):Void {
        calculateNearesPointIndex(e.localX);
        drawSelectorArea();
    }

    public function drawSelectorArea():Void {
        var gr:Graphics;

        if (selectorArea == null){
            selectorArea = new Sprite();
            chart.addChild(selectorArea);
            trace("Create Layout");
            tf = new JTextField();
            chart.append(tf);
        }

        gr = selectorArea.graphics;
        gr.clear();
        gr.beginFill(0x000000, 0.3);
        gr.drawRect(windowIndentX, 0, newPoints[indexMin].displayX - windowIndentX - arrowIndentX, heightWindow - windowIndentY);
        gr.endFill();
        tf.text = (Std.string(newPoints[indexMin].xCaption + "\n" + newPoints[indexMin].yCaption));
        trace ("ss : " + newPoints[indexMin].xCaption);

        gr.beginFill(0x000000, 0.5);
        gr.drawRect(newPoints[indexMin].displayX, 0, widthWindow, heightWindow - windowIndentY);
        gr.endFill();




        indexMin = 0;
    }
}
