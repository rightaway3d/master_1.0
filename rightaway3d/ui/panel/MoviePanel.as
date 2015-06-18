package rightaway3d.ui.panel
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import rightaway3d.media.VideoPlayer;
	
	public final class MoviePanel extends Sprite
	{
		private var loader:Loader;
		private var isLoading:Boolean;
		
		private var content:DisplayObject;
		
		private var viewWidth:int = 990;
		private var viewHeight:int = 600;
		
		private var contentWidth:int = 990;
		private var contentHeight:int = 600;
		
		private var videoPlayer:VideoPlayer;
		
		public function MoviePanel()
		{
			super();
		}
		
		public function loadVideo(url:String,width:int,height:int):void
		{
			clearMovie();
			if(!videoPlayer)videoPlayer = new VideoPlayer();
			if(!videoPlayer.stage)this.addChild(videoPlayer);
			videoPlayer.play(url,width,height);
		}
		
		public function loadMovie(url:String):void
		{
			clearMovie();
			clearVideo();
			_load(url);
		}
		
		private function clearMovie():void
		{
			if(content)
			{
				if(content is DisplayObjectContainer)
				{
					stopAllMovieClips(DisplayObjectContainer(content))
					/*var dc:DisplayObjectContainer = content as DisplayObjectContainer;
					dc.stopAllMovieClips();*/
				}
				this.removeChild(content);
				content = null;
			}			
		}
		
		private function clearVideo():void
		{
			if(videoPlayer && videoPlayer.stage)
			{
				videoPlayer.close();
				this.removeChild(videoPlayer);
			}
		}
		
		private function _load(url:String):void
		{
			if(!loader)
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			}
			else if(isLoading)
			{
				loader.close();
				loader.unload();
			}
			
			loader.load(new URLRequest(url));
			
			isLoading = true;
		}
		
		protected function onLoadError(event:IOErrorEvent):void
		{
			isLoading = false;
		}
		
		protected function onLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			
			contentWidth = loaderInfo.width;
			contentHeight = loaderInfo.height;
			
			content = loaderInfo.content;
			
			if(content is Bitmap)
			{
				var bmp:Bitmap = content as Bitmap;
				bmp.smoothing = true;
			}
			else if(content is MovieClip)
			{
				var mc:MovieClip = content as MovieClip;
				mc.play();
			}
			
			this.addChild(content);
			
			loaderInfo.loader.unload();
			isLoading = false;
			
			setViewSize(viewWidth,viewHeight);
		}
		
		public function show():void
		{
			this.visible = true;
			
			if(content && content is MovieClip)
			{
				var mc:MovieClip = content as MovieClip;
				mc.play();
			}
		}
		
		public function close():void
		{
			this.visible = false;
			
			/*if(content is MovieClip)
			{
				var mc:MovieClip = content as MovieClip;
				stopAllMovieClips(mc);
				try
				{
					mc.stopAllMovieClips();
				}
				catch(e:*)
				{
					stopAllMovieClips(mc);
				}
			}
			else
			if(content is DisplayObjectContainer)
			{
				stopAllMovieClips(DisplayObjectContainer(content))
			} */
			this.clearMovie();
			this.clearVideo();
		}
		
		private function stopAllMovieClips(mc:DisplayObjectContainer):void
		{
			if(mc is MovieClip)MovieClip(mc).stop();
			
			var len:int = mc.numChildren;
			for(var i:int=0;i<len;i++)
			{
				var d:DisplayObject = mc.getChildAt(i);
				if(d is DisplayObjectContainer)
				{
					stopAllMovieClips(DisplayObjectContainer(d));
				}
			}
		}
		
		public function setViewSize(w:int,h:int):void
		{
			viewWidth = w;
			viewHeight = h;
			
			if(videoPlayer)videoPlayer.updateView(w,h);
			
			if(!content)return;
			
			if(contentWidth>w || contentHeight>h)
			{
				if(contentWidth/contentHeight > w/h)//内容的宽高比比舞台的宽高比大时，使内容的宽度适合舞台的宽度，否则使内容的高度适合舞台的高度
				{
					content.scaleX = w/contentWidth;
					content.scaleY = content.scaleX;
				}
				else
				{
					content.scaleY = h/contentHeight;
					content.scaleX = content.scaleY;
				}
			}
			else
			{
				content.scaleY = 1;
				content.scaleX = 1;
			}
			
			content.x = (w-contentWidth*content.scaleX)/2;
			content.y = (h-contentHeight*content.scaleY)/2;
		}
	}
}


















