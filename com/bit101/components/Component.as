package com.bit101.components
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;

    public class Component extends Sprite
    {
        protected var Ronda:Class;
        protected var _width:Number = 0;
        protected var _height:Number = 0;
        protected var _tag:int = -1;
        protected var _enabled:Boolean = true;
        public static const DRAW:String = "draw";

        public function Component(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0)
        {
            this.Ronda = Component_Ronda;
            this.move(param2, param3);
            if (param1 != null)
            {
                param1.addChild(this);
            }
            this.init();
            return;
        }// end function

        protected function init() : void
        {
            this.addChildren();
            this.invalidate();
            return;
        }// end function

        protected function addChildren() : void
        {
            return;
        }// end function

        protected function getShadow(param1:Number, param2:Boolean = false) : DropShadowFilter
        {
            return new DropShadowFilter(param1, 45, Style.DROPSHADOW, 1, param1, param1, 0.3, 1, param2);
        }// end function

        protected function invalidate() : void
        {
            addEventListener(Event.ENTER_FRAME, this.onInvalidate);
            return;
        }// end function

        public function move(param1:Number, param2:Number) : void
        {
            this.x = Math.round(param1);
            this.y = Math.round(param2);
            return;
        }// end function

        public function setSize(param1:Number, param2:Number) : void
        {
            this._width = param1;
            this._height = param2;
            this.invalidate();
            return;
        }// end function

        public function draw() : void
        {
            dispatchEvent(new Event(Component.DRAW));
            return;
        }// end function

        protected function onInvalidate(event:Event) : void
        {
            removeEventListener(Event.ENTER_FRAME, this.onInvalidate);
            this.draw();
            return;
        }// end function

        override public function set width(param1:Number) : void
        {
            this._width = param1;
            this.invalidate();
            dispatchEvent(new Event(Event.RESIZE));
            return;
        }// end function

        override public function get width() : Number
        {
            return this._width;
        }// end function

        override public function set height(param1:Number) : void
        {
            this._height = param1;
            this.invalidate();
            dispatchEvent(new Event(Event.RESIZE));
            return;
        }// end function

        override public function get height() : Number
        {
            return this._height;
        }// end function

        public function set tag(param1:int) : void
        {
            this._tag = param1;
            return;
        }// end function

        public function get tag() : int
        {
            return this._tag;
        }// end function

        override public function set x(param1:Number) : void
        {
            super.x = Math.round(param1);
            return;
        }// end function

        override public function set y(param1:Number) : void
        {
            super.y = Math.round(param1);
            return;
        }// end function

        public function set enabled(param1:Boolean) : void
        {
            this._enabled = param1;
            var _loc_2:* = this._enabled;
            mouseChildren = this._enabled;
            mouseEnabled = _loc_2;
            tabEnabled = param1;
            alpha = this._enabled ? (1) : (0.5);
            return;
        }// end function

        public function get enabled() : Boolean
        {
            return this._enabled;
        }// end function

        public static function initStage(param1:Stage) : void
        {
            param1.align = StageAlign.TOP_LEFT;
            param1.scaleMode = StageScaleMode.NO_SCALE;
            return;
        }// end function

    }
}
