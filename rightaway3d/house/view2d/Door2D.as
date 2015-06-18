package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	
	public class Door2D extends WinDoor2D
	{
		public function Door2D(type:String,doorWidth:int)
		{
			super();
		}
		
		override public function updateView():void
		{
			//trace("Door2D updateView");
			
			/*var x0:Number = doorWidth/2;
			var y0:Number = wallWidth/2;
			
			var gra:Graphics = this.graphics;
			
			gra.lineStyle(1,lineColor);
			
			gra.beginFill(fillColor);
			gra.drawRect(-x0,-y0,doorWidth,wallWidth);
			gra.endFill();
			
			gra.moveTo(-x0,0);
			gra.lineTo(-x0,doorWidth);
			gra.curveTo(x0,doorWidth,x0,0);*/
		}
	}
}