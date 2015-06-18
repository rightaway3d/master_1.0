package rightaway3d.house.vo
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import rightaway3d.house.utils.Point3D;
	
	[Event(name="ground_material_change", type="flash.events.Event")]
	
	[Event(name="ceiling_material_change", type="flash.events.Event")]

	public class Room extends BaseVO
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
		//=================================================================================================================
		static public const GROUND_MATERIAL_CHANGE:String = "ground_material_change";
		
		static public const CEILING_MATERIAL_CHANGE:String = "ceiling_material_change";
		
		//=================================================================================================================
		
		/**
		 * 位图材质比例，每个像素4毫米
		 */
		static public var textureScale:Number = 4;
		
		public var index:int = 0;
		
		public var name:String = "厨房";
		
		private var _groundMaterialName:String;

		public function get groundMaterialName():String
		{
			return _groundMaterialName;
		}

		public function set groundMaterialName(value:String):void
		{
			if(_groundMaterialName == value)return;
			
			_groundMaterialName = value;
			
			if(this.hasEventListener(GROUND_MATERIAL_CHANGE))
			{
				this.dispatchEvent(new Event(GROUND_MATERIAL_CHANGE));
			}
		}

		
		private var _ceilingMaterialName:String;

		public function get ceilingMaterialName():String
		{
			return _ceilingMaterialName;
		}

		public function set ceilingMaterialName(value:String):void
		{
			if(_ceilingMaterialName == value)return;
			
			_ceilingMaterialName = value;

			if(this.hasEventListener(CEILING_MATERIAL_CHANGE))
			{
				this.dispatchEvent(new Event(CEILING_MATERIAL_CHANGE));
			}
	}

		
		/*public var groundTextureURL:String = "";
		
		public var groundNormalURL:String = "";
		
		public var groundSpecular:Number = 0;
		
		public var ceilingTextureURL:String = "";
		
		public var ceilingNormalURL:String = "";
		
		public var ceilingSpecular:Number = 0;*/
		
		/**
		 * 以顺时针方向排列的墙体序列体
		 */
		public var walls:Vector.<CrossWall> = new Vector.<CrossWall>();
		
		public var floor:Floor;
		
		public function Room()
		{
		}
		
		override public function dispose():void
		{
			dispatchWillDisposeEvent();
			
			if(floor)
			{
				floor.removeRoom(this);
			}
			
			//删除房间时，解除墙面与房间的关系，（还要解除房间中所有墙面之间的关联关系？）
			if(walls)
			{
				while(walls.length>0)walls.pop().room = null;
				walls = null;
			}
			
			dispatchDisposeEvent();
		}
		
		/**
		 * 房间中是否已经布置了门
		 * @return 
		 * 
		 */
		public function hasDoor():Boolean
		{
			for each(var cw:CrossWall in walls)
			{
				var holes:Vector.<WallHole> = cw.wall.holes;
				for each(var hole:WallHole in holes)
				{
					if(hole.modelType<200)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * 房间中是否已经布置了窗
		 * @return 
		 * 
		 */
		public function hasWindow():Boolean
		{
			for each(var cw:CrossWall in walls)
			{
				var holes:Vector.<WallHole> = cw.wall.holes;
				for each(var hole:WallHole in holes)
				{
					if(hole.modelType>=200)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * 获取离目标点最近的墙体
		 * @param srcPoint
		 * @param footPoint
		 * @return 
		 * 
		 */
		public function getNearestWall(srcPoint:Point,footPoint:Point):CrossWall
		{
			var nearestWall:CrossWall;
			var dist:Number = Infinity;
			var len:int = walls.length;
			var i:int;
			var fx:Number,fy:Number;
			
			for(i=0;i<len;i++)
			{
				var cw:CrossWall = walls[i];
				var n:Number = cw.wall.distToPoint(srcPoint,footPoint);
				if(n<dist)
				{
					dist = n;
					fx = footPoint.x;
					fy = footPoint.y;
					nearestWall = cw;
				}
			}
			
			footPoint.x = fx;
			footPoint.y = fy;
			
			return nearestWall;
		}
		
		/**
		 * 测试指定的点是否在房间内，只在房间为凸多边形时有效
		 * 如果判断点在所有边界线的同侧，就能判定该点在多边形内部。
		 * 判断方法就是判断两条同起点射线斜率差。
 		 * @param x
		 * @param y
		 * @return 
		 * 
		 */
		public function hitTestPoint(x:Number,y:Number):Boolean
		{
			var inside:Boolean = false;
			var count1:int = 0;
			var count2:int = 0;
			var n:int = walls.length;
			var i:int;
			for(i=0;i<n;i++)
			{
				var cw:CrossWall = walls[i];
				var p1:Point3D = cw.isHead?cw.wall.groundHeadPoint.point:cw.wall.groundEndPoint.point;
				var p2:Point3D = cw.isHead?cw.wall.groundEndPoint.point:cw.wall.groundHeadPoint.point;
				var value:Number = (x - p1.x) * (p2.z - p1.z) - (y - p1.z) * (p2.x - p1.x);
				if (value > 0)
					++count1;
				else if (value < 0)
					++count2;
			}
			if (0 == count1 ||	0 == count2)
			{
				inside = true;
			}
			return inside;
		}
		/*bool InsidePolygon4( POINTD *polygon,int N,POINTD p )
		{
			int i,j;
			bool inside = false;
			int count1 = 0;
			int count2 = 0;
			
			for (i = 0,j = N - 1;i < N;j = i++) 
			{
				double value = (p.x - polygon[j].x) * (polygon[i].y - polygon[j].y) - (p.y - polygon[j].y) * (polygon[i].x - polygon[j].x);
				if (value > 0)
					++count1;
				else if (value < 0)
					++count2;
			}
			
			if (0 == count1 ||
				0 == count2)
			{
				inside = true;
			}
			return inside;
		}*/
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"index\":" + index + ",";
			s += "\"name\":\"" + name + "\",";
			
			s += "\"groundMaterial\":\"" + _groundMaterialName + "\",";
			//s += "\"groundNormalURL\":\"" + groundNormalURL + "\",";
			//s += "\"groundSpecular\":" + groundSpecular + ",";
			s += "\"ceilingMaterial\":\"" + _ceilingMaterialName + "\",";
			//s += "\"ceilingNormalURL\":\"" + ceilingNormalURL + "\",";
			//s += "\"ceilingSpecular\":" + ceilingSpecular + ",";
			
			s += getWallsJsonData();
			
			s += "}";
			return s;
		}
		
		private function getWallsJsonData():String
		{
			var s:String = "\"walls\":[";
			
			var len:int = walls.length;
			for(var i:int=0;i<len;i++)
			{
				var cw:CrossWall = walls[i]
				s += cw.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
	}
}