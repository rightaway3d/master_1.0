package ztc.meshbuilder.room
{
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;

	/**
	 * Container 的数据类
	 */
	public class ContainerData
	{
		public var container:ObjectContainer3D;
		
		public var max:Vector3D;
		public var min:Vector3D;
		private var _max:Vector3D;
		private var _min:Vector3D;
		
		public var rectx:Rectangle;
		public var recty:Rectangle;
		public var rectz:Rectangle;
		
		public function ContainerData(container:ObjectContainer3D) {
			this.container = container;
			
			max = new Vector3D();
			min = new Vector3D();
			
			update();
		}
		
		public function update():void {
			_max = new Vector3D(container.maxX,container.maxY,container.maxZ);
			_min = new Vector3D(container.minX,container.minY,container.minZ);
			//trace("----");
			//trace("position:"+container.position);
			//trace("max1:"+_max+"min1:"+_min);
			_max = container.transform.transformVector(_max);
			_min = container.transform.transformVector(_min);
			//trace("max2:"+_max+"min2:"+_min);
			
			if (_max.x > _min.x) {
				max.x = _max.x;
				min.x = _min.x;
			} else {
				max.x = _min.x;
				min.x = _max.x;
			}
			
			if (_max.y > _min.y) {
				max.y = _max.y;
				min.y = _min.y;
			} else {
				max.y = _min.y;
				min.y = _max.y;
			}
			
			if (_max.z > _min.z) {
				max.z = _max.z;
				min.z = _min.z;
			} else {
				max.z = _min.z;
				min.z = _max.z;
			}
			//trace("max3:"+max+"min3:"+min);
			
//			rectx = new Rectangle(min.z,max.y,max.z - min.z,max.y - min.y);
//			recty = new Rectangle(min.x,max.z,max.x - min.x,max.z - min.z);
//			rectz = new Rectangle(min.x,max.y,max.x - min.x,max.y - min.y);
			
			rectx = new Rectangle(min.z,min.y,max.z - min.z,max.y - min.y);
			recty = new Rectangle(min.x,min.z,max.x - min.x,max.z - min.z);
			rectz = new Rectangle(min.x,min.y,max.x - min.x,max.y - min.y);
			
			//trace("rectx:"+rectx);
			//trace("recty:"+recty);
			//trace("rectz:"+rectz);
		}
	}
}