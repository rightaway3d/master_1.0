package rightaway3d.house.vo
{
	import rightaway3d.house.utils.Point3D;

	public class HousePoint extends BaseVO
	{
		static private var index:int = 0;
		static public function getNextIndex():int
		{
			return ++index;
		}
		static public function setNextIndex(value:int):void
		{
			if(value>index)index = value;
		}
		
		//=======================================================================================
		public var index:int = 0;
		
		public var point:Point3D = new Point3D();
		
		public var crossWalls:Vector.<CrossWall> = new Vector.<CrossWall>();
		
		public function removeCrossWall(wall:Wall):void
		{
			var n:int = findWall(wall);
			if(n>-1)
			{
				if(n<crossWalls.length-1)
				{
					crossWalls[n] = crossWalls.pop();
				}
				else
				{
					crossWalls.pop();
				}
			}
		}
		
		private function findWall(wall:Wall):int
		{
			var len:int = crossWalls.length;
			for(var i:int=0;i<len;i++)
			{
				if(crossWalls[i].wall == wall)
				{
					return i;
				}
			}
			return -1;
		}
		
		public function HousePoint()
		{
		}
		
		override public function dispose():void
		{
			point = null;
			crossWalls = null;
			
			dispatchDisposeEvent();
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"index\":" + index + ",";
			s += "\"x\":" + point.x + ",";
			s += "\"y\":" + point.y + ",";
			s += "\"z\":" + point.z;
			//s += "," + getWallsJsonData();
			s += "}";
			return s;
		}
		
		private function getWallsJsonData():String
		{
			var s:String = "\"walls\":[";
			
			var len:int = crossWalls.length;
			for(var i:int=0;i<len;i++)
			{
				var cw:CrossWall = crossWalls[i]
				s += cw.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
	}
}