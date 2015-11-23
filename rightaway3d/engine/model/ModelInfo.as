package rightaway3d.engine.model
{
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	
	import rightaway3d.engine.animation.AnimationAction;
	import rightaway3d.engine.product.ProductObject;
	
	import sunag.animation.Animation;

	public class ModelInfo
	{
		/**
		 * 当产品或模型的实例都被清除后，是否清除产品或模型的信息对象
		 * 当场景中的产品及模型的重复利用率高时，保留产品和模型的信息对象，
		 * 有助于提高加载效率，缺点是模型数据会比较占用内存
		 */
		static public var disposeInfoObject:Boolean = true;
		
		public var infoID:int;
		
		public var name:String;
		public var name_en:String;
		
		public var infoFileURL:String;
		public var infoDataFormat:String;
		
		public var modelFileURL:String;
		public var modelType:String;
		public var modelDataFormat:String;
		public var modelFileData:*;//模型文件的原始数据
		public var isModelReady:Boolean = false;
		
		public var md5:String;
		public var crc32:String;
		public var bytes:Number;
		public var bounds:Vector3D;//模型的长宽高数据
		//public var centerOffset:Vector3D;//模型的中心点偏移
		//public var scale:Vector3D;//模型的缩放比例
		
		public var rotation:Vector3D = new Vector3D();
		
		//public var color:uint=0xffffff;
		public var color:uint=0;
		public var specular:Number=-1;
		public var ambient:Number=-1;
		public var gloss:Number=-1;
		//public var specular:Number=0.5;
		//public var ambient:Number=0.5;
		//public var gloss:Number=50;
		
		/**
		 * 挷定此模型的产品信息，每个模型允许1个以上的产品关联挷定
		 */
		//public var products2:Vector.<ProductInfo> = new Vector.<ProductInfo>();
		
		/**
		 *模型的克隆模式，auto：从第二个实例开始克隆，all：全部克隆，none：没有克隆，所有模型实例直接解析出来 
		 */		
		//public var cloneMode:String = "auto";
		
		/**
		 * 模型自身实例，只作存储数据用
		 */
		//public var ownModelInstance:ModelObject;
		
		public var meshs:Vector.<Mesh>;
		public var materials:Vector.<MaterialBase>;
		public var seaAnimations:Vector.<Animation>;
		
		public var animationActions:Vector.<AnimationAction>;
		
		public var reflections2:Vector.<ReflectionInfo>;
		
		public var mirrors:Vector.<MirrorInfo>;
		
		//此模型的所有实例集合，以模型实例的objectID为键，ModelObject对象为值
		private var modelObjects:Object = {};
		
		/**
		 * 此模型是否双面渲染
		 */
		public var renderBothSides:Boolean = false;
		
		public function ModelInfo()
		{
			//ownModelInstance = new ModelObject();
			//ownModelInstance.modelInfo = this;
		}
		
		//在满足条件时，会被自动清理掉
		private function dispose():void
		{
			//trace("-------dispose modelInfo:"+this.infoFileURL);
			
			ModelManager.own.deleteModelInfo(this);
			
			if(meshs)
			{
				for each(var mesh:Mesh in meshs)
				{
					mesh.disposeWithAnimatorAndChildren();
				}
				meshs = null;
			}
			
			if(materials)
			{
				for each(var mat:MaterialBase in materials)
				{
					mat.dispose();
				}
				materials = null;
			}
			
			modelFileData = null;
			bounds = null;
			
			seaAnimations = null;
			animationActions = null;
			reflections2 = null;
			mirrors = null;
			modelObjects = null;
		}
		
		public function parse(xml:XML):void
		{
			name = xml.name;
			name_en = xml.name_en;
			modelFileURL = xml.file;
			modelType = modelFileURL.slice(-4).toLowerCase();
			modelDataFormat = xml.dataFormat;
			md5 = xml.md5;
			crc32 = xml.crc32;
			bytes = xml.byteSize;
			
			if(xml.color!=undefined)color = xml.color;
			if(xml.specular!=undefined)specular = xml.specular;
			if(xml.ambient!=undefined)ambient = xml.ambient;
			if(xml.gloss!=undefined)gloss = xml.gloss;
			
			//cloneMode = xml.cloneMode;
			
			if(xml.rotation!=undefined)
			{
				var s:String = xml.rotation;
				var a:Array = s.split(",");
				rotation = new Vector3D(a[0],a[1],a[2]);
			}
			
			s = xml.dimensions;
			a = s.split(",");
			bounds = new Vector3D(a[0],a[1],a[2]);
			//trace("dimensions:"+s+" "+bounds);
			
			s = xml.renderBothSides!=undefined?xml.renderBothSides:"false";
			renderBothSides = s=="true"?true:false;
			
			/*s = xml.centerOffset;
			a = s.split(",");
			centerOffset = new Vector3D(a[0],a[1],a[2]);*/
			
			/*s = xml.scale;
			a = s.split(",");
			scale = new Vector3D(a[0],a[1],a[2]);*/
			if(xml.animates!=undefined && xml.animates.animate!=undefined)
			{
				var list:XMLList = xml.animates.animate;
				var len:int = list.length();
				animationActions = new Vector.<AnimationAction>(len);
				
				for(var i:int=0;i<len;i++)
				{
					animationActions[i] = new AnimationAction(list[i]);
				}
			}
			
			//trace("reflection:"+xml.reflection);
			if(xml.reflection!=undefined && xml.reflection.item!=undefined)
			{
				var items:XMLList = xml.reflection.item;
				len = items.length();
				reflections2 = new Vector.<ReflectionInfo>();
				for(i=0;i<len;i++)
				{
					var r:ReflectionInfo = new ReflectionInfo(items[i]);
					reflections2.push(r);
				}
			}
			
			if(xml.mirror!=undefined && xml.mirror.item!=undefined)
			{
				items = xml.mirror.item;
				len = items.length();
				
				mirrors = new Vector.<MirrorInfo>();
				
				for(i=0;i<len;i++)
				{
					var mr:MirrorInfo = new MirrorInfo(items[i]);
					mirrors.push(mr);
				}
			}
		}
		
		public function getMeshByName(meshName:String):Mesh
		{
			if(meshs)
			{
				for each(var m:Mesh in meshs)
				{
					if(m.name==meshName)
					{
						return m;
					}
				}
			}
			return null;
		}
		
		public function getMaterialByName(materialName:String):MaterialBase
		{
			if(materials)
			{
				for each(var m:MaterialBase in materials)
				{
					if(m.name==materialName)
					{
						return m;
					}
				}
			}
			return null;
		}
		
		//===================================================================
		
		
		//添加产品实例
		public function addModelObject(modelObject:ModelObject):void
		{
			//trace("----");
			var id:String = modelObject.id;
			var p:ProductObject = modelObject.parentProductObject;
			while(p)
			{
				//trace(p.productInfo.fileURL);
				id = p.id + "_" + id;
				p = p.parentProductObject;
			}
			
			//trace("addModelObject id="+id,modelObjects,this.infoFileURL);
			modelObject.objectID = id;
			
			modelObjects[id] = modelObject;
			ModelManager.own.addObject(modelObject);
			
			modelObject.modelInfo = this;
		}
		
		//删除产品实例
		public function removeModelObject(modelObject:ModelObject):void
		{
			ModelManager.own.removeObject(modelObject);
			
			if(modelObjects[modelObject.objectID]==modelObject)
			{
				delete modelObjects[modelObject.objectID];
			}
			
			if(disposeInfoObject && getModelObjects().length==0)
			{
				this.dispose();
			}
		}
		
		//删除产品实例
		/*public function removeModelObject(objectID:String):void
		{
			if(modelObjects[objectID])
			{
				delete modelObjects[objectID];
			}
		}*/
		
		//获取指定产品实例
		/*public function getModelObject(objectID:String):ModelObject
		{
			return modelObjects[objectID];
		}*/
		
		//获取所有产品实例
		public function getModelObjects():Array
		{
			var a:Array = [];
			for each(var o:ModelObject in modelObjects)
			{
				a.push(o);
			}
			return a;
		}
		
		/*public function cloneObject():ModelObject
		{
			var clone:ModelObject = new ModelObject();
			//clone.id = ownModelInstance.id;
			//clone.id = "0";
			
			return clone;
		}*/
	}
}





















