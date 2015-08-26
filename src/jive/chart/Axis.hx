package jive.chart;

class Axis {

    public var axisName: String;
    public var axisUnit: String;

    public function new(axisName:String = null, axisUnit: String = null) {
        this.axisName = axisName;
        this.axisUnit = axisUnit;
    }

    public function getLabelValueString(minValue: ChartValue, maxValue: ChartValue): String {
        return doGetLabelValueString(axisName, axisUnit, minValue, maxValue);
    }

    public dynamic function doGetLabelValueString(axisName: String, axisUnit: String, minValue: ChartValue, maxValue: ChartValue): String {

        var text = getPrefixString(axisName, axisUnit, minValue, maxValue);
        if (minValue.floatValue == maxValue.floatValue) {
            text += getValueString(minValue);
        } else {
            text += getValueString(minValue) + " - " + getValueString(maxValue);
        }
        text += getSuffixString(axisName, axisUnit, minValue, maxValue);

        return text;
    }

    public dynamic function getPrefixString(axisName: String, axisUnit: String, minValue: ChartValue, maxValue: ChartValue): String {
        var text = "";

        if (null != axisName) text += axisName;
        if (null != axisUnit) text += " (" + axisUnit+ ")";
        if ("" != text) text += ": ";
        return text;
    }

    public dynamic function getSuffixString(axisName: String, axisUnit: String, minValue: ChartValue, maxValue: ChartValue): String {
        return "";
    }

    public dynamic function getValueString(value: ChartValue) {
        return value.caption;
    }

    public dynamic function getShortValueString(value: ChartValue) {
        return value.caption;
    }
}
