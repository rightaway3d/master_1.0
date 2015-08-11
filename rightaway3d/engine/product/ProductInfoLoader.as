package rightaway3d.engine.product
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import rightaway3d.Urls;
	import rightaway3d.engine.model.ModelInfoLoader;
	
	[Event(name="all_complete", type="flash.events.Event")]

	public class ProductInfoLoader extends EventDispatcher
	{
		public static const ALL_COMPLETE:String = "all_complete";
		/**
		 * 是否加载中的指示标志
		 */
		public var isLoading:Boolean;
		/**
		 * 是否还有未加载完成的指示标志
		 */
		public var hasNotLoaded:Boolean;
		
		private var urlLoader:URLLoader;
		
		public function ProductInfoLoader()
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
			var url:String = Urls.pdtBaseURL + currProduct.fileURL;
			trace("--ProductInfo loaded:"+url);
			
			var xml:XML = new XML(urlLoader.data);
			ProductManager.own.parseProductInfo(xml);
			
			loadNext();
			loadModelInfo();
		}
		
		protected function onLoadError(event:Event):void
		{
			trace("====ProductInfo Load Error:"+currProduct.fileURL);
			loadNext();
		}
		
		private var loadQueue:Array = [];
		private var currProduct:ProductInfo;
		
		public function addInfo(info:ProductInfo):void
		{
			loadQueue.push(info);
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
				currProduct = loadQueue.shift();
				load(currProduct);
			}
			else
			{
				isLoading = false;
				hasNotLoaded = false;
				
				trace("------------All ProductInfo Loaded!");
				if(this.hasEventListener(ALL_COMPLETE))
				{
					this.dispatchEvent(new Event(ALL_COMPLETE));
				}
				
				loadModelInfo();
			}
		}
		
		private var mloader:ModelInfoLoader = ModelInfoLoader.own;
		
		public function loadModelInfo():void
		{
			if(mloader.hasNotLoaded && !mloader.isLoading)//加载器中还存在未加载的内容，同时加载器也不在加载中，则启动加载
			{
				mloader.startLoad();
			}
		}

		private function load(p:ProductInfo):void
		{
			var url:String = Urls.pdtBaseURL + p.fileURL;
			trace("--ProductInfo load:"+url);
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.load(new URLRequest(url));
			isLoading = true;
		}
		
		//==================================================
		static private var _own:ProductInfoLoader;
		static public function get own():ProductInfoLoader
		{
			_own = _own || new ProductInfoLoader();
			return _own;
		}
	}
}