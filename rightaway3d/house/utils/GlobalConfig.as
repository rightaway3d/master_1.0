package rightaway3d.house.utils
{
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
		
		//public function set drainer
		
		public function toJsonString():String
		{
			var s:String = "{" +
					"\"wallPlateWidth\":" + wallPlateWidth
				+ "}";
			return s;
		}
		
		public function setConfigData(data:Object):void
		{
			Log.log("config1:"+data.wallPlateWidth);
			if(data.wallPlateWidth!=undefined)
			{
				wallPlateWidth = data.wallPlateWidth;
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
