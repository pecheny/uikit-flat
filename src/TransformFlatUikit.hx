package;

import ec.Entity;
import gl.aspects.TransformAspect;

class TransformFlatUikit extends FlatUikit {
    public function new(stage) {
        super(stage, null, null, new gl.TransformRenderingPipeline());
    }

    override public function createContainer(e:Entity, ?xml) {
        var transform = new TransformAspect();
        e.addComponent(transform);
        pipeline.addAspect(transform);
        return super.createContainer(e, xml);
    }
}
