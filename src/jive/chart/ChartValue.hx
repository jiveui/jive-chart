package jive.chart;

interface ChartValue {
    public var floatValue(get, null): Float;
    public var caption(get, null): String;
    public function getCaptionByFloatValue(v: Float): String;
    public function getChartValueByFloatValue(v: Float): ChartValue;
}
