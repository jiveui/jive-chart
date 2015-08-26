package jive.chart;

import org.aswing.graphics.Pen;
import org.aswing.ASColor;
import org.aswing.graphics.SolidBrush;
import org.aswing.graphics.IBrush;
import org.aswing.geom.IntDimension;
import flash.display.Sprite;

class ChartPeriodSelector extends Chart {

    public var leftIndex(get, set): Int;
    private var _leftIndex: Int;
    private function get_leftIndex(): Int { return _leftIndex; }
    private function set_leftIndex(v: Int): Int {
        _leftIndex = v;
        updateSelectedData();
        return v;
    }

    public var rightIndex(get, set): Int;
    private var _rightIndex: Int;
    private function get_rightIndex(): Int { return _rightIndex; }
    private function set_rightIndex(v: Int): Int {
        _rightIndex = v;
        updateSelectedData();
        return v;
    }

    @bindable public var selectedData: Array<Point>;

    public var leftThumb: Sprite;
    public var rightThumb: Sprite;
    public var thumbSize: IntDimension = new IntDimension(15, 30);
    public var thumbCornerSize: Int = 5;
    public var thumbBrush: IBrush;

    override private function set_data(v: Array<Point>): Array<Point> {
        super.set_data(v);
        leftIndex = 0;
        rightIndex = v.length-1;
        return _data;
    }

    public function new(){
        super("");

        fillSpaceUnderPolyline = true;
        markPoints = false;

        graphPen = new Pen(ASColor.RED, 1, true);

        thumbBrush = new SolidBrush(ASColor.LIGHT_GRAY);

        leftThumb = new Sprite();
        leftThumb.useHandCursor = true;
        leftThumb.buttonMode = true;
        rightThumb = new Sprite();
        rightThumb.useHandCursor = true;
        rightThumb.buttonMode = true;

        addChild(leftThumb);
        addChild(rightThumb);
    }

    @:dox(hide)
    override public function getDefaultBasicUIClass():Class<Dynamic> {
        return jive.chart.ChartPeriodSelectorUI;
    }

    @:dox(hide)
    override public function getUIClassID():String{
        return "ChartPeriodSelectorUI";
    }

    private function updateSelectedData() {
        selectedData = data.slice(leftIndex, rightIndex + 1);
    }

}


