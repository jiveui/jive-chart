package jive.chart;

//import flash.Lib;
//import flash.display.Graphics;
//import flash.events.Event;
//import flash.events.MouseEvent;
//import flash.display.Sprite;
import org.aswing.UIManager;
import org.aswing.Container;
import Array;


class Chart extends Container {

    public var title:String;

//    public var mouseArea:Sprite = new Sprite();
//    private var gr:Graphics = new Graphics();

//    public var newChart = new ChartUI();
    public var newChart = new ChartUI();

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


