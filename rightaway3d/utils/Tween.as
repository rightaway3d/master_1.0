package rightaway3d.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Tween
	{
		private var timer:Timer;
		private var target:Object;
		private var duration:int;
		private var vars:Object;
		
		private var time0:int;
		private var vars0:Object;
		private var varsLen:Object;
		private var completeFun:Function;
		
		public function Tween()
		{
			timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
		}
		
		public function start(target:Object,duration:int,vars:Object,complete:Function=null):void
		{
			this.target = target;
			this.duration = duration;
			this.vars = vars;
			this.completeFun = complete;
			
			vars0 = {};
			varsLen = {};
			for(var s:String in vars)
			{
				vars0[s] = target[s];
				varsLen[s] = vars[s] - vars0[s];
			}
			
			time0 = getTimer();
			timer.start();
		}
		
		private function onTimer(event:TimerEvent):void
		{
			var dtime:int = getTimer() - time0;
			if(dtime<duration)
			{
				var n:Number = dtime/duration;
				for(var s:String in vars0)
				{
					target[s] = vars0[s] + varsLen[s] * n;
				}
			}
			else
			{
				for(s in vars0)
				{
					target[s] = vars[s];
				}
				
				timer.stop();
				timer.reset();
				
				tweens.push(this);
				
				if(completeFun)
				{
					completeFun(target);
				}
			}
		}
		
		static private var tweens:Array = [];
		static public function to(target:Object,duration:int,vars:Object,complete:Function=null):Tween
		{
			//trace("-------tweens.length:"+tweens.length);
			var t:Tween = tweens.length>0?tweens.pop():new Tween();
			t.start(target,duration,vars,complete);
			return t;
		}
	}
}