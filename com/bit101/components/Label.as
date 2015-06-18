package com.bit101.components
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    public class Label extends Component
    {
        protected var _autoSize:Boolean = true;
        protected var _text:String = "";
        protected var _tf:TextField;

        public function Label(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0, param4:String = "")
        {
            this.text = param4;
            super(param1, param2, param3);
            return;
        }// end function

        override protected function init() : void
        {
            super.init();
            mouseEnabled = false;
            mouseChildren = false;
            return;
        }// end function

        override protected function addChildren() : void
        {
            _height = 18;
            this._tf = new TextField();
            this._tf.height = _height;
            this._tf.embedFonts = Style.embedFonts;
            this._tf.selectable = false;
            this._tf.mouseEnabled = false;
            this._tf.defaultTextFormat = new TextFormat(Style.fontName, Style.fontSize, Style.LABEL_TEXT);
            this._tf.text = this._text;
            addChild(this._tf);
            this.draw();
            return;
        }// end function

        override public function draw() : void
        {
            super.draw();
            this._tf.text = this._text;
            if (this._autoSize)
            {
                this._tf.autoSize = TextFieldAutoSize.LEFT;
                _width = this._tf.width;
                dispatchEvent(new Event(Event.RESIZE));
            }
            else
            {
                this._tf.autoSize = TextFieldAutoSize.NONE;
                this._tf.width = _width;
            }
            var _loc_1:int = 18;
            this._tf.height = 18;
            _height = _loc_1;
            return;
        }// end function

        public function set text(param1:String) : void
        {
            this._text = param1;
            if (this._text == null)
            {
                this._text = "";
            }
            invalidate();
            return;
        }// end function

        public function get text() : String
        {
            return this._text;
        }// end function

        public function set autoSize(param1:Boolean) : void
        {
            this._autoSize = param1;
            return;
        }// end function

        public function get autoSize() : Boolean
        {
            return this._autoSize;
        }// end function

        public function get textField() : TextField
        {
            return this._tf;
        }// end function

    }
}
