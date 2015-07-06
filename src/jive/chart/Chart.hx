package jive.chart;

import flash.Lib;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.Sprite;
import org.aswing.UIManager;
import org.aswing.Container;
import Array;


class Chart extends Container {

    public var title:String;

    private var mouseCoord:Sprite = new Sprite();
    private var gr:Graphics = new Graphics();

    public var data(get, set):Array<Point>;
    private var _data: Array<Point>;
    private function get_data(): Array<Point> { return _data; }
    private function set_data(v: Array<Point>): Array<Point> {
        _data = v;
        repaint();
        return _data;
    }

    public function new(title = ""){
        super();
        data = [];
        this.DrawOnCanvas();
        this.mouseCoord.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        this.mouseCoord.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);

//        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseCoordinats);
//        mouseCoord.addEventListener(MouseEvent.MOUSE_MOVE, globalMouseCoordinats)
        addChild(mouseCoord);
    }

    private function onMouseDown(e:MouseEvent):Void {
        this.gr.moveTo(e.localX, e.localY);
        this.mouseCoord.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
        trace("onMouseDown");
    }

    private function onMouseUp(e:MouseEvent):Void{
        this.mouseCoord.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
        trace("onMouseUp");
    }

    private function onMouseMove(e:MouseEvent):Void{
        this.gr.lineTo(e.localX, e.localY);
        trace("onMouseMove" + " x " + e.localX + " y " + e.localY );
    }

    private function DrawOnCanvas():Void
    {
        this.mouseCoord = new Sprite();
        this.gr = this.mouseCoord.graphics;
        this.gr.beginFill(0x9966ff);
        this.gr.drawRect(0, 0, 300, 300);
        this.gr.endFill();
        this.gr.lineStyle(1, 0xff0000, 1);
        flash.Lib.current.addChild(this.mouseCoord);
        this.mouseCoord.x = 80;
        this.mouseCoord.y = 0;
    }




    @:dox(hide)
    override public function updateUI():Void{
        setUI(UIManager.getUI(this));
    }

    @:dox(hide)
    override public function getDefaultBasicUIClass():Class<Dynamic> {
        return jive.chart.ChartUI;
    }

    @:dox(hide)
    override public function getUIClassID():String{
        return "ChartUI";
    }



}


