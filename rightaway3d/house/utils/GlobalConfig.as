package rightaway3d.house.utils
{
	import flash.geom.Vector3D;
	
	import away3d.errors.AbstractMethodError;
	
	import jell3d.utils.SO;
	
	import rightaway3d.house.vo.Floor;
	import rightaway3d.utils.Log;

	/**
	 * 全局配置参数
	 * @author Jell
	 * 
	 */
	public class GlobalConfig
	{
		private const _wallPlateWidth:uint = 100;
		
		/**
		 * 临接墙的封板最大宽度，默认100
		 * @return 
		 * 
		 */
		public function get wallPlateWidth():uint
		{
			//return _wallPlateWidth;
			var s:String = SO.getSO("wallPlateWidth");
			return s?uint(s):_wallPlateWidth;
		}

		public function set wallPlateWidth(value:uint):void
		{
			Log.log("set wallPlateWidth:"+value);
			SO.setSO("wallPlateWidth",String(value));
		}
		
		/**
		 *灶台洞口数据，x：洞口宽度，y：洞口进深，z：圆角半径 
		 */
		private var flueHole:Vector3D;
		/**
		 * 设置灶台洞口数据，如果要清除自定义洞口数据，则将洞口宽度或进深设为0
		 * @param width：洞口宽度
		 * @param depth：洞口进深
		 * @param radius：圆角半径
		 * 
		 */
		public function setFlueHoleData(width:Number,depth:Number,radius:Number):void
		{
			if(width==0 || depth==0)
			{
				flueHole = null;
				return;
			}
			
			flueHole ||= new Vector3D();
			flueHole.x = width;
			flueHole.y = depth;
			flueHole.z = radius;
		}
		
		/**
		 * 灶台洞口宽度
		 * @return 
		 * 
		 */
		public function get flueHoleWidth():Number
		{
			return flueHole?flueHole.x:0;
		}
		
		/**
		 * 灶台洞口进深
		 * @return 
		 * 
		 */
		public function get flueHoleDepth():Number
		{
			return flueHole?flueHole.y:0;
		}
		
		/**
		 * 灶台洞口圆角半径
		 * @return 
		 * 
		 */
		public function get flueHoleRadius():Number
		{
			return flueHole?flueHole.z:0;
		}
		
		/**
		 *水盆洞口数据，x：洞口宽度，y：洞口进深，z：圆角半径 
		 */
		private var drainerHole:Vector3D;
		/**
		 * 设置水盆洞口数据，如果要清除自定义洞口数据，则将洞口宽度或进深设为0
		 * @param width：洞口宽度
		 * @param depth：洞口进深
		 * @param radius：圆角半径
		 * 
		 */
		public function setDrainerHoleData(width:Number,depth:Number,radius:Number):void
		{
			if(width==0 || depth==0)
			{
				drainerHole = null;
				return;
			}
			
			drainerHole ||= new Vector3D();
			drainerHole.x = width;
			drainerHole.y = depth;
			drainerHole.z = radius;
		}
		
		/**
		 * 水盆洞口宽度
		 * @return 
		 * 
		 */
		public function get drainerHoleWidth():Number
		{
			return drainerHole?drainerHole.x:0;
		}
		
		/**
		 * 水盆洞口进深
		 * @return 
		 * 
		 */
		public function get drainerHoleDepth():Number
		{
			return drainerHole?drainerHole.y:0;
		}
		
		/**
		 * 水盆洞口圆角半径
		 * @return 
		 * 
		 */
		public function get drainerHoleRadius():Number
		{
			return drainerHole?drainerHole.z:0;
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			if(drainerHole)s += "\"drainerHole\":" + getHoleData(drainerHole);
			if(flueHole)s += "\"flueHole\":" + getHoleData(flueHole);
			s += "\"wallPlateWidth\":" + wallPlateWidth;
			s += "}";
			return s;
		}
		
		private function getHoleData(hole:Vector3D):String
		{
			var s:String = "{";
			s += "\"x\":" + hole.x + ",";
			s += "\"y\":" + hole.y + ",";
			s += "\"z\":" + hole.z;
			s += "},";
			return s;
		}
		
		public function setConfigData(data:Object):void
		{
			//Log.log("config1:"+data.wallPlateWidth);
			if(data.wallPlateWidth!=undefined)
			{
				wallPlateWidth = data.wallPlateWidth;
			}
			
			if(data.drainerHole!=undefined)
			{
				var o:Object = data.drainerHole;
				setDrainerHoleData(o.x,o.y,o.z);
			}
			
			if(data.flueHole!=undefined)
			{
				o = data.flueHole;
				setFlueHoleData(o.x,o.y,o.z);
			}
		}
		
		//==============================================================================================
		public function GlobalConfig(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("GlobalConfig是一个单例类，请用静态属性instance来获得类的实例。");
			}
		}
		//==============================================================================================
		static private var _instance:GlobalConfig;
		
		static public function get instance():GlobalConfig
		{
			return _instance ||= new GlobalConfig(new InstanceClass());
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}
