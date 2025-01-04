package;

import Axis2D;
import al.core.Align;
import backends.openfl.DrawcallUtils;
import ec.Entity;
import fu.FuCtx;
import fu.gl.GuiDrawcalls;
import gl.RenderingPipeline;
import gl.aspects.ExtractionUtils;
import gl.passes.CmsdfPass;
import gl.passes.FlatColorPass;
import gl.passes.ImagePass;
import htext.FontAspectsFactory;

class FlatUikit {
    var ctx:FuCtx;

    public var drawcallsLayout(default, null):Xml;

    public function new(ctx:FuCtx) {
        this.ctx = ctx;
        drawcallsLayout = Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement();
    }

    public function configure(e:Entity) {
        var fntPath = "Assets/fonts/robo.fnt";
        ctx.fonts.initFont("", fntPath, null);

        regDefaultDrawcalls();

        var fitStyle = ctx.textStyles.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();
        ctx.textStyles.resetToDefaults();
    }

    function regDefaultDrawcalls():Void {
        var pipeline:RenderingPipeline = ctx.pipeline;
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, new FlatColorPass());
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, new CmsdfPass());
        var fontAsp = new FontAspectsFactory(ctx.fonts, pipeline.textureStorage);
        pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, fontAsp.create, fontAsp.getAlias);

        pipeline.addPass(PictureDrawcalls.IMAGE_DRAWCALL, new ImagePass());
        var picAsp = new TextureAspectFactory(pipeline.textureStorage);
        pipeline.addAspectExtractor(PictureDrawcalls.IMAGE_DRAWCALL, picAsp.create);
    }

    public function createContainer(e) {
        return DrawcallUtils.createContainer(ctx.pipeline, e, drawcallsLayout);
    }
}
