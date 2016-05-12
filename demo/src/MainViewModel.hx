package ;


import openfl.Assets;
import haxe.ds.StringMap;
import flash.events.Event;
import flash.Lib;
import haxe.Http;
import jive.chart.Point;
import bindx.IBindable;
import haxe.Json;


class MainViewModel implements IBindable {

    var urls = ["http://www.quandl.com/api/v1/datasets/OFDP/GOLD_1.json?trim_start=1971-02-05",
    "http://www.quandl.com/api/v1/datasets/WORLDBANK/RUS_SP_POP_TOTL.json?trim_start=1971-01-01",
    "http://www.quandl.com/api/v1/datasets/BAVERAGE/USD.json",
    "http://www.quandl.com/api/v1/datasets/DOE/RBRTE.json"];

    var cache = [ Assets.getText("gold.json"), Assets.getText("ru_population.json"), Assets.getText("usd_bitcoin.json"), Assets.getText("oil.json")];

    @bindable public var menuSelectedIndex(default, set): Int;
    private function set_menuSelectedIndex(v: Int): Int {
        menuSelectedIndex = v;
        loadUrl(v);
        return v;
    }

    @bindable public var chartData: Array<Point> = [];
    @bindable public var selectedChartData: Array<Point> = [];
    @bindable public var chartTitle: String;

    public function new() {
        loadUrl(0);
    }


    // private var loadPopup(get, null):JPopup;
    // private function get_loadPopup(): JPopup {
    //     if (null == _loadPopup) {
    //         _loadPopup = new LoadingView();
    //         _loadPopup.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
    //         Lib.current.stage.addEventListener(Event.RESIZE, function(e) {
    //             _loadPopup.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
    //         });
    //     }
    //     return _loadPopup;
    // }
    // private var _loadPopup: JPopup;

    private function processData(data: String) {
        var result: Dynamic = Json.parse(data);
        var points = [];
        for (v in cast(result.data, Array<Dynamic>)) {
            points.push(new Point(Date.fromString(v[0]), v[1]));
        }
        chartData = points;
        chartTitle = result.name;
        loadPopup.hide();
    }

    private function loadUrl(index: Int) {
        loadPopup.show();

        var http: Http = new Http(urls[index]);

        http.onData = function(data) {
            trace(data);
            try {
                processData(data);
            } catch(e: Dynamic) {
                trace(e);
                processData(cache[index]);
            }
        }

        http.onError = function(msg: String) {
            processData(cache[index]);
        }

        http.request();
    }
}
