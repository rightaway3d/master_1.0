package rightaway3d.engine.skybox
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import rightaway3d.Urls;
	
	[Event(name="all_loaded", type="flash.events.Event")]
	[Event(name="load_error", type="flash.events.Event")]

	public class SkyBoxLoader extends EventDispatcher
	{
		private var loader:Loader;
		
		public function SkyBoxLoader()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
		}
		
		protected function onLoaded(event:Event):void
		{
			var bmp:Bitmap = loader.content as Bitmap;
			queue[index] = bmp.bitmapData;
			
			loadNext();
		}
		
		protected function onLoadError(event:IOErrorEvent):void
		{
			trace("SkyBoxLoader loadError:"+queue[index]);
			this.dispatchEvent(new Event("load_error"));
		}
		
		private var queue:Array;
		private var index:int;
		
		public function get bitmaps():Array
		{
			return queue;
		}
		
		public function load(queue:Array):void
		{
			this.queue = queue;
			
			index = -1;
			loadNext();
		}
		
		private function loadNext():void
		{
			if(++index < queue.length)
			{
				_load();
			}
			else
			{
				this.dispatchEvent(new Event("all_loaded"));
			}
		}
		
		private function _load():void
		{
			var url:String = Urls.skyboxBaseURL + queue[index];
			//trace("SkyBoxLoader load:"+url);
			loader.load(new URLRequest(url));
		}
	}
}