package rightaway3d.house.vo
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.utils.Geom;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.utils.MyMath;
	
	[Event(name="size_change", type="flash.events.Event")]

	public class Wall extends BaseVO
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
		//==========================================================================
		
		static public const SIZE_CHANGE:String = "size_change";
		
		public function dispatchSizeChangeEvent():void
		{
			if(this.hasEventListener(SIZE_CHANGE))
			{
				this.dispatchEvent(new Event(SIZE_CHANGE));
			}
		}
		
		//==========================================================================
		
		public function Wall()
		{
			frontCrossWall = new CrossWall(this,true);
			backCrossWall = new CrossWall(this,false);
		}
		
		override public function dispose():void
		{
			dispatchWillDisposeEvent();
			
			if(holes)
			{
				if(holes.length>0)holes[0].dispose();
				holes = null;
			}
			
			if(groundHeadPoint)
			{
				groundHeadPoint.removeCrossWall(this);
				if(groundHeadPoint.crossWalls.length==0)
				{
					this.removeHousePoint(floor.groundPoints,groundHeadPoint);
				}
				groundHeadPoint = null;
			}
			
			if(groundEndPoint)
			{
				groundEndPoint.removeCrossWall(this);
				if(groundEndPoint.crossWalls.length==0)
				{
					this.removeHousePoint(floor.groundPoints,groundEndPoint);
				}
				groundEndPoint = null;
			}
			
			if(frontCrossWall)
			{
				frontCrossWall.dispose();
				frontCrossWall = null;
			}
			
			if(backCrossWall)
			{
				backCrossWall.dispose();
				backCrossWall = null;
			}
			
			if(floor)
			{
				floor.removeWall(this);
				floor = null;
			}
			
			groundHeadPoint = null;
			groundEndPoint = null;
			groundHead = null;
			groundEnd = null;
			
			groundFrontHeadPoint = null;
			groundFrontEndPoint = null;
			groundBackHeadPoint = null;
			groundBackEndPoint = null;
			
			groundFrontHead = null;
			groundFrontEnd = null;
			groundBackHead = null;
			groundBackEnd = null;
			
			dispatchDisposeEvent();
		}
		
		public var index:int = 0;
		
		public var name:String = "";
		
		/**
		 * 此墙体的正面的相关数据
		 */
		public var frontCrossWall:CrossWall;
		
		/**
		 * 此墙体的背面的相关数据
		 */
		public var backCrossWall:CrossWall;
		
		/**
		 * 墙体的地面起点坐标，也是墙体在房子里的位置（全局坐标系）
		 * （墙体的地面起点坐标与终点坐标一定且必须在同一个高度上，
		 * 默认为此墙体所在楼层的地面标高）
		 */
		public var groundHeadPoint:HousePoint;
		
		/**
		 * 墙体的地面终点坐标（全局坐标系）
		 * （墙体的地面起点坐标与终点坐标一定且必须在同一个高度上，
		 * 默认为此墙体所在楼层的地面标高）
		 */
		public var groundEndPoint:HousePoint;
		
		/**
		 * 墙体在天花板处的起点坐标，默认高度是此墙体所在楼层的地面标高加上楼层高度（全局坐标系）
		 * 墙体在天花板的起点坐标高度与终点坐标的高度可不相一致，并可单独设置
		 */
		//public var ceilingHeadPoint:HousePoint;
		
		/**
		 * 墙体在天花板处的终点坐标，默认高度是此墙体所在楼层的地面标高加上楼层高度（全局坐标系）
		 * 墙体在天花板的起点坐标高度与终点坐标的高度可不相一致，并可单独设置
		 */
		//public var ceilingEndPoint:HousePoint;
		
		/**
		 * 墙框地面处的一个顶点（全局坐标系）
		 */
		public var groundFrontHeadPoint:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（全局坐标系）
		 */
		public var groundFrontEndPoint:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（全局坐标系）
		 */
		public var groundBackHeadPoint:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（全局坐标系）
		 */
		public var groundBackEndPoint:Point3D = new Point3D();
		
		/**
		 * 墙体轴线地面起点（本地坐标系）
		 */
		public var groundHead:Point3D = new Point3D();
		/**
		 * 墙体轴线地面终点（本地坐标系）
		 */
		public var groundEnd:Point3D = new Point3D();
		
		/**
		 * 墙体轴线天花板起点（本地坐标系）
		 */
		//public var ceilingHead:Point3D = new Point3D();
		/**
		 * 墙体轴线天花板终点（本地坐标系）
		 */
		//public var ceilingEnd:Point3D = new Point3D();
		
		/**
		 * 墙框地面处的一个顶点（本地坐标系）
		 */
		public var groundFrontHead:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（本地坐标系）
		 */
		public var groundFrontEnd:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（本地坐标系）
		 */
		public var groundBackHead:Point3D = new Point3D();
		/**
		 * 墙框地面处的一个顶点（本地坐标系）
		 */
		public var groundBackEnd:Point3D = new Point3D();
		
		/**
		 * 墙框在天花板处的一个顶点（本地坐标系）
		 */
		//public var ceilingFrontHead:Point3D = new Point3D();
		/**
		 * 墙框在天花板处的一个顶点（本地坐标系）
		 */
		//public var ceilingFrontEnd:Point3D = new Point3D();
		/**
		 * 墙框在天花板处的一个顶点（本地坐标系）
		 */
		//public var ceilingBackHead:Point3D = new Point3D();
		/**
		 * 墙框在天花板处的一个顶点（本地坐标系）
		 */
		//public var ceilingBackEnd:Point3D = new Point3D();
		
		/**
		 * 墙体区域选择范围
		 */
		public var selectorArea:Array;
		
		/**
		 * 墙洞
		 */
		public var holes:Vector.<WallHole> = new Vector.<WallHole>();
		
		public function addHole(hole:WallHole):void
		{
			holes.push(hole);
			hole.wall = this;
			
			sortHoles(holes);
			
			frontCrossWall.addWallObject(hole.objectInfo);
			backCrossWall.addWallObject(hole.objectInfo2);
			
			//frontCrossWall.initTestObject();
			//backCrossWall.initTestObject();
			
			this.isChanged = true;
		}
		
		//墙洞按位置从左至右(升序)排序
		private function sortHoles(holes:Vector.<WallHole>):void
		{
			var len:int = holes.length;
			if(len>1)
			{
				var th:WallHole;
				for(var i:int=0;i<len-1;i++)
				{
					var h:WallHole = holes[i];
					for(var j:int=i+1;j<len;j++)
					{
						if(holes[j].x<h.x)
						{
							th = h;
							h = holes[j];
							holes[j] = th;
						}
					}
					holes[i] = h;
				}
			}
		}
		
		public function removeHole(hole:WallHole):void
		{
			var n:int = holes.indexOf(hole);
			if(n>-1)
			{
				if(n<holes.length-1)
				{
					holes[n] = holes.pop();
				}
				else
				{
					holes.pop();
				}
				hole.wall = null;
				
				frontCrossWall.removeWallObject(hole.objectInfo);
				backCrossWall.removeWallObject(hole.objectInfo2);
				
				//frontCrossWall.initTestObject();
				//backCrossWall.initTestObject();
				this.isChanged = true;
			}
		}
		
		//过滤掉窗洞，返回门洞集合
		public function getDoorsOfWall():Array
		{
			var a:Array = [];
			var len:int = holes.length;
			for(var i:int=0;i<len;i++)
			{
				var h:WallHole = holes[i];
				if(h.modelType<200)
				{
					a.push(h);
				}
			}
			return a;
		}
		
		/**
		 * 此墙所属房间，最多可有两个房间(正面墙所在房间，背面墙所在房间)
		 */
		//public var rooms:Vector.<Room> = new Vector.<Room>();
		
		/**
		 * 墙体的轴心长度，单位毫米（mm）
		 */
		public var length:int = 1;
		
		/**
		 * 墙体的宽度，单位毫米（mm），默认值：240
		 */
		public var width:int = 240;
		
		/**
		 * 墙体高度
		 * @return 
		 * 
		 */
		public function get height():int
		{
			return floor.ceilingHeight;
		}

		
		private var _angles:Number = 0;//角度值
		
		/**
		 * 墙体的旋转角度，单位度；
		 * 此数值为笛卡尔右手系坐标系统值，与左手系及屏幕坐标系有区别，需要转换使用；
		 */
		public function get angles():Number
		{
			return _angles;
		}

		public function set angles(value:Number):void
		{
			_angles = MyMath.turnAngles(value);
			_radians = MyMath.anglesToRadians(value);
		}

		
		private var _radians:Number = 0;//弧度值
		
		/**
		 * 墙体的旋转角度，单位弧度
		 * 此数值为笛卡尔右手系坐标系统值，与左手系及屏幕坐标系有区别，需要转换使用；
		 */
		public function get radians():Number
		{
			return _radians;
		}

		public function set radians(value:Number):void
		{
			_radians = value;
			_angles = MyMath.turnAngles(MyMath.radiansToAngles(value));
		}
		
		//public var isChanged:Boolean = true;
		
		public var floor:Floor;
		
		public function localToGlobal(value:Point3D,result:Point3D=null):Point3D
		{
			updateRadians();
			
			var dx:Number = value.x;
			var dz:Number = value.z;
			var r:Number = Math.sqrt(dx*dx + dz*dz);//计算目标点与当前墙体原点的距离
			var n:Number = Math.atan2(dz,dx) + this.radians;//计算目标点在当前墙体外的角度
			
			if(result)
			{
				result.y = value.y;
				value = result;
			}
			else
			{
				value = value.clone();
			}
			
			var p0:Point3D = this.groundHeadPoint.point;
			
			value.x = p0.x + r * Math.cos(n);
			value.z = p0.z + r * Math.sin(n);
			//value.x = p0.x + (r * Math.cos(n));
			//value.z = p0.z + (r * Math.sin(n));
			//value.y += floor.groundHeight;
			value.y = 0;
			
			return value;
		}
		
		public function localToGlobal2(value:Point,result:Point=null):Point
		{
			updateRadians();
			
			var dx:Number = value.x;
			var dz:Number = value.y;
			var r:Number = Math.sqrt(dx*dx + dz*dz);//计算目标点与当前墙体原点的距离
			var n:Number = Math.atan2(dz,dx) + this.radians;//计算目标点在当前墙体外的角度
			
			result ||= new Point();
			var p0:Point3D = this.groundHeadPoint.point;
			
			result.x = p0.x + r * Math.cos(n);
			result.y = p0.z + r * Math.sin(n);
			
			return result;
		}
		
		/*public function localToGlobal2(value:Point):Point
		{
			updateRadians();
			
			var dx:Number = value.x;
			var dz:Number = value.y;
			var r:Number = Math.sqrt(dx*dx + dz*dz);//计算目标点与当前墙体原点的距离
			var n:Number = Math.atan2(dz,dx) + this.radians;//计算目标点在当前墙体外的角度
			
			var p0:Point3D = this.groundHeadPoint.point;
			
			//value.x = p0.x + MyMath.round(r * Math.cos(n));
			//value.y = p0.z + MyMath.round(r * Math.sin(n));
			value.x = p0.x + r * Math.cos(n);
			value.y = p0.z + r * Math.sin(n);
			
			return value;
		}*/
		
		public function globalToLocal(value:Point3D,result:Point3D=null):Point3D
		{
			updateRadians();
			
			var p0:Point3D = this.groundHeadPoint.point;
			var dx:Number = value.x - p0.x;
			var dz:Number = value.z - p0.z;
			var r:Number = Math.sqrt(dx*dx + dz*dz);//计算目标点与当前墙体原点的距离
			var n:Number = Math.atan2(dz,dx) - this.radians;//计算目标点在当前墙体内的角度
			
			if(result)
			{
				result.y = value.y;
				value = result;
			}
			else
			{
				value = value.clone();
			}
			
			//value.x = MyMath.round(r * Math.cos(n));
			//value.z = MyMath.round(r * Math.sin(n));
			value.x = r * Math.cos(n);
			value.z = r * Math.sin(n);
			//value.y -= floor.groundHeight;
			value.y = 0;
			
			return value;
		}
		
		public function globalToLocal2(value:Point,result:Point=null):Point
		{
			updateRadians();
			
			var p0:Point3D = this.groundHeadPoint.point;
			var dx:Number = value.x - p0.x;
			var dz:Number = value.y - p0.z;
			var r:Number = Math.sqrt(dx*dx + dz*dz);//计算目标点与当前墙体原点的距离
			var n:Number = Math.atan2(dz,dx) - this.radians;//计算目标点在当前墙体内的角度
			
			result ||= new Point();
			result.x = r * Math.cos(n);
			result.y = r * Math.sin(n);
			
			return result;
		}
		
		public function countCrossWall():void
		{
			_countCrossWall(groundHeadPoint);
			_countCrossWall(groundEndPoint);
		}
		
		private function _countCrossWall(hp:HousePoint):void
		{
			var cws:Vector.<CrossWall> = hp.crossWalls;
			var len:int = cws.length;
			
			if(len==1)return;
			
			sortCrossWall(cws);
			
			for(var i:int=0;i<len-1;i++)
			{
				countWallFaceCrossPoint(cws[i],cws[i+1]);
			}
			countWallFaceCrossPoint(cws[i],cws[0]);
		}
		
		/**
		 * 计算两个墙的邻面的交点
		 * @param cw1
		 * @param cw2
		 * 
		 */
		private function countWallFaceCrossPoint(cw1:CrossWall,cw2:CrossWall):void
		{
			var p1:Point=new Point(),p2:Point=new Point(),s1:Point=new Point(),s2:Point=new Point();
			var pp11:Point3D,pp12:Point3D,pp21:Point3D,pp22:Point3D,ss11:Point3D,ss12:Point3D,ss21:Point3D,ss22:Point3D;
			var w1:Wall = cw1.wall;
			var w2:Wall = cw2.wall;
			
			if(cw1.isHead)
			{
				pp11 = w1.groundBackHeadPoint;
				pp12 = w1.groundBackEndPoint;
				pp21 = w1.groundBackHead;
				pp22 = w1.groundBackEnd;
				
				var cw:CrossWall = cw1.wall.backCrossWall;
				cw.headCrossWall = cw2;//设置相邻相交墙面
			}
			else
			{
				pp11 = w1.groundFrontEndPoint;
				pp12 = w1.groundFrontHeadPoint;
				pp21 = w1.groundFrontEnd;
				pp22 = w1.groundFrontHead;
				
				cw = cw1.wall.frontCrossWall;
				cw.endCrossWall = cw2;//设置相邻相交墙面
			}
			
			if(cw2.isHead)
			{
				ss11 = w2.groundFrontHeadPoint;
				ss12 = w2.groundFrontEndPoint;
				ss21 = w2.groundFrontHead;
				ss22 = w2.groundFrontEnd;
				
				cw2.headCrossWall = cw;//设置相邻相交墙面
			}
			else
			{
				ss11 = w2.groundBackEndPoint;
				ss12 = w2.groundBackHeadPoint;
				ss21 = w2.groundBackEnd;
				ss22 = w2.groundBackHead;
				
				cw2.endCrossWall = cw;//设置相邻相交墙面
			}
			
			p1.x = pp11.x;
			p1.y = pp11.z;
			p2.x = pp12.x;
			p2.y = pp12.z;
			
			s1.x = ss11.x;
			s1.y = ss11.z;
			s2.x = ss12.x;
			s2.y = ss12.z;
			
			if(!Geom.parallel(p1,p2,s1,s2))
			{
				//取两个墙体中宽度值大的为基数，再扩大后作为墙面延长的距离
				var w:Number = (w1.width>w2.width)?(w1.width):(w2.width);
				w *= 10;
				var p:Point = Geom.distent(p2,p1,w);
				var s:Point = Geom.distent(s2,s1,w);
				
				//trace("计算交点：",p2,p1,s2,s1);
				//如果有交点，则取交点为相交墙面的端点
				if(Geom.intersect_in(p,p2,s,s2))
				{
					var p0:Point = Geom.intersection(p,p2,s,s2);
					pp11.x = p0.x;
					pp11.z = p0.y;
					ss11.x = p0.x;
					ss11.z = p0.y;
					
					//trace("交点1：",pp21,ss21);
					w1.globalToLocal(pp11,pp21);
					w2.globalToLocal(ss11,ss21);
					
					//trace("交点2：",p0,pp21,ss21);
					
					//设置两个墙面的关系
					/*if(cw1.isHead)cw1.headCrossWall = cw2;
					else
						cw1.endCrossWall = cw2;
					
					if(cw2.isHead)cw2.headCrossWall = cw1;
					else
						cw2.endCrossWall = cw1;*/
					
					w1.isChanged = true;
					w2.isChanged = true;
				}
				else
				{
					//否则取延长后的点为相交墙面的端点
					//p1.x = p.x;
					//p1.y = p.y;
					//s1.x = s.x;
					//s1.y = s.y;
				}
			}
			else
			{
				//trace("墙面平行");
			}
		}
		
		//按相交墙体的旋转方向顺时针排序
		private function sortCrossWall(cws:Vector.<CrossWall>):void
		{
			//trace("sortCrossWall");
			var len:int = cws.length;
			var a:Array = [];
			for(var i:int=0;i<len;i++)
			{
				var cw:CrossWall = cws[i];
				var angle:int = cw.isHead ? cw.wall.angles : MyMath.turnAngles(cw.wall.angles+180);//如果相交点不在头端，要进行转换
				a[i] = {angle:angle,cw:cw};
			}
			
			a.sortOn("angle",Array.NUMERIC);//进行排序
			
			for(i=0;i<len;i++)
			{
				var o:Object = a[i];
				//trace("angle:"+o.angle);
				cws[i] = o.cw;
			}
		}
		
		public function findCrossWall():void
		{
			var threshold:Number = this.width*0.5;//以墙体宽度的一半为分辨阈值来查找房间点
			var hp:HousePoint = findHousePoint(floor.groundPoints,groundHeadPoint.point,threshold,groundHeadPoint,groundEndPoint);
			if(hp)
			{
				mergeCrossWalls(hp.crossWalls,groundHeadPoint.crossWalls);
				removeHousePoint(floor.groundPoints,groundHeadPoint);
				groundHeadPoint = hp;
			}
			
			hp = findHousePoint(floor.groundPoints,groundEndPoint.point,threshold,groundHeadPoint,groundEndPoint);
			if(hp)
			{
				mergeCrossWalls(hp.crossWalls,groundEndPoint.crossWalls);
				removeHousePoint(floor.groundPoints,groundEndPoint);
				groundEndPoint = hp;
			}
		}
		
		//合并相交墙体后，移除多余的房间点
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
			
			hp.dispose();
		}
		
		//合并相交墙体
		private function mergeCrossWalls(cws1:Vector.<CrossWall>,cws2:Vector.<CrossWall>):void
		{
			while(cws2.length>0)cws1.push(cws2.pop());
		}
		
		private function findHousePoint(hps:Vector.<HousePoint>,d:Point3D,threshold:Number,except:HousePoint,except2:HousePoint):HousePoint
		{
			for each(var hp:HousePoint in hps)
			{
				var p:Point3D = hp.point;
				if(hp!=except && hp!=except2)
				{
					var dx:Number = p.x - d.x;
					var dz:Number = p.z - d.z;
					if(dx*dx + dz*dz < threshold*threshold)
					{
						//trace("findHousePoint:",hps.length,p.x,p.y,p.z,threshold," ok");
						return hp;
					}
				}
			}
			return null;
		}
		
		public function updatePosition(x:Number,y:Number):void
		{
			var sceneHeightSize:int = Base2D.screenToSize(Scene2D.sceneHeight);
			var p:Point3D = groundHeadPoint.point;
			
			var x1:Number = Base2D.screenToSize(x);
			var y1:Number = p.y;
			var z1:Number = Base2D.screenToSize(y);
			z1 = sceneHeightSize - z1;//将屏幕坐标值转换为左手系坐标值
			
			var dx:Number = x1 - p.x;
			var dz:Number = z1 - p.z;
			
			updateHousePoint(this.groundHeadPoint,x1,y1,z1);
			
			p = groundEndPoint.point;
			
			updateHousePoint(this.groundEndPoint,p.x+dx,p.y,p.z+dz);
			
			update1();
			update2();
			
			this.updateCrossWall();
			
			updateRooms();
		}
		
		public function updateRooms():void
		{
			if(frontCrossWall.room)frontCrossWall.room.isChanged = true;
			if(backCrossWall.room)backCrossWall.room.isChanged = true;
			
			/*for each(var room:Room in rooms)
			{
				room.isChanged = true;
			}*/
		}
		
		private function updateCrossWall():void
		{
			_updateCrossWall(groundHeadPoint);
			_updateCrossWall(groundEndPoint);
		}
		
		private function _updateCrossWall(hp:HousePoint):void
		{
			var cws:Vector.<CrossWall> = hp.crossWalls;
			for each(var cw:CrossWall in cws)
			{
				var w:Wall = cw.wall;
				if(w!=this)
				{
					w.updateLength();
					w.countCrossWall();
					w.isChanged = true;
				}
			}
		}
		
		public function update(startX:Number,startY:Number,dx:Number,dy:Number,wallWidth:Number=0):void
		{
			this.width = wallWidth>0?wallWidth:floor.wallWidth;//如果不指定墙体的宽度，则采用楼层的默认墙宽
			
			var sceneHeightSize:int = Base2D.screenToSize(Scene2D.sceneHeight);
			
			var x1:Number = Base2D.screenToSize(startX);
			var y1:Number = floor.groundHeight;
			var z1:Number = Base2D.screenToSize(startY);
			z1 = sceneHeightSize - z1;//将屏幕坐标值转换为左手系坐标值
			
			var x2:Number = Base2D.screenToSize(startX+dx);
			//var y2:int = floor.groundHeight+floor.ceilingHeight;
			var z2:Number = Base2D.screenToSize(startY+dy);
			z2 = sceneHeightSize - z2;//将屏幕坐标值转换为左手系坐标值
			
			//墙体地面起点的全局坐标
			var hp:HousePoint;
			if(!this.groundHeadPoint)//当前点不存在时，创建新房间点
			{
				hp = createHousePoint(x1,y1,z1);
				this.groundHeadPoint = hp;
				hp.crossWalls.push(frontCrossWall);//new CrossWall(this,true));
				floor.groundPoints.push(hp);
			}
			else//更新房间点位置
			{
				updateHousePoint(this.groundHeadPoint,x1,y1,z1);
			}
			
			//墙体地面终点的全局坐标
			if(!this.groundEndPoint)//当前点不存在时，创建新房间点
			{
				hp = createHousePoint(x2,y1,z2);
				this.groundEndPoint = hp;
				hp.crossWalls.push(backCrossWall);//new CrossWall(this,false));
				floor.groundPoints.push(hp);
			}
			else//更新房间点位置
			{
				updateHousePoint(this.groundEndPoint,x2,y1,z2);
			}
			
			
			//墙体的长度
			this.length = Base2D.screenToSize(Math.sqrt(dx*dx + dy*dy));
			
			//更新墙体的旋转角度
			updateRadians();
			//trace("wall Angles:"+this.angles);
			
			update1();
			update2();
		}
		
		private function update1():void
		{
			//墙体轴线地面起点，本地坐标
			this.groundHead.x = 0;
			this.groundHead.y = 0;
			this.groundHead.z = 0;
			
			//墙体轴线地面终点，本地坐标
			this.groundEnd.x = this.length;
			this.groundEnd.y = 0;
			this.groundEnd.z = 0;
			
			//墙体轴线天花板起点，本地坐标
			/*this.ceilingHead.x = 0;
			this.ceilingHead.y = floor.ceilingHeight;
			this.ceilingHead.z = 0;*/
			
			//墙体轴线天花板终点，本地坐标
			/*this.ceilingEnd.x = this.length;
			this.ceilingEnd.y = floor.ceilingHeight;
			this.ceilingEnd.z = 0;*/
			
			this.groundFrontHead.x = this.groundHead.x;
			this.groundFrontHead.y = this.groundHead.y;
			this.groundFrontHead.z = - this.width * 0.5;
			
			this.groundFrontEnd.x = this.groundEnd.x;
			this.groundFrontEnd.y = this.groundEnd.y;
			this.groundFrontEnd.z = this.groundFrontHead.z;
			
			this.groundBackHead.x = this.groundHead.x;
			this.groundBackHead.y = this.groundHead.y;
			this.groundBackHead.z = this.width * 0.5;
			
			this.groundBackEnd.x = this.groundEnd.x;
			this.groundBackEnd.y = this.groundEnd.y;
			this.groundBackEnd.z = this.groundBackHead.z;
		}
		
		/**
		 * 根据墙体前后墙面的四个顶点本地坐标，更新墙体前后墙面四个顶点的全局坐标
		 * 
		 */
		private function update2():void
		{
			this.localToGlobal(groundFrontHead,groundFrontHeadPoint);
			this.localToGlobal(groundFrontEnd,groundFrontEndPoint);
			this.localToGlobal(groundBackHead,groundBackHeadPoint);
			this.localToGlobal(groundBackEnd,groundBackEndPoint);
			
			this.isChanged = true;
		}
		
		public function updateLength():void
		{
			var p1:Point3D = groundHeadPoint.point;
			var p2:Point3D = groundEndPoint.point;
			var dx:Number = p2.x - p1.x;
			var dz:Number = p2.z - p1.z;
			this.length = Math.sqrt(dx*dx + dz*dz);
			this.radians = Math.atan2(dz,dx);
			
			update1();
			update2();
		}
		
		private function updateRadians():void
		{
			var p1:Point3D = this.groundHeadPoint.point;
			var p2:Point3D = this.groundEndPoint.point;
			this.radians = Math.atan2(p2.z-p1.z,p2.x-p1.x);
			
			//trace("updateRadians:"+this.index+" p1:"+p1+" p2:"+p2+" angles:"+this.angles);
		}
		
		private function createHousePoint(x:Number,y:Number,z:Number):HousePoint
		{
			//trace("创建新的房间点:",x,y,z);
			var hp:HousePoint = new HousePoint();
			hp.point.x = x;
			hp.point.y = y;
			hp.point.z = z;
			hp.index = HousePoint.getNextIndex();
			
			return hp;
		}
		
		private function updateHousePoint(hp:HousePoint,x:Number,y:Number,z:Number):void
		{
			//trace("更新房间点:",x,y,z);
			hp.point.x = x;
			hp.point.y = y;
			hp.point.z = z;
		}
		
		/**
		 * 计算指定点到墙体轴线的垂足及垂直距离
		 * @param srcPoint
		 * @param footPoint
		 * @return 
		 * 
		 */
		public function distToPoint(srcPoint:Point,footPoint:Point=null):Number
		{
			footPoint = Geom.getFootPoint2(srcPoint,groundHeadPoint.point,groundEndPoint.point,footPoint);
			return Point.distance(srcPoint,footPoint);
		}
		
		//墙体属性数据：index,name,location,length,width,height,angles,
		//hole:x,y,width,heigth
		//materail:frontSurface:normalTexture,specular,backSurface:normalTexture,specular
		override public function toString():String
		{
			var s:String;
			return s;
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"index\":" + index + ",";
			s += "\"name\":\"" + name + "\",";
			s += "\"width\":" + width + ",";
			
			//s += "coordinate:{gh:"+groundHeadPoint.index+",ge:"+groundEndPoint.index+",ch:"+ceilingHeadPoint.index+",ce:"+ceilingEndPoint.index+"},";
			//s += "\"coord\":{\"gh\":"+groundHeadPoint.index+",\"ge\":"+groundEndPoint.index+"}";
			s += "\"groundHead\":" + groundHeadPoint.index + ",";
			s += "\"groundEnd\":" + groundEndPoint.index + ",";
			
			s += getHolesJsonData() + ",";
			
			s += getMaterialJsonData("frontCrossWall",frontCrossWall) + ",";
			s += getMaterialJsonData("backCrossWall",backCrossWall);
			
			s += "}";
			return s;
		}
		
		private function getMaterialJsonData(name:String,cw:CrossWall):String
		{
			return "\"" + name + "\":" + cw.getMaterialJsonString2();
		}
		
		private function getHolesJsonData():String
		{
			var s:String = "\"holes\":[";
			
			var len:int = holes.length;
			for(var i:int=0;i<len;i++)
			{
				var h:WallHole = holes[i]
				s += h.toJsonString() + (i<len-1?",":"");
			}
			
			s += "]";
			return s;
		}
	}
}



















