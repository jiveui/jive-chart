package jive.chart;

class DateValue implements ChartValue {

    var value(default, null): Date;

    public function new(v: Date) {
        value = v;
    }

    public var floatValue(get, null): Float;
    private function get_floatValue(): Float { return value.getTime(); }

    public var caption(get, null): String;
    private function get_caption(): String { return DateTools.format(value, "%d.%m.%Y" ); }

    public function getCaptionByFloatValue(v: Float): String { return DateTools.format(Date.fromTime(v),"%d.%m.%Y" ) ;}

}
