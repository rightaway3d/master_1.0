package com.bit101.components
{
    import flash.display.*;
    import flash.events.*;

    public class VBox extends Component
    {
        protected var _spacing:Number = 5;

        public function VBox(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0)
        {
            super(param1, param2, param3);
            return;
        }// end function

        override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
        {
            super.addChildAt(param1, param2);
            param1.addEventListener(Event.RESIZE, this.onResize);
            invalidate();
            return param1;
        }// end function

        override public function removeChild(param1:DisplayObject) : DisplayObject
        {
            super.removeChild(param1);
            param1.removeEventListener(Event.RESIZE, this.onResize);
            invalidate();
            return param1;
        }// end function

        override public function removeChildAt(param1:int) : DisplayObject
        {
            var _loc_2:* = super.removeChildAt(param1);
            _loc_2.removeEventListener(Event.RESIZE, this.onResize);
            invalidate();
            return _loc_2;
        }// end function

        protected function onResize(event:Event) : void
        {
            invalidate();
            return;
        }// end function

        override public function draw() : void
        {
            var _loc_3:DisplayObject = null;
            _width = 0;
            _height = 0;
            var _loc_1:Number = 0;
            var _loc_2:int = 0;
            while (_loc_2 < numChildren)
            {
                
                _loc_3 = getChildAt(_loc_2);
                _loc_3.y = _loc_1;
                _loc_1 = _loc_1 + _loc_3.height;
                _loc_1 = _loc_1 + this._spacing;
                _height = _height + _loc_3.height;
                _width = Math.max(_width, _loc_3.width);
                _loc_2++;
            }
            _height = _height + this._spacing * (numChildren - 1);
            dispatchEvent(new Event(Event.RESIZE));
            return;
        }// end function

        public function set spacing(param1:Number) : void
        {
            this._spacing = param1;
            invalidate();
            return;
        }// end function

        public function get spacing() : Number
        {
            return this._spacing;
        }// end function

    }
}
