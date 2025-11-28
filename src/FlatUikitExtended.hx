package;

import gl.passes.CirclePass;

class FlatUikitExtended extends FlatUikit {
    public function new(stage) {
        super(stage);
        drawcallsLayout.addChild(Xml.parse('<drawcall type="circle"/>').firstElement());
    }

    override function regDefaultDrawcalls() {
        super.regDefaultDrawcalls();
        pipeline.addPass("circle", new CirclePass());
    }
}
