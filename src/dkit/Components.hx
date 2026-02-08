package dkit;

import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import a2d.Widget;
import al.appliers.ContainerRefresher;
import al.core.DataView;
import al.core.TWidget.IWidget;
import al.layouts.AxisLayout;
import al.layouts.WholefillLayout;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.PropStorage;
import fu.Signal;
import fu.Uikit;
import fu.bootstrap.ButtonScale;
import fu.graphics.ColouredQuad;
import fu.input.AutoFocusComponent;
import fu.input.WidgetFocus;
import fu.ui.ButtonBase;
import fu.ui.ButtonEnabled;
import fu.ui.CMSDFLabel;
import fu.ui.Properties.EnabledProp;
import fu.ui.Slider.FlatSlider;
import fu.ui.Slider.SliderInput;
import graphics.ShapesColorAssigner;
import htext.style.TextContextBuilder.TextContextStorage;

using a2d.ProxyWidgetTransform;

@:uiComp("button")
class ButtonDkit extends BaseDkit {
    public var label:CMSDFLabel;
    public var text(default, set):String = "";
    public var onClick:Void->Void;
    public var enabled:Bool = true;

    /**
        Move focus on this button just after it had added to the stage. Forces 'focus' to be enabled.
    **/
    public var autoFocus:Bool = false;

    /**
        Add focus component to be managet by FocusManager.
    **/
    public var focus:Bool = false;

    public var style(default, default):String = "";

    @:once var styles:TextContextStorage;
    @:once var props:MultiPropStorage;

    public function new(p:Placeholder2D, ?parent) {
        super(p, parent);
        initComponent();
    }

    override function init() {
        super.init();
        ProxyWidgetTransform.grantInnerTransformPh(ph);
        fui.quad(ph.getInnerPh(), 0);
        if (style == "")
            style = props.getString(Dkit.TEXT_STYLE);
        label = new CMSDFLabel(ph.getInnerPh(), fui.s(style));
        new ButtonScale(ph.entity);
        text = text;
        if (ph.entity.hasComponent(EnabledProp) || enabled == false)
            initEnabled(ph)
        else
            initSimple(ph);
        if (autoFocus) {
            focus = true;
            entity.addComponent(new AutoFocusComponent());
        }
        if (focus)
            new WidgetFocus(ph);
    }

    function initSimple(ph) {
        var btn = new ButtonBase(ph, _onClick);
        btn.addHandler(new InteractiveColors(entity.getComponent(ShapesColorAssigner).setColor, Uikit.INTERACTIVE_COLORS).viewHandler);
        btn.changeViewState(Idle);
    }

    function initEnabled(ph:Placeholder2D) {
        function setLabelAlpha(enabled:Bool) {
            var color:utils.RGBA = @:privateAccess label.color;
            color.a = enabled ? 0xff : 0x90;
            label.setColor(color);
        };

        var ic = new InteractiveColors(ph.entity.getComponent(ShapesColorAssigner).setColor);
        var ep = EnabledProp.getOrCreate(ph.entity);
        ep.onChange.listen(() -> {
            @:privateAccess ic.colors = ep.value ? Uikit.INTERACTIVE_COLORS : Uikit.INACTIVE_COLORS;
            setLabelAlpha(ep.value);
        });
        ep.value = ep.value;
        var btn = new ButtonEnabled(ph, _onClick);
        btn.entity.addComponent(ic);
        btn.addHandler(ic.viewHandler);
        btn.changeViewState(Idle);
    }

    function _onClick() {
        if (onClick != null)
            onClick();
    }

    function set_text(value:String):String {
        text = value;
        label?.withText(value);
        return value;
    }
}

@:uiComp("label")
@:domkitDecl
class LabelDkit extends BaseDkit // implements DataView<String>
{
    public var align(default, set):Null<htext.Align>;
    public var color(default, set):Null<Int>;
    public var alpha(get, set):Int;
    public var label:CMSDFLabel;
    public var text(default, set):String = "";
    public var style(default, default):String = "";
    public var autoSize:Bool = false;

    @:once var styles:TextContextStorage;
    @:once var props:MultiPropStorage;

    public function new(p:Placeholder2D, ?parent) {
        super(p, parent);
    }

    override function init() {
        super.init();
        if (style == "")
            style = props.getString(Dkit.TEXT_STYLE);
        if (color == null)
            color = props.getInt(Dkit.TEXT_COLOR);
        if (color == null)
            color = 0;

        //  commented code - wip on scroll support for label widget
        // var ph = this.ph;
        // if (scroll)
        //     ph = b().b();
        label = new CMSDFLabel(ph, fui.s(style));
        if (autoSize) {
            label.setAutoSizeMode(word_wrap);
            // entity.addComponentByType(ResizableWidget2D, label);
        }
        // initDkit();
        color = color;
        text = text;
        align = align;
    }

    function set_color(value:Int):Int {
        color = value;
        label?.setColor(value);
        return value;
    }

    function set_alpha(v:Int) {
        var color:utils.RGBA = this.color;
        color.a = v;
        this.color = color;
        return v;
    };

    function get_alpha():Int {
        var color:utils.RGBA = this.color;
        return color.a;
    }

    function set_text(value:String):String {
        text = value;
        label?.withText(value);
        return value;
    }

    // public function initData(descr:String):Void {
    //     set_text(descr);
    // }

    function set_align(value) {
        label?.setAlign(value);
        return align = value;
    }
}

// @:postInit(initDkit)

@:uiComp("slider")
class SliderDkit extends BaseDkit {
    public var onChange(default, null):Signal<Float->Void>;
    public var onRelease(default, null):Signal<Void->Void>;
    public var value(get, set):Float;

    // public var align:Axis2D = horizontal;
    // see [2025-03-09 Sun 21:04] slider / input, next floor settings gui         :jnote:
    static var SRC = <slider ></slider>

    var input:SliderInput;

    // override function initDkit() {
    // super.initDkit();
    public function new(p:Placeholder2D, ?parent) {
        super(p, parent);
        input = new SliderInput(ph, horizontal);
        onChange = input.onChange;
        onRelease = input.onRelease;
        input.withProgress(0.5);
        FlatSlider.withFlat(input);
        initComponent();
    }

    function set_value(value:Float):Float {
        input.withProgress(value);
        return value;
    }

    function get_value():Float {
        return input.value;
    }
}
