package rightaway3d.user
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import rightaway3d.URLTool;
	import rightaway3d.engine.utils.BMP;
	
	[Event(name="data_loaded", type="flash.events.Event")]

	public class Project extends EventDispatcher
	{
		public var name:String;
		public var id:String;
		public var projectData:String;
		
		public var image2dURL:String;
		public var image3dURL:String;
		
		public var image2dID:String;
		public var image3dID:String;
		
		public var image2dData:ByteArray;
		public var image3dData:ByteArray;
		
		public var image2d:Bitmap;
		public var image3d:Bitmap;
		
		public function setImage2D(bmd:BitmapData):void
		{
			image2d = new Bitmap(bmd);
			image2dData = BMP.encodeBitmap(bmd);
		}
		
		public function setImage3D(bmd:BitmapData):void
		{
			image3d = new Bitmap(bmd);
			image3dData = BMP.encodeBitmap(bmd);
		}
		
		public function loadProjectData():void
		{
			var o:Object = {caseid:id};
			URLTool.CallRemote("getCaseData",o,onGetProjectData,onError);
		}
		
		private function onGetProjectData(result:*):void
		{
			trace("onGetProjectData:"+result);
			projectData = String(result);
			
			if(this.hasEventListener("data_loaded"))this.dispatchEvent(new Event("data_loaded"));
		}
		
		private function onError(result:Object):void
		{
			trace("getProjectData error:"+result);
		}
		
		public function Project()
		{
		}
	}
}