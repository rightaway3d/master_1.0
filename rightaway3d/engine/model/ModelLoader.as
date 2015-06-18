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
	
	[Event(name="model_loaded", type="flash.events.Event")]
	
	[Event(name="all_model_loaded", type="flash.events.Event")]
	
	[Event(name="load_progress", type="flash.events.Event")]
	
	public class ModelLoader extends EventDispatcher
	{
		/**
		 * 是否加载中的指示标志
		 */
		public var isLoading:Boolean;
		/**
		 * 是否还有未加载完成的指示标志
		 */
		public var hasNotLoaded:Boolean;
		
		public var currModel:ModelInfo;
		
		public var progress:Number;
		
		private var urlLoader:URLLoader;
		
		private var loadQueue:Array = [];
		
		private var currIndex:int = -1;
		
		private var bytesTotal:Number = 0xffffff;
		private var bytesLoaded:Number = 0;
		
		private const modelLoadedEvent:Event = new Event("model_loaded");
		private const allModelLoadedEvent:Event = new Event("all_model_loaded");
		private const loadProgressEvent:Event = new Event("load_progress");
		
		public function ModelLoader()
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
			
			isLoading = false;
			hasNotLoaded = false;
		}
		
		protected function onLoadProgress(event:ProgressEvent):void
		{
			if(event.bytesTotal!=currModel.bytes)
			{
				currModel.bytes = event.bytesTotal;
				updateBytesTotal();
			}
			
			progress = (event.bytesLoaded+bytesLoaded) / bytesTotal;
			
			this.dispatchEvent(loadProgressEvent);
		}
		
		private function updateBytesTotal():void
		{
			var n:Number = 0;
			for each(var m:ModelInfo in loadQueue)
			{
				n += m.bytes;
			}
			
			bytesTotal = n;
		}
		
		private function updateBytesLoaded():void
		{
			var n:Number = 0;
			for each(var m:ModelInfo in loadQueue)
			{
				if(m.isModelReady)
				{
					n += m.bytes;
				}
			}
			
			bytesLoaded = n;
		}
		
		protected function onLoadComplete(event:Event):void
		{
			currModel.modelFileData = urlLoader.data;
			//trace("ModelLoader loaded:"+currModel.modelFileURL);
			
			currModel.isModelReady = true;
			updateBytesLoaded();
			
			this.dispatchEvent(modelLoadedEvent);
			
			loadNext();
		}
		
		protected function onLoadError(event:Event):void
		{
			trace("====ModelLoader Load Error:"+currModel.modelFileURL);
			
			currModel.isModelReady = true;
			updateBytesLoaded();
			
			loadNext();
		}
		
		private function initLoader():void
		{
			currIndex = -1;
			loadQueue.length = 0;
			
			isLoading = false;
			hasNotLoaded = false;
		}
		
		public function addInfo(info:ModelInfo):void
		{
			loadQueue.push(info);
			hasNotLoaded = true;
		}
		
		public function startLoad():void
		{
			bytesLoaded = 0;
			updateBytesTotal();
			loadNext();
		}
		
		private function loadNext():void
		{
			currIndex++;
			//trace("=================ModelLoader currIndex:"+currIndex);
			if(currIndex<loadQueue.length)
			{
				currModel = loadQueue[currIndex];
				load(currModel);
			}
			else
			{
				isLoading = false;
				hasNotLoaded = false;
				
				initLoader();
				
				if(!ProductInfoLoader.own.hasNotLoaded && !ModelInfoLoader.own.hasNotLoaded)
				{
					trace("模型全部加载完成");
					this.dispatchEvent(allModelLoadedEvent);
				}
			}
		}
		
		private function load(m:ModelInfo):void
		{
			isLoading = true;
			if(m.modelType!=ModelType.BOX)
			{
				var url:String = Urls.modelBaseURL + m.modelFileURL;
				trace("==ModelLoader load:"+url);
				urlLoader.dataFormat = m.modelDataFormat==URLLoaderDataFormat.TEXT?URLLoaderDataFormat.TEXT:URLLoaderDataFormat.BINARY;
				urlLoader.load(new URLRequest(url));
			}
			else//box格式模型没有模型文件，根据模型信息文件中的dimensions数据解析宽高及进深，并创建BoxMesh（CubeGeometry）
			{
				currModel.isModelReady = true;
				
				this.dispatchEvent(modelLoadedEvent);
				
				loadNext();
			}
		}
		
		
		//==================================================
		static private var _own:ModelLoader;
		static public function get own():ModelLoader
		{
			_own = _own || new ModelLoader();
			return _own;
		}
	}
}
/*
一个线上三维产品的构想
产品名称：虚拟房产
口号：虚拟房产助您网上安家，圆您住房梦
运营：
1，用户注册虚拟房产，送虚拟币若干，送虚拟住宅（毛坯房）一套（xx小区x楼x单元x房间），没有任何装饰，也没有任何家具电器，用户可自行装修装饰
   用户可以随意选择一套住宅，也可以根据自己的实际住处选择相匹配的三维户型，用户也可以选择自行创建新户型，可以分享户型，并奖励虚拟币，
   以后此户型每被一个其他用户使用，都会奖励一定的虚拟币
2，虚拟房产提供各种家具电器模型，有免费的，也有收费的，收费产品用虚拟币交易
3，虚拟房产提供虚拟土地出售，用户购买后，可自行修建及装饰房子(这个可以参考http://floorplanner.com/)
4，用户之间可以互相交易虚拟房产
5，用户之间可以互相帮助装饰
6，用户之间可以互相展示（炫耀）自己的虚拟家居
7，...各种规则玩法的制定完善

盈利模式：
1，虚拟币充值
2，和各大电商合作，虚拟房产中提供的家具电器关联到在售商品（在虚拟场景中点击模型可跳转到该商品购买链接）
3，和房地产商合作，进行在售房产的在线展示与推广
4，与家装公司合作
5，出租房屋三维展示
6，广告收入
 * */













