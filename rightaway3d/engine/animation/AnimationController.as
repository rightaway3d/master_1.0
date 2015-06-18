package rightaway3d.engine.animation
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import rightaway3d.engine.model.ModelObject;

	public class AnimationController
	{
		private var currObject:ModelObject;
		
		//private var frame_spt:Sprite;
		private var timer:Timer;
		
		private var currTime:Number;
		private var totalTime:Number;
		private var startTime:Number;
		private var endTime:Number;
		
		//private var isLoop:Boolean;
		private var numLoop:int;
		private var indexLoop:int;
		
		private var frameRate:int = 30;
		
		public function AnimationController()
		{
			timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER,onEnterFrame);
		}
		
		public function setCurrObject(obj:ModelObject):void
		{
			currObject = obj;
		}
		
		private var callbackFun:Function;
		
		public function play(startFrame:uint,endFrame:uint,numLoop:int=1,frameRate:int=30,callback:Function=null):void
		{
			if(!currObject || !currObject.animPlayer)return;
			
			this.callbackFun = callback;
			
//			isLoop = loop;
			this.numLoop = numLoop;
			indexLoop = 1;
			trace("indexLoop:"+indexLoop);
			trace("numLoop:"+numLoop);
			
			this.frameRate = frameRate;
			var frame:Number = 1000/frameRate;
			
			currObject.animPlayer.currentAnimation = "root";
			totalTime = currObject.animPlayer.duration;
			
			startTime = startFrame * frame;
			if(startTime>totalTime)startTime = totalTime;
			
			endTime = endFrame * frame;
			if(endTime>totalTime)endTime = totalTime;
			
//			trace("totalTime:"+totalTime);
//			trace("startTime:"+startTime);
//			trace("endTime:"+endTime);
			
			currTime = startTime;
			
			/*frame_spt ||= new Sprite();
			frame_spt.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			trace("frame_spt:"+frame_spt);*/
			timer.reset();
			timer.start();
			
			time = getTimer();
			update();
		}
		
		private var time:int;
		
		protected function onEnterFrame(event:TimerEvent):void
		{
//			trace("onEnterFrame");
			var t:int = getTimer();
			var dt:Number = t - time;
			time = t;
			if(endTime > startTime)//正序播放动画
			{
				currTime += dt;
				if(currTime<endTime)
				{
					update();
				}
				else if(numLoop==0 || indexLoop++<numLoop)
				{
					trace("indexLoop2:"+indexLoop);
					currTime = startTime;
					update();
				}
				else
				{
					currTime = endTime;
					update();
					stop();
				}
			}
			else//倒序播放动画
			{
				currTime -= dt;
				if(currTime>endTime)
				{
					update();
				}
				else if(numLoop==0 || indexLoop++<numLoop)
				{
					trace("indexLoop2:"+indexLoop);
					currTime = startTime;
					update();
				}
				else
				{
					currTime = endTime;
					update();
					stop();
				}
			}
		}
		
		private function update():void
		{
			var n:Number = currTime/totalTime;
			currObject.animPlayer.position = n;
			currObject.animPlayer.updateTime(currObject.animPlayer.time, time);
			
//			trace("currTime:"+n,currTime,totalTime);
		}
		
		public function stop():void
		{
			//if(frame_spt)frame_spt.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			timer.stop();
			if(callbackFun!=null)
			{
				callbackFun();
			}
		}
	}
}