package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.HousePoint;

	public class WallNode2D extends Base2D
	{
		static public var lineColor:uint = 0x808080;
		static public var fillColor:uint = 0xFFFFFF;
		
		public var housePoint:HousePoint;
		
		public function WallNode2D()
		{
		}
		
		public function updateView():void
		{
			var cws:Vector.<CrossWall> = this.housePoint.crossWalls;
			var ww:int = 0;
			
			for each(var cw:CrossWall in cws)
			{
				if(cw.wall.width>ww)
				{
					ww = cw.wall.width;
				}
			}
			
			var n:Number = cws.length==1?1:1.414;
			var r:Number = Base2D.sizeToScreen(ww * 0.5) * n;
			var gra:Graphics = this.graphics;
			gra.clear();
			gra.lineStyle(0,lineColor);
			gra.beginFill(fillColor,0.9);
			gra.drawCircle(0,0,r);
			gra.endFill();
			
			this.x = Base2D.sizeToScreen(housePoint.point.x);
			this.y = Base2D.sizeToScreen(Base2D.screenToSize(Scene2D.sceneHeight) - housePoint.point.z);
		}
		
		public function updateCrossWall():void
		{
			
		}
	}
}