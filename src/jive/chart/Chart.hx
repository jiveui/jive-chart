package jive.chart;

import org.aswing.UIManager;
import Date;
import flash.display.Shape;
import flash.display.Graphics;
import org.aswing.JTextField;
import org.aswing.Container;
import org.aswing.geom.IntPoint;
import org.aswing.geom.IntDimension;
import Array;
import Date;
import org.aswing.ASColor;

class Chart extends Container {

    public var title:String;
    public var data:Array<Point>;


    public function new(title = ""){
        super();
        data = [];
        trace("chart");
        trace(ui);
    }

    @:dox(hide)
    override public function updateUI():Void{
        setUI(UIManager.getUI(this));
        trace(ui);
    }

    @:dox(hide)
    override public function getDefaultBasicUIClass():Class<Dynamic> {
        trace("getDefaultBasicUIClass");
        return jive.chart.ChartUI;
    }

    @:dox(hide)
    override public function getUIClassID():String{
        return "ChartUI";
    }

}


