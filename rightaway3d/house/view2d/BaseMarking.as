package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.utils.MyTextField;

	public class BaseMarking extends Sprite
	{
		static public var lineColor:uint = 0x0;
		
		private var txt:MyTextField;
		
		public function BaseMarking()
		{
			txt = new MyTextField();
			txt.textSize = 60;
		}
		
		public function updateView(points:Array,direction:String="up",legLength:int=100,outLength:int=60):void
		{
			var len:int = points.length;
			if(len<2)return;
			
			this.removeChildren();
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor);
			
			var ty1:int,ty2:int;
			if(direction=="up")
			{
				ty1 = -legLength;
				ty2 = ty1 - outLength;
			}
			else
			{
				ty1 = legLength;
				ty2 = ty1 + outLength;
			}
			
			var y1:Number = Base2D.sizeToScreen(ty1);
			
			var x0:int = points[0];
			var tx0:int = 0;
			
			var tx1:int = points[len-1];
			
			drawLine(g,-outLength,tx1-x0+outLength,ty1,ty1);//画横线
			drawLine(g,tx0,tx0,0,ty2);//画竖线
			drawCircle(g,tx0,ty1);//画交叉点
			
			for(var i:int=1;i<len;i++)
			{
				tx1 = points[i] - x0;
				drawLine(g,tx1,tx1,0,ty2);//画竖线
				drawCircle(g,tx1,ty1);//画交叉点
				
				var length:int = tx1 - tx0;
				
				var textBmp:Bitmap = getSizeText(length);
				this.addChild(textBmp);
				textBmp.y = y1 - textBmp.height;
				textBmp.x = Base2D.sizeToScreen(tx0) + (Base2D.sizeToScreen(length)-textBmp.width)*0.5;
				
				tx0 = tx1;
			}
		}
		
		private function drawLine(g:Graphics,x0:int,x1:int,y0:int,y1:int):void
		{
			var tx0:Number = Base2D.sizeToScreen(x0);
			var tx1:Number = Base2D.sizeToScreen(x1);
			var ty0:Number = Base2D.sizeToScreen(y0);
			var ty1:Number = Base2D.sizeToScreen(y1);
			
			g.moveTo(tx0,ty0);
			g.lineTo(tx1,ty1);
		}
		
		private function drawCircle(g:Graphics,x0:int,y0:int):void
		{
			var tx:Number = Base2D.sizeToScreen(x0);
			var ty:Number = Base2D.sizeToScreen(y0);
			
			g.beginFill(lineColor);
			g.drawCircle(tx,ty,0.5);
			g.endFill();
		}
		
		private function getSizeText(length:int):Bitmap
		{
			txt.text = String(length);
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			txt.width = txt.textWidth + 5;
			txt.height = txt.textHeight + 2;
			txt.textColor = lineColor;
			txt.align = TextFormatAlign.CENTER;
			
			var bmd:BitmapData = new BitmapData(txt.width,txt.height,true,0);
			bmd.draw(txt,null,null,null,null,true);
			
			var bmp:Bitmap = new Bitmap(bmd,"auto",true);
			bmp.smoothing = true;
			//trace(bmp.width+"x"+bmp.height);
			bmp.scaleX = bmp.scaleY = 0.1;
			//trace(bmp.width+"x"+bmp.height);
			
			//txts.addChild(bmp);
			
			return bmp;
		}
	}
}