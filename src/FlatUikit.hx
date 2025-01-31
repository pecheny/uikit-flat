package;

import macros.AVConstructor;
import shimp.ClicksInputSystem.ClickTargetViewState;
import a2d.ContainerStyler;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import backends.openfl.DrawcallUtils;
import dkit.Dkit;
import ec.Entity;
import fu.FuCtx;
import fu.PropStorage;
import fu.gl.GuiDrawcalls;
import gl.RenderingPipeline;
import gl.aspects.ExtractionUtils;
import gl.passes.CmsdfPass;
import gl.passes.FlatColorPass;
import gl.passes.ImagePass;
import htext.FontAspectsFactory;

class FlatUikit {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xE6484848, 0xE6484848, 0xE6484848, 0xE6484848,);
    
    public static var INTERACTIVE_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

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
        regStyles(e);
        regLayouts(e);
    }

    function regStyles(e:Entity) {
        var default_text_style = "small-text";

        var pcStyle = ctx.textStyles.newStyle(default_text_style)
            .withSize(sfr, .07)
            .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .build();

        ctx.textStyles.resetToDefaults();

        var fitStyle = ctx.textStyles.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();
        ctx.textStyles.resetToDefaults();

        var props = new DummyProps<String>();
        props.set(Dkit.TEXT_STYLE, default_text_style);
        e.addComponentByType(PropStorage, props);
    }

    function regLayouts(e) {
        var distributer = new al.layouts.Padding(new FractionSize(.25), new PortionLayout(Center, new FixedSize(0.1)));
        var contLayouts = new ContainerStyler();
        contLayouts.reg("hcards", distributer, WholefillLayout.instance);
        e.addComponent(contLayouts);
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
