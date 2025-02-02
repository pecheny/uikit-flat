package dkit;

import fu.ui.Properties.EnabledProp;
import fu.ui.ButtonEnabled;
import fu.Uikit;
import al.core.DataView;
import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import a2d.Widget;
import al.appliers.ContainerRefresher;
import al.core.TWidget.IWidget;
import al.layouts.AxisLayout;
import al.layouts.WholefillLayout;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.PropStorage;
import fu.bootstrap.ButtonScale;
import fu.graphics.ColouredQuad;
import fu.ui.ButtonBase;
import fu.ui.CMSDFLabel;
import graphics.ShapesColorAssigner;
import htext.style.TextContextBuilder.TextContextStorage;

using a2d.ProxyWidgetTransform;

@:uiComp("button")
class ButtonDkit extends BaseDkit {
    public var label:CMSDFLabel;
    public var text(default, set):String = "";
    public var onClick:Void->Void;
    public var style(default, default):String = "";

    @:once var styles:TextContextStorage;
    @:once var props:PropStorage<Dynamic>;

    public function new(p:Placeholder2D, ?parent) {
        super(p, parent);
        initComponent();
    }

    override function init() {
        super.init();
        ProxyWidgetTransform.grantInnerTransformPh(ph);
        fui.quad(ph.getInnerPh(), 0);
        if (style == "")
            style = props.get(Dkit.TEXT_STYLE);
        label = new CMSDFLabel(ph.getInnerPh(), fui.s(style));
        new ButtonScale(ph.entity);
        text = text;
        if (ph.entity.hasComponent(EnabledProp))
            initEnabled(ph)
        else
            initSimple(ph);
    }

    function initSimple(ph) {
        var btn = new ButtonBase(ph, _onClick);
        btn.addHandler(new InteractiveColors(entity.getComponent(ShapesColorAssigner).setColor, Uikit.INTERACTIVE_COLORS).viewHandler);
    }

    function initEnabled(ph:Placeholder2D) {
        var ic = new InteractiveColors(ph.entity.getComponent(ShapesColorAssigner).setColor);
        var ep = EnabledProp.getOrCreate(ph.entity);
        ep.onChange.listen(() -> {
            @:privateAccess ic.colors = ep.value ? Uikit.INTERACTIVE_COLORS : Uikit.INACTIVE_COLORS;
        });
        ep.value = ep.value;
        var btn = new ButtonEnabled(ph, _onClick);
        btn.entity.addComponent(ic);
        btn.addHandler(ic.viewHandler);
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
class LabelDkit extends BaseDkit // implements DataView<String>
{
    public var color(default, set):Int = 0xffffff;
    public var label:CMSDFLabel;
    public var text(default, set):String = "";
    public var style(default, default):String = "";

    @:once var styles:TextContextStorage;
    @:once var props:PropStorage<Dynamic>;

    // public function new(p:Placeholder2D, ?parent) {
    //     super(p, parent);
    //     initComponent();
    // }

    override function init() {
        super.init();
        if (style == "")
            style = props.get(Dkit.TEXT_STYLE);
        label = new CMSDFLabel(ph, fui.s(style));
        color = color;
        text = text;
    }

    function set_color(value:Int):Int {
        color = value;
        label?.setColor(value);
        return value;
    }

    function set_text(value:String):String {
        text = value;
        label?.withText(value);
        return value;
    }

    // public function initData(descr:String):Void {
    //     set_text(descr);
    // }
}
