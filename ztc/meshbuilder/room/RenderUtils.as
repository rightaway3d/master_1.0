package ztc.meshbuilder.room
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.textures.BitmapTexture;

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
				var bitmapTexture:BitmapTexture = new BitmapTexture(bmp.bitmapData);
				
				completeFunc(bitmapTexture);
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
		public static function setMaterial(mesh:*, name:String, scaleUV:Boolean = true, ml:MaterialLibrary = null):void {
			if (ml == null) ml = MaterialLibrary.instance;
			var md:Object = ml.getMaterialData(name);
			
////			if (mesh is Mesh || mesh is SubMesh) {
////				mesh.material = md.material;
				
			if (mesh is Mesh) {
				for each(var m:SubMesh in mesh.subMeshes) {
					m.material = md.material;
				}
			} else if (mesh is SubMesh) {
				mesh.material = md.material;
			}
				
				// set UV scale
				if (scaleUV) 
					scaleMeshUV(mesh,md.scaleU,md.scaleV);
//			}
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
				for each( var m:SubMesh in mesh.subMeshes) {
					m.subGeometry.scaleUV(u,v);
				}
			} else if (mesh is SubMesh) {
				SubMesh(mesh).subGeometry.scaleUV(u,v);
			}
			
//			mesh.geometry.scaleUV(u,v);
			
//			mesh.subMeshes[0].scaleU = u;
//			mesh.subMeshes[0].scaleV = v;
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