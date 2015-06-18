package rightaway3d.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	public final class ByteArrayUploader extends EventDispatcher
	{
		public var returnData:*;
		
		private var loader:URLLoader;
		
		public function ByteArrayUploader()
		{
			super();
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;

			loader.addEventListener(Event.COMPLETE, onUploadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onUploadEvent);
			//loader.addEventListener(ProgressEvent.PROGRESS,onUploadEvent);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onUploadEvent);
		}
		
		public function upload(serviceURL:String,data:ByteArray=null):void
		{
			//trace("upload:"+serviceURL);
			//var req:URLRequest = new URLRequest("http://192.168.1.133/xhouse/services/upload.php?fileName=a3d&type=a3d");
			var req:URLRequest = new URLRequest(serviceURL);
			req.method = URLRequestMethod.POST;
			if(data)
			{
				req.data = data;
				req.contentType = "application/octet-stream";
			}
			
			loader.load(req);
		}
		
		private function onUploadComplete(e:Event):void
		{
			this.returnData = loader.data;
			//trace("uploadcomplete:"+returnData);
			this.dispatchEvent(e);
		}
		
		private function onUploadEvent(e:*):void
		{
			Log.log("上传失败了:"+e.type);
			this.dispatchEvent(e);
		}
	}
}