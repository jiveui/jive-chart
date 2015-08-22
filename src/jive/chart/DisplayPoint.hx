package jive.chart;

class DisplayPoint extends Point {

    public var minX(default, null): Point;
    public var maxX(default, null): Point;
    public var minY(default, null): Point;
    public var maxY(default, null): Point;

    public var displayX:Float;
    public var displayY:Float;

    public function new(minX: Point, maxX: Point, minY: Point, maxY: Point) {
        super(minX.xValue, minX.yValue);
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
    }

}
