package fu.ui;

import fu.graphics.ColouredQuad;

class Button extends ButtonBase {
    public function new(w, h, text, style) {
        super(w, h);
        ColouredQuad.flatClolorQuad(w);
        new Label(w, style).withText(text);
    }
}
