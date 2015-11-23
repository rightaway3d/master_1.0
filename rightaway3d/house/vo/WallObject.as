package rightaway3d.house.vo
{
	/**
	 * 定义关联到墙体上的产品数据属性
	 * @author Jell
	 * 
	 */
	public class WallObject
	{
		/**
		 * 橱柜与墙体之间的默认距离，单位mm
		 */
		//static public var distToWall:int = 0;//50;
		
		public var crossWall:CrossWall;
		
		/**
		 * 忽略的物体，关联到墙上时，和其它物体之间不会进行重叠检测
		 */
		public var isIgnoreObject:Boolean = false;
		
		/**
		 * 物体类型，包括门窗，各种橱柜，柱体，烟道，管道
		 */
		public var type:String = "";
		
		/**
		 * 物体对象的引用
		 */
		public var object:*;
		
		public var x:int = 0;
		public var y:int = 0;
		public var z:int = 0;
		
		public var width:int = 0;
		public var height:int = 0;
		public var depth:int = 0;
		
		public function WallObject()
		{
		}
		
		public function clone():WallObject
		{
			var c:WallObject = new WallObject();
			c.x = this.x;
			c.y = this.y;
			c.z = this.z;
			c.width = this.width;
			c.height = this.height;
			c.depth = this.depth;
			c.type = this.type;
			c.isIgnoreObject = this.isIgnoreObject;
			return c;
		}
		
		public function dispose():void
		{
			if(crossWall)
			{
				var cw:CrossWall = crossWall;
				cw.removeWallObject(this);
				//cw.dispatchSizeChangeEvent();
			}
			object = null;
		}
		
		public function toString():String
		{
			return "WallObject[x:"+x+",y:"+y+",z:"+z+",width:"+width+",height:"+height+",depth:"+depth+"]";
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			
			s += "\"x\":" + x + ",";
			s += "\"y\":" + y + ",";
			s += "\"z\":" + z + ",";
			s += "\"width\":" + width + ",";
			s += "\"height\":" + height + ",";
			s += "\"depth\":" + depth + ",";
			s += "\"isIgnoreObject\":\"" + isIgnoreObject + "\",";
			
			s += "\"type\":\"" + type +"\"";
			
			if(crossWall)s += ",\"crossWall\":" + crossWall.toJsonString();
			
			s += "}";
			return s;
		}
	}
}