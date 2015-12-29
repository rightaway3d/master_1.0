package rightaway3d.house.vo
{
	import flash.events.Event;
	
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.view2d.WallArea2D;
	import rightaway3d.utils.MyMath;
	
	[Event(name="material_change", type="flash.events.Event")]
	
	[Event(name="size_change", type="flash.events.Event")]

	public final class CrossWall extends BaseVO
	{
		static public const MATERIAL_CHANGE:String = "material_change";
		static public const SIZE_CHANGE:String = "size_change";
		
		
		/**
		 * 相交的墙体
		 */
		public var wall:Wall;
		
		/**
		 * 在HousePoint中，为true时，交点在头端，否则交点在尾端
		 * 在Wall中，为true时，表示墙体正面，否则为墙体背面
		 */		
		public var isHead:Boolean;
		
		private var _materialName:String = "";

		/**
		 * 墙面材质名称
		 */
		public function get materialName():String
		{
			return _materialName;
		}

		/**
		 * @private
		 */
		public function set materialName(value:String):void
		{
			if(_materialName == value)return;
			
			_materialName = value;
			
			if(this.hasEventListener(MATERIAL_CHANGE))
			{
				this.dispatchEvent(new Event(MATERIAL_CHANGE));
			}
		}
		
		public function dispatchSizeChangeEvent():void
		{
			this.wall.isChanged = true;
			if(this.hasEventListener(SIZE_CHANGE))
			{
				this.dispatchEvent(new Event(SIZE_CHANGE));
			}
		}

		
		/**
		 * 纹理贴图地址
		 */
		//public var textureURL:String;
		
		/**
		 * 法线贴图地址
		 */
		//public var normalURL:String;
		
		/**
		 * 相交于此墙面首端点的墙面
		 * 此墙面首端点与此墙体之首端点一样，位于墙体起始端之正面或背面
		 */
		public var headCrossWall:CrossWall;
		
		/**
		 * 相交于此墙面尾端点的墙面
		 * 此墙面尾端点与此墙体之尾端点一样，位于墙体末端之正面或背面
		 */
		public var endCrossWall:CrossWall;
		
		/**
		 * 此墙面所属的房间
		 */
		public var room:Room;
		
		//其它的关联到墙体的对象
		public var otherObjects:Array;
		
		public function addOtherObject(wo:WallObject):void
		{
			otherObjects ||= [];
			otherObjects.push(wo);
		}
		
		public function removeOtherObject(wo:WallObject):void
		{
			var n:int = otherObjects.indexOf(wo);
			if(n>-1)
			{
				otherObjects.splice(n,1);
			}
		}
		
		/**
		 * 在地面上沿着此墙体放置的产品
		 */
		private var _groundObjects:Array = [];
		
		/**
		 * 挂在此墙上的产品
		 */
		private var _wallObjects:Array = [];
		
		private var tmpGroundObjects:Array = [];
		private var tmpWallObjects:Array = [];
		
		public function CrossWall(wall_:Wall,isHead_:Boolean)
		{
			wall = wall_;
			isHead = isHead_;
		}
		
		override public function dispose():void
		{
			//trace("CrossWall dispose Wall:"+wall.index+" isHead:"+isHead);
			if(_groundObjects)
			{
				while(_groundObjects.length>0)this.removeWallObject(_groundObjects[0]);
			}
			
			if(_wallObjects)
			{
				while(_wallObjects.length>0)this.removeWallObject(_wallObjects[0]);
			}
			
			if(headCrossWall)
			{
				if(headCrossWall.headCrossWall==this)headCrossWall.headCrossWall = null;
				else if(headCrossWall.endCrossWall==this)headCrossWall.endCrossWall = null;

				headCrossWall = null;
			}
			if(endCrossWall)
			{
				if(endCrossWall.headCrossWall==this)endCrossWall.headCrossWall = null;
				else if(endCrossWall.endCrossWall==this)endCrossWall.endCrossWall = null;
				
				endCrossWall = null;
			}
			
			_groundObjects = null;
			_wallObjects = null;
			
			tmpGroundObjects = null;
			tmpWallObjects = null;
			
			room = null;
			
			dispatchDisposeEvent();
		}
		
		/**
		 * 墙面的有效长度
		 * @return 
		 * 
		 */
		public function get validLength():Number
		{
			return isHead?wall.groundFrontEnd.x-wall.groundFrontHead.x:wall.groundBackEnd.x-wall.groundBackHead.x;
		}
		
		/**
		 * 墙面头点本地坐标
		 * @return 
		 * 
		 */
		public function get localHead():Point3D
		{
			return isHead?wall.groundFrontHead:wall.groundBackHead;
		}
		
		/**
		 * 墙面尾点本地坐标
		 * @return 
		 * 
		 */
		public function get localEnd():Point3D
		{
			return isHead?wall.groundFrontEnd:wall.groundBackEnd;
		}
		
		//public var selectLocalHead:Point3D;
		//public var selectLocalEnd:Point3D;
		
		/**
		 * 墙面头点全局坐标
		 * @return 
		 * 
		 */
		public function get globalHead():Point3D
		{
			return isHead?wall.groundFrontHeadPoint:wall.groundBackEndPoint;
		}
		
		/**
		 * 墙面尾点全局坐标
		 * @return 
		 * 
		 */
		public function get globalEnd():Point3D
		{
			return isHead?wall.groundFrontEndPoint:wall.groundBackEndPoint;
		}
		
		public function get groundObjects():Array
		{
			//trace("groundObjects:"+_groundObjects);
			if(tmpGroundObjects && tmpGroundObjects.length>0)return tmpGroundObjects.concat();
			return _groundObjects.concat();
		}
		
		public function get wallObjects():Array
		{
			if(tmpWallObjects && tmpWallObjects.length>0)return tmpWallObjects.concat();
			return _wallObjects.concat();
		}
		
		/**
		 * 关联到墙体的悬挂物体的下沿高度(1540)，用以区分添加到此墙体的物体，是添加到groundObjects中，还是wallObjects中
		 */
		static public var WALL_OBJECT_HEIGHT:int = 1470;
		
		/**
		 * 关联到墙体的地面物体的高度(800)
		 */
		static public var GROUND_OBJECT_HEIGHT:int = 800;
		
		/**
		 * 低于此高度(80)的物体，将会被忽略
		 */
		static public var IGNORE_OBJECT_HEIGHT:int = 80;
		
		/**
		 * 获取此墙面指定区段中的地面物体（WallObject）
		 * @param x0 区段起点
		 * @param x1 区段终点
		 * @param groundObjects 区段中的地面物体，存于此数组返回
		 * 
		 */
		public function getGroundObjectOfPos(x0:Number,x1:Number,groundObjects:Array):void
		{
			_getGroundObjectOfPos(x0,x1,groundObjects,this.tmpGroundObjects);
		}
		
		private function _getGroundObjectOfPos(x0:Number,x1:Number,groundObjects:Array,sources:Array):void
		{
			//trace("getGroundObjectOfPos x0:"+x0+" x1:"+x1);
			if(x0>x1)
			{
				var t:Number = x0;
				x1 = x0;
				x0 = x1;
			}
			
			if(isHead)
			{
				getHeadWallObject(x0,x1,sources,groundObjects);
			}
			else
			{
				getEndWallObject(x0,x1,sources,groundObjects);
			}
		}
		
		/**
		 * 获取此墙面指定区段中的挂置物体（WallObject）
		 * @param x0 区段起点
		 * @param x1 区段终点
		 * @param wallObjects 区段中墙面物体，存于此数组返回
		 * 
		 */
		public function getWallObjectOfPos(x0:Number,x1:Number,wallObjects:Array):void
		{
			_getWallObjectOfPos(x0,x1,wallObjects,this.tmpWallObjects);
		}
		
		private function _getWallObjectOfPos(x0:Number,x1:Number,wallObjects:Array,sources:Array):void
		{
			//trace("getWallObjectOfPos x0:"+x0+" x1:"+x1);
			if(x0>x1)
			{
				var t:Number = x0;
				x1 = x0;
				x0 = x1;
			}
			
			if(isHead)
			{
				getHeadWallObject(x0,x1,sources,wallObjects);
			}
			else
			{
				getEndWallObject(x0,x1,sources,wallObjects);
			}
		}
		
		private function getHeadWallObject(x0:Number,x1:Number,sources:Array,objects:Array):void
		{
			if(x0==x1)return;
			
			var len:int = sources.length;
			//trace("getHeadWallObject x0:"+x0+" x1:"+x1+" srcNum:"+len);
			for(var i:int=0;i<len;i++)
			{
				var o:WallObject = sources[i];
				if(o.x>x0 && o.x-o.width<x1)//找出与[x0，x1]区间有重叠的物体，并添加到数组中返回
				{
					objects.push(o);
					//trace(i+" : "+o);
				}
			}
		}
		
		private function getEndWallObject(x0:Number,x1:Number,sources:Array,objects:Array):void
		{
			trace("功能末实现");
		}
		
		/**
		 * 加入关联到此墙面的物体
		 * @param object
		 * 
		 */
		public function addWallObject(wo:WallObject):void
		{
			//trace("addWallObject_1");
			if(wo.crossWall==this)return;
			
			if(wo.crossWall)
			{
				var cw:CrossWall = wo.crossWall;
				cw.removeWallObject(wo);
			}
			//trace("addWallObject_2");
			
			//关联到此墙面的圆柱体，可以与其它物体重叠在一块
			if(wo.isIgnoreObject)//object.type==ModelType.CYLINDER || object.type==ModelType.CYLINDER_C || object.y+object.height<IGNORE_OBJECT_HEIGHT)
			{
				wo.crossWall = this;
				return;
			}
			//trace("addWallObject isHead:"+isHead+" index:"+wall.index+" x:"+object.x+" y:"+object.y+" width:"+object.width+" height:"+object.height);
			//trace("_groundObjects1:"+_groundObjects);
			//trace("_wallObjects1:"+_wallObjects);
			//trace("addWallObject2");
			
			wo.crossWall = this;
			
			if(wo.y<GROUND_OBJECT_HEIGHT)
			{
				_groundObjects.push(wo);
				_groundObjects.sortOn("x",Array.NUMERIC);//进行排序
				
				tmpGroundObjects.push(wo);
				tmpGroundObjects.sortOn("x",Array.NUMERIC);
				
				if(headCrossWall)var wo01:WallObject = this.getMaxDepthObject(this.headCrossWall._groundObjects);
				if(wo01)
				{
					headCrossWall.resetGroundObjects(wo01);
				}
				
				if(endCrossWall)var wo11:WallObject = this.getMaxDepthObject(this.endCrossWall._groundObjects);
				if(wo11)
				{
					endCrossWall.resetGroundObjects(wo11);
				}
			}
			
			if(wo.y+wo.height>WALL_OBJECT_HEIGHT)
			{
				_wallObjects.push(wo);
				_wallObjects.sortOn("x",Array.NUMERIC);//进行排序
				
				tmpWallObjects.push(wo);
				tmpWallObjects.sortOn("x",Array.NUMERIC);
				
				if(headCrossWall)var wo02:WallObject = this.getMaxDepthObject(this.headCrossWall._wallObjects);
				if(wo02)
				{
					headCrossWall.resetWallObject(wo02);
				}
				
				if(endCrossWall)var wo12:WallObject = this.getMaxDepthObject(this.endCrossWall._wallObjects);
				if(wo12)
				{
					endCrossWall.resetWallObject(wo12);
				}
			}
			
			if(wo01 || wo02)
			{
				headCrossWall.dispatchSizeChangeEvent();
			}
			
			if(wo11 || wo12)
			{
				endCrossWall.dispatchSizeChangeEvent();
			}
			
			this.dispatchSizeChangeEvent();
			
			//trace("addWallObject_groundObjects.length:"+_groundObjects.length);
			//trace("--wallObjects num:"+_wallObjects.length+","+_wallObjects);
			//trace("--acddWallObject index:",wall.index,object,"ground:",_groundObjects.length,"wall:",_wallObjects.length);
			
			//this.initTestObject();
			//this.wall.isChanged = true;
			//this.wall.dispatchChangeEvent();
			
			/*if(object.object is ProductObject)
			{
				this.headCrossWall.initTestObject();
				this.endCrossWall.initTestObject();
				
				this.headCrossWall.wall.isChanged = true;
				this.endCrossWall.wall.isChanged = true;
				
				//headCrossWall.wall.dispatchChangeEvent();
				//endCrossWall.wall.dispatchChangeEvent();
			}*/
		}
		
		/**
		 * 移除关联到此墙面的物体
		 * @param object
		 * 
		 */
		public function removeWallObject(wo:WallObject):Boolean
		{
			//trace("removeWallObject1");
			if(wo.crossWall!=this)return false;
			
			wo.crossWall = null;
			//trace("removeWallObject2");
			
			if(wo.isIgnoreObject)//object.type==ModelType.CYLINDER || object.type==ModelType.CYLINDER_C || object.y+object.height<IGNORE_OBJECT_HEIGHT)
				return true;
			
			if(wo.y<GROUND_OBJECT_HEIGHT)
			{
				_groundObjects.splice(_groundObjects.indexOf(wo),1);
				
				tmpGroundObjects.splice(tmpGroundObjects.indexOf(wo),1);
				
				var a:Array = headCrossWall.tmpGroundObjects;
				if(a.length>0 && a[a.length-1].object == wo)
				{
					a.pop();
					headCrossWall.dispatchSizeChangeEvent();
				}
				else
				{
					a = endCrossWall.tmpGroundObjects;
					if(a.length>0 && a[0].object == wo)
					{
						a.shift();
						endCrossWall.dispatchSizeChangeEvent();
					}
				}
			}
			//trace("removeWallObject_groundObjects.length:",_groundObjects.length);
			if(wo.y+wo.height>WALL_OBJECT_HEIGHT)
			{
				_wallObjects.splice(_wallObjects.indexOf(wo),1);
				
				tmpWallObjects.splice(tmpWallObjects.indexOf(wo),1);
				
				a= headCrossWall.tmpWallObjects;
				if(a.length>0 && a[a.length-1].object == wo)
				{
					a.pop();
					headCrossWall.dispatchSizeChangeEvent();
				}
				else
				{
					a = endCrossWall.tmpWallObjects;
					if(a.length>0 && a[0].object == wo)
					{
						a.shift();
						endCrossWall.dispatchSizeChangeEvent();
					}
				}
			}
			
			//this.initTestObject();
			this.dispatchSizeChangeEvent();
			//this.resetGroundObjects(
			/*if(object.object is ProductObject)
			{
				if(headCrossWall)
				{
					this.headCrossWall.initTestObject();
					this.headCrossWall.wall.isChanged = true;
				}
				if(endCrossWall)
				{
					this.endCrossWall.initTestObject();
					this.endCrossWall.wall.isChanged = true;
				}
			}*/
			
			return true;
		}
		
		private function resetGroundObjects(testWO:WallObject):void
		{
			var wos:Array = [];
			var wo:WallObject,two:WallObject;
			var x0:Number,x1:Number;
			var td:Number;
			
			if(testWO.y < GROUND_OBJECT_HEIGHT)
			{
				tmpGroundObjects = _groundObjects.concat();
				
				if(headCrossWall._groundObjects.length>0)
				{
					x1 = headCrossWall.localEnd.x;
					td = testWO.z + testWO.depth;
					x0 = x1 - td;
					
					headCrossWall._getGroundObjectOfPos(x0,x1,wos,headCrossWall._groundObjects);
					wo = this.getMaxDepthObject(wos);
					
					if(wo)
					{
						two = cloneWallObject(wo);
						two.x = localHead.x + two.width;
						tmpGroundObjects.unshift(two);
					}
				}
				
				if(endCrossWall._groundObjects.length>0)
				{
					wos.length = 0;
					x0 = endCrossWall.localHead.x;
					x1 = x0 + testWO.z + testWO.depth;
					
					endCrossWall._getGroundObjectOfPos(x0,x1,wos,endCrossWall._groundObjects);
					wo = this.getMaxDepthObject(wos);
					
					if(wo)
					{
						two = cloneWallObject(wo);
						two.x = localEnd.x;
						tmpGroundObjects.push(two);
					}
				}
			}
			
			resetWallObject(testWO);
		}
		
		private function resetWallObject(testWO:WallObject):void
		{
			var wos:Array = [];
			var wo:WallObject,two:WallObject;
			var x0:Number,x1:Number;
			var td:Number;
			
			if(testWO.y + testWO.height > GROUND_OBJECT_HEIGHT)
			{
				tmpWallObjects = _wallObjects.concat();
				
				if(headCrossWall._wallObjects.length>0)
				{
					wos.length = 0;
					x1 = headCrossWall.localEnd.x;
					td = testWO.z + testWO.depth;
					x0 = x1 - td;
					headCrossWall._getWallObjectOfPos(x0,x1,wos,headCrossWall._wallObjects);
					wo = getMaxDepthObject(wos);
					if(wo)
					{
						two = cloneWallObject(wo);
						two.x = localHead.x + two.width;
						tmpWallObjects.unshift(two);
					}
				}
				
				if(endCrossWall._wallObjects.length>0)
				{
					wos.length = 0;
					x0 = endCrossWall.localHead.x;
					x1 = x0 + testWO.z + testWO.depth;
					endCrossWall._getWallObjectOfPos(x0,x1,wos,endCrossWall._wallObjects);
					wo = getMaxDepthObject(wos);
					if(wo)
					{
						two = cloneWallObject(wo);
						two.x = localEnd.x;
						tmpWallObjects.push(two);
					}
				}
			}
		}
		
		private function cloneWallObject(wo:WallObject):WallObject
		{
			var two:WallObject = new WallObject();
			two.width = wo.z + wo.depth;
			two.height = wo.height;
			
			two.y = wo.y;
			
			two.type = wo.type;
			//two.object = wo.object;
			two.object = wo;
			
			return two;
		}
		
		/*public function initTestObject2():void
		{
			return;
			
			tmpGroundObjects = _groundObjects.concat();
			tmpWallObjects = _wallObjects.concat();
			trace("initTestObjects:",wall.index,tmpGroundObjects);
			var gos:Array = [];
			var wos:Array = [];
			var x0:Number,x1:Number;
			var two:WallObject;
			var groundObjectDepth:int=570,wallObjectDepth:int=350;
			
			if(headCrossWall)//计算头端相邻墙面要避让的物体
			{
				//trace("--headCrossWall isHead:"+headCrossWall.isHead+" index:"+headCrossWall.wall.index);
				if(headCrossWall.isHead)//为相邻墙体的正面
				{
					x1 = headCrossWall.localEnd.x;
					wo = getMaxDepthObject(_groundObjects);
					groundObjectDepth = wo ? wo.z + wo.depth : 0;
					trace("groundObjectDepth:"+groundObjectDepth);
					x0 = x1 - groundObjectDepth;
					headCrossWall._getGroundObjectOfPos(x0,x1,gos,headCrossWall._groundObjects);
					//trace("x0:"+x0+" x1:"+x1+" gos:"+gos);
					
					wo = getMaxDepthObject(_wallObjects);
					wallObjectDepth = wo ? wo.z + wo.depth : 0;
					trace("wallObjectDepth:"+wallObjectDepth);
					x0 = x1 - wallObjectDepth;
					headCrossWall._getWallObjectOfPos(x0,x1,wos,headCrossWall._wallObjects);
					//trace("x0:"+x0+" x1:"+x1+" wos:"+wos);
				}
				else//为相邻墙体的背面
				{
					trace("功能末实现");
				}
				
				var wo:WallObject = getMaxDepthObject(gos);//取相邻墙面上深度最大的物体
				if(wo)
				{
					two = new WallObject();
					two.width = wo.depth;
					two.height = wo.height;
					
					two.x = localHead.x + wo.z + wo.depth;
					two.y = wo.y;
					
					two.type = wo.type;
					two.object = null;//wo.object;
					
					removeRepeatObject1(tmpGroundObjects,two);
					
					tmpGroundObjects.unshift(two);
					trace("tmpGroundObjects0:"+two);
				}
				
				wo = getMaxDepthObject(wos);
				if(wo)
				{
					two = new WallObject();
					two.width = wo.depth;
					two.height = wo.height;
					
					two.x = localHead.x + wo.z + wo.depth;
					two.y = wo.y;
					
					two.type = wo.type;
					two.object = null;//wo.object;
					
					removeRepeatObject1(tmpWallObjects,two);
					
					tmpWallObjects.unshift(two);
					trace("tmpWallObjects1:"+two);
				}
			}
			
			if(endCrossWall)//计算尾端相邻墙面要避让的物体
			{
				//trace("--endCrossWall isHead:"+endCrossWall.isHead+" index:"+endCrossWall.wall.index);
				gos.length = 0;
				wos.length = 0;
				
				if(endCrossWall.isHead)//为相邻墙体的正面
				{
					x0 = endCrossWall.localHead.x;
					
					wo = getMaxDepthObject(_groundObjects);
					groundObjectDepth = wo ? wo.z + wo.depth : 0;
					x1 = x0 + groundObjectDepth;
					endCrossWall._getGroundObjectOfPos(x0,x1,gos,endCrossWall._groundObjects);
					//trace("x0:"+x0+" x1:"+x1+" gos:"+gos);
					
					wo = getMaxDepthObject(_wallObjects);
					wallObjectDepth = wo ? wo.z + wo.depth : 0;
					x1 = x0 + wallObjectDepth;
					endCrossWall._getWallObjectOfPos(x0,x1,wos,endCrossWall._wallObjects);
					//trace("x0:"+x0+" x1:"+x1+" wos:"+wos);
				}
				else//为相邻墙体的背面
				{
					trace("功能末实现");
				}
				
				wo = getMaxDepthObject(gos);
				if(wo)
				{
					two = new WallObject();
					two.width = wo.depth;
					two.height = wo.height;
					
					two.x = localEnd.x-wo.z;
					two.y = wo.y;
					
					two.type = wo.type;
					two.object = null;//wo.object;
					
					removeRepeatObject2(tmpGroundObjects,two);
					
					tmpGroundObjects.push(two);
					trace("tmpGroundObjects2:"+two);
				}
				
				wo = getMaxDepthObject(wos);
				if(wo)
				{
					two = new WallObject();
					two.width = wo.depth;
					two.height = wo.height;
					
					two.x = localEnd.x-wo.z;
					two.y = wo.y;
					
					two.type = wo.type;
					two.object = null;//wo.object;
					
					removeRepeatObject2(tmpWallObjects,two);
					
					tmpWallObjects.push(two);
					trace("tmpWallObjects3:"+two);
				}
			}
			trace("--tmpWallObjects num:"+tmpGroundObjects.length+","+tmpGroundObjects);
			trace("--tmpWallObjects num:"+tmpWallObjects.length+","+tmpWallObjects);
			//trace("--initTestObject index:",wall.index);
			//trace("--initTestObject index:",wall.index,"ground:",tmpGroundObjects.length,"wall:",tmpWallObjects.length);
		}*/
		
		private function removeRepeatObject1(objects:Array,wo:WallObject):void
		{
			if(objects.length>0)
			{
				var o:WallObject = objects[0];
				if(o.x<wo.x)
				{
					objects.shift();
					removeRepeatObject1(objects,wo);
				}
			}
		}
		
		private function removeRepeatObject2(objects:Array,wo:WallObject):void
		{
			if(objects.length>0)
			{
				var o:WallObject = objects[objects.length-1];
				if(o.x-o.width>wo.x-wo.width)
				{
					objects.pop();
					removeRepeatObject2(objects,wo);
				}
			}
		}
		
		private function getMaxDepthObject(objects:Array):WallObject
		{
			var len:int = objects.length;
			if(len==0)return null;
			//if(len==1)return objects[0];
			
			var o:WallObject = objects[0];
			for(var i:int=1;i<len;i++)
			{
				var t:WallObject = objects[i];
				if(t.z + t.depth > o.z + o.depth)
				{
					o = t;
				}
			}
			//trace("getMaxDepthObject depth:"+o.depth);
			return o.depth>1?o:null;//排除深度为0的物体
		}
		
		/*public function testAutoAddToHead(object:WallObject,xPos:Number):Boolean
		{
			//trace("testAutoAddToHead groundObjects:"+_groundObjects);
			
			var x1:Number = xPos;
			if(isHead)
			{
				var x0:Number = xPos-object.width;
				if(x0 < localHead.x)return false;//剩余的空间不足以放置物体
				
				var gos:Array = [];
				var wos:Array = [];
				
				//trace("tmpGroundObjects.length:"+tmpGroundObjects.length+" tmpWallObjects.length:"+tmpWallObjects.length);
				if(object.y<GROUND_OBJECT_HEIGHT)//检测地柜区域
				{
					//trace("0");
					this.getHeadWallObject(x0,xPos,this.tmpGroundObjects,gos);
				}
				
				if(object.y+object.height>WALL_OBJECT_HEIGHT)//检测吊柜区域
				{
					//trace("1");
					this.getHeadWallObject(x0,xPos,this.tmpWallObjects,wos);
				}
				
				if(gos.length>0)//地柜位置被占用，将起始位置移到占用位置左则
				{
					//trace("2");
					var o:WallObject = gos[0];
					xPos = o.x - o.width;
				}
				
				if(wos.length>0)//吊柜位置被占用，将起始位置移到占用位置左则
				{
					//trace("3");
					o = wos[0];
					if(xPos > o.x - o.width)
					{
						xPos = o.x - o.width;
					}
				}
				
				//trace("testAutoAddToHead2 groundObjects:"+_groundObjects);
				if(x1==xPos)
				{
					//trace("4");
					object.x = x1;
					return true;
				}
				
				//trace("5:"+xPos);
				return testAutoAddToHead(object,xPos);
			}
			else
			{
				trace("功能末实现");
			}
			
			return true;
		}*/
		
		/*public function testAutoAddToEnd(object:WallObject,xPos:Number):Boolean
		{
			//trace("testAutoAddToEnd groundObjects:"+_groundObjects);

			var x1:Number = xPos;
			if(isHead)
			{
				if(x1 > localEnd.x)return false;//剩余的空间不足以放置物体
				
				var gos:Array = [];
				var wos:Array = [];
				var x0:Number = xPos-object.width;
				
				if(object.y<GROUND_OBJECT_HEIGHT)//检测地柜区域
				{
					//trace("0");
					this.getHeadWallObject(x0,x1,this.tmpGroundObjects,gos);
				}
				
				if(object.y+object.height>WALL_OBJECT_HEIGHT)//检测吊柜区域
				{
					//trace("1");
					this.getHeadWallObject(x0,x1,this.tmpWallObjects,wos);
				}
				
				if(gos.length>0)//地柜位置被占用，将起始位置移到占用位置物体右则
				{
					//trace("2");
					var o:WallObject = gos[gos.length-1];
					xPos = o.x + object.width;
				}
				
				if(wos.length>0)//吊柜位置被占用，将起始位置移到占用位置物体右则
				{
					//trace("3");
					o = wos[wos.length-1];
					if(xPos-object.width < o.x)
					{
						xPos = o.x + object.width;
					}
				}
				
				//trace("testAutoAddToEnd2 groundObjects:"+_groundObjects);
				if(x1==xPos)
				{
					//trace("4");
					object.x = x1;
					return true;
				}
				
				//trace("5:"+xPos);
				return testAutoAddToEnd(object,xPos);
			}
			else
			{
				trace("功能末实现");
			}
			return true;
		}*/
		
		public function testAddObject(object:WallObject):Boolean
		{
			//trace("testAddObject");
			//if(object.y+object.height<IGNORE_OBJECT_HEIGHT)return true;//忽略的物体
			if(object.isIgnoreObject)//忽略的物体只作房间内判断
			{
				var x0:Number = wall.groundFrontHead.x;
				var x1:Number = wall.groundFrontEnd.x;
				return testObject(x0,x1,object);
			}
			return testAddObject2(object);
		}
		
		/**
		 * 检测物体是否在墙体的选择区域范围内
		 * @param object
		 * @return 
		 * 
		 */
		public function testInSelectArea(object:WallObject):Boolean
		{
			var a:Array = this.wall.selectorArea;
			if(!a)return false;
			
			for each(var wa:WallArea2D in a)
			{
				var vo:WallArea = wa.vo;
				if(vo.enable && object.x<vo.x1 && object.x-object.width>vo.x0)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 向当前选择的墙体区域中添加中高柜或高柜
		 * 
		 */
		public function addMiddleHeightCabinet(po:ProductObject):void
		{
			var wo:WallObject = po.objectInfo;
			var wa:WallArea = getSelectArea(wo.x-wo.width,wo.x);
			if(!wa)return;
			
			//当前物体的中心位置，位于选择区域的后半区域时
			if(wo.x-wo.width*0.5-wa.x0>wa.length*0.5)
			{
				wa.endCabinet = po;
				//trace("-----endCabinet");
			}
			else//当前物体的中心位置，位于选择区域的前半区域时
			{
				wa.headCabinet = po;
				//trace("-----headCabinet");
			}
		}
		
		/**
		 * 从当前选择的墙体区域中去掉中高柜或高柜
		 * 
		 */
		public function removeMiddleHeightCabinet(po:ProductObject):void
		{
			var wo:WallObject = po.objectInfo;
			var wa:WallArea = getSelectArea(wo.x-wo.width,wo.x);
			if(wa)
			{
				if(wa.endCabinet == po)
				{
					wa.endCabinet = null;
				}
				else if(wa.headCabinet == po)
				{
					wa.headCabinet = null;
				}
			}
		}
		
		private function getObject(x0:Number,x1:Number):WallObject
		{
			var a:Array = [];
			this._getGroundObjectOfPos(x0,x1,a,this.tmpGroundObjects);
			if(a.length>0)return a[0];
			return null;
		}
		
		/**
		 * 获取指定位置的物体
		 * @param xPos
		 * @return 
		 * 
		 */
		public function getGroundObject(xPos:Number):WallObject
		{
			return getObject(xPos,xPos);
		}
		
		/**
		 * 测试是否可以向当前选择的墙体区域中添加中高柜或高柜
		 * 
		 */
		public function testMiddleHeightCabinet(po:ProductObject):Boolean
		{
			var wo:WallObject = po.objectInfo;
			var wa:WallArea = getSelectArea(wo.x-wo.width,wo.x);
			if(!wa || !wa.enable)return false;
			
			//当前物体的中心位置，位于选择区域的后半区域时
			if(wo.x-wo.width*0.5-wa.x0>wa.length*0.5)
			{
				if(wa.endEnable && !wa.endCabinet)
				{
					var o:WallObject = getObject(wa.x1-1,wa.x1);//检测区域尾部是否有障碍物
					wo.x = o?o.x-o.width:wa.x1;
					if(testAvoidOfWindoor(wo))
					{
						//wa.endCabinet = po;
						return true;
					}
				}
				return false;
			}
			
			//else当前物体的中心位置，位于选择区域的前半区域时
			if(wa.headEnable && !wa.headCabinet)
			{
				o = getObject(wa.x0,wa.x0+1);//检测区域头部是否有障碍物
				wo.x = (o?o.x:wa.x0) + wo.width;
				if(testAvoidOfWindoor(wo))
				{
					//wa.headCabinet = po;
					return true;
				}
			}
			
			return false;
		}
		
		private function getSelectArea(x0:Number,x1:Number):WallArea
		{
			var a:Array = this.wall.selectorArea;
			if(!a)return null;
			
			for each(var wa:WallArea2D in a)
			{
				var vo:WallArea = wa.vo;
				if(vo.enable && MyMath.isGreaterEqual(x0,vo.x0) && MyMath.isLessEqual(x1,vo.x1))
				{
					return vo;
				}
			}
			return null;
		}
		
		/**
		 * 检测物体是否避让拐角柜区域
		 * @param wo
		 * @return 
		 * 
		 */
		public function isAvoidCornerArea(wo:WallObject):Boolean
		{
			var cornerAreaWidth:int = 620;
			
			if(wo.x>localEnd.x-cornerAreaWidth)//尾部区域
			{
				var tx0:Number = endCrossWall.localHead.x;
				var tx1:Number = tx0 + cornerAreaWidth;
				if(endCrossWall.isOverlapSelectArea(tx0,tx1))
				{
					return false;
				}
			}
			
			if(wo.x-wo.width < localHead.x+cornerAreaWidth)//柜首区域
			{
				tx1 = headCrossWall.localEnd.x;
				tx0 = tx1 - cornerAreaWidth;
				if(headCrossWall.isOverlapSelectArea(tx0,tx1))
				{
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * 指定区域与有效的选择区域是否有重叠
		 * 有任意重叠区域即返回true
		 */
		public function isOverlapSelectArea(x0:Number,x1:Number):Boolean
		{
			var a:Array = this.wall.selectorArea;
			if(!a)return false;
			
			for each(var wa:WallArea2D in a)
			{
				var vo:WallArea = wa.vo;
				if(vo.enable)
				{
					if(x1>vo.x0 && x0<vo.x1)
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		/**
		 * 检测物体是否避让墙洞
		 * @param wo
		 * @return 
		 * 
		 */
		public function testAvoidOfWindoor(wo:WallObject):Boolean
		{
			var windoors:Array = getWindoorObjects();
			var len:int = windoors.length;
			for(var i:int=0;i<len;i++)
			{
				var windoor:WallObject = windoors[i];
				if(wo.x>windoor.x-windoor.width && wo.x-wo.width<windoor.x)//物体左右侧与门有重叠
				{
					if(wo.y+wo.height>windoor.y)//物体上沿与门下沿有重叠，物体没有避让开门
					{
						return false;
					}
				}
			}
			return true;
		}
		
		private function getWindoorObjects():Array
		{
			var a:Array = [];
			var len:int = _wallObjects.length;
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = _wallObjects[i];
				if(wo.object is WallHole)
				{
					a.push(wo);
				}
			}
			return a;
		}
		
		public function testAddObject2(object:WallObject):Boolean
		{
			resetGroundObjects(object);
			
			var oldX:Number = object.x;
			var result:Boolean;
			
			if(isHead)//墙体正面
			{
				//trace("1");
				if(object.y<GROUND_OBJECT_HEIGHT && object.y+object.height>WALL_OBJECT_HEIGHT)//需要地面的墙上都要检查的情况
				{
					//trace("2");
					result = testAddObjectHead(object,tmpGroundObjects);//测试地面是否有空间放置
					if(result)
					{
						//trace("3");
						result = testAddObjectHead(object,tmpWallObjects);//地面有空间放置，还要测试新位置在墙面是否有空间放置
						if(result)
						{
							//trace("4");
							result = testAddObjectHead(object,tmpGroundObjects);//测试空间位置后，要重新测试地面是否有空间放置
						}
					}
				}
				else if(object.y<GROUND_OBJECT_HEIGHT)
				{
					//trace("5");
					result = testAddObjectHead(object,tmpGroundObjects);//测试地面是否有空间放置
				}
				else if(object.y+object.height>WALL_OBJECT_HEIGHT)
				{
					//trace("6");
					result = testAddObjectHead(object,tmpWallObjects);//测试墙面是否有空间放置
				}
			}
			else//墙体背面
			{
				if(object.y<GROUND_OBJECT_HEIGHT && object.y+object.height>WALL_OBJECT_HEIGHT)//需要地面的墙上都要检查的情况
				{
					result = testAddObjectEnd(object,tmpGroundObjects);//测试地面是否有空间放置
					if(result)
					{
						result = testAddObjectEnd(object,tmpWallObjects);//地面有空间放置，还要测试新位置在墙面是否有空间放置
						if(result)
						{
							result = testAddObjectEnd(object,tmpGroundObjects);//测试空间位置后，要重新测试地面是否有空间放置
						}
					}
				}
				else if(object.y<GROUND_OBJECT_HEIGHT)
				{
					result = testAddObjectEnd(object,tmpGroundObjects);//测试地面是否有空间放置
				}
				else if(object.y+object.height>WALL_OBJECT_HEIGHT)
				{
					result = testAddObjectEnd(object,tmpWallObjects);//测试墙面是否有空间放置
				}
			}
			
			return result;
		}
		
		private function testAddObjectHead(object:WallObject,objects:Array):Boolean
		{
			//trace("testAddObjectHead x:"+object.x+" y:"+object.y+" width:"+object.width+" height:"+object.height);
			var result:Boolean;
			var x0:Number = wall.groundFrontHead.x;
			var x1:Number = wall.groundFrontEnd.x;
			
			var len:int = objects.length;
			if(len==0)
			{
				//trace("1");
				result = testObject(x0,x1,object);
			}
			else
			{
				//trace("2");
				var t:WallObject = objects[0];
				result = testObject(x0,t.x-t.width,object);
				if(!result)
				{
					for(var i:int=1;i<len;i++)
					{
						var t2:WallObject = objects[i];
						result = testObject(t.x,t2.x-t2.width,object);
						if(result)//当找到合适位置时，结束循环
						{
							break;
						}
						t = t2;
					}
					if(!result)
					{
						result = testObject(t.x,x1,object);
					}
				}
			}
			
			
			return result;
		}
		
		public function testAddCabinet(object:WallObject):Boolean
		{
			//trace("--------testAddCabinet:",object,this.tmpGroundObjects);
			
			var result:Boolean = true;
			if(object.isIgnoreObject)return result;
			
			resetGroundObjects(object);
			
			if(MyMath.isEqual(object.y,IGNORE_OBJECT_HEIGHT))
			{
				result = testAddObjectHead(object,tmpGroundObjects);
			}
			
			if(result && object.y+object.height>GROUND_OBJECT_HEIGHT)
			{
				result = testAddObjectHead(object,tmpWallObjects);
			}
			
			return result;
		}
		
		/**
		 * 测试指定区域是否可以容纳特定的物体，并在此物体的中心点在指定范围内时，自动移动物体使其整体进入指定范围
		 * @param x0：指定区域开始位置
		 * @param x1：指定区域结束位置
		 * @param object：要测试的物体
		 * @return 返回是否可以容纳特定的物体，并自动移动
		 * 
		 */
		public function testObject3(x0:Number,x1:Number,object:WallObject):Boolean
		{
			//trace("testObject x0:"+x0+" x1:"+x1);
			var x:Number = object.x - object.width * 0.5;//计算物体中心位置
			if(x<x0 || x>x1)
			{
				//trace("物体中心位置不在计算区间中");
				return false;//
			}
			
			if(MyMath.isGreater(object.width,x1-x0))
			{
				//trace("区间位置不够容纳物体");
				return false;//
			}
			
			if(object.x>x1)object.x = x1;
			else if(object.x-object.width<x0)object.x = x0 + object.width;
			
			return true;
		}
		
		public function testObject(x0:Number,x1:Number,object:WallObject):Boolean
		{
			if(MyMath.isGreater(object.width,x1-x0))
			{
				//trace("区间位置不够容纳物体");
				return false;//
			}
			
			if(object.x<x0 || object.x-object.width>x1)//当前物体完全不在区域内
			{
				return false;
			}
			
			if(object.x>x1)object.x = x1;
			else if(object.x-object.width<x0)object.x = x0 + object.width;
			
			return true;
		}
		
		private function testAddObjectEnd(object:WallObject,objects:Array):Boolean
		{
			var result:Boolean;
			var x0:Number = wall.groundBackHead.x;
			var x1:Number = wall.groundBackEnd.x;
			trace("功能末实现");
			
			return result;
		}
		
		public function getMaterialJsonString2():String
		{
			var s:String = "{";
			s += "\"material\":\"" + _materialName + "\"";
			s += "}";
			return s;
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"isHead\":\"" + isHead + "\",";
			s += "\"index\":" + wall.index;
			s += "}";
			
			//trace("crossWall:"+s);
			return s;
		}
	}
}