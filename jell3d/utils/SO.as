package jell3d.utils
{
	import flash.net.SharedObject;

	public final class SO
	{
		public function SO()
		{
		}
		
		/**
		 * 设置共享数据
		 * @param key：键
		 * @param value：值，当值为空或null时，删除共享数据
		 * @param path：共享数据存放位置
		 * 
		 */
		static public function setSO(key:String,value:String,path:String="data"):void
		{
			var so:SharedObject = SharedObject.getLocal(path);
			if(value){
				so.data[key] = value;
			}else if(so.data[key]){
				delete so.data[key];
			}
			
			so.flush();
		}
		
		/**
		 * 取出共享数据
		 * @param key：键
		 * @param path：共享数据存放位置
		 * @return 
		 * 
		 */
		static public function getSO(key:String,path:String="data"):String
		{
			var so:SharedObject = SharedObject.getLocal(path);
			//trace(key+":"+so.data[key]);
			return so.data[key]?so.data[key]:null;
		}
	}
}