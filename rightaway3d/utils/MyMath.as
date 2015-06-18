package rightaway3d.utils
{
	import flash.geom.Vector3D;

	public class MyMath
	{
		static public const PI:Number = Math.PI;
		static public var ZERO:Number = 0.0000001;
		
		/**
		 * 角度转弧度
		 */
		static public function anglesToRadians(value:Number):Number
		{
			return value / 180 * PI;
		}
		
		/**
		 * 角度转弧度
		 */
		static public function radiansToAngles(value:Number):Number
		{
			return ((value / PI * 180)+360)%360;
		}
		
		/**
		 * 将角度值转换到[0,360)的范围内
		 */
		static public function turnAngles(value:Number):Number
		{
			value %= 360;
			return value<0 ? value+360 : value;
		}
		
		/**
		 * 四舍五入取整
		 */
		static public function round(value:Number):int
		{
			return int(value+0.5);
		}
		
		/**
		 * 判断两个浮点数是否相等
		 * @param n1
		 * @param n2
		 * @return 
		 * 
		 */
		static public function isEqual(n1:Number,n2:Number):Boolean
		{
			return (n1>n2?n1-n2:n2-n1)<ZERO;
		}
		
		/**
		 * 判断n1是否大于n2
		 * @param n1
		 * @param n2
		 * @return 
		 * 
		 */
		static public function isGreater(n1:Number,n2:Number):Boolean
		{
			return !isEqual(n1,n2) && n1>n2;
		}
		
		/**
		 * 判断n1是否大于等于n2
		 * @param n1
		 * @param n2
		 * @return 
		 * 
		 */
		static public function isGreaterEqual(n1:Number,n2:Number):Boolean
		{
			return isEqual(n1,n2) || n1>n2;
		}
		
		/**
		 * 判断n1是否小于n2
		 * @param n1
		 * @param n2
		 * @return 
		 * 
		 */
		static public function isLess(n1:Number,n2:Number):Boolean
		{
			return !isEqual(n1,n2) && n1<n2;
		}
		
		/**
		 * 判断n1是否小于等于n2
		 * @param n1
		 * @param n2
		 * @return 
		 * 
		 */
		static public function isLessEqual(n1:Number,n2:Number):Boolean
		{
			return isEqual(n1,n2) || n1<n2;
		}
		
		/**
		 * 重置最大最小值
		 * @param max
		 * @param min
		 * 
		 */
		static public function resetMaxMin(max:Vector3D,min:Vector3D):void
		{
			if(min.x>max.x)
			{
				var t:Number = min.x;
				min.x = max.x;
				max.x = t;
			}
			if(min.y>max.y)
			{
				t = min.y;
				min.y = max.y;
				max.y = t;
			}
			if(min.z>max.z)
			{
				t = min.z;
				min.z = max.z;
				max.z = t;
			}
		}
		
	}
}














