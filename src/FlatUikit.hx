package;

import a2d.Placeholder2D;
import a2d.ContainerStyler;
import a2d.Stage;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import ec.Entity;
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

class FlatUikit extends fu.UikitBase {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xBB121212, 0xBB121212, 0xBB121212, 0xBB121212,);

    public static var INTERACTIVE_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

    public function new(stage:Stage, ?drawcallsLayout:Xml, fontPath = "Assets/fonts/robo.fnt", ?pipeline:RenderingPipeline) {
        if (drawcallsLayout == null)
            drawcallsLayout = Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement();
        super(stage, drawcallsLayout, fontPath, pipeline);
    }

    override function regStyles(e:Entity) {
        super.regStyles(e);
        textStyles.newStyle("small-text")
            .withSize(sfr, .07)
            .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .build();

        textStyles.newStyle("small-text-center").withAlign(horizontal, Center).build();

        var ts = textStyles;
        ts.resetToDefaults();
        ts.newStyle("center").withAlign(horizontal, Center).build();
        ts.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();

        textStyles.resetToDefaults();
    }

    override function regLayouts(e:Entity) {
        super.regLayouts(e);
        var distributer = new al.layouts.Padding(new FractionSize(.25), new PortionLayout(Center, new FixedSize(0.1)));
        containers.reg("hcards", distributer, WholefillLayout.instance);
    }

    override function regDefaultDrawcalls():Void {
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, new FlatColorPass());
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, new CmsdfPass());
        var fontAsp = new FontAspectsFactory(fonts, pipeline.textureStorage);
        pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, fontAsp.create, fontAsp.getAlias);

        pipeline.addPass(PictureDrawcalls.IMAGE_DRAWCALL, new ImagePass());
        var picAsp = new TextureAspectFactory(pipeline.textureStorage);
        pipeline.addAspectExtractor(PictureDrawcalls.IMAGE_DRAWCALL, picAsp.create);
    }

    override public function shape(ph:Placeholder2D, descr:Dynamic):Placeholder2D {
        return switch descr.type {
            case "quad": quad(ph, descr.color ?? 0);
            case _:
                trace('Unknown shape ${descr.type}');
                ph;
        }
    }

    public function quad(ph:a2d.Placeholder2D, color) {
        var attrs = gl.sets.ColorSet.instance;
        var shw = new fu.graphics.ShapeWidget(attrs, ph, true);
        shw.addChild(new graphics.shapes.QuadGraphicElement(attrs));
        var colors = new graphics.ShapesColorAssigner(attrs, color, shw.getBuffer());
        ph.entity.addComponent(colors);
        shw.manInit();
        return shw.ph;
    }
}
