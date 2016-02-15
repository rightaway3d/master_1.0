package rightaway3d.engine.product
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import away3d.containers.ObjectContainer3D;
	
	import rightaway3d.engine.action.PropertyAction;
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.engine.core.ModelAlign;
	import rightaway3d.engine.model.ModelInfo;
	import rightaway3d.engine.model.ModelManager;
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.parser.ModelParser;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.cabinet.CustomizeProduct2D;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallObject;

	public class ProductManager
	{
		public var engineManager:EngineManager;
		
		private var infoDict:Dictionary;
		
		private var objectDict:Dictionary;
		
		public function ProductManager()
		{
			infoDict = new Dictionary();
			objectDict = new Dictionary();
		}
		
		//==================================================
		
		public function getInfo(infoID:int):ProductInfo
		{
			return infoDict[infoID]; 
		}
		
		public function getObject(objectID:String):ProductObject
		{
			return objectDict[objectID]; 
		}
		
		//==================================================
		
		/*public function setAllCabinetDoorMaterial2(texture:String):void
		{
			loadCabinetDoorTexture2(texture);
		}*/
		
		/*private var cabinetDoorURL:String;
		public function loadCabinetDoorTexture2(url:String):void
		{
			trace("loadCabinetDoorTexture:"+url);
			if(cabinetDoorURL==url)return;
			cabinetDoorURL = url;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCabinetDoorTextureLoaded);
			loader.load(new URLRequest(url));			
		}*/
		
		/*protected function onCabinetDoorTextureLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onCabinetDoorTextureLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			//var ow:int = bmp.bitmapData.width*Room.textureScale;
			//var oh:int = bmp.bitmapData.height*Room.textureScale;
			
			//omGeom.groundTextureWidth = ow;
			//roomGeom.groundTextureHeight = oh;
			
			var bt:BitmapTexture = new BitmapTexture(BMP.scaleBmpData(bmp.bitmapData));
			
			loaderInfo.loader.unload();
			
			setProductMaterial("cabinet_door_plank",bt);
		}*/
		
		/**
		 * 设置指定类型产品的材质
		 * @param type：产品类型
		 * @param matName：材质名称
		 * @param yPos：只有当产品的y轴坐标值等于此参数时，才设置
		 * 
		 */
		public function setProductMaterial(type:String,matName:String,yPos:int=-1):void
		{
			for each(var obj:ProductObject in objectDict)
			{
				if(obj.productInfo.type==type)
				{
					if(yPos==-1 || obj.position.y==yPos)
					{
						obj.customMaterialName = matName;
					}
				}
			}
		}
		
		//==================================================
		/*public function replaceProductObjectByID(targetObjectID:int,srcInfoID:int,fileURL:String,name:String,dataFormat:String="text"):void
		{
			var po:ProductObject = getObject(targetObjectID);
			if(po)
			{
				replaceProductObject(po,srcInfoID,fileURL,name,dataFormat);
			}
		}*/
		
		private function _createProductObject(targetObject:ProductObject,srcInfoID:int,fileURL:String,name:String,width:int,depth:int,height:int,dataFormat:String="text"):ProductObject
		{
			var info:ProductInfo = this.createProductInfo(srcInfoID,fileURL,dataFormat);
			
			var objID:int = ProductObject.getNextIndex();
			var newProduct:ProductObject = this.createProductObject(info,objID,name,"",targetObject.isActive,targetObject.position);
			//trace("newProduct1:"+newProduct.position.y);
			
			//updateScale2(newProduct);
			
			if(targetObject.objectInfo)
			{
				var wo:WallObject = targetObject.objectInfo.clone();
			}
			else if(!newProduct.objectInfo)
			{
				wo = new WallObject();
			}
			else
			{
				wo = newProduct.objectInfo;
			}
			
			wo.width = width;
			wo.depth = depth;
			wo.height = height;
			wo.object = newProduct;
			newProduct.objectInfo = wo;
			//trace("wo1:",wo);
			
			if(!info.isReady)
			{
				info.addEventListener("ready",onReplaceReady);
				this.loadProduct();
				
				var d0:Vector3D = info.dimensions;
				d0.x = width;
				d0.y = height;
				d0.z = depth;
			}
			
			//trace("newProduct2:"+newProduct.position.y);
			var cw:CrossWall = targetObject.objectInfo?targetObject.objectInfo.crossWall:null;
			if(cw)
			{
				cw.removeWallObject(targetObject.objectInfo);
				
				cw.addWallObject(newProduct.objectInfo);
				var a:Number = 360 - cw.wall.angles;
				a = cw.isHead ? a+180 : a;
			}
			else
			{
				a = targetObject.container3d.rotationY;
			}
			
			addProductToScene(newProduct);
			
			if(targetObject.view2d)
			{
				CabinetController.getInstance().createProduct(newProduct);
				trace("wo2:",wo);
			}
			
			newProduct.rotation.y = newProduct.container3d.rotationY = a;
			newProduct.rotation.z = newProduct.container3d.rotationZ = targetObject.rotation.z;
			
			if(newProduct.view2d)
			{
				newProduct.view2d.rotation = a;
			}
			
			if(!targetObject.parentProductObject)
			{
				GlobalEvent.event.dispatchProductCreatedEvent(newProduct);
			}
			
			trace("dimensions:",info.dimensions);
			trace("targetObject.rotation:",targetObject.rotation);
			trace("newProduct.rotation:",newProduct.rotation);
			trace("wo3:",wo);
			return newProduct;
		}
		
		/**
		 * 替换产品对象
		 */
		public function replaceProductObject(targetObject:ProductObject,srcInfoID:int,fileURL:String,name:String,width:int,depth:int,height:int,dataFormat:String="text"):ProductObject
		{
			trace("replaceProductObject:"+targetObject.name);
			if(!targetObject.parentProductObject && targetObject.productInfo.infoID!=srcInfoID)//此产品非子产品，且目标与源不是同一个产品
			{
				var newProduct:ProductObject = this._createProductObject(targetObject,srcInfoID,fileURL,name,width,depth,height);
				newProduct.isLock = targetObject.isLock;
				newProduct.isOrder = targetObject.isOrder;
				newProduct.name = targetObject.name;
				newProduct.name_en = targetObject.name_en;
				
				targetObject.dispose();
				
				trace("replaceProductObject2:"+newProduct.name);
				return newProduct;
			}
			
			return null;
		}
		
		private function onReplaceReady(e:Event):void
		{
			var info:ProductInfo = e.currentTarget as ProductInfo;
			info.removeEventListener("ready",onReplaceReady);
		}
		
		//两个换一个产品
		public function replaceProductObject1_2(target:ProductObject,srcs:Array,dataFormat:String="text"):Array
		{
			//trace("replaceProductObject1_2:"+target.parentProductObject);
			if(target.parentProductObject)return [];//子产品不替换
			
			var cw:CrossWall = target.objectInfo.crossWall;
			
			var src1:XML,src2:XML;
			var id1:int,file1:String,id2:int,file2:String;
			var w1:int,d1:int,h1:int,w2:int,d2:int,h2:int;
			
			src1 = srcs[0];
			id1 = src1.id;
			file1 = src1.file;
			w1 = src1.width;
			d1 = src1.depth;
			h1 = src1.height;
			//trace("w1,d1,h1:",w1,d1,h1);
			var newProduct1:ProductObject = this._createProductObject(target,id1,file1,"",w1,d1,h1);
			newProduct1.isLock = target.isLock;
			newProduct1.isOrder = target.isOrder;
			
			src2 = srcs[1];
			id2 = src2.id;
			file2 = src2.file;
			w2 = src2.width;
			d2 = src2.depth;
			h2 = src2.height;
			//trace("w2,d2,h2:",w2,d2,h2);
			
			var newProduct2:ProductObject = this._createProductObject(target,id2,file2,"",w2,d2,h2);
			newProduct2.isLock = target.isLock;
			newProduct2.isOrder = target.isOrder;
			
			var wo:WallObject = newProduct2.objectInfo;
			wo.x = newProduct1.objectInfo.x - w1;
			//trace("x1:"+newProduct1.objectInfo.x);
			//trace("w1:"+w1);
			//trace("w2:"+wo.x);
			CabinetController.getInstance().setProductPos(newProduct2,cw,wo.x,wo.y,wo.z);
			this.updateProductModel(newProduct2);
			
			target.dispose();
			
			return [newProduct1,newProduct2];
		}
		
		//一个换两个产品
		public function replaceProductObject2_1(target1:ProductObject,target2:ProductObject,src1:XML,dataFormat:String="text"):ProductObject
		{
			var target:ProductObject = target1.objectInfo.x>target2.objectInfo.x?target1:target2;
			
			var id1:int,file1:String;
			var w1:int,d1:int,h1:int;
			
			id1 = src1.id;
			file1 = src1.file;
			w1 = src1.width;
			d1 = src1.depth;
			h1 = src1.height;
			
			var newProduct1:ProductObject = this._createProductObject(target,id1,file1,"",w1,d1,h1);
			newProduct1.isLock = target1.isLock;
			newProduct1.isOrder = target1.isOrder;
			
			target1.dispose();
			target2.dispose();
			
			return newProduct1;
		}
		
		public function replaceProductObject2_2(target1:ProductObject,target2:ProductObject,srcs:Array):Array
		{
			var target:ProductObject = target1.objectInfo.x>target2.objectInfo.x?target1:target2;
			var a:Array = replaceProductObject1_2(target,srcs);
			
			target==target1?target2.dispose():target1.dispose();
			
			return a;
		}
		
		//==================================================
		/*public function replaceProductObjects(targets:Array,srcIDs:Array,files:Array):void
		{
			if(targets.length==1 && srcIDs.length==1)//1个换1个
			{
				replaceProductObject(targets[0],srcIDs[0],files[0],"");
			}
			else if(targets.length==1 && srcIDs.length==2)//1个换2个
			{
				replaceProductObject1_2(targets[0],srcIDs[0],files[0],srcIDs[1],files[1]);
			}
			else if(targets.length==2 && srcIDs.length==1)//2个换1个
			{
				replaceProductObject2_1(targets[0],targets[1],srcIDs[0],files[0]);
			}
		}*/
		
		public function replaceSubProductObject(target:ModelObject,srcID:int,file:String,name:String,dataFormat:String="text"):void
		{
			var po:ProductObject = target.parentProductObject;
			
			if(po.productInfo.infoID==srcID)return;//替换目标与源目标相同
			
			if(po.parentProductObject)
			{
				var ppo:ProductObject = po.parentProductObject;
				var info:ProductInfo = this.createProductInfo(srcID,file,dataFormat);
				trace("replaceSubProductObject po.position,po.rotation:"+po.position,po.rotation);
				
				var objID:int = po.id;
				var newProduct:ProductObject = this.createProductObject(info,objID,name,"",po.isActive,po.position,po.rotation);
				newProduct.isLock = po.isLock;
				newProduct.isOrder = po.isOrder;
				newProduct.objectID = po.objectID;
				newProduct.dynaminReplaceName = po.dynaminReplaceName;
								
				po.dispose();
				
				ppo.addDynamicSubProduct(newProduct);//替换的子产品为动态子产品
				
				//updateScale2(newProduct);
				
				this.loadProduct();
			}
		}
		
		//==================================================
		//private var dict:Dictionary = new Dictionary();
		
		private var houseDX:Number = 0;
		private var houseDZ:Number = 0;
		public function updateProductPosition(dx:Number,dz:Number):void
		{
			houseDX = dx;
			houseDZ = dz;
			//trace("----updateProductPosition");
			for each(var obj:ProductObject in objectDict)
			{
				if(!obj.parentProductObject)
				{
					var c:ObjectContainer3D = obj.container3d;
					c.x = obj.position.x + dx;
					c.z = obj.position.z + dz;
					c.y = obj.position.y;
				}
			}
		}
		
		//==================================================
		//解析产品信息
		public function addDynamicSubProduct(parent:ProductObject,subData:*):ProductObject
		{
			if(subData is ProductObject)
			{
				pObj = subData;
				//info = pObj.productInfo;
			}
			else
			{
				var info:ProductInfo = getProductInfo(subData);
				var pObj:ProductObject = _parseProductObject(subData);
				info.addProductObject(pObj);
			}
			
			//pObj.id = parent.getNextIndex();//重置id
			//trace("addDynamicSubProduct objectID:"+pObj.id);
			
			parent.addDynamicSubProduct(pObj);
			
			//setProductObject(pObj,info);
			
			//updateScale2(pObj);
			
			//parent.dynamicSubProductObjects ||= new Vector.<ProductObject>();
			//parent.dynamicSubProductObjects.push(pObj);
			//info.cloneToProductObject(pObj);//如果此产品已经存在，将会直接创建出来
			
			this.loadProduct();//如果此产品信息未加载，将会立即加载
			
			return pObj;
		}
		
		//==================================================
		
		//解析产品信息
		public function parseProductInfo(xml:XML):ProductInfo
		{
			var id:int = xml.id;
			if(! infoDict[id])
				throw new Error("找不到指定ID的产品信息:"+id);
			
			var pInfo:ProductInfo = infoDict[id];
			if(pInfo.infoID!=id)
				throw new Error("指定的产品信息ID[" + pInfo.infoID + "]与找到的产品信息ID[" + id + "]不一致！");
			
			if(xml.name!=undefined)pInfo.name = xml.name;
			if(xml.name_en!=undefined)pInfo.name_en = xml.name_en;
			if(xml.type!=undefined)pInfo.type = xml.type;
			
			if(xml.productCode!=undefined)pInfo.productCode = xml.productCode;//物料编码
			if(xml.productModel!=undefined)pInfo.productModel = xml.productModel;//产品型号
			
			if(xml.category!=undefined)pInfo.category = xml.category;
			if(xml.version!=undefined)pInfo.version = xml.version;
			if(xml.style!=undefined)pInfo.style = xml.style;
			
			if(xml.productID!=undefined)pInfo.productID = xml.productID;
			if(xml.dscp!=undefined)pInfo.dscp = xml.dscp;
			if(xml.memo!=undefined)pInfo.memo = xml.memo;
			
			if(xml.unit!=undefined)pInfo.unit = xml.unit;
			if(xml.price!=undefined)pInfo.price = xml.price;
			if(xml.specifications!=undefined)pInfo.specifications = xml.specifications;
			
			if(xml.image2dURL!=undefined)pInfo.image2dURL = xml.image2dURL;
			if(xml.image3dURL!=undefined)pInfo.image3dURL = xml.image3dURL;
			
			if(xml.tag!=undefined)
			{
				var tag:String = xml.tag;
				pInfo.tags = tag.split(",");
			}
			else
			{
				pInfo.tags = [];
			}
			
			if(xml.align!=undefined)
			{
				var s:String = xml.align;
				pInfo.aligns = s.split("|");
			}
			else
			{
				pInfo.aligns = [];
			}
			
			if(xml.align.@dx!=undefined)pInfo.alignOffset.x = xml.align.@dx;
			if(xml.align.@dy!=undefined)pInfo.alignOffset.y = xml.align.@dy;
			if(xml.align.@dz!=undefined)pInfo.alignOffset.z = xml.align.@dz;
			//trace("+++++++++++alignOffset:"+pInfo.alignOffset,pInfo.infoID);
			
			pInfo.scale = (xml.scale!=undefined)?parseVectorStr(xml.scale):new Vector3D(1,1,1);;
			
			pInfo.dimensions = (xml.dimensions!=undefined)?parseVectorStr(xml.dimensions):new Vector3D();
			//trace("---------pInfo.dimensions:"+pInfo.dimensions,typeof(xml.dimensions));
			
			if(xml.actions!=undefined)
			{
				var actionList:XMLList = xml.actions.action;
				//trace("-----------------------------------actions:"+actionList);
				len = actionList.length();
				
				if(len>0)
				{
					var actions:Vector.<PropertyAction> = new Vector.<PropertyAction>(len);
					
					for(i=0;i<len;i++)
					{
						var action:PropertyAction = PropertyAction.parse(actionList[i]);
						actions[i] = action;
					}
					pInfo.actions = actions;
					//pInfo.updateAction();
					trace(pInfo.infoID+":"+pInfo.actions.length);
				}
			}
			
			if(xml.model!=undefined)
			{
				var m:XML = xml.model[0];
				var mInfo:ModelInfo = ModelManager.own.getModelInfo(m);//获取此产品所关联的模型信息
				//mInfo.products.push(pInfo);//在模型信息添加关联的产品信息
				
				pInfo.modelInfo = mInfo;
				//pInfo.modelInstance = mInfo.ownModelInstance;
				//pInfo.ownProductInstance.modelObject = mInfo.ownModelInstance;
				
				//trace("parseProductInfo:"+pInfo.fileURL);
				//trace("mInfo.materials:"+mInfo.materials);
				/*if(!mInfo.materials)
				{
				if(pInfo.type=="cabinet_door_plank")
				{
				var md:Object = MaterialLibrary.instance.getMaterialData(RenderUtils.getDefaultMaterial('cabinetDoor'));
				} else if (pInfo.type=="cabinet_body_plank") {
				md = MaterialLibrary.instance.getMaterialData(RenderUtils.getDefaultMaterial('cabinetBody'));
				}
				//trace("md:"+md);
				if(md)
				{
				mInfo.materials = new Vector.<MaterialBase>(1);
				mInfo.materials[0] = md.material;
				}
				}*/
				
				//复制子产品
				pInfo.cloneToAllProductObject();
			}
			else if(xml.subProduct!=undefined)
			{
				var subProduct:XML = xml.subProduct[0];
				var ps:XMLList = subProduct.item;
				var len:int = ps.length();
				
				pInfo.subProductInstances = new Vector.<ProductObject>(len);
				
				for(var i:int=0;i<len;i++)
				{
					var subXML:XML = ps[i];
					//parseProductObject(subXML,pInfo);
					pInfo.subProductInstances[i] = createSubProduct(subXML);//创建子产品
				}
				
				//trace("infoID:"+pInfo.infoID+" childrens:"+subProduct.children().length()+" products:"+len);
				if(subProduct.children().length()>len)//总的子产品数量大于固定子产品数量时，有动态子产品
				{
					pInfo.subProductData = subProduct;
				}
				//setDynamicProduct(pInfo);
				
				//复制子产品
				pInfo.cloneToAllProductObject();
			}
			else
			{
				//trace("ProductInfo Error:"+xml);
				//既没有子产品，也没有模型的产品，只能作为子产品存在，用于数据统计，而不需要显示的产品
			}
			
			pInfo.isReady = true;
			pInfo.dispatchReadyEvent();
			
			return pInfo;
		}
		
		private var lib:CabinetLib = CabinetLib.lib;
		
		public function setDynamicProduct(pInfo:ProductInfo):void
		{
			if(!pInfo.subProductData)return;
			
			var subProduct:XML = pInfo.subProductData;//所有子产品数据
			
			var dynamicProductList:Array = lib.getDynamicProductList();//动态产品名称列表
			var len:int = dynamicProductList.length;
			
			for(var i:int=0;i<len;i++)
			{
				var name:String = dynamicProductList[i];
				//trace(name+":"+(subProduct[name]!=undefined));
				
				if(subProduct[name]!=undefined)//子产品中存在动态子产品
				{
					var dynamicProductData:XML = lib.getDynamicProductData(name);
					
					var productsData:XMLList = subProduct[name];
					var plen:int = productsData.length();
					
					//trace("--------productsData:"+plen);
					//trace(productsData);
					
					for(var j:int=0;j<plen;j++)//遍历动态子产品
					{
						var productData:XML = productsData[j];
						if(dynamicProductData)//更新动态子产品数据
						{
							var id:String = dynamicProductData.infoID;
							var file:String = dynamicProductData.file;
							productData.infoID = id;
							productData.file = file;
						}

						//var name2:String = name + "_" + String(j);
						var name2:String = name + "_" + productData.objectID;
						//trace("--------------setDynamicProduct:"+name2);
						
						var pos:Array = pInfo.getProductObjects();//获取当前产品的所有实例
						var tlen:int = pos.length;
						
						//trace(pInfo.fileURL+" pos:"+tlen);
						
						for(var k:int=0;k<tlen;k++)//遍历产品实例，为每一个实例创建子产品
						{
							//trace("k:"+k);
							var po:ProductObject = pos[k];
							if(!po.hasDynamicProduct(name2))//当前子产品还未被创建
							{
								/*var p:ProductObject = parseProductObject(productData,po);
								p.dynaminReplaceName = name2;*/
								
								var info:ProductInfo = getProductInfo(productData);
								var pObj:ProductObject = _parseProductObject(productData);
								pObj.dynaminReplaceName = name2;
								
								info.addProductObject(pObj);
								
								po.addDynamicSubProduct(pObj);
								
								//if(po.parentProductObject)trace("parent:"+po.parentProductObject.toJsonString());
								
								//trace("DynamicSubProduct:"+po.parentProductObject.toJsonString());
								//trace("DynamicSubProduct2:"+pObj.toJsonString());
							}
						}
					}
				}
			}
		}
		
		private function createSubProduct(xml:XML):ProductObject
		{
			var info:ProductInfo = getProductInfo(xml);
			//trace("info:"+info.fileURL);
			var o:ProductObject = _parseProductObject(xml);
			//info.ownProductInstance = o;
			o.productInfo = info;
			//info.addProductObject(o);
			return o;
		}
		
		//==================================================
		public function createRootProductObject(data:XML):ProductObject
		{
			var vo:ProductObject = getProductObject(data);
			addProductToScene(vo);
			
			return vo;
		}
		
		public function getProductObject(data:XML):ProductObject
		{
			var id:int = data.id;
			var file:String = data.file;
			var width:int = data.width;
			var height:int = data.height;
			var depth:int = data.depth;
			var name:String = data.name;
			
			var oid:int = ProductObject.getNextIndex();
			
			//var vo:ProductObject = addProductObject(oid,name,id,file);
			var info:ProductInfo = createProductInfo(id,file,"text");;
			if(!info.isReady)
			{
				loadProduct();
			}
			
			var vo:ProductObject = createProductObject(info,oid,name);
			
			var wo:WallObject = vo.objectInfo;
			wo.width = width;
			wo.height = height;
			wo.depth = depth;
			
			return vo;
		}
		
		public function addProductObject(objID:int,objName:String,infoID:int,fileURL:String,dataFormat:String="text"):ProductObject
		{
			var info:ProductInfo = createProductInfo(infoID,fileURL,dataFormat);;
			if(!info.isReady)
			{
				loadProduct();
			}
			
			var pObj:ProductObject = createProductObject(info,objID,objName);
			
			//setProductObject(pObj,info);
			
			//engineManager.addRootChild(pObj.container3d);
			//engineManager.addCollisionObject(pObj.container3d);
			
			//info.createSubObject(pObj);
			addProductToScene(pObj);
			
			return pObj;
		}
		
		public function addProductToScene(pObj:ProductObject):void
		{
			//pObj.createContainer3D();
			
			engineManager.addRootChild(pObj.container3d);
			engineManager.addCollisionObject(pObj.container3d);
			
			setDynamicProduct(pObj.productInfo);
			
			setProductObject(pObj);
			
			updateProductModel(pObj);
			//trace("addProductToScene:",pObj,pObj.productInfo);
			
			flash.utils.setTimeout(cloneObject,100,pObj);
		}
		
		private function cloneObject(pObj:ProductObject):void
		{
			pObj.productInfo.cloneToProductObject(pObj);
			ProductInfo.setDefaultMaterial(pObj);
		}
		
		/**
		 * 创建自定义尺寸产品对象
		 */
		public function createCustomizeProduct(modelType:String,pName:String,enName:String,width:int,height:int,depth:int,color:uint,
													  isActive:Boolean=true,infoID:int=0,objID:int=0,rotation:Vector3D=null):ProductObject
		{
			if(infoID==0)
			{
				infoID = CustomizeProduct2D.getNextIndex();
			}
			else
			{
				CustomizeProduct2D.setNextIndex(infoID);//重置产品id号，避免新创建的产品id重复
			}
			
			if(objID==0)objID = ProductObject.getNextIndex();
			
			var aligns:Array = [ModelAlign.BOTTOM,ModelAlign.LEFT,ModelAlign.FRONT];
			
			var po:ProductObject = createCustomizeProductObject(modelType,infoID,objID,pName,enName,width,height,depth,color,aligns,isActive);
			
			var mi:ModelInfo = po.productInfo.modelInfo;
			
			if(rotation)
			{
				mi.rotation.x = rotation.x;
				mi.rotation.y = rotation.y;
				mi.rotation.z = rotation.z;
			}
			
			ModelParser.own.addModel(mi,true);
			
			return po;
		}
		
		/**
		 * 创建自定义尺寸产品对象
		 */
		private function createCustomizeProductObject(modelType:String,infoID:int,objID:int,objName:String,enName:String,width:int,height:int,depth:int,color:uint,aligns:Array=null,isActive:Boolean=true):ProductObject
		{
			var pInfo:ProductInfo = createProductInfo(infoID);
			if(aligns)pInfo.aligns = aligns;
			pInfo.dimensions.x = width;
			pInfo.dimensions.y = height;
			pInfo.dimensions.z = depth;
			pInfo.type = "CustomizeObject";
			
			var pObj:ProductObject = createProductObject(pInfo,objID,objName,enName,isActive);
			
			//setProductObject(pObj,pInfo);
			
			//updateScale(pObj);
			
			var mInfo:ModelInfo = ModelManager.own.getModelInfoByID(infoID);//创建此产品所关联的模型信息
			mInfo.modelType = modelType;
			mInfo.bounds = pInfo.dimensions;
			mInfo.color = color;
			
			//engineManager.addRootChild(pObj.container3d);
			//engineManager.addCollisionObject(pObj.container3d);
			//mInfo.products.push(pInfo);//在模型信息添加关联的产品信息
			
			pInfo.modelInfo = mInfo;
			
			var wo:WallObject = new WallObject();
			wo.width = width;
			wo.height = height;
			wo.depth = depth;
			
			wo.type = modelType;
			
			wo.object = pObj;
			
			pObj.objectInfo = wo;
			
			//复制子产品
			//pInfo.createSubObject(pObj);
			return pObj;
		}
		
		public function createProductObject(info:ProductInfo,objID:int,name:String,name_en:String="",isActive:Boolean=true,position:Vector3D=null,rotation:Vector3D=null):ProductObject
		{
			var o:ProductObject = new ProductObject();
			o.id = objID;
			o.name = name;
			o.name_en = name_en;
			o.isActive = isActive;
			
			o.position = position ? position.clone() : new Vector3D();
			o.rotation = rotation ? rotation.clone() : new Vector3D();
			o.scale = new Vector3D(1,1,1);
			
			o.objectInfo = new WallObject();
			o.objectInfo.object = o;
			
			info.addProductObject(o);
			
			return o;
		}
		
		//==================================================
		/**
		 * 解析保存的产品数据，创建产品实例
		 * @param xml 产品实例信息（配置文件名，位置，缩放，旋转）
		 * @param parentProductInfo 当前产品的父产品，未指定时，产品实例模型放置于根场景，否则产品实例作为子产品存在
		 * 
		 */
		public function parseProductObject(data:Object,parent:ProductObject=null):ProductObject
		{
			var type:String = data.objectInfo?data.objectInfo.type:"";
			//trace("parseProductObject name:"+data.name+" file:"+data.file);
			
			if(type==ModelType.BOX_C || type==ModelType.CYLINDER_C)//用户动态创建的物体
			{
				var modelColor:uint = data.modelColor?data.modelColor:0;
				var isActive:Boolean = data.active=="true"?true:false;
				
				var objData:Object = data.objectInfo;
				var rot:Vector3D = data.modelRotation?parseVectorStr(data.modelRotation):null;
				var rot2:Vector3D = parseVectorStr(data.rotation);

				//createCustomizeProduct(type,pName,radius*2,height,radius*2,color,isActive);
				//创建自定义产品
				pObj = createCustomizeProduct(type,data.name,data.name_en,objData.width,objData.height,objData.depth,modelColor,isActive,0,0,rot);
				
				var pos:Object = data.position;
				pObj.position.x = pos.x;
				pObj.position.y = pos.y;
				pObj.position.z = pos.z;
				
				pObj.rotation = rot2;
			}
			else
			{
				var info:ProductInfo = getProductInfo(data);
				var pObj:ProductObject = _parseProductObject(data);
				info.addProductObject(pObj);
			}
			
			if(parent)
			{
				parent.addDynamicSubProduct(pObj);
			}
			else
			{
				addProductToScene(pObj);
				
				ProductObject.setNextIndex(pObj.id);//重置产品对象id号，避免新创建的产品对象id重复
				setObjectInfo(data,pObj);
			}
			
			if(data.image2dURL)pObj.image2dURL = data.image2dURL;
			if(data.image3dURL)pObj.image3dURL = data.image3dURL;
			
			if(data.view3d)pObj.container3d.visible = data.view3d=="true"?true:false;
			if(data.memo)pObj.memo = data.memo;
			if(data.type)pObj.type = data.type;
			if(data.unit)pObj.unit = data.unit;
			if(data.price)pObj.price = data.price;
			if(data.productCode)pObj.productCode = data.productCode;
			if(data.productModel)pObj.productModel = data.productModel;
			if(data.specifications)pObj.specifications = data.specifications;
			if(data.customMaterial)pObj.customMaterialName = data.customMaterial;
			if(data.dynaminReplaceName)pObj.dynaminReplaceName = data.dynaminReplaceName;
			
			if(data.subProductObjects)
			{
				var subs:Array = data.subProductObjects;
				for each(var sub:Object in subs)
				{
					parseProductObject(sub,pObj);
				}
			}
			
			/*if(data.slaveProducts)
			{
				pObj.slaveProducts = data.slaveProducts;
				
				if(data.slaveData)
				{
					var slaves:Array = data.slaveData;
					var len:int = slaves.length;
					for(var i:int=0;i<len;i++)
					{
						var slavePO:ProductObject = parseProductObject(slaves[i]);
						var masters:Array = slavePO.masterProducts;
						var len2:int = masters.length;
						for(var j:int=0;j<len2;j++)
						{
							var id:String = masters[j];
							var masterPO:ProductObject = this.getObject(id);
							if(masterPO)
							{
								masterPO.addSlaveProduct(slavePO);
							}
						}
					}
				}
			}*/
			
			if(data.masterProducts)
			{
				pObj.masterProducts = data.masterProducts;
				//trace("------------"+pObj.toString());
				
//				var wo:WallObject = pObj.objectInfo;
//				CabinetController.getInstance().setProductPos(pObj,wo.x,wo.y,wo.z);
			}
			
			return pObj;
		}
		
		private function setObjectInfo(data:Object,po:ProductObject):void
		{
			if(data.objectInfo!=undefined)
			{
				var objData:Object = data.objectInfo;
				var wo:WallObject = new WallObject();
				wo.x = objData.x;
				wo.y = objData.y;
				wo.z = objData.z;
				wo.width = objData.width;
				wo.height = objData.height;
				wo.depth = objData.depth;
				wo.type = objData.type;
				
				wo.isIgnoreObject = objData.isIgnoreObject=="true"?true:false
				
				wo.object = po;
				po.objectInfo = wo;
				
				if(objData.crossWall!=undefined)
				{
					var w:Object = objData.crossWall;
					var index:int = w.index;
					var isHead:String = w.isHead;
					
					//var wall:Wall = wallDict[index];
					var wall:Wall = house.currFloor.getWall(index);
					var cw:CrossWall = isHead=="true"?wall.frontCrossWall:wall.backCrossWall;
					cw.addWallObject(wo);
					
					//CabinetController.getInstance().setProductPos(po,wo.x,wo.y,wo.z);
				}
			}
		}
		
		private var house:House = House.getInstance();
		
		//==================================================
		private function getProductInfo(data:Object):ProductInfo
		{
			var infoID:int = data.infoID;
			var fileURL:String = data.file;
			var dataFormat:String = data.dataFormat;
			return createProductInfo(infoID,fileURL,dataFormat);
		}
		
		public function createProductInfo(infoID:int,fileURL:String="",dataFormat:String=""):ProductInfo
		{
			var info:ProductInfo = infoDict[infoID];
			//trace("createProductInfo:",infoID,infoDict[infoID]);
			if(!info)
			{
				info = new ProductInfo();
				info.infoID = infoID;
				info.fileURL = fileURL;
				info.dataFormat = dataFormat;
				
				infoDict[infoID] = info;
				
				if(fileURL)ProductInfoLoader.own.addInfo(info);
				
				if(infoID<0)
				{
					CustomizeProduct2D.setNextIndex(infoID);//重置产品id号，避免新创建的产品id重复
				}
			}
			//trace("createProductInfo2:",infoID,infoDict[infoID]);
			
			return info;
		}
		
		public function deleteProductInfo(info:ProductInfo):Boolean
		{
			//throw new Error();
			
			//trace("-----deleteProductInfo:"+info.infoID);
			if(infoDict[info.infoID]==info)
			{
				delete infoDict[info.infoID];
				return true;
			}
			return false;
		}
		
		//==================================================
		
		private function _parseProductObject(data:Object):ProductObject
		{
			var po:ProductObject = new ProductObject();
			po.id = data.objectID;
			
			po.name = data.name;
			po.name_en = data.name_en;
			//po.type2 = data.type;
			
			var active:String = data.active;
			po.isActive = active == "true" ? true : false;
			
			po.isLock = data.isLock=="true"?true:false;
			
			po.isOrder = data.isOrder=="false"?false:true;//默认为true
			
			po.position = parseVectorStr(data.position);
			po.rotation = parseVectorStr(data.rotation);
			po.scale = parseVectorStr(data.scale);
			
			//trace("---------------------------memo:"+data.memo);
			if(data.memo!=undefined)po.memo=data.memo;
			
			return po;
		}
		
		private function parseVectorStr(data:Object,delim:String=","):Vector3D
		{
			//trace("parseVectorStr:"+(typeof(data)=="xml"));
			if(typeof(data)=="xml")
			{
				var a:Array = String(data).split(delim);
				return new Vector3D(a[0],a[1],a[2]);
			}
			return new Vector3D(data.x,data.y,data.z);
		}
		
		public function updateProductModel(obj:ProductObject):void
		{
			//trace("updateProductModel:"+obj.productInfo.infoID);
			var container:ObjectContainer3D = obj.container3d;
			var infoScale:Vector3D = obj.productInfo.scale;
			
			if(obj.parentProductObject)
			{
				container.position = obj.position;
			}
			else
			{
				container.x = obj.position.x + houseDX;
				container.z = obj.position.z + houseDZ;
				container.y = obj.position.y;
				//trace("-------container:",container.x,container.y,container.z,obj.position,houseDX,houseDZ);
			}
			
			container.rotationX = obj.rotation.x;
			container.rotationY = obj.rotation.y;
			container.rotationZ = obj.rotation.z;
			
			container.scaleX = obj.scale.x * infoScale.x;
			container.scaleY = obj.scale.y * infoScale.y;
			container.scaleZ = obj.scale.z * infoScale.z;
			
			if(container.scaleX!=1)
			{
				//trace("-----------setProductObject:"+container.scale,obj.scale,infoScale);
			}
		}
		
		//==================================================
		public function setProductObject(obj:ProductObject):void
		{
			//trace("");
			//trace("--setProductObject:"+obj.id,obj.productInfo.fileURL);
			
			//trace("objectID1:"+obj.objectID);
			if(objectDict[obj.objectID])
			{
				delete objectDict[obj.objectID];
				//trace(obj);
				//throw new Error();
			}
			
			var objectID:String = String(obj.id);
			//trace("objectID2:"+objectID);
			var p:ProductObject = obj.parentProductObject;
			while(p)
			{
				objectID = p.id + "_" + objectID;
				p = p.parentProductObject;
			}
			
			obj.objectID = objectID;
			trace("objectID3:"+obj.objectID);
			
			if(objectDict[obj.objectID])
			{
				var o:ProductObject = objectDict[obj.objectID];
				//trace("old data:"+o);
				throw new Error("当前添加的产品实例已经存在:"+obj);
			}
			
			objectDict[objectID] = obj;
		}
		
		//==================================================
		
		/**
		 * 查找指定类型的产品信息
		 * @param type：要查找的类型
		 * @return Array:[ProductInfo...]
		 * 
		 */
		public function getProductsByType(type:String):Array
		{
			var a:Array = [];
			for each(var info:ProductInfo in infoDict)
			{
				//trace(info.type);
				if(info.type==type)
				{
					a.push(info);
				}
			}
			return a;
		}
		
		/**
		 * 查找指定类型的产品实例
		 * @param type：要查找的类型
		 * @return Array:[ProductObject...]
		 * 
		 */
		public function getProductObjectsByType(type:String):Array
		{
			var a:Array = [];
			for each(var po:ProductObject in objectDict)
			{
				if(po.type==type)
				{
					a.push(po);
				}
			}
			
			return a;
		}
		
		/**
		 * 获取指定产品的指定类型的子产品
		 * @param parent：指定产品
		 * @param type：指定类型
		 * @param subs：找到的子产品将在此集合中返回
		 * 
		 */
		public function getSubProductObjectsByType(parent:ProductObject,type:String,result:Array):void
		{
			if(parent.subProductObjects)findProductObjectsByType(parent.subProductObjects,type,result);
			if(parent.dynamicSubProductObjects)findProductObjectsByType(parent.dynamicSubProductObjects,type,result);
		}
		
		private function findProductObjectsByType(pos:Vector.<ProductObject>,type:String,result:Array):void
		{
			for each(var po:ProductObject in pos)
			{
				if(po.type==type)
				{
					result.push(po);
				}
				else
				{
					getSubProductObjectsByType(po,type,result);
				}
			}
			
		}
		
		public function deleteProductObjectsByType(type:String):void
		{
			var a:Array = getProductObjectsByType(type);
			for each(var po:ProductObject in a)
			{
				po.dispose();
			}
		}
		
		public function getProductObjectsByEnName(enName:String):Array
		{
			var a:Array = [];
			for each(var po:ProductObject in objectDict)
			{
				if(po.name_en==enName)
				{
					a.push(po);
				}
			}
			
			return a;
		}
		
		public function deleteProductObjectsByEnName(enName:String):void
		{
			var a:Array = getProductObjectsByEnName(enName);
			for each(var po:ProductObject in a)
			{
				po.dispose();
			}
		}
		
		//==================================================
		
		public function removeProductObject(pObj:ProductObject):Boolean
		{
			if(objectDict[pObj.objectID]==pObj)
			{
				trace("removeProductObject:",pObj.objectID);
				delete objectDict[pObj.objectID];
				//trace(pObj);
				//throw new Error();
				return true;
			}
			return false;
		}
		
		public function getRootProductByName(name:String):ProductObject
		{
			for each(var pb:ProductObject in objectDict)
			{
				if(!pb.parentProductObject && pb.name==name)
				{
					return pb;
				}
			}
			return null;
		}
		
		public function getRootProductsByName(name:String):Array
		{
			var a:Array = [];
			for each(var pb:ProductObject in objectDict)
			{
				if(!pb.parentProductObject && pb.name==name)
				{
					a.push(pb);
				}
			}
			return a;
		}
		
		public function getProductByName(name:String):ProductObject
		{
			for each(var pb:ProductObject in objectDict)
			{
				//trace(pb.productInfo.fileURL,pb.name);
				if(pb.name==name)
				{
					return pb;
				}
			}
			return null;
		}
		
		public function getProductsByName(name:String):Array
		{
			var a:Array = [];
			for each(var pb:ProductObject in objectDict)
			{
				//trace(pb.productInfo.fileURL,pb.name);
				if(pb.name==name)
				{
					a.push(pb);
				}
			}
			return a;
		}
		
		/*public function getProductObjects2():Array
		{
			var a:Array = [];
			for each(var pb:ProductObject in objectDict)
			{
				if(!pb.parentProductObject)
				{
					a.push(pb);
				}
			}
			return a;
		}*/
		
		public function getRootProductObjects():Array
		{
			var a:Array = [];
			for each(var pb:ProductObject in objectDict)
			{
				if(!pb.parentProductObject)
				{
					a.push(pb);
				}
			}
			return a;
		}
		
		public function clearRootProductObject():void
		{
			var pos:Array = getRootProductObjects();
			for each(var po:ProductObject in pos)
			{
				po.dispose();
			}
		}
		
		public function getRootProductJsonString():String
		{
			var a:Array = getRootProductObjects();
			var s:String = "[";
			s += a;
			s += "]";
			/*var len:int = a.length;
			for(var i:int=0;i<len;i++)
			{
				var po:ProductObject = a[i];
			}*/
			return s;
		}
		
		public function getRootParent(po:ProductObject):ProductObject
		{
			while(po.parentProductObject)
			{
				po = po.parentProductObject;
			}
			return po;
		}
		
		//==================================================
		private var loader:ProductInfoLoader = ProductInfoLoader.own;
		public function loadProduct():void
		{
			//trace("-------------start load productInfo");
			if(loader.hasNotLoaded && !loader.isLoading)//加载器中还存在未加载的内容，同时加载器也不在加载中，则启动加载
			{
				loader.startLoad();
			}
		}
		
		//==================================================
		static private var _own:ProductManager;
		static public function get own():ProductManager
		{
			_own ||= new ProductManager();
			return _own;
		}
	}
}
/*
parseProductObject->productObject::productInfo->productInfoList
loadProductInfo
 * */

















