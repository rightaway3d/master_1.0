package rightaway3d.house.utils
{
	public final class Point3D
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		
		public function Point3D(x_:Number=0,y_:Number=0,z_:Number=0)
		{
			x = x_;
			y = y_;
			z = z_;
		}
		
		public function clone():Point3D
		{
			return new Point3D(x,y,z);
		}
		
		public function toString():String
		{
			var s:String = "";
			s += "[x="+x;
			s += ",y="+y;
			s += ",z="+z+"]";
			return s;
		}
		
		static public function dist(p1:Point3D,p2:Point3D):Number
		{
			var dx:int = p2.x - p1.x;
			var dy:int = p2.y - p1.y;
			var dz:int = p2.z - p1.z;
			return Math.sqrt(dx*dx+dy*dy+dz*dz);
		}
	}
}