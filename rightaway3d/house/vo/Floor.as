package rightaway3d.house.vo
{
	public class Floor extends BaseVO
	{
		static private var index:int = 0;
		static public function getNextIndex():int
		{
			return index++;
		}
		static public function setNextIndex(value:int):void
		{
			if(value>index)index = value;
		}
		
		/**
		 * 楼层编号
		 */
		public var index:int = 0;
		
		/**
		 * 楼层名称
		 */
		public var name:String = "一层";
		
		/**
		 * 楼层地面标高，单位毫米（mm）
		 */
		public var groundHeight:int = 0;
		
		/**
		 * 楼层天花板相对地面高度，单位毫米（mm）
		 */
		public var ceilingHeight:int = 2800;
		
		/**
		 * 天花板厚度，单位毫米（mm）
		 */
		public var ceilingThickness:int = 100;
		
		/**
		 * 墙体的全局宽度，单位毫米（mm）
		 */
		public var wallWidth:int = 240;
		
		/**
		 * 门槛高度，单位毫米（mm）
		 */
		public var doorSillHeight:int = 10;
		
		/**
		 * 门洞高度，单位毫米（mm）
		 */
		public var doorHeight:int = 1900;
		
		/**
		 * 窗台高度，单位毫米（mm）
		 */
		public var windowSillHeight:int = 910;
		
		/**
		 * 窗洞高度，单位毫米（mm）
		 */
		public var windowHeight:int = 1000;
		
		/**
		 * 房子里的地面全局坐标点
		 */
		public var groundPoints:Vector.<HousePoint> = new Vector.<HousePoint>();
		
		/**
		 * 房子里的天花板全局坐标点
		 */
		//public var ceilingPoints:Vector.<HousePoint> = new Vector.<HousePoint>();
		
		public var rooms:Vector.<Room> = new Vector.<Room>();
		
		public function addRoom(room:Room):void
		{
			rooms.push(room);
			
			room.floor = this;
			room.index = Room.getNextIndex();
		}
		
		public function removeRoom(room:Room):void
		{
			var n:int = rooms.indexOf(room)
			if(n>-1)
			{
				if(n<walls.length-1)
				{
					rooms[n] = rooms.pop();
				}
				else
				{
					rooms.pop();
				}
				room.floor = null;
			}
		}
		
		public var walls:Vector.<Wall> = new Vector.<Wall>();
		
		public function addWall(wall:Wall):void
		{
			//trace("addWall:"+wall.index);
			wall.floor = this;
			walls.push(wall);
		}
		
		public function getWall(index:int):Wall
		{
			for each(var wall:Wall in walls)
			{
				if(wall.index==index)
				{
					return wall;
				}
			}
			return null;
		}
		
		public function removeWall(wall:Wall):void
		{
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
			
			wall.floor = null;
		}
		
		private function removeHousePoint(hps:Vector.<HousePoint>, hp:HousePoint):void
		{
			var n:int = hps.indexOf(hp);
			
			if(n<0)return;
			
			if(n<hps.length-1)
			{
				hps[n] = hps.pop();
			}
			else
			{
				hps.pop();
			}
		}
		
		override public function dispose():void
		{
			if(rooms)
			{
				while(rooms.length>0)rooms.pop().dispose();
				rooms = null;
			}
			
			if(walls)
			{
				while(walls.length>0)walls[0].dispose();
				walls = null;
			}
			
			if(groundPoints)
			{
				while(groundPoints.length>0)groundPoints.pop().dispose();
				groundPoints = null;
			}

			dispatchDisposeEvent();
		}
		
		public function Floor()
		{
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"index\":" + index + ",";
			s += "\"name\":\"" + name + "\",";
			s += "\"groundHeight\":" + groundHeight + ",";
			s += "\"ceilingHeight\":" + ceilingHeight + ",";
			s += "\"ceilingThickness\":" + ceilingThickness + ",";
			s += "\"wallWidth\":" + wallWidth + ",";
			s += "\"doorSillHeight\":" + doorSillHeight + ",";
			s += "\"doorHeight\":" + doorHeight + ",";
			s += "\"windowSillHeight\":" + windowSillHeight + ",";
			s += "\"windowHeight\":" + windowHeight + ",";
			s += getPointsJsonData("groundPoints",groundPoints) + ",";
			//s += getPointsJsonData("ceilingPoints",ceilingPoints) + ",";
			s += getWallsJsonData() + ",";
			s += getRoomsJsonData();
			s += "}";
			return s;
		}
		
		private function getPointsJsonData(name:String,points:Vector.<HousePoint>):String
		{
			var s:String = "\""+ name + "\":[";
			
			var len:int = points.length;
			for(var i:int=0;i<len;i++)
			{
				var hp:HousePoint = points[i]
				s += hp.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
		
		private function getWallsJsonData():String
		{
			var s:String = "\"walls\":[";
			
			var len:int = walls.length;
			for(var i:int=0;i<len;i++)
			{
				var w:Wall = walls[i]
				s += w.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
		
		private function getRoomsJsonData():String
		{
			var s:String = "\"rooms\":[";
			
			var len:int = rooms.length;
			for(var i:int=0;i<len;i++)
			{
				var r:Room = rooms[i]
				s += r.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
	}
}