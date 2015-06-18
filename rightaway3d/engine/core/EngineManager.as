package rightaway3d.engine.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.PlanarReflectionMethod;
	import away3d.primitives.RegularPolygonGeometry;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.PlanarReflectionTexture;
	
	import rightaway3d.engine.action.PropertyAction;
	import rightaway3d.engine.model.MirrorInfo;
	import rightaway3d.engine.model.ModelInfo;
	import rightaway3d.engine.model.ModelInfoLoader;
	import rightaway3d.engine.model.ModelLoader;
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.engine.model.ReflectionInfo;
	import rightaway3d.engine.parser.ModelParser;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductInfoLoader;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.engine.utils.GlobalVar;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view3d.Room3D;
	import rightaway3d.house.view3d.Wall3D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	
	import ztc.meshbuilder.room.CabinetTable3D;
	import ztc.meshbuilder.room.DragObject;

	public class EngineManager
	{
		public var engine3d:Engine3D;
		
		private var modelLoader:ModelLoader;
		private var modelParser:ModelParser;
		
		private var productManager:ProductManager;
		
		private var gevent:GlobalEvent = GlobalEvent.event;
		private var gvar:GlobalVar = GlobalVar.own;
		
		public function EngineManager(engine3d:Engine3D,modelLoader:ModelLoader,modelParser:ModelParser)
		{
			this.engine3d = engine3d;
			this.modelLoader = modelLoader;
			this.modelParser = modelParser;
			
			modelLoader.addEventListener("model_loaded",onModelLoaded);
			modelLoader.addEventListener("all_model_loaded",onAllModelLoaded);
			
			modelParser.addEventListener("model_parsed",onModelParsed);
			modelParser.addEventListener("all_model_parsed",onAllModelParsed);
			
			productManager = ProductManager.own;
			productManager.engineManager = this;
			
			gevent.addEventListener("ground_mouse_down",unSelectCurrProduct);
			gevent.addEventListener("ceiling_mouse_down",unSelectCurrProduct);
			gevent.addEventListener("wall_mouse_down",unSelectCurrProduct);
			gevent.addEventListener("cross_wall_mouse_down",unSelectCurrProduct);
			gevent.addEventListener("cabinet_table_mouse_down",unSelectCurrProduct);
			
			engine3d.view.stage.addEventListener(MouseEvent.RIGHT_CLICK,onStageRightClick);
		}
		
		private function onAllModelParsed(e:Event):void
		{
			if(ProductInfoLoader.own.hasNotLoaded || ModelInfoLoader.own.hasNotLoaded)return;
			
			updateCubeReflection();
		}
		
		public function updateCubeReflection(delay:uint=1000):void
		{
			trace("updateCubeReflection");
			setTimeout(function():void {
				engine3d.updateCubeReflection();
			},delay);
		}
		
		private function onModelParsed(event:Event):void
		{
			var modelInfo:ModelInfo = modelParser.currModel;
			//trace("EngineManager onModelParsed:"+modelInfo.modelFileURL);
			
			setModelMirror(modelInfo);
			//setModelReflection(modelInfo);
			setMaterialLightPicker(modelInfo);
			
			cloneModelObject(modelInfo);
		}
		
		/**
		 * 在解析完模型之后，将模型复制到模型信息的每一个实例中
		 * @param modelInfo
		 * 
		 */
		private function cloneModelObject(modelInfo:ModelInfo):void
		{
			var ms:Array = modelInfo.getModelObjects();
			for each(var modelObj:ModelObject in ms)
			{
				modelObj.cloneFromInfo();
				
				var ppo:ProductObject = modelObj.parentProductObject;
				//trace("model:"+modelObj.modelInfo.infoFileURL+"  product:"+ppo.productInfo.fileURL);
				ppo.setCustomMaterial();
				
				var b:Vector3D = new Vector3D();//将返回模型的包围盒尺寸
				engine3d.addChildMeshs(modelObj.meshs,ppo.container3d,ppo.productInfo.aligns,ppo.productInfo.alignOffset,false,b);
				
				var r:Vector3D = modelInfo.rotation;
				if(r.x!=0 || r.y!=0 || r.z!=0)//如果设置了模型旋转角度，要重置模型的长宽高尺寸
				{
					var d:Vector3D = ppo.productInfo.dimensions;
					//var c:ObjectContainer3D = ppo.container3d;
					d.x = b.x;
					d.y = b.y;
					d.z = b.z;
				}
				addModelEvent(modelObj);
			}
		}
		
		public var rootContainer:ObjectContainer3D;
		
		/**
		 * 创建根产品对象
		 * 
		 */
		public function addRootChild(obj:ObjectContainer3D):void
		{
			//trace("addRootChild:"+rootContainer);
			if(rootContainer)
			{
				rootContainer.addChild(obj);
			}
			else
			{
				engine3d.addRootChild(obj);
			}
		}
		
		public function removeRootChild(obj:ObjectContainer3D):void
		{
			//trace("removeRootChild:"+rootContainer,obj.parent,(obj.parent==rootContainer));
			if(rootContainer)
			{
				rootContainer.removeChild(obj);
			}
			else
			{
				engine3d.removeRootChild(obj);
			}
		}
		
		public function addChildMeshs(meshs:Vector.<Mesh>,parent:ObjectContainer3D,aligns:Array,offset:Vector3D,bothSides:Boolean=false):void
		{
			engine3d.addChildMeshs(meshs,parent,aligns,offset,bothSides,null);
		}
		
		private function setMaterialLightPicker(modelInfo:ModelInfo):void
		{
			if(modelInfo.materials)
			{
				for each(var mat:MaterialBase in modelInfo.materials)
				{
					mat.lightPicker = engine3d.lightPicker;
				}
			}
		}
		
		private function setModelMirror(modelInfo:ModelInfo):void
		{
			if(modelInfo.mirrors)
			{
				for each(var mr:MirrorInfo in modelInfo.mirrors)
				{
					var mesh:Mesh = initMirror(mr);
					modelInfo.meshs.push(mesh);
				}
			}
			/*var mesh:Mesh = modelInfo.getMeshByName("mirror");
			if(mesh && mesh.material is TextureMaterial)
			{
				trace("setModelReflection:"+mesh.material);
				var reflectionTexture:PlanarReflectionTexture = engine3d.getPlanarReflectionTexture();
				var reflectionMethod:PlanarReflectionMethod = new PlanarReflectionMethod(reflectionTexture);
				
				var mat:TextureMaterial = TextureMaterial(mesh.material);
				mat.addMethod(reflectionMethod);
				reflectionTexture.applyTransform(mesh.sceneTransform);
				
				trace("alpha:"+mat.alpha);
				trace("specular:"+mat.specular);
				mat.alpha = 1;
				mat.specular = 0.2;
			}*/
		}
		
		
		private function initMirror(mr:MirrorInfo) : Mesh
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
			//trace("-----------------------rotation:"+mr.position,mr.rotation,mr.alpha);

			reflectionTexture.applyTransform(mesh.sceneTransform);
			
			return mesh;
		}
		
		private function setModelReflection(modelInfo:ModelInfo):void
		{
			//trace("-----------------------setModelReflection:"+modelInfo.reflections);
			if(modelInfo.reflections2)
			{
				var len:int = modelInfo.reflections2.length;
				for(var i:int=0;i<len;i++)
				{
					var ref:ReflectionInfo = modelInfo.reflections2[i];
					var mat:MaterialBase = modelInfo.getMaterialByName(ref.materialName);
					if(mat is SinglePassMaterialBase)
					{
						var specular:Number = SinglePassMaterialBase(mat).specular;
						//trace("gloss:"+SinglePassMaterialBase(mat).gloss);
						//trace("specular:"+specular);
							
						if(ref.environment)
						{
							//trace("-----------------------environment");
							var fresnelMethod : FresnelEnvMapMethod = new FresnelEnvMapMethod(engine3d.getCubeReflectionTexture2());
							fresnelMethod.normalReflectance = specular;
							fresnelMethod.fresnelPower = 0;
							SinglePassMaterialBase(mat).addMethod(fresnelMethod);
							//SinglePassMaterialBase(mat).addMethod(new EnvMapMethod(engine3d.getCubeReflectionTexture(),specular));
						}
						
						if(ref.skybox)
						{
							var t:CubeTextureBase = engine3d.getSkyBoxTexture();
							if(t)
							{
								//trace("-----------------------skybox");
								SinglePassMaterialBase(mat).addMethod(new EnvMapMethod(t,specular));
							}
						}
					}
				}
			}
		}
		
		private var modelDict:Dictionary = new Dictionary();
		
		public var autoDrag:Boolean = false;
		
		public function addModelEvent(modelObj:ModelObject):void
		{
			var po:ProductObject = modelObj.parentProductObject;
			if(po.isActive)
			{
				po.addEventListener("will_dispose",onModelWillDispose);
				
				for each(var m:Mesh in modelObj.meshs)
				{
					modelDict[m] = modelObj;
					// AS3 triangle pickers for meshes with low poly counts are faster than pixel bender ones.
					//m.pickingCollider = PickingColliderType.BOUNDS_ONLY; // this is the default value for all meshes
					m.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
					//m.pickingCollider = PickingColliderType.PB_BEST_HIT;
					//m.pickingCollider = PickingColliderType.AS3_BEST_HIT; // slower and more accurate, best for meshes with folds
					//m.pickingCollider = PickingColliderType.AUTO_FIRST_ENCOUNTERED; // automatically decides when to use pixel bender or actionscript
					//m.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseEvent);
					m.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
					//m.addEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
					//m.addEventListener(MouseEvent3D.CLICK,onMouseClick);
					m.mouseEnabled = m.mouseChildren = true;
				}
				
				if(autoDrag)
				{
					autoDrag = false;
					
					var p:ProductObject = po;
					while(p.parentProductObject)
					{
						p = p.parentProductObject;
					}
					//p.container3d.y = p.position.y;
					
					p.container3d.position = this.dragObject.getMouse3DPos(engine3d.view,p.position.y);
					
					var mesh:Mesh = modelObj.meshs[0];
					mousedownObject = modelDict[mesh];
					
					var cpo:ProductObject = getRootProduct(mousedownObject);
					gvar.currProduct = cpo;
					
					flash.utils.setTimeout(dispathchModelDownEvent,1,mesh);
				}
			}
			
			//set actions
			while(po)
			{
				_updateAction(po,po.productInfo,po.container3d);
				po = po.parentProductObject;
			}
		}
		
		private function dispathchModelDownEvent(mesh:Mesh):void
		{
			mesh.dispatchEvent(new MouseEvent3D(MouseEvent3D.MOUSE_DOWN));
		}
		
		private function onModelWillDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			
			for each(var m:Mesh in po.modelObject.meshs)
			{
				delete modelDict[m];
				m.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
				//m.removeEventListener(MouseEvent3D.CLICK,onMouseClick);
			}
		}
		
		private function _updateAction(productObj:ProductObject,pInfo:ProductInfo,obj3d:ObjectContainer3D):void
		{
			if(productObj.isActive && !productObj.actions && pInfo.actions)
			{
				var len:int = pInfo.actions.length;
				//trace(pInfo.infoID,"--------pInfo.actions:"+len,pInfo.actions);
				
				var actions:Vector.<PropertyAction> = new Vector.<PropertyAction>(len);
				productObj.actions = actions;
				
				for(var i:int=0;i<len;i++)
				{
					var action:PropertyAction = pInfo.actions[i].clone();
					actions[i] = action;
					if(action.targetName=="__own__")
					{
						action.target = obj3d;
					}
				}
			}
		}
		
		public function addCollisionObject(container:ObjectContainer3D):void
		{
			dragObject.avoidList.push(container);
		}
		
		public function removeCollisionObject(container:ObjectContainer3D):void
		{
			var list:Vector.<ObjectContainer3D> = dragObject.avoidList;
			var n:int = list.indexOf(container);
			if(n<list.length-1)
			{
				list[n] = list.pop();
			}
			else
			{
				list.pop();
			}
		}
		
		//private var isMouseDown:Boolean;
		
		private var isMouseMove:Boolean;
		
		private var isMouseDown:Boolean;
		
		//private var currProduct:ProductObject;
		
		public var isDragMode:Boolean = true;
		
		private var isSwitchModel:Boolean;//当前是否选择了另外的模型
		
		private var dragObject:DragObject = new DragObject();
		
		private var house:House = House.getInstance();
		
		private var footPoint:Point = new Point();
		
		//private var mousePoint:Point = new Point();
		
		private var currCrossWall:CrossWall;
		
		private var rooms:Vector.<Room>;
		
		private var sceneHeightSize:int;
		
		//private var mousePoint3d:Vector3D;// = new Vector3D();
		public var mousedownObject:ModelObject;
		
		/*private function onStageRightDown(e:MouseEvent):void
		{
			var o3d:ObjectContainer3D = dragObject.getPickedObject3D(engine3d.view);
			if(modelDict[o3d])
			{
				var mo:ModelObject = modelDict[o3d];
				
				var rp:ProductObject = getRootProduct(mo);
				gevent.dispatchProductMouseDownEvent(rp);
				gevent.dispatchModelMouseDownEvent(mo);
			}
		}*/
		
		private function onStageRightClick(e:MouseEvent):void
		{
			//trace("scene3d visible:"+engine3d.view.parent.visible);
			if(!engine3d.view.parent.visible)return;
			
			if(isMouseDown)return;//如果左键被按下，则返回
			
			var picked:PickingCollisionVO = dragObject.getPickedObject3D(engine3d.view);
			if(!picked)return;
			
			var o3d:ObjectContainer3D = picked.entity;
			//trace("--------onStageRightClick:"+o3d,mo,picked.index,picked.subGeometryIndex);
			
			if(modelDict[o3d])
			{
				var mo:ModelObject = modelDict[o3d];
				var rp:ProductObject = getRootProduct(mo);
				
				//if(gvar.currProduct!=rp)
				//{
					gvar.currProduct = rp;
					
					gevent.dispatchProductMouseUpEvent(gvar.currProduct);
					
					var repList:Array = getReplaceData(mo);
					gevent.dispatchModelMouseUpEvent(mo,repList);
					
					return;
				//}
			}
			else if(o3d is Wall3D)
			{
				Wall3D(o3d).dispatchMouseUpEvent(picked.subGeometryIndex);
			}
			else if(o3d is Room3D)
			{
				Room3D(o3d).dispatchMouseUpEvent(picked.subGeometryIndex);
			}
			else if(o3d is CabinetTable3D)
			{
				CabinetCreator.getInstance().dispatchCabinetTableMouseUpEvent();
			}
		}
		
		private function onMouseDown(e:MouseEvent3D):void
		{
			trace("onEngineMouseDown");
			if(isMouseDown)return;//鼠标按下后，未复位，拒绝执行

			mousedownObject = modelDict[e.currentTarget];
			
			var p:ProductObject = getRootProduct(mousedownObject);
			
			if(e.ctrlKey)//多选模式
			{
				gvar.currProduct2 = p;
				return;
			}
			
			isMouseDown = true;
			isMouseMove = false;
			trace("onMouseDown1");
			
			//mousePoint3d = event.scenePosition;
			//trace("onMouseDown:"+mousePoint3d);
			
			//trace(p.productInfo.fileURL);
			gevent.dispatchProductMouseDownEvent(p);
			gevent.dispatchModelMouseDownEvent(mousedownObject);
			
			//鼠标点击模型，在按下时，要先判断此模型是否已经选中
			//对已经选中的模型，可以进行拖动
			//对当前不是选中状态的模型，要先置为选中状态，
			//如果在点击过程中，鼠标发生了移动，则不能置为选中状态
			if(gvar.currProduct != p)
			{
				/*if(currProduct)
				{
					ProductUtils.showBounds(currProduct,false);
				}*/
				gvar.currProduct = null;
				isSwitchModel = true;
			}
			else
			{
				isSwitchModel = false;
			}
			
			if(p.isLock)isSwitchModel = true;//如果模型被锁定时，也不准移动
			trace("onMouseDown2",isSwitchModel,isDragMode,p.objectInfo);
			
			currCrossWall = null;
			
			if(!isSwitchModel && isDragMode && p.objectInfo)//没有发生切换时，进行拖动
			{
				sceneHeightSize = Base2D.screenToSize(Scene2D.sceneHeight);
				rooms = house.currFloor.rooms;
				
				if(p.objectInfo.crossWall)
				{
					currCrossWall = p.objectInfo.crossWall;
					//trace("removeWallObject");
					currCrossWall.removeWallObject(p.objectInfo);
					//currCrossWall.initTestObject();
				}
				
				dragObject.initDrag(p.container3d,engine3d.view);
				//productManager.initDrag(currProduct.container3d);
				
				engine3d.camCtrl.disable();
				trace("onMouseDown3");
				
				//engine3d.disableScene();
				p.container3d.mouseChildren = false;
				p.container3d.mouseEnabled = false;
				engine3d.view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				
				p.dispatchStartDragEvent();
			}
			
			engine3d.view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			isMouseMove = true;
			trace("onMouseMove1");//,gvar.currProduct);
			
			if(!isSwitchModel && isDragMode)
			{
				//trace("onMouseMove2");
				var p:ProductObject = gvar.currProduct;
				p.dispatchDragingEvent();
				
				var pos:Vector3D = dragByWall();
				if(pos)
				{
					trace("--",pos);
					//-- Vector3D(-259.62584938377597, 80, 1353.5730325695613)
					//-- Vector3D(889.1038585773197, 80, -20751.752899516752)
					pos = dragObject.draging(pos);
					
					p.container3d.x = pos.x;
					p.container3d.z = pos.z;
					
					pos.x += house.x;
					pos.z += house.z;
					
					if(p.view2d)
					{
						p.view2d.x = Base2D.sizeToScreen(pos.x);
						p.view2d.y = Base2D.sizeToScreen(sceneHeightSize - pos.z);
					}
					
					p.position.x = pos.x;
					p.position.z = pos.z;
				}
			}
			//trace("onMouseMove2",gvar.currProduct);
		}
		
		private function dragByWall():Vector3D
		{
			//trace("----dragByWall",gvar.currProduct,gvar.currProduct.view2d);
			
			/*mousePoint.x = p.x;
			mousePoint.y = p.z;*/
			
			//if(!currCrossWall)
			//{
				/*for each(var room:Room in rooms)
				{
					if(room.hitTestPoint(p.x,p.z))
					{
						currCrossWall = room.getNearestWall(mousePoint,footPoint);
						//currCrossWall.initTestObject();
						break;
					}
				}*/
				var picked:PickingCollisionVO = dragObject.getPickedObject3D(engine3d.view);
				//trace("picked:"+picked);
				
				if(picked)
				{
					var o3d:ObjectContainer3D = picked.entity;
					if(o3d is Wall3D)
					{
						currCrossWall = Wall3D(o3d).vo.frontCrossWall;
					}
					else
					{
						currCrossWall = null;
						/*if(!modelDict[o3d])
						{
							trace("----",o3d,modelDict[o3d]);
							currCrossWall = null;
						}*/
						if(!(o3d is Room3D))//检测的对象不是房间地面时，当前物体不移动
						{
							return null;
						}
					}
				}
				else//没有检测到对象时，当前物体不移动
				{
					currCrossWall = null;
					return null;
				}
			//}
			
			if(currCrossWall)//currCabinet.vo.objectInfo.crossWall)//当前产品被吸附在某个墙上
			{
				var cw:CrossWall = currCrossWall;
				var wall:Wall = cw.wall;
				var bounds:Vector3D = gvar.currProduct.productInfo.dimensions;
				var ww:Number = wall.width * 0.5;
				/*var dist:Number = wall.distToPoint(mousePoint,footPoint);*///计算当前点到墙体的垂直距离，及当前垂足坐标
				//trace("dist:"+dist);
				//if(true)//dist<800)
				//{
					var dx:Number = bounds.x * 0.5;
					footPoint.x = picked.localPosition.x+dx;
					//wall.globalToLocal2(footPoint,footPoint);
					//trace("footPoint1:"+footPoint);
					//footPoint.x += cw.isHead?dx:-dx;
					var zWall:int = gvar.currProduct.objectInfo.z;
					var dy:Number = zWall + ww;
					
					footPoint.y = cw.isHead?-dy:dy;
					
					//currCabinet.xWall = footPoint.x;
					gvar.currProduct.objectInfo.x = footPoint.x;
					
					var result:Boolean = currCrossWall.testAddObject(gvar.currProduct.objectInfo);
					//trace("testAddObject:"+result);
					
					if(result)
					{
						footPoint.x = gvar.currProduct.objectInfo.x;
						//trace("footPoint2:"+footPoint);
						wall.localToGlobal2(footPoint,footPoint);
						
						gvar.currProduct.container3d.x = footPoint.x - house.x;
						gvar.currProduct.container3d.z = footPoint.y - house.z;
						
						//footPoint.x += house.x;
						//footPoint.y += house.z;
						
						var a:Number = 360 - wall.angles;
						a = cw.isHead ? a+180 : a;
						
						var view2d:Sprite = gvar.currProduct.view2d;
						if(view2d)
						{
							view2d.x = Base2D.sizeToScreen(footPoint.x);
							view2d.y = Base2D.sizeToScreen(sceneHeightSize - footPoint.y);
							view2d.rotation = a;
						}
						
						gvar.currProduct.position.x = footPoint.x;
						gvar.currProduct.position.z = footPoint.y;
						gvar.currProduct.rotation.y = gvar.currProduct.container3d.rotationY = a;
					}
					else
					{
						currCrossWall = null;
						return null;
					}
				/*}
				else
				{
					currCrossWall = null;
				}*/
			}
			
			if(!currCrossWall)//currCabinet.vo.objectInfo.crossWall)
			{
				var p:Vector3D = picked.localPosition.clone();
				p.x += o3d.x;
				p.z += o3d.z;
				//return picked.rayDirection;
				//var p:Vector3D = dragObject.draging2();
				/*p.x += house.x;
				p.z += house.z;
				
				p.x -= house.x;
				p.z -= house.z;*/
				
				return p;
			}
			
			return null;
		}
		
		private var lastTime:int = 0;
		private function onMouseUp(event:MouseEvent):void
		{
			engine3d.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			engine3d.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			engine3d.camCtrl.enable();
			//engine3d.enableScene();
			
			trace("onmouseup1",gvar.currProduct);
			var p:ProductObject = gvar.currProduct;
			if(p)
			{
				//trace("objectInfo",gvar.currProduct.objectInfo);
				if(currCrossWall && p.objectInfo)
				{
					//trace("addWallObject");
					currCrossWall.addWallObject(p.objectInfo);
					currCrossWall.wall.dispatchSizeChangeEvent();
					p.dispatchChangeEvent();
				}
				
				p.dispatchEndDragEvent();
				
				p.container3d.mouseChildren = true;
				p.container3d.mouseEnabled = true;
			}
			
			if(!isMouseDown)return;
			isMouseDown = false;
			
			//trace("onmouseup2");
			if(isMouseMove)return;
			
			//trace("onMouseClick:"+event.scenePosition);
			//var mesh:Mesh = event.currentTarget as Mesh;
			//mesh.showBounds = true;
			
			//var mObj:ModelObject = modelDict[mesh];
			//trace("onMouseEvent:"+mObj);
		
			var rp:ProductObject = getRootProduct(mousedownObject);
			
			if(p!=rp)
			{
				//if(currProduct)showBounds(currProduct,false);
				
				gvar.currProduct = rp;
				//ProductUtils.showBounds(gvar.currProduct,true);
				
				return;
			}
			
			var n:int = getTimer();
			//trace(n-lastTime);
			if(n-lastTime<200)//执行双击
			{
				gevent.dispatchProductMouseUpEvent(gvar.currProduct);
				
				var repList:Array = getReplaceData(mousedownObject);
				gevent.dispatchModelMouseUpEvent(mousedownObject,repList);
				
				//trace("productMouseUpEvent1:"+(n-lastTime));
				//trace("modelObject:"+mousedownObject.modelInfo.infoFileURL);
				//trace("repList:"+repList);
				lastTime = 0;
			}
			else
			{
				lastTime = n;
				flash.utils.setTimeout(_doAction,200);
			}
		}
		
		private function getReplaceData(model:ModelObject):Array
		{
			var po:ProductObject = model.parentProductObject;
			var type:String = po.productInfo.type;
			//if(type==CabinetType.OVEN || type==CabinetType.STERILIZER || type==CabinetType.HANDLE)//目标是烤箱或消毒柜时
			//{
			var a:Array = CabinetLib.lib.getReplaceList([po.productInfo.infoID]);
			if(a && a.length>0)
			{
				return a;
			}
			//}
			
			while(po.parentProductObject)
			{
				po = po.parentProductObject;//找到根产品
			}
			
			return CabinetLib.lib.getReplaceList([po.productInfo.infoID]);
		}
		
		private function _doAction():void
		{
			//trace("productMouseUpEvent2:"+lastTime);
			if(lastTime>0)//执行单击
			{
				doAction(mousedownObject);//只在单击时，执行相关动作
				lastTime = 0;
			}
		}
		
		private function doAction(mObj:ModelObject):void
		{
			var pObj:ProductObject = mObj.parentProductObject;
			while(pObj)
			{
				//trace("pObj:"+pObj.id+" isActive:"+pObj.isActive+" actions:"+pObj.actions);
				if(pObj.isActive && pObj.actions)
				{
					//trace("id:"+pObj.id);
					for each(var action:PropertyAction in pObj.actions)
					{
						//trace("action:"+action);
						action.run();
					}
				}
				pObj = pObj.parentProductObject;
			}
		}
		
		private function unSelectCurrProduct(e:Event):void
		{
			if(isMouseDown)return;//鼠标按下后，未复位，拒绝执行
			/*if(gvar.currProduct)
			{
				//ProductUtils.showBounds(gvar.currProduct,false);
			}*/
			gvar.currProduct2 = null;
		}
		
		public function getRootProduct(model:ModelObject):ProductObject
		{
			var pObj:ProductObject = model.parentProductObject;
			while(pObj.parentProductObject)
			{
				pObj = pObj.parentProductObject;
			}
			return pObj;
		}
		
		private function onModelLoaded(event:Event):void
		{
			modelParser.addModel(modelLoader.currModel,true);
		}
		
		private function onAllModelLoaded(event:Event):void
		{
			modelParser.startParse();
		}
	}
}