package ;

class LoadingView extends org.aswing.JPopup {

    public function destroyHml():Void {
        
    }
    

    inline function get_aSColor__0():org.aswing.ASColor {
        /* declarations/LoadingView.xml:8 characters: 13-20 */
        var res = new org.aswing.ASColor();
        /* declarations/LoadingView.xml:8 characters: 37-42 */
        res.alpha = 0.5;
        /* declarations/LoadingView.xml:8 characters: 22-25 */
        res.rgb = 0xcccccc;
        return res;
    }

    inline function get_centerLayout__0():org.aswing.CenterLayout {
        /* declarations/LoadingView.xml:11 characters: 13-25 */
        var res = new org.aswing.CenterLayout();
        return res;
    }

    inline function get_intDimension__0():org.aswing.geom.IntDimension {
        /* declarations/LoadingView.xml:15 characters: 17-34 */
        var res = new org.aswing.geom.IntDimension();
        /* declarations/LoadingView.xml:15 characters: 36-41 */
        res.width = 100;
        /* declarations/LoadingView.xml:15 characters: 48-54 */
        res.height = 20;
        return res;
    }

    inline function get_jProgressBar__0():org.aswing.JProgressBar {
        /* declarations/LoadingView.xml:13 characters: 9-21 */
        var res = new org.aswing.JProgressBar();
        /* declarations/LoadingView.xml:13 characters: 23-36 */
        res.indeterminate = true;
        /* declarations/LoadingView.xml:14 characters: 13-26 */
        res.preferredSize = get_intDimension__0();
        return res;
    }

    inline function get_jPanel__0():org.aswing.JPanel {
        /* declarations/LoadingView.xml:6 characters: 5-11 */
        var res = new org.aswing.JPanel();
        /* declarations/LoadingView.xml:6 characters: 13-19 */
        res.opaque = true;
        /* declarations/LoadingView.xml:7 characters: 9-19 */
        res.background = get_aSColor__0();
        /* declarations/LoadingView.xml:10 characters: 9-15 */
        res.layout = get_centerLayout__0();
        res.append(get_jProgressBar__0());
        return res;
    }

    public function new() {
        /* declarations/LoadingView.xml:2 characters: 1-7 */
        super();
        this.append(get_jPanel__0());
    }
}
