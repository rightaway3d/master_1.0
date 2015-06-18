package rightaway3d.preloader
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	//import rightaway3d.ui.loading.ILoading;

	//import flash.utils.ByteArray;
	
	//import rightaway3d.utils.crypt.Decrypt;
	
	public class Preloader extends Sprite
	{
		protected var mainSwf:*;
		protected var loading:*;
		
		protected var configFileName:String = "config/config_preloader.xml";
		
		private var percent:int;
		
		private var mainSwfURL:String;
		private var swfInfo:String;
		
		private var loadingURL:String;
		
		public function Preloader()
		{
			if(stage)
			{
				init();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,init);
			}
			super();
		}
		
		private function init(event:Event=null):void
		{
			if(event)this.removeEventListener(Event.ADDED_TO_STAGE,init);
			
			initStage();
//			loadConfig(configFileName);
		}
		
		public function loadConfig(url:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onConfigLoaded);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(new URLRequest(url));
			trace("loadConfig:"+url);
		}
		
		protected function onConfigLoaded(event:Event):void
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE,onConfigLoaded);
			
			var xml:XML = new XML(loader.data);
			mainSwfURL = xml.mainSwf;
			var s:String = xml.swfInfo;
			swfInfo = s?s:"null";
			
			loadingURL = xml.loadingSwf;
			percent = xml.loadPercent;
			trace("loadingURL:"+loadingURL);
			trace("mainSwfURL:"+mainSwfURL);
			trace("percent:"+percent);
			trace("swfInfo:"+swfInfo);
			loadLoading(loadingURL);
		}
		
		private function loadLoading(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadingLoaded);
			loader.load(new URLRequest(url));
		}
		
		protected function onLoadingLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onLoadingLoaded);
			
			loading = loaderInfo.content;// as Loading3;
			stage.addChild(loaderInfo.content);
			onStageResize();
			
			loaderInfo.loader.unload();
			
			loading.progress = 0;
			loading.startProgress();
			
			loadMainSwf(mainSwfURL);
		}
		
		private function loadMainSwf(url:String):void
		{
			//if(swfInfo)
			/*if(false)
			{
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(ProgressEvent.PROGRESS,onLoadMainSwfProgress);
				urlLoader.addEventListener(Event.COMPLETE,onMainSwfDataLoaded);
				urlLoader.load(new URLRequest(url));
			}
			else
			{
			}*/
			var c:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			c.allowCodeImport = true;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onMainSwfLoaded);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onLoadMainSwfProgress);
			loader.load(new URLRequest(url),c);
			trace("load:"+url);
		}
		
		protected function onMainSwfLoaded2(event:Event):void
		{
			trace("onMainSwfLoaded2");
		}
		
		/*protected function onMainSwfDataLoaded(event:Event):void
		{
			var urlLoader:URLLoader = event.currentTarget as URLLoader;
			urlLoader.removeEventListener(ProgressEvent.PROGRESS,onLoadMainSwfProgress);
			urlLoader.removeEventListener(Event.COMPLETE,onMainSwfDataLoaded);
			
			var b:ByteArray = urlLoader.data;
			b.uncompress();//解压缩数据
			b = Decrypt.decrypt(b,swfInfo);//解密
			
			var c:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			c.allowCodeImport = true;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onMainSwfLoaded);
			loader.loadBytes(b,c);
		}*/
		
		private var loadSwf:*;
		
		private function onMainSwfLoaded(event:Event):void
		{
			trace("onMainSwfLoaded");
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onMainSwfLoaded);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS,onLoadMainSwfProgress);
			
			loadSwf = loaderInfo.content;
			loaderInfo.loader.unload();
			if(loadSwf.hasOwnProperty("egg"))
			{
				trace("hasOwnProperty.egg");
				this.addEventListener(Event.ENTER_FRAME,doGetEgg);
			}
			else
			{
				initMainSwf(loadSwf);
			}
		}
		
		protected function doGetEgg(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME,doGetEgg);
			trace("doGetEgg:"+swfInfo);
			
			loadSwf.egg = swfInfo;
			loadSwf.addEventListener(Event.COMPLETE,onEggReady);
		}
		
		private function onEggReady(e:Event):void
		{
			var swf:* = e.currentTarget;
			swf.removeEventListener(Event.COMPLETE,onEggReady);
			initMainSwf(swf.egg);
		}
		
		protected function initMainSwf(swf:*):void
		{
			trace("initMainSwf");
			
			mainSwf = swf;
			mainSwf.setLoading(loading,percent);
			
			stage.addChildAt(mainSwf,0);
			
			stage.removeEventListener(Event.RESIZE,onStageResize);
			
			if(percent==100)
			{
				stage.removeChild(DisplayObject(loading));
				loading.endProgress();
			}
				
			loading = null;
			
			stage.removeChild(this);
		}
		
		private function onLoadMainSwfProgress(event:ProgressEvent):void
		{
			var n:Number = (event.bytesLoaded / event.bytesTotal) * percent;
			trace("%"+n+"="+event.bytesLoaded+"/"+event.bytesTotal);
			loading.progress = n;
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE,onStageResize);
		}
		
		private function onStageResize(event:Event=null):void
		{
			if(loading)
			{
				loading.setViewSize(stage.stageWidth,stage.stageHeight);
			}
		}
	}
}