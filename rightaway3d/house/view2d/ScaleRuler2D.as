package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import rightaway3d.utils.MyTextField;
	
	/**
	 * 比例尺
	 * @author Jell
	 * 
	 */
	public class ScaleRuler2D extends Sprite
	{
		private var ruler:Shape;
		private var txt:MyTextField;
		
		public function ScaleRuler2D()
		{
			super();
			init();
		}
		
		private function init():void
		{
			ruler = new Shape();
			this.addChild(ruler);
			
			txt = new MyTextField();
			txt.textSize = 20;
			txt.height = 30;
			this.addChild(txt);
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function updateView(scale:Number):void
		{
			var step:Number;
			if(scale<2)step = 50;
			else if(scale<10)step = 5;
			else
				step = 1;
			
			step *= scale;
			
			var gra:Graphics = ruler.graphics;
			gra.clear();
			gra.lineStyle(1,0x808080);
			
			var i:Number = 0;
			var dt:int = step*10<150?11:6;
			
			var t:int = 0;
			while(i<150 && t++<dt)
			{
				gra.moveTo(i,0);
				gra.lineTo(i,5);
				i += step;
			}
			
			i -= step;
			
			gra.lineStyle(2,0);
			gra.moveTo(0,0);
			gra.lineTo(0,10);
			
			gra.moveTo(i,0);
			gra.lineTo(i,10);
			
			gra.lineStyle(4,0);
			gra.moveTo(0,10);
			gra.lineTo(i,10);
			
			var n:Number = Math.round(i * Base2D.scaleRuler / scale);
			txt.text = String(n) + " mm";
			txt.width = txt.textWidth + 5;			
			txt.x = (i-txt.width)/2;
			ruler.y = 30;
		}
	}
}


















