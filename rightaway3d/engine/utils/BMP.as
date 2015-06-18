package rightaway3d.engine.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageQuality;
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
		static public function scaleBmpData(bmpData:BitmapData,width:int=0,height:int=0,disposeBmpData:Boolean=true):BitmapData
		{
			var bw:uint = bmpData.width;
			var bh:uint = bmpData.height;
			var pw:uint = width>0?width:getMaxPower(bw);
			var ph:uint = height>0?height:getMaxPower(bh);
			if(pw!=bw || ph!=bh)
			{
				trace("自动将实际尺寸为"+bw+"x"+bh+"的位图，尺寸调整为"+pw+"x"+ph);
				
				//var sprite:Sprite = new Sprite();
				var bmp:Bitmap = new Bitmap(bmpData,"auto",true);
				//sprite.addChild(bmp);
				//sprite.width = pw;
				//sprite.height = ph;
				bmp.width = pw;
				bmp.height = ph;
				
				var sprite2:Sprite = new Sprite();
				sprite2.addChild(bmp);
				
				var bmpData2:BitmapData = new BitmapData(pw,ph,false,0);
				//bmpData2.drawWithQuality(sprite2,null,null,null,null,true,StageQuality.HIGH);					
				try{
					bmpData2.drawWithQuality(sprite2,null,null,null,null,true,StageQuality.HIGH_8X8);					
				}catch(e:*){
					bmpData2.draw(sprite2,null,null,null,null,true);					
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
		
	}
}