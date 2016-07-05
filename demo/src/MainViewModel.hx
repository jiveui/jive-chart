package ;


import openfl.Assets;
import flash.events.Event;
import flash.Lib;
import haxe.ds.StringMap;
import haxe.Http;
import haxe.Json;
import jive.ViewModel;
import jive.Flow;
import jive.chart.Point;


@:bindable
class MainViewModel extends ViewModel {

    private var urls = ["http://www.quandl.com/api/v1/datasets/OFDP/GOLD_1.json?trim_start=1971-02-05",
    "http://www.quandl.com/api/v1/datasets/WORLDBANK/RUS_SP_POP_TOTL.json?trim_start=1971-01-01",
    "http://www.quandl.com/api/v1/datasets/BAVERAGE/USD.json",
    "http://www.quandl.com/api/v1/datasets/DOE/RBRTE.json"];

    private var cache = [ Assets.getText("gold.json"), Assets.getText("ru_population.json"), Assets.getText("usd_bitcoin.json"), Assets.getText("oil.json")];

    public var menuSelectedIndex(default, set): Int;
    private function set_menuSelectedIndex(v: Int): Int {
        menuSelectedIndex = v;
        loadUrl(v);
        return v;
    }

    public var chartData: Array<Point> = [];
    public var selectedChartData: Array<Point> = [];
    public var chartTitle: String;

    public function new() {
        super();
        loadUrl(2);
    }

    private function processData(data: String) {
        var result: Dynamic = Json.parse(data);
        var points = [];
        for (v in cast(result.data, Array<Dynamic>)) {
            points.push(new Point(Date.fromString(v[0]), v[1]));
        }
        chartData = points;
        chartTitle = result.name;
    }

    private function loadUrl(index: Int) {
        var http: Http = new Http(urls[index]);

        // http.onData = function(data) {
        //     trace(data);
        //     try {
        //         processData(data);
        //     } catch(e: Dynamic) {
        //         trace(e);
        //         processData(cache[index]);
        //     }
        // }

        // http.onError = function(msg: String) {
            processData(cache[index]);
        // }

        http.request();
    }
}
