package jive.chart;

class IntValue implements ChartValue {

    var value(default, null): Int;

    public function new(v: Int) {
        value = v;
    }

    public var floatValue(get, null): Float;
    private function get_floatValue(): Float { return value; }

    public var caption(get, null): String;
    private function get_caption(): String { return Std.string(value); }

    public function getCaptionByFloatValue(v: Float): String { return Std.string(Std.int(v));}
}
