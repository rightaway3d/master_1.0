package ztc.meshbuilder.room
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import away3d.bounds.BoundingVolumeBase;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;

	/**
	 * 与渲染相关的方法类
	 */
	public class RenderUtils
	{
		/**
		 * 载入图片的方法
		 * str : 图片的路径
		 * completeFunc(texture:BitmapTexture) : 载入完成后的回调函数
		 */
		public static function loadTexture(str:String, completeFunc:Function):void {
			var loader:Loader = new Loader();
			//var url:String = decodeURI(str);
			//trace("load texture:"+str);
			var url:String = encodeURI(str);
			loader.load(new URLRequest(url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
				var bmp:Bitmap = loader.content as Bitmap;
				completeFunc(bmp);
				//var bitmapTexture:BitmapTexture = new BitmapTexture(bmp.bitmapData);
				
				//completeFunc(bitmapTexture);
			});
		}
		
		/**
		 * 载入XML文档
		 */
		public static function loadXML(str:String, completeFunc:Function):void {
			var loader:URLLoader = new URLLoader(new URLRequest(str));
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var xml:XML = XML(loader.data);
				
				completeFunc(xml);
			});
		}
		
		/**
		 * 设置材质的方法并可以同时设置Mesh/SubMesh的ScaleU与ScaleV
		 * 如不需要改变UV,可以将scaleUV设置为false
		 */
		public static function setMaterial(mesh:*, name:String, scaleUV:Boolean = true, ml:MaterialLibrary = null,useNormal:Boolean=true):MaterialData
		{
			if(mesh is SubMesh)
			{
				var size:Vector3D = getSubGeometrySize(SubMesh(mesh).subGeometry);
				var w:int = size.x;
				var h:int = size.y;
				var d:int = size.z;
			}
			else
			{
				var b:BoundingVolumeBase = Mesh(mesh).bounds;
				w = b.max.x - b.min.x;
				h = b.max.y - b.min.y;
				d = b.max.z - b.min.z;
			}
			
			var dx:int,dy:int;
			
			if(w<h && w<d)//侧着放的板
			{
				dx = d;
				dy = h;
				
				useNormal = false;//侧板不加法线贴图
			}
			else if(d>h)//横着放的板
			{
				dx = w;
				dy = d;
			}
			else
			{
				dx = w;
				dy = h;
			}
			
			if(!useNormal)
			{
				dy = 250;
			}
			
			if (ml == null) ml = MaterialLibrary.instance;
			var md:MaterialData = ml.getMaterialData(name,dx,dy,useNormal);
			
			//TextureMaterial(md.material).ambient = 1;
		
////			if (mesh is Mesh || mesh is SubMesh) {
////				mesh.material = md.material;
				
			if (mesh is Mesh) {
				for each(var m:SubMesh in mesh.subMeshes) {
					m.material = md.material;
				}
			} else if (mesh is SubMesh) {
				mesh.material = md.material;
			}
			
			var grid9:Boolean = md.grid9Scale;
			
			var tw:int = md.tileWidth;
			var th:int = md.tileHeight;
			
			var su:Number = md.scaleU;
			var sv:Number = md.scaleV;
			
			// set UV scale
			if(mesh is CabinetTable3D)
			{
				CabinetTable3D(mesh).updateUV(tw,th);
			}
			/*else if(mesh is CubeMesh)
			{
				CubeMesh(mesh).updateUV();
			}*/
			else if(grid9 || su==0 || sv==0)
			{
				scaleMeshUV(mesh,1,1);
				if(mesh is CubeMesh)
				{
					CubeMesh(mesh).updateUV(0,0);
				}
			}
			else if(tw!=0 && th!=0)
			{
				if(mesh is CubeMesh)
				{
					CubeMesh(mesh).updateUV(tw,th);
				}
				else
				{
					su = dx/tw;
					sv = dy/th;
					
					//trace("scaleMeshUV1 tw,th,dx,dy,su,sv:",tw,th,dx,dy,su,sv);
					scaleMeshUV(mesh,su,sv);
				}
			}
			else if (scaleUV)
			{
				//trace("scaleMeshUV2 su,sv:",md.scaleU,md.scaleV);
				scaleMeshUV(mesh,su,sv);
			}
			
			return md;
		}
		
		/**
		 * 缩放Mesh的UV,确保Mesh物体的默认ScaleU/V为1,1
		 */
		public static function scaleMeshUV(mesh:*,u:Number,v:Number):void {
//			var baseScaleU:Number = mesh.subMeshes[0].scaleU;
//			var baseScaleV:Number = mesh.subMeshes[0].scaleV;
//			
//			var scaleU:Number = u / baseScaleU;
//			var scaleV:Number = v / baseScaleV;
//			
//			// 如果UV尺寸不变则返回
//			if (scaleU == 1 && scaleV == 1) return;
			if (mesh is Mesh) {
				Mesh(mesh).geometry.scaleUV(u,v);
				//Mesh(mesh).geometry.subGeometries
				//Mesh(mesh).geometry.scaleUV(2,2);
				/*for each( var m:SubMesh in mesh.subMeshes) {
					//m.subGeometry.scaleUV(u,v);
					//trace("scaleU1:",m.subGeometry.scaleU);
					//trace("scaleV1:",m.subGeometry.scaleV);
				}*/
			} else if (mesh is SubMesh) {
				SubMesh(mesh).subGeometry.scaleUV(u,v);
				//trace("scaleU2:",SubMesh(mesh).subGeometry.scaleU);
				//trace("scaleV2:",SubMesh(mesh).subGeometry.scaleV);
			}
			
//			mesh.geometry.scaleUV(u,v);
			
//			mesh.subMeshes[0].scaleU = u;
//			mesh.subMeshes[0].scaleV = v;
		}
		
		private static function getSubGeometrySize(subGeom:ISubGeometry):Vector3D
		{
			var max:Vector3D = new Vector3D();
			var min:Vector3D = new Vector3D();
			var size:Vector3D = new Vector3D();
			
			getSubGeometryBounds(subGeom,max,min);
			
			size.x = max.x - min.x;
			size.y = max.y - min.y;
			size.z = max.z - min.z;
			
			return size;
		}
		
		private static function getSubGeometryBounds(subGeom:ISubGeometry,max:Vector3D,min:Vector3D):void
		{
			var minX:Number, minY:Number, minZ:Number;
			var maxX:Number, maxY:Number, maxZ:Number;
			
			var vertices:Vector.<Number> = subGeom.vertexData;
			var i:uint = subGeom.vertexOffset;
			minX = maxX = vertices[i];
			minY = maxY = vertices[i + 1];
			minZ = maxZ = vertices[i + 2];
			
			var vertexDataLen:uint = vertices.length;
			var stride:uint = subGeom.vertexStride;
			
			while (i < vertexDataLen) {
				var v:Number = vertices[i];
				if (v < minX)
					minX = v;
				else if (v > maxX)
					maxX = v;
				
				v = vertices[i + 1];
				if (v < minY)
					minY = v;
				else if (v > maxY)
					maxY = v;
				
				v = vertices[i + 2];
				if (v < minZ)
					minZ = v;
				else if (v > maxZ)
					maxZ = v;
				
				i += stride;
			}
			
			max.x = maxX;
			max.y = maxY;
			max.z = maxZ;
			min.x = minX;
			min.y = minY;
			min.z = minZ;
		}
		
		/**
		 * 通过给定的Material Type值,得以期对就的默认材质名
		 * 
		 * types: wall|ceiling|ground|table|cabinetDoor|cabinetBody
		 * 
		 * 返回:String
		 */
		public static function getDefaultMaterial(materialType:String):String {
			// 先判断,默认材质是否已经载入完成
			if (RendingManager.instance.defaultMaterialXML != null) {
				return RendingManager.instance.defaultMaterials[materialType];		
			}
			
			return null;
		}
	}
}