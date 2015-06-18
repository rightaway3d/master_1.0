package rightaway3d.house.vo
{
	import flash.geom.Vector3D;
	
	import rightaway3d.house.utils.Point3D;

	public class House extends BaseVO
	{
		public var floors:Vector.<Floor> = new Vector.<Floor>();
		
		public var currFloor:Floor;
		public var currRoom:Room;
		
		public var max:Vector3D = new Vector3D();
		public var min:Vector3D = new Vector3D();
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		
		public var width:int = 0;//dx
		public var height:int = 0;//dy
		public var depth:int = 0;//dz
		
		public var currPanAngle:Number = 180;
		
		public function updateBounds():void
		{
			//trace("currFloor:"+currFloor);
			if(!currFloor)return;
			
			var hps:Vector.<HousePoint> = currFloor.groundPoints;
			var maxX:Number = -Infinity;
			var minX:Number = Infinity;
			var maxY:Number = -Infinity;
			var minY:Number = Infinity;
			var maxZ:Number = -Infinity;
			var minZ:Number = Infinity;
			
			for each(var hp:HousePoint in hps)
			{
				var p:Point3D = hp.point;
				if(p.x > maxX)maxX = p.x;
				if(p.x < minX)minX = p.x;
				if(p.y > maxY)maxY = p.y;
				if(p.y < minY)minY = p.y;
				if(p.z > maxZ)maxZ = p.z;
				if(p.z < maxZ)minZ = p.z;
			}
			
			max.x = maxX;
			max.y = this.currFloor.ceilingHeight;
			max.z = maxZ;
			
			min.x = minX;
			min.y = minY;
			min.z = minZ;
			
			width = maxX - minX;
			height = maxY - minY;
			depth = maxZ - minZ;
			
			x = (maxX + minX)/2;
			y = minY;
			z = (maxZ + minZ)/2;
			
			//trace("updateBounds:",x,y,z,length,height,width);
		}
		
		public function toJsonString():String
		{
			var s:String = "{" +
				"\"floors\":" +
				"[";
			
			var len:int = floors.length;
			for(var i:int=0;i<len;i++)
			{
				var f:Floor = floors[i]
				s += f.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]" +
				"}";
			return s;
		}
		
		//==============================================================================================
		public function addFloor(f:Floor):void
		{
			if(floors.indexOf(f)>-1)return;//如果要添加的楼层已经存在，则返回
			
			floors.push(f);
			currFloor = f;
		}
		
		public function removeFloor(floor:Floor):void
		{
			var n:int = floors.indexOf(floor);
			trace(n);
			if(n<floors.length-1)
			{
				floors[n] = floors.pop();
			}
			else
			{
				floors.pop();
			}
			
			floor.dispose();
		}
		
		public function removeAllFloor():void
		{
			while(floors.length>0)removeFloor(floors[0]);
		}
		
		/*public function House()
		{
			currFloor = new Floor();
			floors.push(currFloor);
		}*/
		
		//==============================================================================================
		public function House(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("House是一个单例类，请用静态方法getInstance()来获得类的实例。");
			}
			
			//currFloor = new Floor();
			//floors.push(currFloor);
		}
		
		static private var instance:House;
		
		static public function getInstance():House
		{
			instance ||= new House(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}
