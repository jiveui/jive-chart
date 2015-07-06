package jive.chart;

import flash.Lib;
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

    private var mouseArea:Sprite = new Sprite();
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
        areaListener();
        mouseArea.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addChild(mouseArea);
    }

    private function onMouseMove(e:MouseEvent):Void {
        gr.moveTo(e.localX, e.localY);
        trace("onMouseMove" + " x " + e.localX + " y " + e.localY );
    }

    private function areaListener():Void
    {
        var widthf = Lib.current.stage.stageWidth;
        var heightf = Lib.current.stage.stageHeight;
        mouseArea = new Sprite();
        gr = this.mouseArea.graphics;
//        gr.beginFill(0x9966ff);
        gr.drawRect(0, 0, widthf, heightf);
//        gr.endFill();
//        gr.lineStyle(1, 0xff0000, 1);
//        flash.Lib.current.addChild(mouseCoord);
        mouseArea.x = 80;
        mouseArea.y = 0;
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


