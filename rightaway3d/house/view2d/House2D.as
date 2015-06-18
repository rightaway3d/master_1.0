package rightaway3d.house.view2d
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import rightaway3d.house.vo.Floor;
	import rightaway3d.house.vo.House;

	public class House2D extends Base2D
	{
		public var vo:House = House.getInstance();
		
		public var floors:Vector.<Floor2D> = new Vector.<Floor2D>();
		
		private var _currFloor:Floor2D;
		
		public function get currFloor():Floor2D
		{
			return _currFloor;
		}

		
		public function House2D()
		{
			super();
		}
		
		private var floorDict:Dictionary = new Dictionary();
		
		public function createFloor(floor:Floor):void
		{
			if(!floor)
			{
				floor = new Floor();
			}
			
			vo.addFloor(floor);
			
			_currFloor = new Floor2D();
			_currFloor.vo = floor;
			
			floor.addEventListener("dispose",onFloorDisposed);
			floorDict[floor] = _currFloor;
			
			floors.push(_currFloor);
			
			this.addChild(_currFloor);
		}
		
		private function onFloorDisposed(e:Event):void
		{
			var vo:Floor = e.currentTarget as Floor;
			vo.removeEventListener("dispose",onFloorDisposed);
			
			var floor2d:Floor2D = floorDict[vo];
			delete floorDict[vo];
			
			var n:int = floors.indexOf(floor2d);
			if(n<floors.length-1)
			{
				floors[n] = floors.pop();
			}
			else
			{
				floors.pop();
			}
			
			this.removeChild(floor2d);
			floor2d.dispose();
			
			if(_currFloor==floor2d)
			{
				_currFloor = null;
			}
		}
		
		public function addWall(wall:Wall2D):void
		{
			_currFloor.addWall(wall);
			_currFloor.addSizeMark(wall.sizeMark);
		}
		
		public function removeWall(wall:Wall2D):void
		{
			_currFloor.removeWall(wall);
			_currFloor.removeSizeMark(wall.sizeMark);
		}
		
		public function addRoom(room:Room2D):void
		{
			_currFloor.addRoom(room);
		}
		
		public function removeRoom(room:Room2D):void
		{
			_currFloor.removeRoom(room);
		}
		
		public function addSizeMark(value:SizeMarking2D):void
		{
			_currFloor.addSizeMark(value);
		}
		
		public function render():void
		{
			if(_currFloor)_currFloor.render();
		}
	}
}