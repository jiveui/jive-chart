package ;

// import MainView;
// import MainViewModel;
import haxe.Http;
import haxe.Json;
import jive.*;
import jive.chart.*;

class Main {
    var chartPeriodSelector : jive.chart.ChartPeriodSelector;
    var chart : jive.chart.Chart;

    public function new() {
        chart = new jive.chart.Chart();
        chart.data = [];
        chart.title = " TEST ";

        chartPeriodSelector = new jive.chart.ChartPeriodSelector();
    }

    public static function main() {
        Jive.start();
        // var w: MainWindow = new MainWindow();
        // w.dataContext = new MainViewModel();
        // w.opened = true;

        loadUrl();
    }

    private function processData(data: String) {
        var result: Dynamic = Json.parse(data);
        var points = [];
        for (v in cast(result.data, Array<Dynamic>)) {
            points.push(new Point(Date.fromString(v[0]), v[1]));
        }
        chartPeriodSelector.data = points;
        chart.title = result.name;
    }

    private function loadUrl() {
        var http: Http = new Http("http://www.quandl.com/api/v1/datasets/OFDP/GOLD_1.json?trim_start=1971-02-05");

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
