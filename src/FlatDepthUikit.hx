package;

import al.prop.DepthComponent;
import a2d.Placeholder2D;
import openfl.Lib;
import a2d.Stage;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import data.DataType;
import data.aliases.AttribAliases;
import ec.Entity;
import fu.gl.GuiDrawcalls;
import gl.AttribSet;
import gl.RenderingPipeline;
import gl.aspects.ExtractionUtils;
import gl.passes.CmsdfPass;
import gl.passes.FlatColorPass;
import gl.passes.ImagePass;
import gl.passes.PassBase;
import gl.sets.CMSDFSet;
import gl.sets.ColorSet;
import htext.FontAspectsFactory;
import macros.AVConstructor;
import shaderbuilder.SnaderBuilder.PosDepth;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import shimp.ClicksInputSystem.ClickTargetViewState;

class FlatDepthUikit extends fu.UikitBase {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xBB121212, 0xBB121212, 0xBB121212, 0xBB121212,);

    public static var INTERACTIVE_COLORS(default, null):AVector<ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

    public static inline var DEPTH_MASK = "DEPTH_MASK";

    public static final DRAWCALLS_LAYOUT = '<container>
        <drawcall type="color"/>
        <drawcall type="text" font="" $DEPTH_MASK="false" />
    </container>';

    public function new(stage:Stage, ?pipeline:RenderingPipeline, fontPath = "Assets/fonts/robo.fnt") {
        CMSDFSet.instance.addAttribute(AttribAliases.NAME_DEPTH, 1, DataType.float32);
        CMSDFSet.instance.createWriters();
        ColorSet.instance.addAttribute(AttribAliases.NAME_DEPTH, 1, DataType.float32);
        ColorSet.instance.createWriters();

        Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, (e) -> {
            Lib.current.stage.context3D?.clear(0, 0, 0, 0, 0);
        });

        Lib.current.stage.addEventListener(openfl.events.RenderEvent.RENDER_OPENGL, onRender);

        super(stage, Xml.parse(DRAWCALLS_LAYOUT).firstElement(), fontPath);
    }
    
    override function configure(e:Entity) {
        super.configure(e);
        var dc = DepthComponent.getOrCreate(e);
        dc.value = 0;
    }

    function onRender(event:openfl.events.RenderEvent) {
        var renderer:openfl.display.OpenGLRenderer = cast event.renderer;
        event.target.stage.context3D.setDepthTest(true, openfl.display3D.Context3DCompareMode.GREATER_EQUAL);
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
        function replacePosElem(cp:PassBase<AttribSet>) {
            cp.vertElems.remove(PosPassthrough.instance);
            cp.vertElems.push(PosDepth.instance);
            return cp;
        }
        var enableMask = new gl.aspects.DepthMaskAspect(true);
        var disableMask = new gl.aspects.DepthMaskAspect(false);
        pipeline.addAspectExtractor(RenderingPipeline.ANY_DRAWCALL, (xml:Xml) -> {
            var dm = xml.get(DEPTH_MASK);
            if (dm == "false")
                return disableMask;
            return enableMask;
        });
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, replacePosElem(cast new FlatColorPass()));
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, replacePosElem(cast new CmsdfPass()));
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
        var attrs = ColorSet.instance;
        var shw = new fu.graphics.ShapeWidget(attrs, ph, true);
        shw.addChild(new graphics.shapes.QuadGraphicElement(attrs));
        var colors = new graphics.ShapesColorAssigner(attrs, color, shw.getBuffer());
        var depth = new fu.graphics.DepthAssigner(attrs, shw.getBuffer());
        ph.entity.addComponent(colors);
        ph.entity.addComponent(depth);
        shw.manInit();
        return shw.ph;
    }

}
