package rightaway3d.engine.model
{
	import flash.geom.Vector3D;

	public class MirrorInfo
	{
		public var radius:Number;
		public var side:uint;
		public var position:Vector3D;
		public var rotation:Vector3D;
		public var scaleX:Number;
		public var scaleY:Number;
		public var alpha:Number;
		
		public function MirrorInfo(xml:XML)
		{
			this.radius = xml.radius;
			this.side = xml.side;
			this.alpha = xml.alpha;
			
			var s:String = xml.position;
			var a:Array = s.split(",");
			this.position = new Vector3D(a[0],a[1],a[2]);
			
			s = xml.rotation;
			a = s.split(",");
			this.rotation = new Vector3D(a[0],a[1],a[2]);
			
			s = xml.scale;
			a = s.split(",");
			this.scaleX = a[0];
			this.scaleY = a[1];
		}
	}
}