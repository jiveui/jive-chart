package jive.chart;

import jive.JLabel;
import haxe.Timer;
import jive.graphics.Graphics2D;
import jive.geom.IntPoint;
import jive.ASColor;
import jive.graphics.SolidBrush;
import flash.Lib;
import flash.events.MouseEvent;
import flash.display.Sprite;
import flash.display.Graphics;
import jive.AsWingUtils;
import jive.geom.IntRectangle;
import jive.Component;

class ChartPeriodSelectorUI extends ChartUI {

    var selectorComponent: ChartPeriodSelector;

    public function new() {
        super();
    }


    override private function getPropertyPrefix():String{
        return "ChartPeriosSelector.";
    }

    override public function installUI(c:Component):Void {
        selectorComponent = AsWingUtils.as(c, ChartPeriodSelector);
        chart = selectorComponent;
        if (null == selectorComponent) return;
        selectorComponent.leftThumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownL);
        selectorComponent.rightThumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownR);

        drawThumb(new Graphics2D(selectorComponent.leftThumb.graphics));
        drawThumb(new Graphics2D(selectorComponent.rightThumb.graphics));

        titleLabel = new JLabel();
        titleLabel.location = new IntPoint(0,0);
        chart.append(titleLabel);
    }

    override public function paint(c:Component, g:Graphics2D, b:IntRectangle):Void {
        super.paint(c, g, b);

        if (null == chart || null == chart.data || chart.data.length <= 0 || null == titleLabel || null == graphBounds) return;

        selectorComponent.leftThumb.x = graphBounds.x - selectorComponent.leftThumb.width/2;
        selectorComponent.leftThumb.y = graphBounds.y + (graphBounds.height-selectorComponent.leftThumb.height)/2;

        selectorComponent.rightThumb.x = graphBounds.x + graphBounds.width - selectorComponent.rightThumb.width/2;
        selectorComponent.rightThumb.y = graphBounds.y + (graphBounds.height-selectorComponent.rightThumb.height)/2;
    }

    private function drawThumb(g: Graphics2D) {
        g.fillRoundRect(selectorComponent.thumbBrush, 0, 0, selectorComponent.thumbSize.width, selectorComponent.thumbSize.height, 10);
    }

    override public function uninstallUI(c:Component):Void { }

    override public function drawAxises(g: Graphics2D):Void{
        chart.labelsLayer.removeAll();
        g.drawLine(chart.axisPen, graphBounds.x, graphBounds.y + graphBounds.height, graphBounds.x, graphBounds.y);
        g.drawLine(chart.axisPen, graphBounds.x, graphBounds.y + graphBounds.height, graphBounds.x + graphBounds.width, graphBounds.y + graphBounds.height);
        drawGridVerticalLinesAndCaptions(g);
        drawGridBorderLines(g);
    }

    public function onMouseDownL(e:MouseEvent):Void {
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveL);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpL);
    }

    public function onMouseUpL(e:MouseEvent):Void {
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveL);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpL);
    }

    public function onMouseMoveL(e:MouseEvent):Void {
        var x: Float = chart.globalToComponent(new IntPoint(Std.int(e.stageX), 0)).x;
        if (x < graphBounds.x - selectorComponent.leftThumb.width/2) x = graphBounds.x - selectorComponent.leftThumb.width/2;
        if (x >= selectorComponent.rightThumb.x - selectorComponent.leftThumb.width) x = selectorComponent.rightThumb.x - selectorComponent.leftThumb.width - 1;
        selectorComponent.leftThumb.x = x;
        updateUnselectedArea();
        selectorComponent.leftIndex = getFullIndexByX(Std.int(selectorComponent.leftThumb.x + selectorComponent.leftThumb.width/2));
    }

    public function onMouseDownR(e:MouseEvent):Void {
        chart.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveR);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpR);
    }

    public function onMouseUpR(e:MouseEvent):Void {
        chart.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveR);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpR);
    }

    public function onMouseMoveR(e:MouseEvent):Void {
        var x: Float = chart.globalToComponent(new IntPoint(Std.int(e.stageX), 0)).x;
        if (x > graphBounds.x + graphBounds.width - selectorComponent.rightThumb.width/2) x = graphBounds.x + graphBounds.width - selectorComponent.rightThumb.width/2;
        if (x <= selectorComponent.leftThumb.x + selectorComponent.leftThumb.width) x = selectorComponent.leftThumb.x + selectorComponent.rightThumb.width + 1;
        selectorComponent.rightThumb.x = x;
        updateUnselectedArea();
        selectorComponent.rightIndex = getFullIndexByX(Std.int(selectorComponent.rightThumb.x + selectorComponent.rightThumb.width/2));
    }

    private function updateUnselectedArea() {
        var g: Graphics2D = new Graphics2D(chart.interactionLayer.graphics);
        g.clear();
        g.fillRectangle(selectorComponent.unselectedAreaBrush, graphBounds.x, graphBounds.y,
            Std.int(selectorComponent.leftThumb.x - graphBounds.x + selectorComponent.leftThumb.width/2),
            graphBounds.height);
        g.fillRectangle(selectorComponent.unselectedAreaBrush, Std.int(selectorComponent.rightThumb.x + selectorComponent.leftThumb.width/2), graphBounds.y,
            Std.int(graphBounds.width - (selectorComponent.rightThumb.x + selectorComponent.leftThumb.width/2 - graphBounds.x)),
            graphBounds.height);
    }

    private function getFullIndexByX(x: Int): Int {
        var index = Std.int((x - graphBounds.x)/graphBounds.width * (chart.data.length - 1));
        if (index < 0) index = 0;
        if (index >= chart.data.length) index = chart.data.length - 1;
        return index;
    }
}
