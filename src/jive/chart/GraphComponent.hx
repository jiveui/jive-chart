package jive.chart;

import flash.display.Graphics;

class GraphComponent extends Container {

    public var graphics(get, never) : Graphics;
    private function get_graphics() : Graphics {
        return sprite.graphics;
    }

    public function new() {
        super();
    }
}