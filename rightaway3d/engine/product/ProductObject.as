package rightaway3d.engine.product
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	
	import rightaway3d.engine.action.PropertyAction;
	import rightaway3d.engine.model.ModelInfo;
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.vo.BaseVO;
	import rightaway3d.house.vo.WallObject;
	
	import ztc.meshbuilder.room.MaterialLibrary;
	import ztc.meshbuilder.room.RenderUtils;
	
	/**
	 * 在3D场景口开始拖拽产品时，派发此事件
	 */
	[Event(name="start_drag", type="flash.events.Event")]
	
	/**
	 * 在3D场景口结束拖拽产品时，派发此事件
	 */
	[Event(name="end_drag", type="flash.events.Event")]
	
	/**
	 * 在3D场景口拖拽产品时，派发此事件
	 */
	[Event(name="draging", type="flash.events.Event")]

	public class ProductObject extends BaseVO
	{
		//==========================================================================
		//根产品对象索引值
		static public var index:int = 0;
		static public function getNextIndex():int
		{
			return ++index;
		}
		static public function setNextIndex(value:int):void
		{
			if(value>index)index = value;
		}
		static public function resetIndex():void
		{
			index = 0;
		}
		//==========================================================================
		//当前产品对象的子产品对象的索引值，当往当前产品动态添加子产品的时候，从此处获取对象id
		public var index:int = 0;
		public function getNextIndex():int
		{
			return ++index;
		}
		public function setNextIndex(value:int):void
		{
			if(value>index)index = value;
		}
		//==========================================================================
		/**
		 * 在3D场景口开始拖拽产品时，派发此事件
		 */
		static public const START_DRAG:String = "start_drag";
		
		/**
		 * 在3D场景口结束拖拽产品时，派发此事件
		 */
		static public const END_DRAG:String = "end_drag";
		
		/**
		 * 在3D场景口拖拽产品时，派发此事件
		 */
		static public const DRAGING:String = "draging";
		
		public function dispatchStartDragEvent():void
		{
			if(this.hasEventListener(START_DRAG))
			{
				this.dispatchEvent(new Event(START_DRAG));
			}
		}
		
		public function dispatchEndDragEvent():void
		{
			if(this.hasEventListener(END_DRAG))
			{
				this.dispatchEvent(new Event(END_DRAG));
			}
		}
		
		private var dragingEvent:Event;
		public function dispatchDragingEvent():void
		{
			if(this.hasEventListener(DRAGING))
			{
				this.dispatchEvent(dragingEvent||=new Event(DRAGING));
			}
		}
		
		//==========================================================================
		
		public var id:int;
		public var objectID:String;
		
		private var _name:String = "";

		public function get name():String
		{
			return _name?_name:productInfo.name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public var name_en:String;
		//public var type2:String;
		
		public var position:Vector3D;
		public var rotation:Vector3D;
		public var scale:Vector3D;
		
		public var memo:String = "";
		
		private var _isActive:Boolean;

		/**
		 * 此产品模型是否允许交互
		 */
		public function get isActive():Boolean
		{
			return _isActive;
		}

		/**
		 * @private
		 */
		public function set isActive(value:Boolean):void
		{
			_isActive = value;
			container3d.mouseEnabled = container3d.mouseChildren = value;
		}

		
		/**
		 * 是否锁定此产品，锁定的产品不允许被拖动
		 */
		public var isLock:Boolean = false;
		
		/**
		 * 此产品是否添加到订单中，默认为true
		 */
		public var isOrder:Boolean = true;
		
		/**
		 *当前产品的附属产品列表，当当前产品销毁时，其附属产品也一并销毁
		 * 一般只在根产品间产生依附关系
		 */
		public var slaveProducts:Array;
		
		/**
		 * 当前产品所依附的主产品，一个产品可以依附到多个产品上，当此产品销毁时，解除与所有主产品的依附关系
		 * 一般只在根产品间产生依附关系
		 */
		public var masterProducts:Array;
		
		public function addSlaveProduct(po:ProductObject):void
		{
			slaveProducts ||= [];
			if(slaveProducts.indexOf(po.objectID)>-1)return;//已经存在依附关系了
			
			slaveProducts.push(po.objectID);
			po.addEventListener("will_dispose",onSlaveProductDispose);
			
			po.masterProducts ||= [];
			po.masterProducts.push(this.objectID);
		}
		
		public function removeSlaveProduct(po:ProductObject):void
		{
			if(slaveProducts)
			{
				var n:int=slaveProducts.indexOf(po.objectID);
				if(n>-1)
				{
					slaveProducts.splice(n,1);
					po.removeEventListener("will_dispose",onSlaveProductDispose);
				}
			}
			
			if(po.masterProducts)
			{
				n = po.masterProducts.indexOf(this.objectID);
				if(n>-1)
				{
					po.masterProducts.splice(this.objectID);
				}
			}
		}
		
		private function onSlaveProductDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			removeSlaveProduct(po);
		}
		
		//---------------------------------------------------
		private var _type:String;

		public function get type():String
		{
			return _type?_type:productInfo.type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		//---------------------------------------------------
		private var _specifications:String;

		/**
		 * 产品规格
		 */
		public function get specifications():String
		{
			return _specifications?_specifications:productInfo.specifications;
		}

		/**
		 * @private
		 */
		public function set specifications(value:String):void
		{
			_specifications = value;
		}

		
		//---------------------------------------------------
		private var _unit:String;
		
		public function get unit():String
		{
			return _unit?_unit:productInfo.unit;
		}
		
		public function set unit(value:String):void
		{
			_unit = value;
		}
		
		
		//---------------------------------------------------
		private var _productCode:String;
		
		public function get productCode():String
		{
			return _productCode?_productCode:productInfo.productCode;
		}
		
		public function set productCode(value:String):void
		{
			_productCode = value;
		}
		
		
		//---------------------------------------------------
		private var _price:Number = 0;

		/**
		 * 产品价格
		 */
		public function get price():Number
		{
			return _price>0?_price:productInfo.price;
		}

		/**
		 * @private
		 */
		public function set price(value:Number):void
		{
			_price = value;
		}

		
		//---------------------------------------------------
		/**
		 * 此产品实例的产品信息
		 */
		public var productInfo:ProductInfo;
		
		/**
		 * 作为子产品存在时的父产品
		 */
		public var parentProductObject:ProductObject;
		
		/**
		 * 模型实例
		 */
		public var modelObject:ModelObject;
		
		/*public function createContainer3D():void
		{
			if(!container3d)container3d = new ObjectContainer3D();
			container3d.mouseEnabled = container3d.mouseChildren = isActive;
		}*/
		
		/**
		 * 固定子产品实例集合(作为组合产品时)，固定子产品为在产品信息配置好的子产品列表，这些子产品不允许随意删除或移动
		 */
		public var subProductObjects:Vector.<ProductObject>;
		
		public function getSubProductByEnname(name:String):ProductObject
		{
			trace("---getSubProductByEnname:"+this.name_en);
			if(!subProductObjects)return null;
			for each(var sp:ProductObject in subProductObjects)
			{
				trace("---name_en:"+sp.name_en);
				if(sp.name_en==name)
				{
					return sp;
				}
			}
			return null;
		}
		
		public function addSubProduct(pObj:ProductObject):void
		{
			subProductObjects ||= new Vector.<ProductObject>();
			subProductObjects.push(pObj);
			
			_addSubProduct(pObj);
		}
		
		private function _addSubProduct(subpo:ProductObject):void
		{
			subpo.addEventListener("will_dispose",onSubProductDispose);

			//var container:ObjectContainer3D = po.container3d?po.container3d:new ObjectContainer3D();//创建模型实例容器
			
			//container.mouseEnabled = container.mouseChildren = po.isActive;
			
			//po.container3d = container;
			
			subpo.parentProductObject = this;
			
			//subpo.createContainer3D();
			
			this.container3d.addChild(subpo.container3d);
			
			//this.setNextIndex(po.id);
			subpo.id = this.getNextIndex();
			
			ProductManager.own.setDynamicProduct(subpo.productInfo);
			
			subpo.productInfo.cloneToProductObject(subpo)
			
			ProductManager.own.setProductObject(subpo);
			ProductManager.own.updateProductModel(subpo);
			
			//trace("----addSubProduct objectID:",subpo.objectID);
			
			flash.utils.setTimeout(cloneObject,100,subpo);
		}
		
		private function cloneObject(pObj:ProductObject):void
		{
			//pObj.productInfo.cloneToProductObject(pObj);
			ProductInfo.setDefaultMaterial(pObj);
		}
		
		/**
		 * 此产品实例作为动态替换进来的产品时的名称
		 */
		public var dynaminReplaceName:String;
		
		/**
		 * 动态子产品实例集合(作为组合产品时)，动态子产品为在软件运行过程，动态添加到此产品实例中的产品，可以动态的删除，目前不支持移动
		 */
		public var dynamicSubProductObjects:Vector.<ProductObject>;
		
		public function addDynamicSubProduct(pObj:ProductObject):void
		{
			dynamicSubProductObjects ||= new Vector.<ProductObject>();
			dynamicSubProductObjects.push(pObj);
			
			_addSubProduct(pObj);
		}
		
		public function hasDynamicProduct(name:String):Boolean
		{
			if(dynamicSubProductObjects)
			{
				for each(var po:ProductObject in dynamicSubProductObjects)
				{
					if(po.dynaminReplaceName==name)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		//动态子产品销毁时
		private function onSubProductDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			po.removeEventListener("will_dispose",onSubProductDispose);
			
			var n:int = dynamicSubProductObjects?dynamicSubProductObjects.indexOf(po):-1;
			if(n>-1)
			{
				dynamicSubProductObjects.splice(n,1);
			}
			else
			{
				n = subProductObjects.indexOf(po);
				if(n>-1)subProductObjects.splice(n,1);
			}
		}
		
		/**
		 * 产品在三维场景中的三维模型的容器
		 */
		public var container3d:ObjectContainer3D;
		
		/**
		 * 此产品实例在二维场景的俯视平面图
		 */
		public var view2d:Product2D;
		
		/**
		 * 此产品关联到墙体的一些数据信息
		 */
		public var objectInfo:WallObject;
		
		/**
		 * 此物体在所吸附墙面上的x位置
		 * @return 
		 * 
		 */
		public function get objectX():int
		{
			return objectInfo?objectInfo.x:0;
		}
		
		private var _image2dURL:String = "";

		/**
		 * 2D视图的图片地址
		 */
		public function get image2dURL():String
		{
			return _image2dURL?_image2dURL:productInfo.image2dURL;
		}

		/**
		 * @private
		 */
		public function set image2dURL(value:String):void
		{
			_image2dURL = value;
		}

		
		private var _image3dURL:String = "";

		/**
		 * 3D视图的图片地址
		 */
		public function get image3dURL():String
		{
			return _image3dURL?_image3dURL:productInfo.image3dURL;
		}

		/**
		 * @private
		 */
		public function set image3dURL(value:String):void
		{
			_image3dURL = value;
		}

		
		private var _customMaterialName:String;

		/**
		 * 自定义材质名称（当前产品为非组合产品时有效）
		 */
		public function get customMaterialName():String
		{
			return _customMaterialName;
		}

		/**
		 * @private
		 */
		public function set customMaterialName(value:String):void
		{
			//trace("------set customMaterialName:"+value,_customMaterialName);
			if(_customMaterialName == value)return;
			
			_customMaterialName = value;
			
			setCustomMaterial();
		}
		
		/**
		 * 设置自定义材质，设置成功将返回true，失败返回false
		 * @return 
		 * 
		 */
		public function setCustomMaterial():Boolean
		{
			if(_customMaterialName && !_customMaterial)_customMaterial = MaterialLibrary.instance.getMaterialData(_customMaterialName);
			
			
			//var i:int = 0;
			if(_customMaterialName && modelObject && modelObject.meshs)//存在自定义材质时，使用自定义材质
			{
				var mat:MaterialBase = MaterialBase(_customMaterial.material);
				for each(var mesh:Mesh in modelObject.meshs)
				{
					//mesh.material = mat;
					RenderUtils.setMaterial(mesh,_customMaterialName);
//					if( i == 0) {
//					    trace('uvdata: ' + mesh.geometry.subGeometries[0].UVData);
//						i++;
//					}
				}
				
				modelObject.materials = new <MaterialBase>[mat];
				
				return true;
			}
			return false;
		}
		
		private var _customMaterial:Object;

		/**
		 * 自定义材质（当前产品为非组合产品时，所包含模型使用自定义材质）
		 */
		public function get customMaterial():Object
		{
			return _customMaterial;
		}

		
		/**
		 * 此产品所贴靠的墙面
		 */
		//public var crossWall:*;
		
		/**
		 * 在触发特定交互事件时，所要执行的动作列表
		 */
		public var actions:Vector.<PropertyAction>;
		
		private var _productModel:String;

		/**
		 *产品型号 
		 */
		public function get productModel():String
		{
			return _productModel?_productModel:productInfo.productModel;
		}

		/**
		 * @private
		 */
		public function set productModel(value:String):void
		{
			_productModel = value;
		}

		
		public function ProductObject()
		{
			container3d = new ObjectContainer3D();
		}
		
		override public function dispose():void
		{
			//trace("----------disposeProductObject objectID:",objectID);
			//trace("id:",id," pid:",parentProductObject?parentProductObject.id:"");
			//trace("fileURL:"+productInfo.fileURL);
			
			this.dispatchWillDisposeEvent();
			//trace("ProductObjects:"+productInfo.getProductObjects());
			//trace("this:"+this.toJsonString());
			//if(this.parentProductObject)trace("parent:"+this.parentProductObject.toJsonString());
			
			if(actions)
			{
				for each(var ac:PropertyAction in actions)
				{
					ac.dispose();
				}
				actions = null;
			}
			
			if(modelObject)
			{
				modelObject.dispose();
				modelObject = null;
			}
			
			if(subProductObjects)
			{
				var pos:Vector.<ProductObject> = subProductObjects.concat();
				for each(var spo:ProductObject in pos)
				{
					spo.dispose();
				}
				subProductObjects = null;
			}
			
			clearDynamicSubProduct();
			dynamicSubProductObjects = null;
			
			if(container3d)
			{
				container3d.disposeWithChildren();
				container3d = null;
			}
			
			if(objectInfo)
			{
				objectInfo.dispose();
				objectInfo = null;
			}
			
			if(productInfo)
			{
				productInfo.removeProductObject(this);
				productInfo = null;
			}
			
			if(slaveProducts)
			{
				var spos:Array = slaveProducts.concat();
				for each(var oid:String in spos)
				{
					var po:ProductObject = ProductManager.own.getObject(oid);
					if(po)po.dispose();
				}
				slaveProducts = null;
			}
			
			_customMaterial = null;
			parentProductObject = null;
			position = null;
			rotation = null;
			scale = null;
			view2d = null;
			
			masterProducts = null;
			
			this.dispatchDisposeEvent();
		}
		
		public function clearDynamicSubProduct():void
		{
			if(!dynamicSubProductObjects)return;
			
			var pos:Vector.<ProductObject> = dynamicSubProductObjects.concat();
			for each(var spo:ProductObject in pos)
			{
				spo.dispose();
			}
		}
		
		override public function toString():String
		{
			return toJsonString();
		}
		
		/**
		 * 返回产品数据信息
		 * @param useDelete：返回的数据是否用于删除后还原功能，如果用于删除后的还原功能，将包括其所附属的产品的详细数据
		 * @return 
		 * 
		 */
		public function toJsonString(useUndoDelete:Boolean=false):String
		{
			var s:String = "{";
			s += "\"infoID\":\"" + productInfo.infoID + "\",";
			s += "\"file\":\"" + productInfo.fileURL + "\",";
			s += "\"dataFormat\":\"" + productInfo.dataFormat + "\",";
			
			s += "\"objectID\":\"" + id + "\",";
			s += "\"name\":\"" + name + "\",";
			s += "\"name_en\":\"" + name_en + "\",";
			s += "\"active\":\"" + _isActive + "\",";
			s += "\"isLock\":\"" + isLock + "\",";
			s += "\"isOrder\":\"" + isOrder + "\",";
			s += "\"view3d\":\"" + this.container3d.visible + "\",";
			s += "\"view2d\":\"" + (view2d?"true":"false") + "\",";
			
			if(_type)s += "\"type\":\"" + _type + "\",";
			if(_specifications)s += "\"specifications\":\"" + _specifications + "\",";
			if(_productCode)s += "\"productCode\":\"" + _productCode + "\",";
			if(_unit)s += "\"unit\":\"" + _unit + "\",";
			if(_price>0)s += "\"price\":\"" + _price + "\",";
			
			if(memo)s += "\"memo\":\"" + memo + "\",";
			
			if(_productModel)s += "\"productModel\":\"" + _productModel + "\",";
			
			if(_image2dURL)s += "\"image2dURL\":\"" + _image2dURL + "\",";
			if(_image3dURL)s += "\"image3dURL\":\"" + _image3dURL + "\",";
			
			if(dynaminReplaceName)s += "\"dynaminReplaceName\":\"" + dynaminReplaceName + "\",";
			
			if(_customMaterialName)s += "\"customMaterial\":\"" + _customMaterialName + "\",";
			
			s += getVector("position",position) + ",";
			s += getVector("rotation",rotation) + ",";
			s += getVector("scale",scale);
			
			if(modelObject)
			{
				var mi:ModelInfo = modelObject.modelInfo;
				var r:Vector3D = mi.rotation;
				s += ",\"modelColor\":" + mi.color;
				s += ",\"modelRotation\":{\"x\":"+r.x+",\"y\":"+r.y+",\"z\":"+r.z+"}";
			}
			
			if(objectInfo)s += ",\"objectInfo\":" + objectInfo.toJsonString();
			
			if(dynamicSubProductObjects && dynamicSubProductObjects.length>0)
			{
				s += ",\"subProductObjects\":["+dynamicSubProductObjects+"]";
			}
			
			if(slaveProducts && slaveProducts.length>0)
			{
				s += ",\"slaveProducts\":["+slaveProducts+"]";
				if(useUndoDelete)
				{
					s += ",\"slaveData\":[";
					
					var len:int = slaveProducts.length;
					for(var i:int=0;i<len;i++)
					{
						var objectID:String = slaveProducts[i];
						var po:ProductObject = ProductManager.own.getObject(objectID);
						if(po)
						{
							s += po.toJsonString(true) + (i<len-1?",":"");
						}
					}
					s += "]";
				}
			}
			
			if(masterProducts && masterProducts.length>0)
			{
				s += ",\"masterProducts\":["+masterProducts+"]";
			}
			
			s += "}";
			return s;
		}
		
		private function getVector(name:String,vec:Vector3D):String
		{
			var s:String = "\"" + name + "\":{";
			s += "\"x\":" + vec.x + ",";
			s += "\"y\":" + vec.y + ",";
			s += "\"z\":" + vec.z;
			s += "}";
			
			return s;
		}
	}
}

