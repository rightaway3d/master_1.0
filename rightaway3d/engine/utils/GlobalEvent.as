package rightaway3d.engine.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	
	import ztc.meshbuilder.room.CabinetTable3D;
	
	[Event(name="product_mouse_down", type="flash.events.Event")]
	[Event(name="product_mouse_up", type="flash.events.Event")]
	
	[Event(name="model_mouse_down", type="flash.events.Event")]
	[Event(name="model_mouse_up", type="flash.events.Event")]
	
	[Event(name="ground_mouse_down", type="flash.events.Event")]
	[Event(name="ground_mouse_up", type="flash.events.Event")]
	
	[Event(name="ceiling_mouse_down", type="flash.events.Event")]
	[Event(name="ceiling_mouse_up", type="flash.events.Event")]
	
	[Event(name="windoor_mouse_down", type="flash.events.Event")]
	[Event(name="windoor_mouse_up", type="flash.events.Event")]
	
	[Event(name="wall_mouse_down", type="flash.events.Event")]
	[Event(name="wall_mouse_up", type="flash.events.Event")]
	
	[Event(name="cross_wall_mouse_down", type="flash.events.Event")]
	[Event(name="cross_wall_mouse_up", type="flash.events.Event")]
	
	[Event(name="cabinet_table_mouse_down", type="flash.events.Event")]
	[Event(name="cabinet_table_mouse_up", type="flash.events.Event")]
	
	[Event(name="double_place", type="flash.events.Event")]
	
	[Event(name="location_flag_ready", type="flash.events.Event")]
	
	[Event(name="set_scene_complete", type="flash.events.Event")]
	
	[Event(name="material_lib_complete", type="flash.events.Event")]
	
	public class GlobalEvent extends EventDispatcher
	{
		static public const PRODUCT_MOUSE_DOWN:String = "product_mouse_down";
		static public const PRODUCT_MOUSE_UP:String = "product_mouse_up";
		
		static public const MODEL_MOUSE_DOWN:String = "model_mouse_down";
		static public const MODEL_MOUSE_UP:String = "model_mouse_up";
		
		static public const GROUND_MOUSE_DOWN:String = "ground_mouse_down";
		static public const GROUND_MOUSE_UP:String = "ground_mouse_up";
		
		static public const CEILING_MOUSE_DOWN:String = "ceiling_mouse_down";
		static public const CEILING_MOUSE_UP:String = "ceiling_mouse_up";
		
		static public const WINDOOR_MOUSE_DOWN:String = "windoor_mouse_down";
		static public const WINDOOR_MOUSE_UP:String = "windoor_mouse_up";
		
		static public const WALL_MOUSE_DOWN:String = "wall_mouse_down";
		static public const WALL_MOUSE_UP:String = "wall_mouse_up";
		
		static public const CROSS_WALL_MOUSE_DOWN:String = "cross_wall_mouse_down";
		static public const CROSS_WALL_MOUSE_UP:String = "cross_wall_mouse_up";
		
		static public const CABINET_TABLE_MOUSE_DOWN:String = "cabinet_table_mouse_down";
		static public const CABINET_TABLE_MOUSE_UP:String = "cabinet_table_mouse_up";
		
		static public const DOUBLE_REPLACE:String = "double_place";
		
		static public const LOCATION_FLAG_READY:String = "location_flag_ready";
		
		static public const SET_SCENE_COMPLETE:String = "set_scene_complete";
		
		static public const MATERIAL_LIB_COMPLETE:String = "material_lib_complete";
		
		//-----------------------------------------------------------------------------------------------------
		public var currentTarget:*;
		
		public var data:*;
		
		public function dispatch(type:String,currentTarget:*,data:* = null):void
		{
			if(this.hasEventListener(type))
			{
				this.currentTarget = currentTarget;
				this.data = data;
				this.dispatchEvent(new Event(type));
			}
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发产品鼠标事件
		public function dispatchProductMouseDownEvent(currentTarget:ProductObject,data:* = null):void
		{
			dispatch(PRODUCT_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchProductMouseUpEvent(currentTarget:ProductObject,data:* = null):void
		{
			dispatch(PRODUCT_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发模型鼠标事件
		public function dispatchModelMouseDownEvent(currentTarget:ModelObject,data:* = null):void
		{
			dispatch(MODEL_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchModelMouseUpEvent(currentTarget:ModelObject,data:* = null):void
		{
			dispatch(MODEL_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		public function dispatchLocationFlagReadyEvent():void
		{
			dispatch(LOCATION_FLAG_READY,null);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发地面鼠标事件
		public function dispatchGroundMouseDownEvent(currentTarget:Room,data:* = null):void
		{
			dispatch(GROUND_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchGroundMouseUpEvent(currentTarget:Room,data:* = null):void
		{
			dispatch(GROUND_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发天花板鼠标事件
		public function dispatchCeilingMouseDownEvent(currentTarget:Room,data:* = null):void
		{
			dispatch(CEILING_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchCeilingMouseUpEvent(currentTarget:Room,data:* = null):void
		{
			dispatch(CEILING_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发门窗鼠标事件
		public function dispatchWindoorMouseDownEvent(currentTarget:WallHole,data:* = null):void
		{
			dispatch(WINDOOR_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchWindoorMouseUpEvent(currentTarget:WallHole,data:* = null):void
		{
			dispatch(WINDOOR_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发墙体鼠标事件
		public function dispatchWallMouseDownEvent(currentTarget:Wall,data:* = null):void
		{
			dispatch(WALL_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchWallMouseUpEvent(currentTarget:Wall,data:* = null):void
		{
			dispatch(WALL_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发墙面鼠标事件
		public function dispatchCrossWallMouseDownEvent(currentTarget:CrossWall,data:* = null):void
		{
			dispatch(CROSS_WALL_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchCrossWallMouseUpEvent(currentTarget:CrossWall,data:* = null):void
		{
			dispatch(CROSS_WALL_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		//派发墙面鼠标事件
		public function dispatchCabinetTableMouseDownEvent(currentTarget:Vector.<CabinetTable3D>,data:* = null):void
		{
			dispatch(CABINET_TABLE_MOUSE_DOWN,currentTarget,data);
		}
		
		public function dispatchCabinetTableMouseUpEvent(currentTarget:Vector.<CabinetTable3D>,data:* = null):void
		{
			dispatch(CABINET_TABLE_MOUSE_UP,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		public function dispatchDoubleReplaceEvent(currentTarget:Array,data:Array):void
		{
			dispatch(DOUBLE_REPLACE,currentTarget,data);
		}
		
		//-----------------------------------------------------------------------------------------------------
		public function dispatchSceneCompleteEvent():void
		{
			dispatch(SET_SCENE_COMPLETE,null);
		}
		
		//-----------------------------------------------------------------------------------------------------
		public function dispatchMaterialLibCompleteEvent():void
		{
			dispatch(MATERIAL_LIB_COMPLETE,null);
		}
		
		//-----------------------------------------------------------------------------------------------------
		public function GlobalEvent(value:SingleInstanceClass)
		{
			if(!value)
			{
				throw new Error("GlobalEvent是一个单例类，请用静态属性event来获得类的实例。");
			}
		}
		
		static private var _event:GlobalEvent;
		
		static public function get event():GlobalEvent
		{
			return _event ||= new GlobalEvent(new SingleInstanceClass());
		}
		//-----------------------------------------------------------------------------------------------------
	}
}

class SingleInstanceClass{}
