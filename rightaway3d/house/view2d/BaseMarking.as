package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import rightaway3d.utils.Utils;

	public class BaseMarking extends Sprite
	{
		static public var lineColor:uint = 0x0;
		
		//private var txt:MyTextField;
		
		public function BaseMarking()
		{
			//txt = new MyTextField();
			//txt.textSize = 60;
		}
		
		public function updateView(points:Array,direction:String="up",legLength:int=100,outLength:int=60,offset:int=0):void
		{
			//trace("marking points:",points);
			var len:int = points.length;
			if(len<2)return;
			
			this.removeChildren();
			
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,lineColor);
			
			if(direction=="left")
			{
				drawLeft(g,points,legLength,outLength,offset);
			}
			else
			{
				drawUp(g,points,direction,legLength,outLength,offset);
			}
		}
		
		private function drawLeft(g:Graphics,points:Array,legLength:int,outLength:int,offset:int):void
		{
			var n:int = 50;//标注线两端出头长度
			var len:int = points.length;
			//var tx0:int,tx1:int;
			var x0:int,y0:int,y1:int;
			y0 = points[0] - n;
			y1 = points[len-1] + n;
			
			x0 = - offset - legLength;
			
			var x1:Number = Base2D.sizeToScreen(x0);
			
			drawLine(g,x0,x0,y0,y1);
			
			for(var i:int=0;i<len;i++)
			{
				y1 = points[i];
				drawLine(g,x0-outLength,x0+legLength,y1,y1);
				drawCircle(g,x0,y1);
				
				if(i>0)
				{
					var dy:int = y1 - y0;
					
					var bmp:Bitmap = Utils.getTextBitmap(String(dy),6,lineColor);//getSizeText(length);
					var sp:Sprite = new Sprite();
					sp.addChild(bmp);
					this.addChild(sp);
					
					sp.x = x1 - bmp.height + 1;
					sp.y = Base2D.sizeToScreen(y1) - (Base2D.sizeToScreen(dy)-bmp.width)*0.5;
					
					sp.rotation = -90;
				}
				y0 = y1;
			}
		}
		
		private function drawUp(g:Graphics,points:Array,direction:String,legLength:int,outLength:int,offset:int):void
		{
			var len:int = points.length;
			var ty1:int,ty2:int;
			if(direction=="up")
			{
				ty1 = -legLength-offset;
				ty2 = ty1 - outLength;
			}
			else if(direction=="down")
			{
				ty1 = legLength-offset;
				ty2 = ty1 + outLength;
			}
			
			var y1:Number = Base2D.sizeToScreen(ty1);
			
			var x0:int = 0;
			var tx0:int = points[0];
			
			var tx1:int = points[len-1]-tx0;
			
			var n:int = 50;//标注线两端出头长度
			
			drawLine(g,x0-n,tx1+n,ty1,ty1);//画横线
			drawLine(g,x0,x0,-offset,ty2);//画竖线
			
			drawCircle(g,x0,ty1);//画交叉点
			
			for(var i:int=1;i<len;i++)
			{
				tx1 = points[i];
				var length:int = tx1 - tx0;
				
				var textBmp:Bitmap = Utils.getTextBitmap(String(length),6,lineColor);//getSizeText(length);
				this.addChild(textBmp);
				textBmp.y = y1 - textBmp.height + 1;
				textBmp.x = Base2D.sizeToScreen(x0) + (Base2D.sizeToScreen(length)-textBmp.width)*0.5;
				
				x0 += length;
				drawLine(g,x0,x0,-offset,ty2);//画竖线
				drawCircle(g,x0,ty1);//画交叉点
				
				tx0 = tx1;
			}
		}
		
		private function drawLine(g:Graphics,x0:int,x1:int,y0:int,y1:int):void
		{
			var tx0:Number = Base2D.sizeToScreen(x0);
			var tx1:Number = Base2D.sizeToScreen(x1);
			var ty0:Number = Base2D.sizeToScreen(y0);
			var ty1:Number = Base2D.sizeToScreen(y1);
			//trace("drawLine:",tx0,ty0,tx1,ty1);
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
		
		/*private function getSizeText(length:int):Bitmap
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
		}*/
	}
}