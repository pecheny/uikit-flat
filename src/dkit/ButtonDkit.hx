package dkit;

import a2d.Placeholder2D;
import dkit.Dkit.BaseDkit;
import fu.PropStorage;
import fu.Uikit;
import fu.bootstrap.ButtonScale;
import fu.graphics.ColouredQuad;
import fu.input.AutoFocusComponent;
import fu.input.WidgetFocus;
import fu.ui.ButtonBase;
import fu.ui.ButtonEnabled;
import fu.ui.CMSDFLabel;
import fu.ui.Properties.EnabledProp;
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
