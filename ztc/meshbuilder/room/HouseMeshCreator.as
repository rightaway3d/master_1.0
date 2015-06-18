package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	
	/**
	 * 用于创建
	 */
	public class HouseMeshCreator extends MeshObject
	{
		public var stickWidth:Number;
		public var geo:Geometry;
		//public var mesh:Mesh;
		public var mat:ColorMaterial;
		public var glassMat:ColorMaterial;
		public var doorFrameMat:ColorMaterial;
		public var doorMat:ColorMaterial;
		
		// glass subGeometry
		public var glassMaterials:Vector.<MaterialBase>;
		
		public function HouseMeshCreator(width:Number = 250,
										 height:Number = 180,
										 depth:Number = 14,
										 frameWidth:Number = 16,
										 stickWidth:Number = 10)
		{
			super();
			this.width = width;
			this.height = height;
			this.depth = depth;
			this.frameWidth = frameWidth;
			this.stickWidth = stickWidth;
			
			// init geo
			geo = new Geometry();
			
			// create Frame material
			mat = new ColorMaterial(0xDDDDDD);
			mat.ambient = 3;
			mat.specular = 0.5;
			
			// cresate glass material
			glassMat = new ColorMaterial(0x001111,0.15);
			glassMat.specular = 1;
			
			
			doorFrameMat = new ColorMaterial(0xD0BB9F);
			doorFrameMat.specular = 0;
			//doorFrameMat.gloss = 0;
			doorFrameMat.ambient = 0.3;
			doorMat = new ColorMaterial(0xD9C9B3);
			doorMat.specular = 0;
			//doorMat.gloss = 0;
			doorMat.ambient = 0.3;
		}
		
		/**
		 * 创建普通窗Mesh的方法
		 */
		public function getNormalWindowMesh(frameMat:MaterialBase = null,glassMat:MaterialBase = null):Mesh {
			geo = new Geometry();
			// 创建外框
			var data:* = frameBuilder(width,height,depth,frameWidth);
			
			geo.addSubGeometry(getSubGeometry(data));
			
			// 创建坚框
			var dataStick:* = StickBuilder(new Vector3D(width / 2,-height + frameWidth,0),
								new Vector3D(width / 2,-frameWidth,0),
								stickWidth,stickWidth);
			
			geo.addSubGeometry(getSubGeometry(dataStick));
			
			// 创建玻璃
			var glassData:* = StickBuilder(new Vector3D(width / 2,-height + frameWidth,0),
										new Vector3D(width / 2,-frameWidth,0),
										width - frameWidth * 2,1);
			var gl:SubGeometry = getSubGeometry(glassData);
			geo.addSubGeometry(gl);
			
			// 创建Mesh
			frameMat = frameMat || mat;
			mesh = new Mesh(geo,frameMat);
			
			// 设置玻璃的材质
			glassMat = glassMat || this.glassMat;
			mesh.getSubMeshForSubGeometry(gl).material = glassMat;
			
			return mesh;
		}
		
		/**
		 * 创建推拉窗Mesh的方法
		 */
		public function getPushWindowMesh(frameMat:MaterialBase = null,glassMat:MaterialBase = null):Mesh {
			geo = new Geometry();
			// 创建外框
			var data:* = frameBuilder(width,height,depth,frameWidth);
			
			geo.addSubGeometry(getSubGeometry(data));
			
			var innerFrameWidth:Number = frameWidth * 0.8;
			var innerDepth:Number = depth * 0.4;
			var fw:Number = (width - frameWidth * 2) / 2 + innerFrameWidth / 2;
			
			// 创建内框1
			var d1:* = frameBuilder(fw,
									height - frameWidth * 2,
									innerDepth,
									innerFrameWidth,
									true,false,frameWidth,-frameWidth,-innerDepth / 2 * 1.01);
			
			geo.addSubGeometry(getSubGeometry(d1));
			
			// 创建内框2
			var d2:* = frameBuilder(fw,
				height - frameWidth * 2,
				innerDepth,
				innerFrameWidth,
				true,false,frameWidth + (width - frameWidth * 2) / 2 - innerFrameWidth / 2,-frameWidth,innerDepth / 2 * 1.01);
			
			geo.addSubGeometry(getSubGeometry(d2));
			
			// 创建玻璃1
			var w1:* = StickBuilder(new Vector3D(frameWidth + fw / 2,-height + frameWidth + innerFrameWidth,-innerDepth / 2 * 1.01),
				new Vector3D(frameWidth + fw / 2,-frameWidth - innerFrameWidth,-innerDepth / 2 * 1.01),
				fw - innerFrameWidth * 2,1);
			
			var wg:SubGeometry = getSubGeometry(w1);
			geo.addSubGeometry(wg);
			
			// 创建玻璃2
			var w2:* = StickBuilder(new Vector3D(width - frameWidth - fw / 2,-height + frameWidth + innerFrameWidth,innerDepth / 2 * 1.01),
				new Vector3D(width - frameWidth - fw / 2,-frameWidth - innerFrameWidth,innerDepth / 2 * 1.01),
				fw - innerFrameWidth * 2,1);
			
			var wg2:SubGeometry = getSubGeometry(w2);
			geo.addSubGeometry(wg2);
			
			// 创建Mesh
			frameMat = frameMat || mat;
			mesh = new Mesh(geo,frameMat);
			
			// 设置玻璃的材质
			glassMat = glassMat || this.glassMat;
			mesh.getSubMeshForSubGeometry(wg).material = glassMat;
			mesh.getSubMeshForSubGeometry(wg2).material = glassMat;
			
			return mesh;
		}
		
		/**
		 * 创建普通门Mesh的方法
		 */
		public function getNormalDoorMesh(frameMat:MaterialBase = null):Mesh {
			geo = new Geometry();
			// 创建外框
			var data:* = frameBuilder(width,height,depth,frameWidth,false);
			
			geo.addSubGeometry(getSubGeometry(data));
			
			// 创建门板
			var doorData:* = StickBuilder(new Vector3D(width / 2,-height,0),
				new Vector3D(width / 2,-frameWidth,0),
				width - frameWidth * 2,depth * 0.4,false,true);
			
			var door:SubGeometry = getSubGeometry(doorData);
			geo.addSubGeometry(door);
			
			// 创建Mesh
			frameMat = frameMat || doorFrameMat;
			mesh = new Mesh(geo,frameMat);
			
			mesh.getSubMeshForSubGeometry(door).material = doorMat;
			
			return mesh;
		}
	}
}