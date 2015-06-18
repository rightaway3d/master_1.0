package rightaway3d
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class URLTool
	{
		public function URLTool()
		{
		}
		
		static public function JoinURL(cmd:String,arg:Object,base:String="index.php?m=control&c=case&a="):String
		{
			var s:String = Urls.ServerURL + base + cmd;
			if(arg)
			{
				for(var key:String in arg)
				{
					s += "&"+key+"="+arg[key];
				}
			}
			return s;
		}
		
		static public function CallRemote(cmd:String,arg:Object,onResult:Function,onFail:Function=null,data:ByteArray=null):void
		{
			var url:String = JoinURL(cmd,arg);
			LoadURL(url,onResult,onFail,data);
		}
		
		static private var loadSuccessDict:Dictionary = new Dictionary();
		static private var loadFailDict:Dictionary = new Dictionary();
		static private var urlDict:Dictionary = new Dictionary();
		
		static public function LoadURL(url:String,onResult:Function,onFail:Function=null,data:ByteArray=null,resultDataFormat:String="text"):void
		{
			trace("callRemote:"+url);
			var loader:URLLoader = new URLLoader();
			
			var r:URLRequest = new URLRequest(url);
			if(data)
			{
				trace("data.length:"+data.length);
				r.data = data;
				r.method = URLRequestMethod.POST;
				//r.contentType = "application/octet-stream";
				r.contentType = "multipart/form-data";
				loader.dataFormat = URLLoaderDataFormat.BINARY;
			}
			else
			{
				loader.dataFormat = resultDataFormat;
			}
			
			loader.addEventListener(Event.COMPLETE,onRemoteCallSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onRemoteCallError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onRemoteCallError);
			
			urlDict[loader] = url;
			loadSuccessDict[loader] = onResult;
			if(onFail!=null)loadFailDict[loader] = onFail;
			
			loader.load(r);
		}
		
		static private function onRemoteCallSuccess(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			
			var resultFun:Function = loadSuccessDict[loader];
			resultFun(loader.data);
			
			removeEvent(loader);
		}
		
		static private function onRemoteCallError(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			
			var msg:String = "Load Fail:[url:" + urlDict[loader] + " type:" + e.type + "]";
			showTips(msg);
			
			if(loadFailDict[loader])
			{
				var failFun:Function = loadFailDict[loader];
				failFun(msg);
			}
			
			removeEvent(loader);
		}
		
		static private function removeEvent(loader:URLLoader):void
		{
			loader.removeEventListener(Event.COMPLETE,onRemoteCallSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onRemoteCallError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onRemoteCallError);
			
			delete urlDict[loader];
			delete loadSuccessDict[loader];
			
			if(loadFailDict[loader])delete loadFailDict[loader];
		}
		
		static private function showTips(s:String):void
		{
			trace(s);
		}
	}
}