package jive.chart;

import org.aswing.geom.IntPoint;
import jive.events.TransformGestureEvent;
import org.aswing.Component;
import org.aswing.JViewport;
import org.aswing.ASFont;
import org.aswing.JLabel;
import org.aswing.border.EmptyBorder;
import org.aswing.EmptyLayout;
import org.aswing.JPanel;
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

    public var xAxis(get, set): Axis;
    private var _xAxis: Axis;
    private function get_xAxis(): Axis { return _xAxis; }
    private function set_xAxis(v: Axis): Axis {
        _xAxis = v;
        if (null == _xAxis) _xAxis = new Axis();
        repaint();
        return v;
    }

    public var xAxisTitleVisible = false;
    public var yAxisTitleVisible = false;
    public var yAxisTitlePosition = YAxisTitlePosition.left;

    public var yAxis(get, set): Axis;
    private var _yAxis: Axis;
    private function get_yAxis(): Axis { return _yAxis; }
    private function set_yAxis(v: Axis): Axis {
        _yAxis = v;
        if (null == _yAxis) _yAxis = new Axis();
        repaint();
        return v;
    }

    public var title(get, set): String;
    private var _title: String;
    private function get_title(): String { return _title; }
    private function set_title(v: String): String {
        _title = v;
        repaint();
        return v;
    }

    public var tickSize: Int = 5;
    public var axisPen: IPen;
    public var axisLabelColor: ASColor;
    public var axisMarginBetweenLabels: Int = Std.int(UIManager.get("margin")/2);
    public var axisMarginBetweenLabelsAndAxis: Int = Std.int(UIManager.get("margin")/3);
    public var graphPen: IPen;
    public var selectorPen: IPen;
    public var selectorBrush: IBrush;
    public var selectorBubbleBorder: IPen;
    public var selectorBubbleBackground: IBrush;
    public var selectorBubblePadding: Int = Std.int(UIManager.get("margin")/5);
    public var selectorBubbleTailSize: Int = Std.int(UIManager.get("margin")/2);
    public var selectorBubbleCornerRadius: Int = UIManager.get("cornerSize");

    public var selectorSize: Int = Std.int(UIManager.get("margin")/10);
    public var gridPen: IPen;
    public var areaUnderLineBrush: IBrush;

    public var titleFont: ASFont;

    public var markBrush: IBrush;
    public var markPen: IPen;
    public var markSize: Int = Std.int(UIManager.get("margin")/12);

    public var minPointDistantion: Int = Std.int(UIManager.get("margin")/4);

    public var data(get, set):Array<Point>;
    private var _data: Array<Point>;
    private function get_data(): Array<Point> { return _data; }
    private function set_data(v: Array<Point>): Array<Point> {
        if (null == v) v = [];
        _data = Lambda.array(Lambda.map(v, function(p) { return p.clone();}));
        _data.sort(function(a,b) { return if (a.x < b.x) -1 else 1; });
        repaint();
        return _data;
    }

    public var fillSpaceUnderPolyline: Bool = false;
    public var markPoints: Bool = true;
    public var unselectedAreaBrush: IBrush;

    public var labelsLayer: Container;
    public var interactionLayer: Container;
    public var graphViewport: JViewport;
    public var graphComponent: Component;

    public function new(title = ""){
        super();

        _xAxis = new Axis();
        _yAxis = new Axis();

        data = [];

        var dpiScale: Float = UIManager.get("dpiScale")/3;

        axisPen = new Pen(ASColor.BLACK, 1.5 * dpiScale, true);
        graphPen = new Pen(ASColor.RED, 2.5 * dpiScale, true);
        unselectedAreaBrush = new SolidBrush(ASColor.RED.changeAlpha(0.5));
        gridPen = new Pen(ASColor.GRAY, 0.3 * dpiScale, true);
        selectorPen = new Pen(ASColor.RED, 1 * dpiScale, true);
        selectorBrush = new SolidBrush(ASColor.RED);
        markPen = new Pen(ASColor.RED, 0.7 * dpiScale, true);
        markBrush = new SolidBrush(ASColor.WHITE);
        selectorBubbleBorder = new Pen(ASColor.DARK_GRAY, 0.7 * dpiScale);
        selectorBubbleBackground = new SolidBrush(new ASColor(0xe5e5e5,0.8));
        labelsLayer = new Container();
        interactionLayer = new Container();
        axisLabelColor = ASColor.GRAY;
        areaUnderLineBrush = new SolidBrush(ASColor.RED.changeAlpha(0.3));

        titleFont = UIManager.get("controlHeaderFont");
        font = UIManager.get("minimumFont");

        graphComponent = new Component();
        graphViewport = new JViewport();
        {
            var container = new Container();
            container.append(graphComponent);
            container.append(interactionLayer);
            graphViewport.append(container);
            graphViewport.setViewPosition(new IntPoint(0,0));
        }

        append(graphViewport);
        append(labelsLayer);

        doLayout();
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


