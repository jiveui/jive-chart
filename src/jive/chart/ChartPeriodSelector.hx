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

    public var LeftSelectorArea:Sprite;
    public var RightSelectorArea:Sprite;

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
        windowIndentX = 25;
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

        chart.removeChild(LeftSelectorArea);
        LeftSelectorArea = null;
        chart.removeChild(RightSelectorArea);
        RightSelectorArea = null;


        chart.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownL);
        chart.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownR);


/*
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);*/
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

    public var toggleSelectorL:Bool = false;
    public var toggleSelectorR:Bool = false;

    public function onMouseDownL(e:MouseEvent):Void {
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveL);
        chart.addEventListener(MouseEvent.MOUSE_UP, onMouseUpL);

    }

    public function onMouseUpL(e:MouseEvent):Void {
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveL);
    }

    public function onMouseMoveL(e:MouseEvent):Void {
        calculateNearesPointIndex(e.localX);
        drawSelectorAreaL();
    }

    public function onMouseDownR(e:MouseEvent):Void {
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveR);
        chart.addEventListener(MouseEvent.MOUSE_UP, onMouseUpR);

    }

    public function onMouseUpR(e:MouseEvent):Void {
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveR);
    }

    public function onMouseMoveR(e:MouseEvent):Void {
        calculateNearesPointIndex(e.localX);
        drawSelectorAreaR();
    }

    public function drawSelectorAreaL():Void {
        var lgr:Graphics;

        if (LeftSelectorArea == null){
            LeftSelectorArea = new Sprite();
            chart.addChild(LeftSelectorArea);
            trace("Create Layout");
            tf = new JTextField();
            chart.append(tf);
        }

        lgr = LeftSelectorArea.graphics;
        lgr.clear();
        lgr.beginFill(0x000000, 0.3);
        lgr.drawRect(windowIndentX, 0, newPoints[indexMin].displayX - windowIndentX - arrowIndentX, heightWindow - windowIndentY);
        lgr.endFill();
        tf.text = (Std.string(newPoints[indexMin].xCaption + "\n" + newPoints[indexMin].yCaption));
        lgr.beginFill(0xff0000, 0.8);
        lgr.drawRect(newPoints[indexMin].displayX - 2, 0, 4, heightWindow - windowIndentY );
        lgr.endFill();
        indexMin = 0;
    }
    public function drawSelectorAreaR():Void {
        var rgr:Graphics;

        if (RightSelectorArea == null){
            RightSelectorArea = new Sprite();
            chart.addChild(RightSelectorArea);
            trace("Create Layout");
        }

        rgr = RightSelectorArea.graphics;
        rgr.clear();

        rgr.beginFill(0x000000, 0.5);
        rgr.drawRect(newPoints[indexMin].displayX, 0, widthWindow - newPoints[indexMin].displayX, heightWindow - windowIndentY);
        rgr.endFill();
//        rgr.beginFill(0xff0000, 0.8);
//        rgr.drawRect(newPoints[indexMin].displayX - 2, 0, 4, heightWindow - windowIndentY );
//        rgr.endFill();

        indexMin = 0;
    }

/*    public function toggleSelectorL(x:Float, width:Float):Void {
        var tsl:Graphics;
        tsl = LeftSelectorArea.graphics;
        tsl.clear();
        tsl.beginFill(0xff0000, 0.8);
        tsl.drawRect(newPoints[indexMin].displayX - arrowIndentX, 0, 10, heightWindow - windowIndentY );
        tsl.endFill();
    }*/
}
