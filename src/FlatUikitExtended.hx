package;

import gl.passes.CirclePass;

class FlatUikitExtended extends FlatUikit {
    public function new(ctx) {
        super(ctx);
        drawcallsLayout.addChild(Xml.parse('<drawcall type="circle"/>').firstElement());
    }

    override function regDefaultDrawcalls() {
        super.regDefaultDrawcalls();
        ctx.pipeline.addPass("circle", new CirclePass());
    }
}
