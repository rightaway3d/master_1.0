package rightaway3d.house.utils
{
	import flash.geom.Point;

	public final class Vertex
	{
		public var index:int;
		public var point:Point;
		
		public function Vertex()
		{
		}
		
		public function toString():String
		{
			return "index["+index+"]";
			//return "index["+index+"] point:"+point;
		}
	}
}