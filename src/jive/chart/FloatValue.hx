package jive.chart;

class FloatValue implements ChartValue {

    var value(default, null): Float;

    public function new(v: Float) {
        value = v;
    }

    public var floatValue(get, null): Float;
    private function get_floatValue(): Float { return value; }

    public var caption(get, null): String;
    private function get_caption(): String { return Std.string(value); }

    public function getCaptionByFloatValue(v: Float): String { return Std.string(v);}
}
