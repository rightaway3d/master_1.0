package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class BackGrid2D extends Sprite
	{
		//public var gridFillColor:uint = 0xFFFFFF;
		
		static public var gridLineColor0:uint = 0x808080;
		static public var gridLineColor1:uint = 0xBBBBBB;
		static public var gridLineColor2:uint = 0xAAAAAA;
		static public var gridLineColor3:uint = 0x999999;
		
		static public var backgroundColor:uint = 0xcccccc;//0xE2E2E2;
		
		static public var backgroundAlpha:Number = 1;
		
		static public var backGridAlpha:Number = 1;
		
		public function BackGrid2D()
		{
		}
		
		public function updateView(width:int,height:int,scale:Number):void
		{
			draw(this.graphics,width,height,scale);
		}
		
		//=========================================================================================================================
		private var thickness1:Number = 0;
		private var thickness2:Number = 0;
		private var thickness3:Number = 0;
		
		public var gridSize:int;
		
		//=========================================================================================================================
		private function draw(gra:Graphics,width:int,height:int,scale:Number):void
		{
			var fillColor:uint = backgroundColor;
			var border:int = 50;
			
			gra.clear();
			
			gra.lineStyle(1, fillColor,backgroundAlpha);
			gra.beginFill(fillColor,backgroundAlpha);
			gra.drawRect(-border,-border,width+border*2,height+border*2);
			gra.endFill();
			
			//trace("backGridAlpha:"+backGridAlpha);
			//gra.lineStyle(3, gridLineColor3);
			//gra.lineStyle(0, 0x808080);
			gra.lineStyle(0, gridLineColor0,backGridAlpha);
			gra.drawRect(0,0,width,height);
			
			var step:int;
			if(scale<2)step = 50;
			else if(scale<10)step = 5;
			else
				step = 1;
			
			gridSize = step;
			
			var i:int;
			
			//先画横线
			for(i=step;i<height;i+=step)
			{
				setLineStyle(step,i,gra);
				
				gra.moveTo(0,i);
				gra.lineTo(width,i);
			}
			
			//再画竖线
			for(i=step;i<width;i+=step)
			{
				setLineStyle(step,i,gra);
				
				gra.moveTo(i,0);
				gra.lineTo(i,height);
			}
		}
		
		private function setLineStyle(step:int,i:int,target:Graphics):void
		{
			if(step>=5)
			{
				if(i%500==0)target.lineStyle(thickness2,gridLineColor3,backGridAlpha);
				else if(i%50==0)target.lineStyle(thickness2,gridLineColor2,backGridAlpha);
				else
					target.lineStyle(thickness2,gridLineColor1,backGridAlpha);
			}
			else
			{
				if(i%50==0)target.lineStyle(thickness2,gridLineColor3,backGridAlpha);
				else if(i%5==0)target.lineStyle(thickness2,gridLineColor2,backGridAlpha);
				else
					target.lineStyle(thickness2,gridLineColor1,backGridAlpha);
			}
		}
		
		//=========================================================================================================================
	}
}