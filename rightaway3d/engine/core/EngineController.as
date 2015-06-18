package rightaway3d.engine.core
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.PlanarReflectionMethod;
	import away3d.primitives.RegularPolygonGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.PlanarReflectionTexture;
	
	import rightaway3d.engine.model.MirrorInfo;
	import rightaway3d.engine.model.ModelManager;
	import rightaway3d.engine.model.ModelObject;

	public class EngineController
	{
		private var engine3d:Engine3D;
		
		public function EngineController(engine3d:Engine3D)
		{
			this.engine3d = engine3d;
		}
		
		public function setMaterialColor(color:uint,materialName:String,objectID:String):void
		{
			var mObj:ModelObject = ModelManager.own.getObject(objectID);
			if(mObj)
			{
				var m:MaterialBase = mObj.getMaterialByName(materialName);
				
				if(m)
				{
					if(m is SinglePassMaterialBase)SinglePassMaterialBase(m).color = color;
					else
						trace("setMaterialColor 在指定的Materail上无法设置颜色:"+m);
				}
				else
				{
					trace("setMaterialColor 找不到指定的Materail:"+materialName);
				}
			}
			else
			{
				trace("setMaterialColor 找不到指定的ModelObject:"+objectID);
			}
		}
		
		public function setMeshColor(color:uint,meshName:String=null,objectID:String=null):void
		{
			if(objectID)
			{
				var mObj:ModelObject = ModelManager.own.getObject(objectID);
				if(mObj)
				{
					var mesh:Mesh = mObj.getMeshByName(meshName);
					if(mesh)
					{
						engine3d.setMeshColor(mesh,color);
					}
					else
					{
						trace("setMeshColor 找不到指定的Mesh:"+meshName);
					}
				}
				else
				{
					trace("setMeshColor 找不到指定的ModelObject:"+objectID);
				}
			}
			else
			{
				var mObjs:Array = ModelManager.own.getAllObjects();
				for each(mObj in mObjs)
				{
					engine3d.setMeshsColor(mObj.meshs,color);
				}
			}
		}
		
		public function setMaterialBitmapTexture(objectID:String,materialName:String,bmpData:BitmapData):void
		{
			var mObj:ModelObject = ModelManager.own.getObject(objectID);
			if(mObj)
			{
				var m:MaterialBase = mObj.getMaterialByName(materialName);
				
				if(m)
				{
					if(m is TextureMaterial && TextureMaterial(m).texture is BitmapTexture)BitmapTexture(TextureMaterial(m).texture).bitmapData = bmpData;
					else
						trace("setMaterialBitmapTexture 在指定的Materail上无法设置材质:"+m);
				}
				else
				{
					trace("setMaterialBitmapTexture 找不到指定的Materail:"+materialName);
				}
			}
			else
			{
				trace("setMaterialBitmapTexture 找不到指定的ModelObject:"+objectID);
			}
		}
		
		public function setMeshBitmapTexture(objectID:String,meshName:String,bmpData:BitmapData):void
		{
			var mObj:ModelObject = ModelManager.own.getObject(objectID);
			if(mObj)
			{
				var mesh:Mesh = mObj.getMeshByName(meshName);
				if(mesh)
				{
					var bt:BitmapTexture = null;
					if(mesh.material is TextureMaterial && 
						TextureMaterial(mesh.material).texture is BitmapTexture)
					{
						bt = TextureMaterial(mesh.material).texture as BitmapTexture;
					}
					else if(mesh.subMeshes.length>0 && 
						mesh.subMeshes[0].material is TextureMaterial && 
						TextureMaterial(mesh.subMeshes[0].material).texture is BitmapTexture)
					{
						bt = TextureMaterial(mesh.subMeshes[0].material).texture as BitmapTexture;
					}
					
					if(bt)
					{
						bt.bitmapData = bmpData;
					}
					else
					{
						var mat:TextureMaterial = new TextureMaterial();
						var texture:BitmapTexture = new BitmapTexture(bmpData);
						mat.texture = texture;
						mesh.material = mat;
						mat.lightPicker = engine3d.lightPicker;
					}
				}
				else
				{
					trace("在模型["+objectID+"]中找不到指定的Mesh:"+meshName);
				}
			}
			else
			{
				trace("找不到指定的ModelObject:"+objectID);
			}
		}
		
		public function addMirrors(mirrors:Vector.<MirrorInfo>):void
		{
			for each(var mr:MirrorInfo in mirrors)
			{
				var mesh:Mesh = createMirror(mr);
				engine3d.addRootChild(mesh);
			}			
		}
		
		private function createMirror(mr:MirrorInfo):Mesh
		{
			var geometry:RegularPolygonGeometry = new RegularPolygonGeometry(mr.radius,mr.side,false);
			var mat:TextureMaterial = new TextureMaterial();
			mat.alpha = mr.alpha;
			
			var reflectionTexture:PlanarReflectionTexture = engine3d.getPlanarReflectionTexture2();
			var reflectionMethod : PlanarReflectionMethod = new PlanarReflectionMethod(reflectionTexture);
			mat.addMethod(reflectionMethod);
			
			var mesh:Mesh = new Mesh(geometry, mat);
			mesh.position = mr.position;
			mesh.rotation = mr.rotation;
			mesh.scaleX = mr.scaleX;
			mesh.scaleY = mr.scaleY;
			mesh.name = "mirror";
			trace("-----------------------initMirror rotation:"+mr.rotation,mr.position,mr.alpha);
			
			reflectionTexture.applyTransform(mesh.sceneTransform);
			
			return mesh;
		}
		
		public function setCamera(pan:Number, tilt:Number, distance:Number, lookAt:Vector3D):void
		{
			engine3d.camCtrl.tweenTo(pan,tilt,distance,lookAt);
		}
		
		public function hideScene(hideBackground:Boolean=false):void
		{
			engine3d.hideScene(hideBackground);
		}
		
		public function showScene():void
		{
			engine3d.showScene();
		}
	}
}