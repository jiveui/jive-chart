package jive.chart;

class IntValue extends FloatValue {

    var intValue(default, null): Int;

    public function new(v: Int) {
        super(v);
        intValue = v;
    }

    override private function get_floatValue(): Float { return intValue; }
    override private function get_caption(): String { return Std.string(intValue); }
    override public function getCaptionByFloatValue(v: Float): String { return Std.string(Std.int(v));}
    override public function getChartValueByFloatValue(v: Float): ChartValue {
        return new IntValue(Std.int(v));
    }

}
