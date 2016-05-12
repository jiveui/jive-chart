package jive.chart;

import jive.*;
import jive.geom.*;
import jive.graphics.*;
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

        graphPen = new Pen(Color.RED, 1, true);

        thumbBrush = new SolidBrush(Color.LIGHT_GRAY);

        leftThumb = new Sprite();
        leftThumb.useHandCursor = true;
        leftThumb.buttonMode = true;
        rightThumb = new Sprite();
        rightThumb.useHandCursor = true;
        rightThumb.buttonMode = true;

        displayObjectContainer.addChild(leftThumb);
        displayObjectContainer.addChild(rightThumb);
    }

    private function updateSelectedData() { 
        selectedData = data.slice(leftIndex, rightIndex + 1); 
    } 
}