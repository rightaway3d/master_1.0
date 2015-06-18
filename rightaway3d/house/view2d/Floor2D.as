package rightaway3d.house.view2d
{
	import flash.display.Sprite;
	
	import rightaway3d.house.editor2d.WallController;
	import rightaway3d.house.vo.Floor;

	public class Floor2D extends Base2D
	{
		public var vo:Floor;
		
		private var roomContainer:Sprite;
		
		private var wallContainer:Sprite;
		
		public var sizeMarkingContainer:Sprite;
		
		public var walls:Vector.<Wall2D>;
		
		public var rooms:Vector.<Room2D>;
		
		private var wallCtr:WallController;
		
		public var wallAreaSelector:WallAreaSelector;
		
		public function Floor2D()
		{
			super();
			init();
		}
		
		override public function dispose():void
		{
			if(roomContainer)
			{
				this.removeChild(roomContainer);
				roomContainer = null;
			}
			
			if(wallContainer)
			{
				this.removeChild(wallContainer);
				wallContainer = null;
			}
			
			if(sizeMarkingContainer)
			{
				this.removeChild(sizeMarkingContainer);
				this.sizeMarkingContainer = null;
			}
			
			if(wallAreaSelector)
			{
				this.removeChild(wallAreaSelector);
				wallAreaSelector = null;
			}
			
			walls = null;
			rooms = null;
			wallCtr = null;
			vo = null;
		}
		
		private function init():void
		{
			roomContainer = new Sprite();
			this.addChild(roomContainer);
			
			wallContainer = new Sprite();
			this.addChild(wallContainer);
			
			this.sizeMarkingContainer = new Sprite();
			this.addChild(sizeMarkingContainer);
			
			wallAreaSelector = new WallAreaSelector();
			this.addChild(wallAreaSelector);
			
			walls = new Vector.<Wall2D>();
			
			rooms = new Vector.<Room2D>();
			
			wallCtr = WallController.getInstance();
		}
		
		public function addSizeMark(value:SizeMarking2D):void
		{
			sizeMarkingContainer.addChild(value);
		}
		
		public function removeSizeMark(value:SizeMarking2D):void
		{
			sizeMarkingContainer.removeChild(value);
		}
		
		public function addWall(wall:Wall2D):void
		{
			wallContainer.addChild(wall);
			walls.push(wall);
		}
		
		public function removeWall(wall:Wall2D):void
		{
			wallContainer.removeChild(wall);
			var n:int = walls.indexOf(wall);
			if(n>-1)
			{
				if(n<walls.length-1)
				{
					walls[n] = walls.pop();
				}
				else
				{
					walls.pop();
				}
			}
		}
		
		public function addRoom(room:Room2D):void
		{
			roomContainer.addChild(room);
			rooms.push(room);
		}
		
		public function removeRoom(room:Room2D):void
		{
			roomContainer.removeChild(room);
			var n:int = rooms.indexOf(room);
			if(n>-1)
			{
				if(n<rooms.length-1)
				{
					rooms[n] = rooms.pop();
				}
				else
				{
					rooms.pop();
				}
			}
		}
		
		public function updateWallMark():void
		{
			for each(var view:Wall2D in walls)
			{
				//view.vo.frontCrossWall.initTestObject();
				//view.vo.backCrossWall.initTestObject();
				view.sizeMark.updateView();
			}
		}
		
		public function render():void
		{
			for each(var view:Wall2D in walls)
			{
				if(view.vo.isChanged)
				{
					view.updateView();
					view.vo.isChanged = false;
				}
			}
			
			for each(var room:Room2D in rooms)
			{
				//trace("render room:",room.vo.isChanged);
				if(room.vo.isChanged)
				{
					room.updateView();
					room.vo.isChanged = false;
				}
			}
		}
	}
}