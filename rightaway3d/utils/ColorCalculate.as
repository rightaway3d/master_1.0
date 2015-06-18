package rightaway3d.utils
{
	/**
	 *定义颜色值的加减乘除运算 
	 * @author a
	 * 
	 */
	public class ColorCalculate
	{
		//----------------------------------------------------------------------------------------
		//
		/**
		 * 加
		 * @param value1
		 * @param value2
		 * @return 
		 * 
		 */
		public static function addition(value1:uint,value2:uint):uint
		{
			var rgb1:Array = colorToRGB(value1);
			var rgb2:Array = colorToRGB(value2);
			
			rgb1[0] = rgb1[0] + rgb2[0];
			rgb1[1] = rgb1[1] + rgb2[1];
			rgb1[2] = rgb1[2] + rgb2[2];
			
			return rgbAryToColor(rgb1);
		}
		//-------------------------------------------------------------
		//
		/**
		 * 减
		 * @param value1
		 * @param value2
		 * @return 
		 * 
		 */
		public static function subtraction(value1:uint,value2:uint):uint
		{
			var rgb1:Array = colorToRGB(value1);
			var rgb2:Array = colorToRGB(value2);
			
			rgb1[0] = rgb1[0] - rgb2[0];
			rgb1[1] = rgb1[1] - rgb2[1];
			rgb1[2] = rgb1[2] - rgb2[2];
			
			return rgbAryToColor(rgb1);
		}
		//-------------------------------------------------------------
		//
		/**
		 * 乘
		 * @param value1
		 * @param value2
		 * @return 
		 * 
		 */
		public static function multiplication(value1:uint,value2:Number):uint
		{
			var rgb1:Array = colorToRGB(value1);
			
			rgb1[0] = rgb1[0] * value2;
			rgb1[1] = rgb1[1] * value2;
			rgb1[2] = rgb1[2] * value2;
			
			return rgbAryToColor(rgb1);
		}
		//-------------------------------------------------------------
		//
		/**
		 * 除
		 * @param value1
		 * @param value2
		 * @return 
		 * 
		 */
		public static function division(value1:uint,value2:uint):uint
		{
			
			if (!value2) {//被除数为0
				return value1;
			}
			
			var rgb1:Array = colorToRGB(value1);
			
			rgb1[0] = rgb1[0] / value2;
			rgb1[1] = rgb1[1] / value2;
			rgb1[2] = rgb1[2] / value2;
			
			return rgbAryToColor(rgb1);
		}
		//----------------------------------------------------------------------------------------
		private static function colorToRGB(color:uint):Array {
			if(color > 0xFFFFFF) {
				return[0xFF, 0xFF, 0xFF];
			}
			var rgb:Array = [];
			rgb[0] = color >> 16;//red
			rgb[1] = color >> 8 & 0xFF;//green
			rgb[2] = color & 0xFF;//blue
			return rgb;
		}
		//-------------------------------------------------------------
		//将包含颜色元素的数组组合成一个颜色值
		private static function rgbAryToColor(rgb:Array):uint {
			var i:int = 0;
			while(i < 3) {
				if(rgb[i] < 0) {
					rgb[i] = 0;
				} else if(rgb[i] > 0xFF) {
					rgb[i] = 0xFF;
				}
				i++;
			}
			return rgb[0] << 16 | rgb[1] << 8 | rgb[2];
		}
		//----------------------------------------------------------------------------------------
	}
}