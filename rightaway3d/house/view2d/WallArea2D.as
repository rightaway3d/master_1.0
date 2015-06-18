package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.vo.WallArea;

	public class WallArea2D extends Base2D
	{
		static public var LineColor:uint = 0xff0000;
		static public var FillColor:uint = 0xff0000;
		static public var FillAlpha:Number = 0.3;
		
		static public var LineColor2:uint = 0xff0000;
		static public var FillColor2:uint = 0xff0000;
		static public var FillAlpha2:Number = 0.2;
		
		public var lineColor:uint = LineColor;
		public var fillColor:uint = FillColor;
		public var fillAlpha:Number = FillAlpha;
		
		public var vo:WallArea;
		
		public function WallArea2D()
		{
			this.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
		}
		
		/**
		 * 此墙体是否锁定，锁定后将禁止任何交互操作
		 */
		public var isLock:Boolean = false;
		
		private function onRollOver(event:MouseEvent):void
		{
			if(isLock || selected || !vo.enable)return;
			
			lineColor = LineColor2;
			fillColor = FillColor2;
			fillAlpha = FillAlpha2;
			updateView();			
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			if(isLock || selected || !vo.enable)return;
			
			lineColor = LineColor;
			fillColor = FillColor;
			fillAlpha = FillAlpha;
			updateView();
		}
		
		override public function set selected(value:Boolean):void
		{
			if(_selected==value)return;
			
			_selected = value;
			
			lineColor = value?LineColor2:LineColor;
			fillColor = value?FillColor2:FillColor;
			fillAlpha = value?FillAlpha2:FillAlpha;
			
			updateView();
		}
		
		override public function dispose():void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
			this.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			
			if(vo)
			{
				vo.dispose();
				vo = null;
			}
		}
		
		public function updateView():void
		{
			var p:Point = new Point(vo.x0,0);
			vo.wall.localToGlobal2(p,p);//将当前视图位置转为全局坐标
			
			var x1:Number = Base2D.sizeToScreen(p.x);//将场景坐标值转换为屏幕坐标值
			var y1:Number = Base2D.sizeToScreen(Scene2D.sceneWidthSize - p.y);
			this.x = x1;
			this.y = y1;
			
			var a:Number = 360 - vo.wall.angles;
			this.rotation = a;//屏幕坐标系下的墙体角度
			
			var w:Number = Base2D.sizeToScreen(vo.x1-vo.x0);
			var h:Number = Base2D.sizeToScreen(vo.wall.width)*0.5;
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor,1);
			g.beginFill(fillColor,fillAlpha);
			g.drawRect(0,-h,w,h*2);
			g.endFill();
		}
	}
}