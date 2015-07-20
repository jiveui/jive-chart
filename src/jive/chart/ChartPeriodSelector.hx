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

class ChartPeriodSelector extends ChartUI{

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

    override public function drawAxises():Void{
        var g = shape.graphics;

        calculateMaximumX();
        calculateMaximumY();
        calculateScalePointX();
        calculateScalePointY();
        calculateMaxTextWidthX();
        calculateMaxTextWidthY();
        calculateMaxTextHeightY();

//        windowIndentX = textWidthY;
        windowIndentY = textHeightX + arrowIndentY;

//axises
        lineStyleAxises();
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(windowIndentX, 0);
        g.moveTo(windowIndentX, heightWindow - windowIndentY);
        g.lineTo(widthWindow, heightWindow - windowIndentY);

        drawGridVerticalLinesAndCaptions(g);
//        drawGridHorizontalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    override public function drawGraph():Void{
        var data = chart.data;
        var g = shape.graphics;

//        chart.graphics.drawRect(0, 0, widthWindow, heightWindow);

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
