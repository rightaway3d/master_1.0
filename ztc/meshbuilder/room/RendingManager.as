package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.containers.View3D;

	/**
	 * 灯光材质总体控制类
	 * 创建此类,会自动创建LightManager 与  MaterialLibrary
	 * 需要传入材质库载入完成后的回调函数
	 */
	public class RendingManager
	{
		public static var instance:RendingManager = null;
		
		public var lightManager:LightManager;
		public var materialLibrary:MaterialLibrary;
		
		private var view:View3D;
		private var materialXMLUrl:String;
		private var houseMax:Vector3D;
		private var houseMin:Vector3D;
		
		public var xmlPath:String;
		public var defaultMaterialXML:XML;
		
		public var defaultMaterials:Object;
		
		public function RendingManager(view:View3D, materialXMLUrl:String, houseMax:Vector3D = null, houseMin:Vector3D = null)
		{
			instance = this;
			
			xmlPath = materialXMLUrl.substring(0,materialXMLUrl.lastIndexOf('/') + 1);
			
			RenderUtils.loadXML(xmlPath + 'defaultMaterials.xml',function(xml:XML):void {
				defaultMaterialXML = xml;
				defaultMaterials = new Object();
				
				for each(var x:XML in xml.children()) {
					defaultMaterials[x.@type] = x.@name;
				}
				trace("----DefaultMaterialsConfigLoaded----");
				materialLibrary.loadLibrary(materialXMLUrl);
			});
			
			this.view = view;
			this.materialXMLUrl = materialXMLUrl;
			this.houseMax = houseMax;
			this.houseMin = houseMin;
			
			init();
		}
		
		private function init():void
		{
			// 	先创建LightManager
			lightManager = new LightManager(view,houseMax,houseMin);
			
			// 再创建MaterialLibrary
			materialLibrary = new MaterialLibrary(view,lightManager);
		}
		
		/**
		 * 更新灯光的位置与亮度
		 */
		public function updateLights(houseMax:Vector3D, houseMin:Vector3D):void {
			this.houseMax = houseMax;
			this.houseMin = houseMin;
			lightManager.update(houseMax, houseMin);
		}
	}
}