package jive.chart;

import StringTools;

class FloatValue implements ChartValue {

    public var value(default, null): Float;

    public function new(v: Float) {
        value = v;
    }

    public var floatValue(get, null): Float;
    private function get_floatValue(): Float { return value; }

    public var caption(get, null): String;
    private function get_caption(): String { return floatToStringPrecision(value, 2); }

    public function getCaptionByFloatValue(v: Float): String { return floatToStringPrecision(v, 2);}

    private static function floatToStringPrecision(n:Float, prec:Int){
        n = Math.round(n * Math.pow(10, prec));
        var str = ''+n;
        var len = str.length;
        if(len <= prec){
            while(len < prec){
                str = '0'+str;
                len++;
            }
            return '0.'+str;
        }
        else{
            return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
        }
    }

    public function getChartValueByFloatValue(v: Float): ChartValue {
        return new FloatValue(v);
    }

}
