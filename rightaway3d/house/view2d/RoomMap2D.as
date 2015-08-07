package rightaway3d.house.view2d
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.utils.MyTextField;

	public class RoomMap2D extends Sprite
	{
		public function RoomMap2D()
		{
			init();
		}
		
		private function init():void
		{
			var r:int = 20;
			var n:Number = r * 0.2;
			var x0:int = -r;
			var x1:int = r;
			var y0:int = -r+n;
			var y1:int = r-n;
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(1);
			/*g.moveTo(x0,0);
			g.lineTo(x1,0);
			g.moveTo(0,y0);
			g.lineTo(0,y1);*/
			g.drawRect(x0,y0,x1-x0,y1-y0);
			
			var txt:MyTextField = addText("A");
			txt.x = -txt.width*0.5;
			txt.y = y0-txt.height;
			
			txt = addText("B");
			txt.x = x1;
			txt.y = -txt.height*0.5;
			
			txt = addText("C");
			txt.x = -txt.width*0.5;
			txt.y = y1;
			
			txt = addText("D");
			txt.x = x0-txt.width;
			txt.y = -txt.height*0.5;
		}
		
		private function addText(s:String):MyTextField
		{
			var txt:MyTextField = new MyTextField();
			this.addChild(txt);
			
			txt.text = s;
			
			txt.textSize = 20;
			txt.align = TextFormatAlign.CENTER;
			
			txt.textColor = 0;
			txt.borderColor = 0xff0000;
			//txt.border = true;
			
			txt.width = txt.textWidth + 6;
			txt.height = txt.textHeight;
			
			return txt;
		}
	}
}