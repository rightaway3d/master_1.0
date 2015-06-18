package ztc.meshbuilder.room
{
	import flash.geom.Matrix3D;
	
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.lightpickers.StaticLightPicker;

	public class Window extends MeshObject
	{
		// Stick Width
		public var stickWidth:Number;
		
		// Type	
		public static var NORMAL:String = "normal";
		public static var PUSH:String = "push";
		
		public var type:String = Window.PUSH;
		
		// materials
		public var frameMat:MaterialBase = null;
		public var glassMat:MaterialBase = null;
		
		// creater
		private var creater:HouseMeshCreator;
		
		public function Window(width:Number = 250,
							   height:Number = 150,
							   depth:Number = 10,
							   frameWidth:Number = 10,
							   stickWidth:Number = 8)
		{
			super();
			this.width = width;
			this.height = height;
			this.depth = depth;
			this.frameWidth = frameWidth;
			this.stickWidth = stickWidth;
			
			creater = new HouseMeshCreator(width,height,depth,frameWidth,stickWidth);
			
			update();
		}
		
		override public function update():void {
			// 记录之前的位置及角度
			var _transform:Matrix3D = mesh ? mesh.transform : new Matrix3D();
			
			switch(type)
			{
				case Window.NORMAL:
				{
					mesh = creater.getNormalWindowMesh(frameMat,glassMat);
					break;
				}
				case Window.PUSH:
				{
					mesh = creater.getPushWindowMesh(frameMat,glassMat);
					break;
				}
			}
			
			// 设置变换
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