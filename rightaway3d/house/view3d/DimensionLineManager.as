package rightaway3d.house.view3d
{
	
	/**
	 * 传入数组 DimensionLineManager.instance.update([-400,0,200*Math.random()+100,400,500]);
	 * 释放所有mesh DimensionLineManager.dispose();
 
	 */
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;

	public class DimensionLineManager
	{
		public var wallY:int=0;
		public var wallZ:int = 0;
		public var parent:ObjectContainer3D;
		private static var _instance:DimensionLineManager = null;
		private var created:Boolean = false;
		private	var oldlen:int =-1;
		private var lines:Array = [];

		public function DimensionLineManager()
		{
		}
		public static function get instance():DimensionLineManager
		{
			if(!_instance) _instance = new DimensionLineManager();
			return _instance;
		}

		public function update(points:Array):void
		{
			var i:uint;
			var len:uint = points.length;
			if(len ==oldlen)
			{
				created = false;
				
			}else
			{
				created = true;
			}
			if(created)
			{
				lines=[];
				var childnum:int = parent.numChildren;
				for (var j:int = 0; j < childnum; j++) 
				{
					parent.getChildAt(0).dispose();
				}
				
				for ( i = 0; i < len-1; i++) 
				{
					lines.push(createLine(xyzToVector3D(points[i]),xyzToVector3D(points[i+1])));
				}

			}else
			{
				for ( i = 0; i < len-1; i++) 
				{
					lines[i].update(xyzToVector3D(points[i]),xyzToVector3D(points[i+1]));
				}
			}
			oldlen = len;		
		}
		
		private function xyzToVector3D(p:int):Vector3D
		{
			return new Vector3D(p,wallY,wallZ);
		}
		
		private function createLine(start:Vector3D,end:Vector3D):DimensionLine
		{
			var line:DimensionLine = new DimensionLine();
			line.createDimension(start,end);
			parent.addChild(line);
			line.y= wallY;
			line.z = wallZ;
			return line;
		}
		
		public static function dispose():void
		{
			while(instance.parent.numChildren>0)
			{	
				instance.parent.getChildAt(0).dispose();
			}
			instance.oldlen = -1;
			instance.created = false;
			instance.lines = [];
		}
	}
}