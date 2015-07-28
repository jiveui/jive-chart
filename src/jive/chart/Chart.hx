package jive.chart;

import org.aswing.graphics.SolidBrush;
import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.graphics.IPen;
import org.aswing.graphics.IBrush;
import org.aswing.graphics.Pen;
import org.aswing.UIManager;
import org.aswing.Container;
import Array;


class Chart extends Container {

    public var title: String;
    public var tickSize: Int = 5;
    public var axisPen: IPen;
    public var graphPen: IPen;
    public var selectorPen: IPen;
    public var selectorBrush: IBrush;
    public var selectorBubbleBorder: IPen;
    public var selectorBubbleBackground: IBrush;

    public var selectorSize: Int = 4;
    public var gridPen: IPen;
    public var areaUnderLineBrush: IBrush;

    public var markBrush: IBrush;
    public var markPen: IPen;
    public var markSize: Int = 3;

    public var minPointDistantion: Int = 10;

    public var data(get, set):Array<Point>;
    private var _data: Array<Point>;
    private function get_data(): Array<Point> { return _data; }
    private function set_data(v: Array<Point>): Array<Point> {
        _data = Lambda.array(Lambda.map(v, function(p) { return p.clone();}));
        _data.sort(function(a,b) { return if (a.x < b.x) -1 else 1; });
        repaint();
        return _data;
    }

    public var labelsLayer: Container;
    public var interactionLayer: Container;

    public function new(title = ""){
        super();
        data = [];

        axisPen = new Pen(ASColor.BLACK, 1.5, true);
        graphPen = new Pen(ASColor.RED, 0.9, true);
        gridPen = new Pen(ASColor.GRAY, 0.3, true);
        selectorPen = new Pen(ASColor.RED, 0.1, true);
        selectorBrush = new SolidBrush(ASColor.RED);
        markPen = graphPen;
        markBrush = new SolidBrush(ASColor.WHITE);
        selectorBubbleBorder = new Pen(ASColor.RED, 0.7);
        selectorBubbleBackground = new SolidBrush(new ASColor(0xffffff, 0.5));
        labelsLayer = new Container();
        interactionLayer = new Container();

        append(labelsLayer);
        append(interactionLayer);
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


