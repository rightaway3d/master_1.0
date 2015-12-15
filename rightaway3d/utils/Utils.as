package rightaway3d.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.text.TextFormatAlign;

	public class Utils
	{
		public function Utils()
		{
		}
		
		/**
		 * 内容尺寸按指定比例适应容器
		 * @param sw：容器宽度
		 * @param sh：容器高度
		 * @param content：要适应的内容
		 * @param fs：内容适应容器的比例，默认为0.8
		 * @param cw：指定内容的宽度，如不指定，使用内容自身无缩放时的宽度
		 * @param ch：指定内容的高度，如不指定，使用内容自身无缩放时的高度
		 * 
		 */
		static public function fitContainer(sw:Number,sh:Number,content:DisplayObject,fs:Number=0.8,cw:Number=0,ch:Number=0):void
		{
			var s:Number = 1;
			
			content.scaleX = 1;
			content.scaleY = 1;
			
			var w:Number = cw>0 ? cw : content.width;//Base2D.sizeToScreen(cw.validLength+500);//face.width;
			var h:Number = ch>0 ? ch : content.height;
			
			if(sw/sh > w/h)//内容比较窄
			{
				s = sh*fs/h;
			}
			else
			{
				s = sw*fs/w;
			}
			
			content.scaleX = s;
			content.scaleY = s;
		}
		
		static public function getTextBitmap(text:String,size:int=6,color:uint=0):Bitmap
		{
			var txt:MyTextField = new MyTextField();
			txt.textSize = size * 10;
			txt.text = text;
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			txt.width = txt.textWidth + 5;
			txt.height = txt.textHeight + 2;
			txt.textColor = color;
			txt.align = TextFormatAlign.CENTER;
			
			var bmd:BitmapData = new BitmapData(txt.width,txt.height,true,0);
			bmd.draw(txt,null,null,null,null,true);
			
			var bmp:Bitmap = new Bitmap(bmd,"auto",true);
			bmp.smoothing = true;
			bmp.scaleX = bmp.scaleY = 0.1;
			
			return bmp;
		}
	}
}