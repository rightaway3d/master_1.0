package rightaway3d.player
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public final class Main extends Sprite
	{
		private const configURL:String = "config_player.xml";
		
		public function Main()
		{
			super();
			if(stage)
			{
				init();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,init);
			}
		}
		
		private function init(e:Event=null):void			
		{
			if(e)this.removeEventListener(Event.ADDED_TO_STAGE,init);
			
			initStage();
			loadConfig();
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		private function loadConfig():void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE,onConfigLoaded);
			loader.load(new URLRequest(configURL));
		}
		
		private function onConfigLoaded(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE,onConfigLoaded);
			
			var xml:XML = new XML(loader.data);
			var sceneName:String = xml.scene_name;
			var dataFormat:String = xml.data_format;
			loadScene(sceneName,dataFormat);
		}
		
		private function loadScene(sceneName:String,dataFormat:String):void
		{
			trace("loadScene:"+sceneName);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = dataFormat==URLLoaderDataFormat.TEXT?dataFormat:URLLoaderDataFormat.BINARY;
			
			loader.addEventListener(Event.COMPLETE,onSceneLoaded);
			loader.load(new URLRequest(sceneName));
		}
		
		private function onSceneLoaded(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE,onConfigLoaded);
			
			var xml:XML = new XML(loader.data);
			trace(xml);
		}
	}
}























