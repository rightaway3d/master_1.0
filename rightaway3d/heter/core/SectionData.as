package rightaway3d.heter.core
{
	import flash.geom.Vector3D;

	public class SectionData
	{
		
		public var startAngle:Number;
		public var endAngle:Number;
		public var startVector:Vector3D;
		public var endVector:Vector3D;
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		public var angle:Number = 0;
		public var sectionVector:Vector.<Vector3D>;
		
		
		public function SectionData(vectors:Vector.<Vector3D>)
		{
			
			if(vectors.length<2)
			{
				throw(new Error("截面是一个点，无法创建截面"))
			}
			sectionVector = vectors;
			startVector = sectionVector[0];
			endVector = sectionVector[1];
			
			x = startVector.x;
			y = startVector.y;
			z = startVector.z;
				
			
		}
		
		
	}
}