package ;

import org.aswing.Insets;
import org.aswing.UIManager;
import org.aswing.SolidBackground;
import org.aswing.AsWingManager;
import flash.events.Event;
import org.aswing.border.EmptyBorder;
import flash.Lib;
import jive.chart.Point;

class Main {
    public static function main() {
        AsWingManager.initAsStandard(Lib.current);

        var WINDOW: MainView = new MainView();

        WINDOW.setBackgroundDecorator(new SolidBackground(UIManager.getColor("window")));
        WINDOW.setBorder(new EmptyBorder(null, Insets.createIdentic(10)));
        WINDOW.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
        WINDOW.show();

        WINDOW.dataContext = new MainViewModel();

        Lib.current.stage.addEventListener(Event.RESIZE, function(e) {
            WINDOW.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
        });
    }
}
