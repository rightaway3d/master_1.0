package rightaway3d.media
{
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoPlayer extends Sprite
	{
		private var nc:NetConnection;
		private var ns:NetStream;
		
		private var video:Video;
		
		public function VideoPlayer()
		{
			super();
		}
		
		public function play(url:String,width:int,height:int):void
		{
			if(!nc)
			{
				nc = new NetConnection();
				nc.connect(null);
				
				ns = new NetStream(nc);
				var _client:Object=new Object();
				_client.onMetaData=onMetaData;
				ns.client=_client;
				
				video = new Video();
				this.addChild(video);
				video.attachNetStream(ns);
			}
			
			video.width = width;
			video.height = height;
			
			updateView(stage.stageWidth,stage.stageHeight);
			
			ns.play(url);
		}
		
		public function close():void
		{
			if(ns)
			{
				ns.pause();
			}
		}
		
		private function onMetaData(data:Object):void
		{
		}
		
		public function updateView(w:int,h:int):void
		{
			if(video)
			{
				video.x = (w-video.width)/2;
				video.y = (h-video.height)/2;
			}
		}
		
		//创建一个 NetConnection 对象
//		private var nc:NetConnection=new NetConnection();
//		
//		/*创建一个 NetStream 对象（该对象将 NetConnection 对象作为参数）并
//		指定要加载的 FLV 文件*/
//		private var ns:NetStream=new NetStream(nc);
//		
//		//音量初始值
//		private var yl:Number=0.5;
//		private var nsyl:SoundTransform. =new SoundTransform();
//		//申明变量播放与下载百分比以及总时间（秒）的初始值为0
//		
//		private var bfbfb:int=0;
//		private var xzbfb:int=0;
//		
//		private function init():void
//		{
//			/*如果连接到没有使用服务器的FLV 文件，则通过向 connect() 方法传递值
//			null，来播放流式 FLV 文件*/
//			nc.connect(null);
//			
//			ns.play("http://www.helpexamples.com/flash/video/cuepoints.flv");
//			
//			/*使用 Video 类的 attachNetStream() 方法附加以前创建的 NetStream
//			对象（视频实例名为vid）*/
//			vid.attachNetStream(ns);
//			
//			//nsyl.volume=yl
//			//播放进度与加载进度影片缩放为0
//			bfjd_mc.scaleX=jzjd_mc.scaleX=0;
//		}
//		private var _duration:Number=0;
//		//指定在其上调用回调方法的对象
//		private var _client:Object=new Object();
//		_client.onMetaData=onMetaData;
//		ns.client=_client;
//		//按钮可见性与添加侦听事件
//		play_btn.visible=false;
//		pause_btn.visible=true;
//		pause_btn.addEventListener(MouseEvent.CLICK, zt);
//		play_btn.addEventListener(MouseEvent.CLICK, bf);
//		//忽略错误
//		ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
//		private function asyncErrorHandler(event:AsyncErrorEvent):void {
//		}
//		//暂停
//		private function zt(event:MouseEvent):void {
//			play_btn.visible=true;
//			pause_btn.visible=false;
//			//视频暂停
//			ns.pause();
//		}
//		//播放
//		private function bf(event:MouseEvent):void {
//			play_btn.visible=false;
//			pause_btn.visible=true;
//			//恢复回放暂停的视频流
//			ns.resume();
//			addEventListener(Event.ENTER_FRAME,gx);
//		}
//		//接收在正播放的 FLV 文件中嵌入的描述性信息时调度
//		private function onMetaData(data:Object):void {
//			_duration=data.duration;
//		}
//		//申明变量播放信号
//		private var bfxh:String;
//		//侦听视频流的开始和末尾
//		ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
//		private function statusHandler(event:NetStatusEvent):void {
//			bfxh=event.info.code;
//		}
//		//不断更新进度与文本的显示
//		addEventListener(Event.ENTER_FRAME,gx);
//		private function gx(event:Event):void {
//			if (ns.bytesLoaded>0) {
//				//加载进度
//				xzbfb=ns.bytesLoaded/ns.bytesTotal*100;
//				jzjd_mc.scaleX=xzbfb/100;
//			}
//			if (_duration>0 && ns.time>0) {
//				//播放进度
//				bfbfb=ns.time/_duration*100;
//				bfjd_mc.scaleX=bfbfb/100;
//			}
//			if (bfxh=="NetStream.Play.Stop") {
//				//播放完毕时的设置
//				bfbfb=0;
//				bfjd_mc.scaleX=0;
//				ns.pause();
//				ns.seek(0);//将播放头置于视频开始处
//				play_btn.visible=true;
//				pause_btn.visible=false;
//			}
//			//文本显示内容
//			bftxt.text=Math.round(ns.time/60)+":"+Math.round(ns.time%60);
//			zcdtxt.text=Math.round(_duration/60)+":"+Math.round(_duration%60);
//			//音量控制
//			yl=(ylhk_mc.x-345)/50;
//			ylt_mc.scaleX=yl;
//			nsyl.volume =yl;
//			ns.soundTransform. =nsyl;
//		}
//		//音量滑块拖动控制
//		private var fw:Rectangle=new Rectangle(345,328,50,0);//拖动范围
//		ylhk_mc.addEventListener(MouseEvent.MOUSE_DOWN,ylhkax);
//		ylhk_mc.addEventListener(MouseEvent.MOUSE_UP,ylhksk);
//		stage.addEventListener(MouseEvent.MOUSE_UP,ylhksk);
//		private function ylhkax(event:MouseEvent):void {
//			ylhk_mc.startDrag(false,fw);
//		}
//		private function ylhksk(event:MouseEvent):void {
//			ylhk_mc.stopDrag();
//		}
	}
}