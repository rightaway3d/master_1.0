package com.bit101.components
{
    import flash.display.*;
    import flash.events.*;

    public class CheckBox extends Component
    {
        protected var _back:Sprite;
        protected var _button:Sprite;
        protected var _label:Label;
        protected var _labelText:String = "";
        protected var _selected:Boolean = false;

        public function CheckBox(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0, param4:String = "", param5:Function = null)
        {
            this._labelText = param4;
            super(param1, param2, param3);
            if (param5 != null)
            {
                addEventListener(MouseEvent.CLICK, param5);
            }
            return;
        }// end function

        override protected function init() : void
        {
            super.init();
            buttonMode = true;
            useHandCursor = true;
            mouseChildren = false;
            return;
        }// end function

        override protected function addChildren() : void
        {
            this._back = new Sprite();
            this._back.filters = [getShadow(2, true)];
            addChild(this._back);
            this._button = new Sprite();
            this._button.filters = [getShadow(1)];
            this._button.visible = false;
            addChild(this._button);
            this._label = new Label(this, 0, 0, this._labelText);
            this.draw();
            addEventListener(MouseEvent.CLICK, this.onClick);
            return;
        }// end function

        override public function draw() : void
        {
            super.draw();
            this._back.graphics.clear();
            this._back.graphics.beginFill(Style.BACKGROUND);
            this._back.graphics.drawRect(0, 0, 10, 10);
            this._back.graphics.endFill();
            this._button.graphics.clear();
            this._button.graphics.beginFill(Style.BUTTON_FACE);
            this._button.graphics.drawRect(2, 2, 6, 6);
            this._label.text = this._labelText;
            this._label.draw();
            this._label.x = 12;
            this._label.y = (10 - this._label.height) / 2;
            _width = this._label.width + 12;
            _height = 10;
            return;
        }// end function

        protected function onClick(event:MouseEvent) : void
        {
            this._selected = !this._selected;
            this._button.visible = this._selected;
            return;
        }// end function

        public function set label(param1:String) : void
        {
            this._labelText = param1;
            invalidate();
            return;
        }// end function

        public function get label() : String
        {
            return this._labelText;
        }// end function

        public function set selected(param1:Boolean) : void
        {
            this._selected = param1;
            this._button.visible = this._selected;
            return;
        }// end function

        public function get selected() : Boolean
        {
            return this._selected;
        }// end function

        override public function set enabled(param1:Boolean) : void
        {
            super.enabled = param1;
            mouseChildren = false;
            return;
        }// end function

    }
}
