package ztc.meshbuilder.room
{
	import flash.geom.Matrix3D;
	
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.lightpickers.StaticLightPicker;

	public class Door extends MeshObject
	{
		// Mesh
		//public var mesh:Mesh;
		
		// material
		public var frameMat:MaterialBase = null;
		
		// creater
		private var creater:HouseMeshCreator;
		
		public function Door(width:Number = 250,
							   height:Number = 150,
							   depth:Number = 10,
							   frameWidth:Number = 10)
		{
			super();
			this.width = width;
			this.height = height;
			this.depth = depth;
			this.frameWidth = frameWidth;
			
			creater = new HouseMeshCreator(width,height,depth,frameWidth);
			
			update();
		}
		
		override public function update():void {
			// 记录之前的位置及角度
			var _transform:Matrix3D = mesh ? mesh.transform : new Matrix3D();
			mesh = creater.getNormalDoorMesh(frameMat);
			mesh.transform = _transform;
		}
		
		/**
		 * 为Material设置LightPicker
		 */
		override public function setLightPicker(lp:StaticLightPicker):void {
			for each (var sb:SubMesh in mesh.subMeshes) 
			{
				sb.material.lightPicker = lp;
			}
		}
	}
}