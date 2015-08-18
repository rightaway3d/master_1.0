package rightaway3d.engine.product
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.action.PropertyAction;
	import rightaway3d.engine.model.ModelInfo;
	import rightaway3d.engine.model.ModelObject;
	
	[Event(name="ready", type="flash.events.Event")]

	public class ProductInfo extends EventDispatcher
	{
		static public const READY:String = "ready";
		
		/**
		 * 产品数据库编号
		 */
		public var infoID:int;
		/**
		 * 产品编号
		 */
		public var productID:String = "";
		/**
		 * 产品型号
		 */
		public var productModel:String = "";
		/**
		 * 产品名称
		 */
		public var name:String = "";
		/**
		 * 产品英文名称
		 */
		public var name_en:String = "";
		/**
		 * 物料编号
		 */
		public var productCode:String = "";
		/**
		 * 产品类型（一级分类）
		 */
		public var category:String = "";
		/**
		 * 产品类型（二级分类）
		 */
		public var type:String = "";
		/**
		 * 产品样式（风格）
		 */
		public var style:String = "";
		/**
		 * 产品标签，在配置文件中是以半角逗号(,)分隔的字符串
		 */
		public var tags:Array;
		/**
		 * 产品描述
		 */
		public var dscp:String = "";
		/**
		 * 备注
		 */
		public var memo:String = "";
		
		/**
		 * 产品的型号版本
		 */
		public var version:String = "";
		
		/**
		 * 产品规格
		 */
		public var specifications:String = "";
		
		public var materialName:String = "";
		public var materialDscp:String = "";
		
		public var unit:String = "";
		
		/**
		 * 产品价格
		 */
		public var price:Number = 0;
		
		/**
		 * 配置文件地址
		 */
		public var fileURL:String = "";
		/**
		 * 配置文件格式，分为文本及二进制两种
		 */
		public var dataFormat:String = "";
		/**
		 * 配置文件是否加载并解析完成的标志
		 */
		public var isReady:Boolean = false;
		
		/**
		 * 2D视图的图片地址
		 */
		public var image2dURL:String = "";
		
		/**
		 * 3D视图的图片地址
		 */
		public var image3dURL:String = "";
		
		/**
		 * 模型的对齐方式，有front,back,left,right,top，bottom几种类型，没值时或值为center时，默认对齐到中心点，相反方向的值不可同时出现
		 */
		public var aligns:Array = [];
		
		/**
		 * 对齐时，模型各轴的偏移量
		 */
		public var alignOffset:Vector3D = new Vector3D();
		
		/**
		 * 模型的缩放比例
		 */
		public var scale:Vector3D = new Vector3D(1,1,1);
		
		/**
		 * 模型缩放后的长宽高数据
		 */
		public var dimensions:Vector3D = new Vector3D(100,100,100);
		
		/**
		 * 此产品所对应的模型信息（模型信息与子产品只能二存一）
		 */
		public var modelInfo:ModelInfo;
		
		/**
		 * 此产品所对应的模型实例数据（模型实例与子产品实例二存一）
		 */
		//public var modelInstance:ModelObject;
		
		/**
		 * 作为子产品存在时的父产品
		 */
		//public var parentProductInfo:ProductInfo;
		
		/**
		 * 子产品的集合（模型信息与子产品只能二存一）
		 */
		//public var subProductInfos:Vector.<ProductInfo>;
		
		/**
		 * 子产品的实例集合，只作存储数据用（模型实例与子产品实例二存一）
		 */
		public var subProductInstances:Vector.<ProductObject>;
		
		public var subProductData:XML;
		
		/**
		 * 产品自身实例，只作存储数据用
		 */
		//public var ownProductInstance:ProductObject;
		
		//用于保存子产品的位置及旋转角度信息，以产品subProductInfos中的productInfo为键
		//public var subProductInfosPos:Object;
		
		private var productManager:ProductManager = ProductManager.own;
		
		/**
		 * 在触发特定交互事件时，所要执行的动作列表
		 */
		public var actions:Vector.<PropertyAction>;
		
		public function ProductInfo()
		{
			//ownProductInstance = new ProductObject();
			//ownProductInstance.productInfo = this;
		}
		
		private function dispose():void
		{
			if(actions)
			{
				for each(var ac:PropertyAction in actions)
				{
					ac.dispose();
				}
				actions = null;
			}
			
			if(subProductInstances)
			{
				for each(var po:ProductObject in subProductInstances)
				{
					po.dispose();
				}
				subProductInstances = null;
			}
			
			if(productManager)
			{
				productManager.deleteProductInfo(this);
				productManager = null;
			}
			
			tags = null;
			aligns = null;
			alignOffset = null;
			scale = null;
			dimensions = null;
			modelInfo = null;
			//parentProductInfo = null;
			//subProductInfos = null;
			
			//productObjectDict = null;
			productObjects = null;
		}
		
		//===================================================================
		/*public function addChildProductInfo(child:ProductInfo):void
		{
			subProductInfos ||= new Vector.<ProductInfo>();
			subProductInfos.push(child);
			//child.parentProductInfo = this;
		}*/
		
		//===================================================================
		
		//此产品的所有实例集合，以产品实例的objectID为键，ProductObject对象为值
		//private var productObjectDict:Dictionary = new Dictionary();
		private var productObjects:Array = [];
		
		//添加产品实例
		public function addProductObject(productObject:ProductObject):void
		{
			/*var id:String = productObject.id;
			var p:ProductObject = productObject.parentProductObject;
			while(p)
			{
				id = p.id + "_" + id;
				p = p.parentProductObject;
			}*/
			
			//productObjectDict[productObject.objectID] = productObject;
			productObjects.push(productObject);
			
			productObject.productInfo = this;
			//trace("----------addProductObject:"+id+" infoID:"+this.infoID);
		}
		
		//删除产品实例
		public function removeProductObject(pObj:ProductObject):void
		{
			
			/*if(productObjectDict[pObj.objectID]==pObj)
			{
				delete productObjectDict[pObj.objectID];
				
			}*/
			if(!productObjects)return;
			
			var n:int = productObjects.indexOf(pObj);
			if(n>-1)
			{
				productObjects.splice(n,1);
				productManager.removeProductObject(pObj);
				
				if(ModelInfo.disposeInfoObject && productObjects.length==0)
				{
					this.dispose();
				}
			}
		}
		
		//删除产品实例
		/*public function removeProductObjectByID(objectID:String):void
		{
			if(productObjectDict[objectID])
			{
				var obj:ProductObject = productObjectDict[objectID];
				delete productObjectDict[objectID];
				
				var n:int = productObjects.indexOf(obj);
				productObjects.splice(n,1);
			}
		}*/
		
		//获取指定产品实例
		/*public function getProductObject(objectID:String):ProductObject
		{
			return productObjectDict[objectID];
		}*/
		
		//获取所有产品实例
		public function getProductObjects():Array
		{
			/*var a:Array = [];
			for each(var o:* in productObjectDict)
			{
				a.push(o);
			}*/
			//trace("productObjects.length:"+productObjects.length);
			return productObjects.concat();
		}
		
		public function dispatchReadyEvent():void
		{
			if(this.hasEventListener(READY))
			{
				this.dispatchEvent(new Event(READY));
			}
		}
		
		private function cloneObject(source:ProductObject):ProductObject
		{
			var clone:ProductObject = new ProductObject();
			
			clone.id = source.id;
			clone.name = source.name;
			clone.name_en = source.name_en;
			
			clone.isActive = source.isActive;
			
			clone.position = source.position;
			clone.rotation = source.rotation;
			clone.scale = source.scale;
			clone.memo = source.memo;
			
			source.productInfo.addProductObject(clone);
			
			return clone;
		}
		
		/**
		 * 自定义材质字典，以模型类型为键，或以模型类型加模型Y轴位置为键，以材质名称为值
		 */
		static public var defaultMaterialDict:Dictionary = new Dictionary();
		
		static public function setDefaultMaterial(po:ProductObject):void
		{
			var type:String = po.productInfo.type;
			if(defaultMaterialDict[type])
			{
				var name:String = defaultMaterialDict[type];
				//trace("matName:"+name);
				po.customMaterialName = name;
			}
			else
			{
				type += String(ProductManager.own.getRootParent(po).objectInfo.y);
				
				if(defaultMaterialDict[type])
				{
					name = defaultMaterialDict[type];
					//trace("matName:"+name);
					po.customMaterialName = name;
				}
			}
			trace("---------modelType:"+type);
		}
		
		/**
		 * 将当前产品信息里的子产品数据，复制到实例产品里
		 * @param productObjectInstance 当前产品信息的实例
		 * 
		 */
		public function cloneToProductObject(productObjectInstance:ProductObject):void
		{
			if(modelInfo)//当前数据为产品模型信息
			{
				if(!productObjectInstance.modelObject)//模型数据还未复制产品实例
				{
					var modelObject:ModelObject = new ModelObject();
					productObjectInstance.modelObject = modelObject;
					modelObject.parentProductObject = productObjectInstance;
					
					modelInfo.addModelObject(modelObject);
					
					modelObject.cloneFromInfo();
					
					//设置产品实例的材质（仅当此产品未设置过材质时）
					if(!productObjectInstance.customMaterialName)setDefaultMaterial(productObjectInstance);
					
					if(modelObject.meshs)
					{
						productManager.engineManager.addChildMeshs(modelObject.meshs,productObjectInstance.container3d,this.aligns,this.alignOffset);
						productManager.engineManager.addModelEvent(modelObject);
					}
				}
			}
			else if(subProductInstances)//当前存在子产品列表信息
			{
				if(!productObjectInstance.subProductObjects)//子产品信息还未复制到产品实例中
				{
					var len:int = subProductInstances.length;
					//var productObjects:Vector.<ProductObject> = new Vector.<ProductObject>(len);
					//productObjectInstance.subProductObjects = productObjects;
					
					for(var i:int=0;i<len;i++)
					{
						var srcObject:ProductObject = subProductInstances[i];
						var subProductInfo:ProductInfo = srcObject.productInfo;
						
						var newObject:ProductObject = subProductInfo.cloneObject(srcObject);
						
						productObjectInstance.addSubProduct(newObject);
						
						//productManager.updateScale2(newObject);
						
						subProductInfo.cloneToAllProductObject(productObjectInstance);
					}
				}
			}
		}
		
		/**
		 * 为当前产品实例复制子产品.
		 * 如果不指定父产品实例，则为当前产品的所有实例创建子产品实例,
		 * 否则只创建指定产品实例的子产品实例.
		 * 
		 */
		public function cloneToAllProductObject(parent:ProductObject=null):void
		{
			//var productObjects:Array = productInfo.getProductObjects();
			for each(var productObject:ProductObject in productObjects)
			{
				//如果不指定父产品实例，则为当前产品的所有实例创建子产品实例
				//否则只创建指定产品实例的子产品实例
				if(!parent || productObject.parentProductObject==parent)
				{
					cloneToProductObject(productObject);
					productManager.updateProductModel(productObject);
				}
			}
			
			productManager.setDynamicProduct(this);
		}
	}
}
