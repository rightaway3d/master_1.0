package rightaway3d.engine.model
{
	import flash.utils.Dictionary;

	public class ModelManager
	{
		private var infoDict:Dictionary;
		private var objectDict:Dictionary;
		
		public function ModelManager()
		{
			infoDict = new Dictionary();
			objectDict = new Dictionary();
		}
		
		//==================================================
		
		public function getInfo(infoID:String):ModelInfo
		{
			return infoDict[infoID]; 
		}
		
		//==================================================
		
		public function getObject(objectID:String):ModelObject
		{
			return objectDict[objectID]; 
		}
		
		public function getAllObjects():Array
		{
			var a:Array = [];
			for each(var mObj:ModelObject in objectDict)
			{
				a.push(mObj);
			}
			
			return a;
		}
		
		public function addObject(mObj:ModelObject):void
		{
			objectDict[mObj.objectID] = mObj;
		}
		
		public function removeObject(mObj:ModelObject):Boolean
		{
			if(objectDict[mObj.objectID]==mObj)
			{
				delete objectDict[mObj.objectID];
				return true;
			}
			return false;
		}
		
		/*public function removeObjectByID(objectID:String):Boolean
		{
			if(objectDict[objectID])
			{
				delete objectDict[objectID];
				return true;
			}
			return false;
		}*/
		
		//==================================================
		/*public function parseModelInfo(xml:XML):void
		{
			//已用ModelInfo.parse()方法代替此方法
		}*/
		
		public function getModelInfo(xml:XML):ModelInfo
		{
			var infoID:int = xml.infoID;
			if(!infoDict[infoID])
			{
				var fileURL:String = xml.file;
				var info:ModelInfo = createModelInfo(infoID);
				info.infoFileURL = fileURL;
				info.infoDataFormat = xml.dataFormat;
				ModelInfoLoader.own.addInfo(info);
			}
			
			info = infoDict[infoID];
			
			return info;
		}
		
		public function getModelInfoByID(infoID:int):ModelInfo
		{
			if(!infoDict[infoID])
			{
				createModelInfo(infoID);
			}
			
			var info:ModelInfo = infoDict[infoID];
			
			return info;
		}
			
		
		private function createModelInfo(infoID:int):ModelInfo
		{
			var info:ModelInfo = new ModelInfo();
			info.infoID = infoID;
			
			infoDict[infoID] = info;
			
			return info;
		}
		
		public function deleteModelInfo(info:ModelInfo):Boolean
		{
			if(infoDict[info.infoID]==info)
			{
				delete infoDict[info.infoID];
				return true;
			}
			return false;
		}
		
		//==================================================
		static private var _own:ModelManager;
		static public function get own():ModelManager
		{
			_own = _own || new ModelManager();
			return _own;
		}
	}
}