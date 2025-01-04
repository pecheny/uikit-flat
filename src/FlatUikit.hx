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
    static var ctx:FuCtx;

    public static function configure(ctx:FuCtx, e:Entity) {
        var dl = Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement();
        var fntPath = "Assets/fonts/robo.fnt";
        ctx.fonts.initFont("", fntPath, null);

        regDefaultDrawcalls(ctx);
        DrawcallUtils.createContainer(ctx.pipeline, e, dl);
        
        var fitStyle = ctx.textStyles.newStyle("fit")
        .withSize(pfr, .5)
        .withAlign(horizontal, Forward)
        .withAlign(vertical, Backward)
        .withPadding(horizontal, pfr, 0.33)
        .withPadding(vertical, pfr, 0.33)
        .build();
        ctx.textStyles.resetToDefaults();

    // rootEntity.addComponent(fitStyle);

    }

    public static function regDefaultDrawcalls(ctx:FuCtx):Void {
        var pipeline:RenderingPipeline = ctx.pipeline;
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, new FlatColorPass());
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, new CmsdfPass());
        var fontAsp = new FontAspectsFactory(ctx.fonts, pipeline.textureStorage);
        pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, fontAsp.create, fontAsp.getAlias);
        // pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, ExtractionUtils.colorUniformExtractor);

        pipeline.addPass(PictureDrawcalls.IMAGE_DRAWCALL, new ImagePass());
        var picAsp = new TextureAspectFactory(pipeline.textureStorage);
        pipeline.addAspectExtractor(PictureDrawcalls.IMAGE_DRAWCALL, picAsp.create);
    }

    public static function createContainer(e) {}
}
