package ;

import MainView;
import MainViewModel;
//import jive.*;

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
        // #if debug
        //     new debugger.HaxeRemote(true, "localhost");
        // #end
        
        Jive.start();
        var w: MainView = new MainView();
        w.dataContext = new MainViewModel();
        w.opened = true;

        // var chart = new jive.chart.Chart("asdf");
    }
}

// import openfl.text.TextField;
// class Main {
//     public static function main() {
//         var tf = new TextField();
//         tf.text = "Some text";
//         openfl.Lib.current.stage.addChild(tf);
//     }
// }
