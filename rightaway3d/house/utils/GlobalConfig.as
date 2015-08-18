package rightaway3d.house.utils
{
	import jell3d.utils.SO;

	/**
	 * 全局配置参数
	 * @author Jell
	 * 
	 */
	public class GlobalConfig
	{
		private var _wallPlateWidth:uint = 100;
		
		/**
		 * 临接墙的封板最大宽度，默认100
		 * @return 
		 * 
		 */
		public function get wallPlateWidth():uint
		{
			var s:String = SO.getSO("wallPlateWidth");
			return s?uint(s):_wallPlateWidth;
		}

		public function set wallPlateWidth(value:uint):void
		{
			SO.setSO("wallPlateWidth",String(value));
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
