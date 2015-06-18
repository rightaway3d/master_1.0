package rightaway3d.house.view2d
{
	import flash.display.Sprite;
	
	import rightaway3d.utils.MyMath;
	
	public class Base2D extends Sprite
	{
		//====================================================================
		/**
		 * 二维视图的全局比例为1像素对应20毫米（1:20）
		 */
		static public var scaleRuler:int = 20;
		
		/**
		 * 将屏幕值转换为对应的实际尺寸
		 */
		static public function screenToSize(value:Number):Number
		{
			return MyMath.round(value * scaleRuler);
		}
		
		/**
		 * 将实际尺寸转换为对应的屏幕值
		 */
		static public function sizeToScreen(value:Number):Number
		{
			return value / scaleRuler;
		}
		
		//====================================================================
		public function Base2D()
		{
			super();
		}
		
		private var _enable:Boolean;

		public function get enable():Boolean
		{
			return _enable;
		}

		public function set enable(value:Boolean):void
		{
			_enable = value;
			this.mouseEnabled = value;
			this.mouseChildren = value;
		}

		
		protected var _selected:Boolean = false;
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
		}
		
		//====================================================================
		public function dispose():void
		{
			
		}
		//====================================================================
	}
}