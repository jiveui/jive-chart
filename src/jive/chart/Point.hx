package jive.chart;

class Point {

    public var displayX(get, null):String;
    private function get_displayX():String { return xValue.caption;}

    public var displayY(get, null):Float;
    private function get_displayY():Float { return xValue.floatValue;}

    public var x(get, null): Float;
    private function get_x(): Float { return xValue.floatValue; }

    public var y(get, null): Float;
    private function get_y(): Float { return yValue.floatValue; }

    public var xCaption(get, null): String;
    private function get_xCaption(): String { return xValue.caption; }

    public var yCaption(get, null): String;
    private function get_yCaption(): String { return yValue.caption; }

    public var xValue: ChartValue;
    public var yValue: ChartValue;

    public function new(x: Dynamic, y: Dynamic) {

        if (Std.is(x, Int)) {
            xValue = new IntValue(x);
        } else if (Std.is(x, Float)) {
            xValue = new FloatValue(x);
        } else if (Std.is(x, Date)) {
            xValue = new DateValue(x);
        } else {
            xValue = x;
        }

        if (Std.is(y, Int)) {
            yValue = new IntValue(y);
        } else if (Std.is(y, Float)) {
            yValue = new FloatValue(y);
        } else if (Std.is(y, Date)) {
            yValue = new DateValue(y);
        } else {
            yValue = x;
        }
    }

}
