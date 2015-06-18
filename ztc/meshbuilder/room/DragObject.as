package ztc.meshbuilder.room
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.core.pick.PickingType;
	import away3d.core.pick.RaycastPicker;
	import away3d.tools.utils.Ray;

	/**
	 * 3D 视图中的拖拽功能类
	 */
	public class DragObject
	{
		// View 物体
		private var _view:View3D;
		
		// Picking
		public var rayCastPicker:RaycastPicker;
		public var lastPicked:PickingCollisionVO;
		public var picked:PickingCollisionVO;
		public var pickedContainer:ObjectContainer3D;
		
		private var mousePlanePos:Vector3D,lastMousePlanePos:Vector3D;
		private var deltaPos:Vector3D;
		private var _dir:Vector3D;
		
		// drag plane
		public var planePoint:Vector3D;
		public var planeNormal:Vector3D = new Vector3D(0,1,0);
		
		// Mouse state
		private var isMouseDown:Boolean = false;
		private var dir:Vector3D;
		
		// Ray
		private var ray:Ray;
		
		// container data
		private var cd:ContainerData;
		
		// 保留的间隙
		public static var space:Number = 1;
		// 吸附距离
		public static var adsorbDis:Number = 100;
		public var realTo:Vector3D;
		
		// 吸附与避让的 ObjectContainer3D 集合
		public var avoidList:Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>();
		public var containerList:Vector.<ContainerData> = new Vector.<ContainerData>();
		
		public function DragObject(view:View3D=null)
		{
			rayCastPicker = new RaycastPicker(false);
			
			if(view)
			{
				this.view = view;
			}
		}
		
		public function set view(view:View3D):void
		{
			this._view = view;
			this._view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			
			// events
			this._view.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this._view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this._view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		public function get view():View3D
		{
			return this._view;
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			// 标识鼠标已经按下
			isMouseDown = true;
			
			// 得到射线
			ray = getScreenToWorldRay(view);
			
			// 得到当前Pick的物体
			picked = rayCastPicker.getSceneCollision(view.camera.position,ray.dir,view.scene);
			
			if (picked != null) {
				// 得到拾取对象的组
				pickedContainer = getPickedContainer();
				
				// 确定位置
				planePoint = pickedContainer.position;
				lastMousePlanePos = mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
				
				deltaPos = pickedContainer.position.subtract(mousePlanePos);
				
				// 记录 ContainerData
				containerList.length = 0;
				for each (var i:ObjectContainer3D in avoidList) 
				{
					if (pickedContainer != i)
						containerList.push(new ContainerData(i));
				}
			}
		}
		
		public function getPickedObject3D(view_:View3D):PickingCollisionVO
		{
			var ray:Ray = getScreenToWorldRay(view_);
			
			// 得到当前Pick的物体
			var picked:PickingCollisionVO = rayCastPicker.getSceneCollision(view_.camera.position,ray.dir,view_.scene);
			
			return picked;
		}
		
		public function getMouse3DPos(view:View3D,yPos:Number):Vector3D
		{
			var r:Ray = getScreenToWorldRay(view);
			return getLinePlaneIntersection(new Vector3D(0,yPos,0),planeNormal,r);
		}
		
		public function initDrag(container:ObjectContainer3D,view:View3D):void
		{
			_view = view;
			ray = getScreenToWorldRay(view);
			
			pickedContainer = container;
			
			// 确定位置
			planePoint = pickedContainer.position;
			lastMousePlanePos = mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
			
			deltaPos = pickedContainer.position.subtract(mousePlanePos);
			
			// 记录 ContainerData
			containerList.length = 0;
			for each (var i:ObjectContainer3D in avoidList) 
			{
				if (pickedContainer != i)
					containerList.push(new ContainerData(i));
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			if (isMouseDown && picked != null) {
				// set position
				pickedContainer.position = draging(draging2());
			}
		}
		
		
		public function draging(to:Vector3D):Vector3D
		{
			//trace("draging");
			// get ray and mouse plane position every frame
			/*ray = getScreenToWorldRay(view);
			mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
			
			_dir = mousePlanePos.subtract(lastMousePlanePos);
			lastMousePlanePos = mousePlanePos;
			
			// new position
			var to:Vector3D = mousePlanePos.add(deltaPos);*/
			
			realTo = to.clone();
			
			var _to:Vector3D = new Vector3D();
			
			// Moving works
			_to = movingWorks(to);
			
			// adsorb works
			_to = adsorbWorks(_to);
			
			return _to;
		}
		
		public function draging2():Vector3D
		{
			// get ray and mouse plane position every frame
			ray = getScreenToWorldRay(_view);
			mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
			
			_dir = mousePlanePos.subtract(lastMousePlanePos);
			lastMousePlanePos = mousePlanePos;
			
			var to:Vector3D = mousePlanePos.add(deltaPos);
			//pickedContainer.position = to;
			
			return to;
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			// 标识鼠标未按下
			isMouseDown = false;	
			picked = null;
		}
		
		/**
		 * 拖动中的避让
		 */
		private var zux:int,zuy:int,zuz:int;  // X,Y,Z 轴是否阻挡了  1为正 -1 为负 0 为没有阻挡
		public function movingWorks(to:Vector3D):Vector3D {
			var toDir:Vector3D= to.subtract(pickedContainer.position);
			
			// 移动物体的 ContainerData
			var cd:ContainerData = new ContainerData(pickedContainer);
			
			// 每一个与之比较的ContainerData
			var rcd:ContainerData;
			
			var k:Vector3D;
			kaox = 10000,kaoy = 10000,kaoz = 10000;
			var minXDis:Number = 10000,minYDis:Number = 10000,minZDis:Number = 10000;
			
			var zudang:Vector3D = to.clone();
			zux = zuy = zuz = 0;
			// 与其它的 avoidList 中的元素比较
			for each (rcd in containerList) {
				//rcd = new ContainerData(i);
				// 排除自身
				//if (rcd.container != pickedContainer) {
					// X
//					k = adsorbAxis(cd,rcd,1,to);
//					if (_minx < kaox) {
//						kaox = _minx;
//						to.x = k.x;
//					}
					
					if (toDir.x > 0) {
						if (cd.max.x < rcd.min.x && 
							(cd.max.x  + toDir.x) > rcd.min.x &&
							cd.rectx.intersects(rcd.rectx)) {
							if ((rcd.min.x - cd.max.x) < minXDis) {
								zudang.x = pickedContainer.x + rcd.min.x - cd.max.x - space;
								minXDis = rcd.min.x - cd.max.x;
								zux = 1;
							}
						} 
					} else if (toDir.x < 0) {
						if (cd.min.x > rcd.max.x &&
							(cd.min.x + toDir.x) < rcd.max.x &&
							cd.rectx.intersects(rcd.rectx)) {
							if ((cd.min.x - rcd.max.x) < minXDis) {
								zudang.x = pickedContainer.x + rcd.max.x - cd.min.x + space;
								minXDis = cd.min.x - rcd.max.x;
								zux = -1;
							}
						}
					} 
					
					
					// Y
//					k = adsorbAxis(cd,rcd,2,to);
//					if (_miny < kaoy) {
//						kaoy = _miny;
//						to.y = k.y;
//					}
					if (toDir.y > 0) {
						if (cd.max.y < rcd.min.y &&
							cd.max.y + toDir.y > rcd.min.y && 
							cd.recty.intersects(rcd.recty)) {
							if ((rcd.min.y - cd.max.y) < minYDis) {
								zudang.y = pickedContainer.y + toDir.y - cd.max.y - space;
								minYDis = rcd.min.y - cd.max.y;
								zuy = 1;
							}
						}
					} else if (toDir.y < 0) {
						if (cd.min.y > rcd.max.y && 
							cd.min.y + toDir.y < rcd.max.y && 
							cd.recty.intersects(rcd.recty)) {
							if ((cd.min.y - rcd.max.y) < minYDis) {
								zudang.y = pickedContainer.y + toDir.y - cd.min.y + space;
								minYDis = cd.min.y - rcd.max.y;
								zuy = -1;
							}
							
						}
					}
					//to = adsorbAxis(cd,rcd,2,to,zuy);
					
					// Z
//					k = adsorbAxis(cd,rcd,3,to);
//					if (_minz < kaoz) {
//						kaoz = _minz;
//						to.z = k.z;
//					}
					if (toDir.z > 0) {
						if (cd.max.z < rcd.min.z && 
							cd.max.z + toDir.z > rcd.min.z && 
							cd.rectz.intersects(rcd.rectz)) {
							if ((rcd.min.z - cd.max.z) < minZDis) {
								zudang.z = pickedContainer.z + rcd.min.z - cd.max.z - space;
								minZDis = rcd.min.z - cd.max.z;
								zuz = 1;
							}
						}
					} else if (toDir.z < 0) {
						if (cd.min.z  > rcd.max.z && 
							cd.min.z + toDir.z < rcd.max.z && 
							cd.rectz.intersects(rcd.rectz)) {
							if ((cd.min.z - rcd.max.z) < minZDis) {
								zudang.z = pickedContainer.z + rcd.max.z - cd.min.z + space;
								minZDis = cd.min.z - rcd.max.z;
								zuz = -1;
							}
						}
					} 
					//to = adsorbAxis(cd,rcd,3,to);
				//}
			}
			
			return zudang;
		}

		/**
		 * 拖动中的吸附
		 */
		public function adsorbWorks(to:Vector3D):Vector3D {
			var res:Vector3D = to.clone();
			
			var cd:ContainerData = new ContainerData(pickedContainer);
			var rcd:ContainerData;
			
			var deltax:Number = to.x - pickedContainer.x;
			var deltay:Number = to.y - pickedContainer.y;
			var deltaz:Number = to.z - pickedContainer.z;
			var _x:Number,_y:Number,_z:Number;
			var _minx:Number = 10000,_miny:Number = 10000,_minz:Number = 10000,min:Number;
			var lx:Number,ly:Number,lz:Number;
			var a:Number,b:Number,c:Number,d:Number;
			
			// 循环比较
			for each (rcd in containerList) 
			{
				// x
				a = rcd.max.x - cd.max.x - deltax;
				min = Math.abs(a); lx = a;
				b = rcd.min.x - cd.max.x - space - deltax;
				if (Math.abs(b) < min) {min = Math.abs(b); lx = b;}
				c = rcd.max.x - cd.min.x + space - deltax;
				if (Math.abs(c) < min) {min = Math.abs(c); lx = c;}
				d = rcd.min.x - cd.min.x - deltax;
				if (Math.abs(d) < min) {min = Math.abs(d); lx = d;}
				
				if (min < adsorbDis && min < _minx) {
					_minx = min;
					_x = lx;
				}
				
				// y
				a = rcd.max.y - cd.max.y - deltay;
				min = Math.abs(a) ; ly = a;
				b = rcd.min.y - cd.max.y - space - deltay;
				if (Math.abs(b) < min) {min = Math.abs(b); ly = b;}
				c = rcd.max.y - cd.min.y + space - deltay;
				if (Math.abs(c) < min) {min = Math.abs(c); ly = c;}
				d = rcd.min.y - cd.min.y - deltay;
				if (Math.abs(d) < min) {min = Math.abs(d); ly = d;}
				
				if (min < adsorbDis && min < _miny) {
					_miny = min;
					_y = ly;
				}
				
				// z
				a = rcd.max.z - cd.max.z - deltaz;
				min = Math.abs(a) ; lz = a;
				b = rcd.min.z - cd.max.z - space - deltaz;
				if (Math.abs(b) < min) {min = Math.abs(b); lz = b;}
				c = rcd.max.z - cd.min.z + space - deltaz;
				if (Math.abs(c) < min) {min = Math.abs(c); lz = c;}
				d = rcd.min.z - cd.min.z - deltaz;
				if (Math.abs(d) < min) {min = Math.abs(d); lz = d;}
				
				if (min < adsorbDis && min < _minz) {
					_minz = min;
					_z = lz;
				}
			}
			
			if(_minx != 10000) {
				if (_x * zux <= 0) {
					res.x = to.x + _x;
				}
			}
			
			if(_miny != 10000) {
				if (_y * zuy <= 0) {
					res.y = to.y + _y;
				}
			}
			
			if(_minz != 10000) {
				if (_z * zuz <= 0) {
					res.z = to.z + _z;
				}
			}
			
			return res;
		}
		
		/**
		 * 轴向的吸附
		 */
		
		private var kaox:Number = 10000,kaoy:Number = 10000,kaoz:Number = 10000;
//		private var _minx:Number,_miny:Number,_minz:Number;
		private var _tox:Number,_toy:Number,_toz:Number;
		
		/*
		public function adsorbAxis(cd:ContainerData,rcd:ContainerData,axis:uint,to:Vector3D):Vector3D {
			var a:Number,b:Number,c:Number,d:Number,min:Number,index:uint = 0;
			var res:Vector3D = to.clone();
			switch(axis)
			{
				case 1: {  // X
					var _x:Number = realTo.x - pickedContainer.x;
					a = Math.abs(rcd.max.x - cd.max.x - _x);
					min = a;
					b = Math.abs(rcd.max.x - cd.min.x - _x);
					if (b < min) {min = b ; index = 1;};
					c = Math.abs(rcd.min.x - cd.max.x - _x);
					if (c < min) {min = c ; index = 2;};
					d = Math.abs(rcd.min.x - cd.min.x - _x);
					if (d < min) {min = d ; index = 3};
					
					if (min < adsorbDis) {
						_minx = min + _x;
						trace("index : " + index + " min: " + _minx + " kaox:" + kaox);
						trace("a: " + a,"b: " + b,"c: " + c,"d: " + d);
						switch(index)
						{
							case 0:
							{
								res.x = pickedContainer.x + rcd.max.x - cd.max.x;
								break;
							}
							case 1:
							{
								res.x = pickedContainer.x + rcd.max.x - cd.min.x + space;	
								break;
							}
							case 2:
							{
								res.x = pickedContainer.x + rcd.min.x - cd.max.x - space
								break;
							}
							case 3:
							{
								res.x = pickedContainer.x + rcd.min.x - cd.min.x;
								break;
							}
						}
					}		
					
					break;
				}
				case 2: {  // Y
					var _y:Number = realTo.y - pickedContainer.y;
					a = Math.abs(rcd.max.y - cd.max.y - _y);
					min = a;
					b = Math.abs(rcd.max.y - cd.min.y - _y);
					if (b < min) {min = b ; index = 1;};
					c = Math.abs(rcd.min.y - cd.max.y - _y);
					if (c < min) {min = c ; index = 2;};
					d = Math.abs(rcd.min.y - cd.min.y - _y);
					if (d < min) {min = d ; index = 3};
					
					if (min < adsorbDis) {
						_miny = min;
						switch(index)
						{
							case 0:
							{
								res.y = pickedContainer.y + rcd.max.y - cd.max.y;
								break;
							}
							case 1:
							{
								res.y = pickedContainer.y + rcd.max.y - cd.min.y + space;	
								break;
							}
							case 2:
							{
								res.y = pickedContainer.y + rcd.min.y - cd.max.y - space
								break;
							}
							case 3:
							{
								res.y = pickedContainer.y + rcd.min.y - cd.min.y;
								break;
							}
						}
					}				
					
					break;
				}
				case 3: {  //  Z
					var _z:Number = realTo.z - pickedContainer.z;
					a = Math.abs(rcd.max.z - cd.max.z - _z);
					min = a;
					b = Math.abs(rcd.max.z - cd.min.z - _z);
					if (b < min) {min = b ; index = 1;};
					c = Math.abs(rcd.min.z - cd.max.z - _z);
					if (c < min) {min = c ; index = 2;};
					d = Math.abs(rcd.min.z - cd.min.z - _z);
					if (d < min) {min = d ; index = 3};
					
					if (min < adsorbDis) {
						_minz = min + _z;
						switch(index)
						{
							case 0:
							{
								res.z = pickedContainer.z + rcd.max.z - cd.max.z;
								break;
							}
							case 1:
							{
								res.z = pickedContainer.z + rcd.max.z - cd.min.z + space;	
								break;
							}
							case 2:
							{
								res.z = pickedContainer.z + rcd.min.z - cd.max.z - space
								break;
							}
							case 3:
							{
								res.z = pickedContainer.z + rcd.min.z - cd.min.z;
								break;
							}
						}
					}				
					
					break;
				}
			}
			
			return res;
		}
		*/
		
		
		/**
		 * 得到当然拾取的物体的顶级Container
		 * :: 需要自定义,得到真正的顶级Container
		 */
		private function getPickedContainer():ObjectContainer3D {
			return picked.entity.parent;
		}
		
		/**
		 * 得到ObjectContainer3D的中心点
		 */
		public function getCenter(container:ObjectContainer3D):Vector3D {
			return new Vector3D(
				(container.maxX + container.minX) / 2,
				(container.maxY + container.minY) / 2,
				(container.maxZ + container.minZ) / 2
			).add(container.position);
		}
		
		
		/**
		 * 得到当前鼠标位置射向场景中的射线
		 */
		public function getScreenToWorldRay(view:View3D):Ray {
			var _x:Number = (view.mouseX - view.width / 2) / (view.width / 2);
			var _y:Number = (view.mouseY - view.height / 2) / (view.height / 2);
			
			var _dir:Vector3D = view.camera.getRay(_x,_y,view.camera.lens.near);
			_dir.normalize();
			
			var ray:Ray = new Ray();
			ray.dir = _dir;
			ray.orig = view.camera.position;
			
			return ray;
		}
		
		/**
		 * 计算射线与平面的交点
		 */
		protected function getLinePlaneIntersection(planePos:Vector3D,planeNormal:Vector3D,ray:Ray):Vector3D {
			var p0:Vector3D = ray.orig;
			var p1:Vector3D = ray.orig.add(ray.dir);
			
			var f:Number = planePos.subtract(p0).dotProduct(planeNormal) / ray.dir.dotProduct(planeNormal);
			var len:Vector3D = ray.dir.clone();
			len.scaleBy(f);
			
			return p0.add(len);
		}
	}
}