package;

import a2d.ContainerStyler;
import a2d.Stage;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import backends.openfl.DrawcallUtils;
import dkit.Dkit;
import ec.Entity;
import font.FontStorage;
import font.bmf.BMFont.BMFontFactory;
import fu.PropStorage;
import fu.gl.GuiDrawcalls;
import gl.RenderingPipeline;
import gl.aspects.ExtractionUtils;
import gl.passes.CmsdfPass;
import gl.passes.FlatColorPass;
import gl.passes.ImagePass;
import htext.FontAspectsFactory;
import htext.style.TextContextBuilder;
import macros.AVConstructor;
import shimp.ClicksInputSystem.ClickTargetViewState;

class FlatUikit {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xBB121212, 0xBB121212, 0xBB121212, 0xBB121212,);

    public static var INTERACTIVE_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

    public var pipeline:RenderingPipeline;
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    public var drawcallsLayout(default, null):Xml;
    public var textStyles:TextContextBuilder;

    public function new(stage:Stage, ?pipeline:RenderingPipeline) {
        this.pipeline = pipeline ?? new RenderingPipeline();
        textStyles = new TextContextBuilder(fonts, stage);
        drawcallsLayout = Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement();
    }

    public function configure(e:Entity) {
        var fntPath = "Assets/fonts/robo.fnt";
        fonts.initFont("", fntPath, null);

        regDefaultDrawcalls();
        regStyles(e);
        regLayouts(e);
    }

    function regStyles(e:Entity) {
        var default_text_style = "small-text";

        var pcStyle = textStyles.newStyle(default_text_style)
            .withSize(sfr, .07)
            .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .build();

        textStyles.newStyle("small-text-center").withAlign(horizontal, Center).build();

        textStyles.resetToDefaults();

        var fitStyle = textStyles.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();
        textStyles.resetToDefaults();

        var props = e.getOrCreate(PropStorage, () -> new CascadeProps<String>(null, "root-props"));
        props.set(Dkit.TEXT_STYLE, default_text_style);
    }

    function regLayouts(e:Entity) {
        var contLayouts = e.getComponent(ContainerStyler);
        if (contLayouts == null) {
            contLayouts = new ContainerStyler();
            e.addComponent(contLayouts);
        }
        var distributer = new al.layouts.Padding(new FractionSize(.25), new PortionLayout(Center, new FixedSize(0.1)));
        contLayouts.reg("hcards", distributer, WholefillLayout.instance);
    }

    function regDefaultDrawcalls():Void {
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, new FlatColorPass());
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, new CmsdfPass());
        var fontAsp = new FontAspectsFactory(fonts, pipeline.textureStorage);
        pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, fontAsp.create, fontAsp.getAlias);

        pipeline.addPass(PictureDrawcalls.IMAGE_DRAWCALL, new ImagePass());
        var picAsp = new TextureAspectFactory(pipeline.textureStorage);
        pipeline.addAspectExtractor(PictureDrawcalls.IMAGE_DRAWCALL, picAsp.create);
    }

    public function createContainer(e) {
        return DrawcallUtils.createContainer(pipeline, e, drawcallsLayout);
    }
}
