package rightaway3d.engine.texture
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import rightaway3d.Urls;
	
	[Event(name="texture_loaded", type="flash.events.Event")]
	
	[Event(name="all_texture_loaded", type="flash.events.Event")]
	
	[Event(name="load_progress", type="flash.events.Event")]

	public class TextureLoader extends EventDispatcher
	{
		private var urlLoader:URLLoader;
		
		private const textureLoadedEvent:Event = new Event("texture_loaded");
		private const allTextureLoadedEvent:Event = new Event("all_texture_loaded");
		private const loadProgressEvent:Event = new Event("load_progress");
		
		public function TextureLoader()
		{
			init();
		}
		
		private function init():void
		{
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,onLoadComplete);
			urlLoader.addEventListener(ProgressEvent.PROGRESS,onLoadProgress);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoadError);
		}
		
		protected function onLoadProgress(event:ProgressEvent):void
		{
			this.dispatchEvent(loadProgressEvent);
		}
		
		protected function onLoadComplete(event:Event):void
		{
			currTexture.fileData = urlLoader.data;
			
			if(currTexture.fileType=="atf")
			{
				onLoaded();
			}
			else
			{
				loadBitmap();
			}
		}
		
		private var loader:Loader;
		
		private function loadBitmap():void
		{
			if(!loader)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onBitmapLoaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			}
			
			loader.loadBytes(currTexture.fileData);
		}
		
		private function onLoaded():void
		{
			currTexture.onReady();
			this.dispatchEvent(textureLoadedEvent);
			currTexture = null;
			loadNext();			
		}
		
		protected function onBitmapLoaded(event:Event):void
		{
			currTexture.bitmap = loader.content as Bitmap;
			onLoaded();
		}
		
		protected function onLoadError(event:Event):void
		{
			trace("Texture Load Error:"+event.type);
			currTexture = null;
			loadNext();
		}
		
		
		private var queue:Array = [];
		private var currTexture:TextureInfo;
		
		public function addTextureInfo(tex:TextureInfo):void
		{
			queue.push(tex);
		}
		
		public function startLoad():void
		{
			loadNext();
		}
		
		private function loadNext():void
		{
			if(queue.length>0 && !currTexture)
			{
				currTexture = queue.shift();
				load(currTexture);
			}
			else
			{
				trace("贴图全部加载完成");
				
				this.dispatchEvent(allTextureLoadedEvent);
			}
		}
		
		private function load(tex:TextureInfo):void
		{
			var url:String = Urls.materialBaseURL + tex.fileURL;
			trace("load:"+url);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(new URLRequest(url));
		}
		
		
		//==================================================
		static private var _own:TextureLoader;
		static public function get own():TextureLoader
		{
			_own = _own || new TextureLoader();
			return _own;
		}
	}
}