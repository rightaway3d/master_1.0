package rightaway3d.house.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="changed", type="flash.events.Event")]
	[Event(name="dispose", type="flash.events.Event")]
	[Event(name="will_dispose", type="flash.events.Event")]

	public class BaseVO extends EventDispatcher
	{
		static public const CHANGED:String = "changed";
		static public const DISPOSE:String = "dispose";
		static public const WILL_DISPOSE:String = "will_dispose";
		
		public var isChanged:Boolean = true;
		
		public function BaseVO()
		{
		}
		
		public function dispose():void
		{
			dispatchDisposeEvent();
		}
		
		public function dispatchChangeEvent():void
		{
			if(this.hasEventListener(CHANGED))
			{
				this.dispatchEvent(new Event(CHANGED));
			}
			isChanged = false;
		}
		
		protected function dispatchDisposeEvent():void
		{
			if(this.hasEventListener(DISPOSE))
			{
				this.dispatchEvent(new Event(DISPOSE));
			}
		}
		
		protected function dispatchWillDisposeEvent():void
		{
			if(this.hasEventListener(WILL_DISPOSE))
			{
				this.dispatchEvent(new Event(WILL_DISPOSE));
			}
		}
	}
}