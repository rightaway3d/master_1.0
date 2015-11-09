package rightaway3d.engine.action
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import rightaway3d.utils.MyMath;
	import rightaway3d.utils.Tween;

	public class PropertyAction
	{
		public var target:Object;
		
		public var eventType:String;
		public var targetName:String;
		public var propertyName:String;
		public var value:Number;
		public var termValue:Number;
		public var delay:int;
		public var duration:int;
		
		private var timer:Timer;
		
		public function PropertyAction()
		{
			timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
		}
		
		public function dispose():void
		{
			timer.removeEventListener(TimerEvent.TIMER,onTimer);
			timer = null;
			target = null;
		}
		
		private function onTimer(event:TimerEvent):void
		{
			//trace("-----onTimer:"+duration);
			timer.stop();
			
			if(duration>0)
			{
				tween();
			}
			else
			{
				target[propertyName] = value;
			}
		}
		
		private function tween():void
		{
			//trace("-----tween");
			var o:Object = {};
			o[propertyName] = value;
			//o["ease"] = Cubic.easeOut;//Expo.easeOut;
			//TweenMax.to(target,duration/1000,o);
			//TweenLite.to(target,duration/1000,o);
			//TweenLite.to(target,duration/1000,{rotationY:value});
			Tween.to(target,duration,o);
		}
		
		public function run():void
		{
			trace("run:"+target);
			if(target && target.hasOwnProperty(propertyName))
			{
				trace(target[propertyName],termValue,value);
				if(MyMath.isEqual(target[propertyName],termValue))
				{
					if(delay==0 && duration>0)
					{
						tween();
						trace("-----tween run!");
					}
					else
					{
						timer.delay = delay<1?1:delay;
						timer.start();
						trace("-----timer run!");
					}
				}
				else
				{
					trace("-----not run!");
				}
			}
			else
			{
				trace("-----run error!");
			}
		}
		
		public function clone():PropertyAction
		{
			var a:PropertyAction = new PropertyAction();
			a.eventType = this.eventType;
			a.targetName = this.targetName;
			a.propertyName = this.propertyName;
			a.value = this.value;
			a.termValue = this.termValue;
			a.delay = this.delay;
			a.duration = this.duration;
			return a;
		}
		
		static public function parse(xml:XML):PropertyAction
		{
			var a:PropertyAction = new PropertyAction();
			a.eventType = xml.eventType;
			a.targetName = xml.target;
			a.propertyName = xml.propertyName;
			a.value = xml.value;
			a.termValue = xml.termValue;
			a.delay = xml.delay;
			a.duration = xml.duration;
			return a;
		}
	}
}