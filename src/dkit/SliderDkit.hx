package dkit;

import a2d.Placeholder2D;
import dkit.Dkit.BaseDkit;
import fu.Signal;
import fu.ui.Slider.FlatSlider;
import fu.ui.Slider.SliderInput;

using a2d.ProxyWidgetTransform;

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
