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
	public class DragObject2
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
		
		public function DragObject2(view:View3D=null)
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
			ray = getScreenToWorldRay(_view);
			
			// 得到当前Pick的物体
			picked = rayCastPicker.getSceneCollision(_view.camera.position,ray.dir,_view.scene);
			
			if (picked != null) {
				// 得到拾取对象的组
				pickedContainer = getPickedContainer();
				// 确定位置
				planePoint = pickedContainer.position;
				lastMousePlanePos = mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
				
				deltaPos = pickedContainer.position.subtract(mousePlanePos);
			}
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
		}
		
		public function draging():void
		{
			// get ray and mouse plane position every frame
			ray = getScreenToWorldRay(_view);
			mousePlanePos = getLinePlaneIntersection(planePoint,planeNormal,ray);
			
			_dir = mousePlanePos.subtract(lastMousePlanePos);
			lastMousePlanePos = mousePlanePos;
			
			var _to:Vector3D = new Vector3D();
			
			// new position
			var to:Vector3D = mousePlanePos.add(deltaPos);
			realTo = to;
			
			// Moving works
			_to = movingWorks(to);
			
			// set position
			pickedContainer.position = _to;
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
		
		protected function onMouseMove(event:MouseEvent):void
		{
			if (isMouseDown && picked != null) {
				draging();
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			// 标识鼠标未按下
			isMouseDown = false;	
			picked = null;
		}
		
		/**
		 * 拖动中的吸附与避让
		 */
		public function movingWorks(to:Vector3D):Vector3D {
			//trace("------------movingWorks");
			var toDir:Vector3D= to.subtract(pickedContainer.position);
			
			// 移动物体的 ContainerData
			var cd:ContainerData = new ContainerData(pickedContainer);
			
			// 每一个与之比较的ContainerData
			var rcd:ContainerData;
			var minXDis:Number = Infinity ,minYDis:Number = Infinity ,minZDis:Number = Infinity ;
			// 与其它的 avoidList 中的元素比较
			for each (var i:ObjectContainer3D in avoidList) {
				// 排除自身
				if (i != pickedContainer) {
					rcd = new ContainerData(i);
					
					// X
					if (toDir.x > 0) {
						if (cd.max.x < rcd.min.x && 
							(cd.max.x  + toDir.x) > rcd.min.x &&
							cd.rectx.intersects(rcd.rectx)) {
							if ((rcd.min.x - cd.max.x) < minXDis) {
								to.x = pickedContainer.x + rcd.min.x - cd.max.x - space;
								minXDis = rcd.min.x - cd.max.x;
							}
						} 
					} else if (toDir.x < 0) {
						if (cd.min.x > rcd.max.x &&
							(cd.min.x + toDir.x) < rcd.max.x &&
							cd.rectx.intersects(rcd.rectx)) {
							if ((cd.min.x - rcd.max.x) < minXDis) {
								to.x = pickedContainer.x + rcd.max.x - cd.min.x + space;
								minXDis = cd.min.x - rcd.max.x;
							}
						}
					} 
					//to = adsorbAxis(cd,rcd,1,to);
					
					// Y
					if (toDir.y > 0) {
						if (cd.max.y < rcd.min.y &&
							cd.max.y + toDir.y > rcd.min.y && 
							cd.recty.intersects(rcd.recty)) {
							if ((rcd.min.y - cd.max.y) < minYDis) {
								to.y = pickedContainer.y + toDir.y - cd.max.y - space;
								minYDis = rcd.min.y - cd.max.y;
							}
						}
					} else if (toDir.y < 0) {
						if (cd.min.y > rcd.max.y && 
							cd.min.y + toDir.y < rcd.max.y && 
							cd.recty.intersects(rcd.recty)) {
							if ((cd.min.y - rcd.max.y) < minYDis) {
								to.y = pickedContainer.y + toDir.y - cd.min.y + space;
								minYDis = cd.min.y - rcd.max.y;
							}
							
						}
					}
					to = adsorbAxis(cd,rcd,2,to);
					
					// Z
					if (toDir.z > 0) {
						if (cd.max.z < rcd.min.z && 
							cd.max.z + toDir.z > rcd.min.z && 
							cd.rectz.intersects(rcd.rectz)) {
							if ((rcd.min.z - cd.max.z) < minZDis) {
								to.z = pickedContainer.z + rcd.min.z - cd.max.z - space;
								minZDis = rcd.min.z - cd.max.z;
							}
						}
					} else if (toDir.z < 0) {
						if (cd.min.z  > rcd.max.z && 
							cd.min.z + toDir.z < rcd.max.z && 
							cd.rectz.intersects(rcd.rectz)) {
							if ((cd.min.z - rcd.max.z) < minZDis) {
								to.z = pickedContainer.z + rcd.max.z - cd.min.z + space;
								minZDis = cd.min.z - rcd.max.z;
							}
						}
					} 
					//to = adsorbAxis(cd,rcd,3,to);
				}
			}
			
			return to;
		}		
		/**
		 * 轴向的吸附
		 */
		public function adsorbAxis(cd:ContainerData,rcd:ContainerData,axis:uint,to:Vector3D):Vector3D {
			var a:Number,b:Number,c:Number,d:Number,min:Number,index:uint = 0;
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
						switch(index)
						{
							case 0:
							{
								to.x = pickedContainer.x + rcd.max.x - cd.max.x;
								break;
							}
							case 1:
							{
								to.x = pickedContainer.x + rcd.max.x - cd.min.x + space;	
								break;
							}
							case 2:
							{
								to.x = pickedContainer.x + rcd.min.x - cd.max.x - space
								break;
							}
							case 3:
							{
								to.x = pickedContainer.x + rcd.min.x - cd.min.x;
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
						switch(index)
						{
							case 0:
							{
								to.y = pickedContainer.y + rcd.max.y - cd.max.y;
								break;
							}
							case 1:
							{
								to.y = pickedContainer.y + rcd.max.y - cd.min.y + space;	
								break;
							}
							case 2:
							{
								to.y = pickedContainer.y + rcd.min.y - cd.max.y - space
								break;
							}
							case 3:
							{
								to.y = pickedContainer.y + rcd.min.y - cd.min.y;
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
						switch(index)
						{
							case 0:
							{
								to.z = pickedContainer.z + rcd.max.z - cd.max.z;
								break;
							}
							case 1:
							{
								to.z = pickedContainer.z + rcd.max.z - cd.min.z + space;	
								break;
							}
							case 2:
							{
								to.z = pickedContainer.z + rcd.min.z - cd.max.z - space
								break;
							}
							case 3:
							{
								to.z = pickedContainer.z + rcd.min.z - cd.min.z;
								break;
							}
						}
					}				
					
					break;
				}
			}
			
			return to;
		}
		
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
		protected function getScreenToWorldRay(view:View3D):Ray {
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