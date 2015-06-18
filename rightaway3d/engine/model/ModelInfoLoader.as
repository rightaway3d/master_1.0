package rightaway3d.engine.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import rightaway3d.Urls;
	import rightaway3d.engine.product.ProductInfoLoader;
	
	public class ModelInfoLoader extends EventDispatcher
	{
		/**
		 * 是否加载中的指示标志
		 */
		public var isLoading:Boolean;
		/**
		 * 是否还有未加载完成的指示标志
		 */
		public var hasNotLoaded:Boolean;
		
		public var currModelInfo:ModelInfo;
		
		private var urlLoader:URLLoader;
		
		private var loadQueue:Array = [];
		
		public function ModelInfoLoader()
		{
			init();
		}
		
		private function init():void
		{
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,onLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoadError);
			
			isLoading = false;
			hasNotLoaded = false;
		}
		
		protected function onLoadComplete(event:Event):void
		{
			var xml:XML = new XML(urlLoader.data);
			currModelInfo.parse(xml);
			ModelLoader.own.addInfo(currModelInfo);
			
			loadNext();
			loadModel();
		}
		
		protected function onLoadError(event:Event):void
		{
			trace("====ModelInfo Load Error:"+currModelInfo.infoFileURL);
			loadNext();
		}
		
		public function addInfo(info:ModelInfo):void
		{
			//trace("addInfo:"+info.infoFileURL);
			loadQueue.push(info);
			//ModelLoader.own.addInfo(info);
			hasNotLoaded = true;
		}
		
		public function startLoad():void
		{
			loadNext();
		}
		
		private function loadNext():void
		{
			if(loadQueue.length>0)
			{
				currModelInfo = loadQueue.shift();
				load(currModelInfo);
			}
			else
			{
				isLoading = false;
				hasNotLoaded = false;
				//loadModel();
				
				if(!ProductInfoLoader.own.hasNotLoaded)trace("模型信息全部加载完成");
			}
		}
		
		private var mloader:ModelLoader = ModelLoader.own;
		
		public function loadModel():void
		{
			if(mloader.hasNotLoaded && !mloader.isLoading)//加载器中还存在未加载的内容，同时加载器也不在加载中，则启动加载
			{
				mloader.startLoad();
			}
		}
		
		private function load(m:ModelInfo):void
		{
			var url:String = Urls.mifBaseURL + m.infoFileURL;
			trace("----ModelInfo load:"+url);
			urlLoader.dataFormat = m.infoDataFormat==URLLoaderDataFormat.TEXT?URLLoaderDataFormat.TEXT:URLLoaderDataFormat.BINARY;
			urlLoader.load(new URLRequest(url));
			isLoading = true;
		}
		
		
		//==================================================
		static private var _own:ModelInfoLoader;
		static public function get own():ModelInfoLoader
		{
			_own = _own || new ModelInfoLoader();
			return _own;
		}
	}
}