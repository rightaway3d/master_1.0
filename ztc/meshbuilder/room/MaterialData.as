package ztc.meshbuilder.room
{
	import away3d.materials.TextureMaterial;

	public class MaterialData
	{
		public var material:TextureMaterial;
		public var scaleU:Number;
		public var scaleV:Number;
		public var tileWidth:int;
		public var tileHeight:int;
		public var grid9Scale:Boolean;
		
		public function MaterialData(mat:TextureMaterial,su:Number,sv:Number,tw:int,th:int,grid9:Boolean)
		{
			material = mat;
			scaleU = su;
			scaleV = sv;
			tileWidth = tw;
			tileHeight = th;
			grid9Scale = grid9;
		}
	}
}