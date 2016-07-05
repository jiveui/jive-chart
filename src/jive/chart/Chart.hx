package jive.chart;


import Array;
import flash.display.Sprite;

import jive.Component;
import jive.Color;
import jive.Container;
import jive.Font;
import jive.Scroll;
import jive.events.TransformGestureEvent;
import jive.geom.Metric;
import jive.geom.IntPoint;
import jive.geom.IntDimension;
import jive.graphics.Graphics2D;
import jive.graphics.IBrush;
import jive.graphics.IPen;
import jive.graphics.Pen;
import jive.graphics.SolidBrush;


class Chart extends GraphComponent {

    public var xAxis(get, set): Axis;
    private var _xAxis: Axis;
    private function get_xAxis(): Axis { return _xAxis; }
    private function set_xAxis(v: Axis): Axis {
        _xAxis = v;
        if (null == _xAxis) _xAxis = new Axis();
        repaint();
        return v;
    }

    public var yAxis(get, set): Axis;
    private var _yAxis: Axis;
    private function get_yAxis(): Axis { return _yAxis; }
    private function set_yAxis(v: Axis): Axis {
        _yAxis = v;
        if (null == _yAxis) _yAxis = new Axis();
        repaint();
        return v;
    }

    public var title(default, set): String;
    private var _title: String;
    // private function get_title(): String { return _title; }
    private function set_title(v: String): String {
        _title = v;
        repaint();
        return v;
    }

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

    public var xAxisTitleVisible = true;
    public var yAxisTitleVisible = true;
    public var yAxisTitlePosition = YAxisTitlePosition.left;

    public var tickSize: Int = 5;
    public var axisPen: IPen;
    public var axisLabelColor: Color;
    public var axisMarginBetweenLabels: Int = Std.int(Jive.theme.margin/2);
    public var axisMarginBetweenLabelsAndAxis: Int = Std.int(Jive.theme.margin/3);
    public var graphPen: IPen;

    public var selectorPen: IPen;
    public var selectorBrush: IBrush;
    public var selectorBubbleBorder: IPen;
    public var selectorBubbleBackground: IBrush;
    public var selectorBubblePadding: Int = Std.int(Jive.theme.margin/5);
    public var selectorBubbleTailSize: Int = Std.int(Jive.theme.margin/2);
    public var selectorBubbleCornerRadius: Int = Jive.theme.cornerSize;
    public var selectorSize: Int = Std.int(Jive.theme.margin/10);
    
    public var gridPen: IPen;
    public var areaUnderLineBrush: IBrush;

    public var titleFont: Font;
    public var font: Font;

    public var markBrush: IBrush;
    public var markPen: IPen;
    public var markSize: Int = Std.int(Jive.theme.margin/12);

    public var minPointDistantion: Int = Std.int(Jive.theme.margin/4);

    public var fillSpaceUnderPolyline: Bool = false;
    public var markPoints: Bool = true;
    public var unselectedAreaBrush: IBrush;

    public var labelsLayer: GraphComponent;
    public var interactionLayer: GraphComponent;
    public var graphScroll: Scroll;
    public var graphComponent: GraphComponent;
    public var graphContainer: GraphComponent;

    private var ui: ChartUI;

    public function new(title = "") {
        super();

        _xAxis = new Axis();
        _yAxis = new Axis();

        data = [];

        var dpiScale: Float = Jive.theme.dpiScale / 3;

        axisPen = new Pen(Color.BLACK, 1.5 * dpiScale, true);
        graphPen = new Pen(Color.RED, 2.5 * dpiScale, true);
        unselectedAreaBrush = new SolidBrush(Color.RED.changeAlpha(0.5));
        gridPen = new Pen(Color.GRAY, 0.3 * dpiScale, true);
        selectorPen = new Pen(Color.RED, 1 * dpiScale, true);
        selectorBrush = new SolidBrush(Color.RED);
        markPen = new Pen(Color.RED, 0.7 * dpiScale, true);
        markBrush = new SolidBrush(Color.WHITE);
        selectorBubbleBorder = new Pen(Color.DARK_GRAY, 0.7 * dpiScale);
        selectorBubbleBackground = new SolidBrush(new Color(0xe5e5e5,0.8));
        axisLabelColor = Color.GRAY;
        areaUnderLineBrush = new SolidBrush(Color.RED.changeAlpha(0.3));

        titleFont = Jive.theme.controlHeaderFont;
        font = new Font("Monospace", 12);

        graphComponent = new GraphComponent();
        interactionLayer = new GraphComponent();
        labelsLayer = new GraphComponent();
        
        graphContainer = new GraphComponent();
        graphContainer.append(graphComponent);
        graphContainer.append(interactionLayer);

        graphScroll = new Scroll();
        graphScroll.append(graphContainer);

        append(graphScroll);
        append(labelsLayer);

        ui = new ChartUI(this);
    }

    override public function paint(size: IntDimension) {
        if (needsPaint) {
            // ui.clear();
            ui.paint(size);
        }

        super.paint(size);
    }
}