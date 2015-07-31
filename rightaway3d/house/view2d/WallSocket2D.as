package rightaway3d.house.view2d
{
	import flash.display.Graphics;

	public class WallSocket2D extends Base2D
	{
		public function WallSocket2D()
		{
			draw();
		}
		
		public function updateView(xPos:int,yPos:int):void
		{
			this.x = Base2D.sizeToScreen(xPos);
			this.y = -Base2D.sizeToScreen(yPos);
		}
		
		private function draw():void
		{
			var width:int=100,height:int=100;
			
			var w:Number = Base2D.sizeToScreen(width);
			var h:Number = Base2D.sizeToScreen(height);
			
			var aw:Number = w*0.5;
			
			var lineColor:uint = WallFace2D.lineColor;
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0.1,lineColor);
			g.drawRect(-aw,-h,w,h);
			
			g.lineStyle(1,lineColor);
			g.moveTo(0,-Base2D.sizeToScreen(80));
			g.lineTo(0,-Base2D.sizeToScreen(60));
			
			var y1:Number = Base2D.sizeToScreen(20);
			var y2:Number = Base2D.sizeToScreen(30);
			
			g.moveTo(-Base2D.sizeToScreen(30),-y1);
			g.lineTo(-Base2D.sizeToScreen(16),-y2);
			
			g.moveTo(Base2D.sizeToScreen(16),-y2);
			g.lineTo(Base2D.sizeToScreen(30),-y1);
		}
	}
}