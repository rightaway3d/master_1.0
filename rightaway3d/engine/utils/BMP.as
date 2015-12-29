package rightaway3d.engine.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	

	public final class BMP
	{
		/**
		 * 缩放位图至指定尺寸，如果未指定尺寸，则将位图尺寸最小限度的缩小到2的整数幂
		 * @param bmpData
		 * @return 
		 * 
		 */
		static public function scaleBmpData(bmpData:BitmapData,width:int=0,height:int=0,disposeBmpData:Boolean=true,transparent:Boolean=false):BitmapData
		{
			var bw:uint = bmpData.width;
			var bh:uint = bmpData.height;
			var pw:uint = width>0?width:getMaxPower(bw);
			var ph:uint = height>0?height:getMaxPower(bh);
			
			if(pw<ph)pw = ph;
			else
				ph = pw;
			
			if(pw!=bw || ph!=bh)
			{
				trace("自动将实际尺寸为"+bw+"x"+bh+"的位图，尺寸调整为"+pw+"x"+ph);
				
				/*var bmp:Bitmap = new Bitmap(bmpData,"auto",true);
				bmp.width = pw;
				bmp.height = ph;
				
				var sprite2:Sprite = new Sprite();
				sprite2.addChild(bmp);*/
				
				var m:Matrix = new Matrix(pw/bw,0,0,ph/bh);
				
				var bmpData2:BitmapData = new BitmapData(pw,ph,transparent,0x0);
				
				try{
					bmpData2.drawWithQuality(bmpData,m,null,null,null,true,StageQuality.HIGH_8X8);					
					//bmpData2.drawWithQuality(sprite2,null,null,null,null,true,StageQuality.HIGH_8X8);					
				}catch(e:*){
					bmpData2.draw(bmpData,m,null,null,null,true);					
					//bmpData2.draw(sprite2,null,null,null,null,true);					
				}
				
				if(disposeBmpData)
				{
					bmpData.dispose();
				}
				
				return bmpData2;
			}
			
			return bmpData;
		}
		
		/**
		 * 返回小于或等于给定值的最大的2的整数幂的值
		 * @param value
		 * @return 
		 * 
		 */
		static public function getMaxPower(value:uint):uint
		{
			var a:uint = 1;
			while(a<=value)
			{
				a = a<<1;
				//trace(a);
			}
			return a>>1;
		}
		
		static public function encodeBitmap(bmd:BitmapData,type:String="jpg"):ByteArray
		{
			var w:int = bmd.width;
			var h:int = bmd.height;
			var data:ByteArray = new ByteArray();
			var o:Object = type=="jpg"?new JPEGEncoderOptions():new PNGEncoderOptions();
			bmd.encode(new Rectangle(0,0,w,h),o,data);
			
			return data;
		}
		
		static public function getColorBitmap(color:uint,width:int,height:int):BitmapData
		{
			var bmd:BitmapData = new BitmapData(width,height,true,color);
			return bmd;
		}
		
		static public function getNormalBitmap(width:int=8,height:int=8):BitmapData
		{
			return new BitmapData(width,height,false,0x7f7fff);
		}
		
		static public function tileBmpData(source:BitmapData,width:int,height:int):BitmapData
		{
			var w:int = source.width;
			var h:int = source.height;
			
			var bd:BitmapData = new BitmapData(width,height,true,0);
			
			var tx:int = 0,ty:int = 0;
			
			while(tx<width)
			{
				ty = 0;
				
				while(ty<height)
				{
					bd.draw(source,new Matrix(1,0,0,1,tx,ty));
					
					ty += h;
				}
				
				tx += w;
			}
			
			return bd;
		}
		
		static private function _draw(source:BitmapData,target:BitmapData,x0:int,y0:int,w0:int,h0:int,x1:int,y1:int,w1:int,h1:int,sx:Number,sy:Number) : void
		{
			var bd:BitmapData = new BitmapData(w0,h0,false,0);
			bd.copyPixels(source,new Rectangle(x0,y0,w0,h0),new Point());
			target.draw(bd,new Matrix(sx,0,0,sy,x1,y1));
		}
		
		static public function grid9Scale(source:BitmapData,left:int,right:int,top:int,bottom:int,targetWidth:int,targetHeight:int) : BitmapData
		{ 
			var w : int = source.width;
			var h : int = source.height;
			
			var x0:int = w - right;
			var y0:int = h - bottom;
			
			var w0:int = x0 - left;
			var h0:int = y0 - top;
			
			var x1:int = targetWidth - right;
			var y1:int = targetHeight - bottom;
			
			var w1:int = x1 - left;
			var h1:int = y1 - top;
			
			var sx:Number = w1 / w0;
			var sy:Number = h1 / h0;
			
			var bd : BitmapData = new BitmapData(targetWidth, targetHeight, false, 0x0);
			
			_draw(source,bd,0,  0,left,   top, 0,  0,left,   top,1, 1);
			_draw(source,bd,0,top,left,    h0, 0,top,left,    h1,1,sy);
			_draw(source,bd,0, y0,left,bottom, 0, y1,left,bottom,1, 1);
			
			_draw(source,bd,left,  0, w0,   top, left,  0,w1,   top,sx, 1);
			_draw(source,bd,left,top, w0,    h0, left,top,w1,    h1,sx,sy);
			_draw(source,bd,left, y0, w0,bottom, left, y1,w1,bottom,sx, 1);
			
			_draw(source,bd,x0,  0,right,   top, x1,  0,right,   top,1, 1);
			_draw(source,bd,x0,top,right,    h0, x1,top,right,    h1,1,sy);
			_draw(source,bd,x0, y0,right,bottom, x1, y1,right,bottom,1, 1);
			
			return bd;
		} 
	}
}

