package rightaway3d.engine.model
{
	public class ReflectionInfo
		
	{
		public var materialName:String;
		
		public var skybox:Boolean;
		public var environment:Boolean;
		
		//public var fresnelMethod:FresnelEnvMapMethod;
		
		public function ReflectionInfo(xml:XML)
		{
			materialName = xml.material;
			
			var s:String = xml.skybox;
			skybox = s=="true"?true:false;
			
			s = xml.environment;
			environment = s=="true"?true:false;
		}
	}
	
}