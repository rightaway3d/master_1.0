package rightaway3d.house.editor2d
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.engine.utils.ActionHistory;
	import rightaway3d.engine.utils.ActionType;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.engine.utils.GlobalVar;
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.cabinet.Cabinet2D;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.cabinet.CircularColumn2D;
	import rightaway3d.house.cabinet.SquarePillar2D;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.view2d.Room2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallObject;

	public class CabinetController
	{
		public var scene:Scene2D;
		public var sceneController:SceneController2D;
		public var engineManager:EngineManager;
		
		private var productManager:ProductManager = ProductManager.own;
		
		private var stage:Stage;
		
		
		private var rooms:Vector.<Room2D>;
		
		//private var products:Array = [];
		
		private var _drainerFlag:Product2D;
		
		private var gvar:GlobalVar = GlobalVar.own;
		
		//水盆柜标志
		public function get drainerFlag():Product2D
		{
			return _drainerFlag;
		}

		//灶台柜标志
		private var _flueFlag:Product2D;
		public function get flueFlag():Product2D
		{
			return _flueFlag;
		}

		
		/**
		 * 是否已经指定的灶台位置
		 * @return 
		 * 
		 */
		public function hasHearth ():Boolean
		{
			return Boolean(_flueFlag && _flueFlag.wall);
		}
		
		/**
		 * 是否已经指定了水盆位置
		 * @return 
		 * 
		 */
		public function hasBasin():Boolean
		{
			return Boolean(_drainerFlag && _drainerFlag.wall);
		}
		
		
		/**
		 * 创建水盆定位标志
		 */
		public function createDrainerFlag():void
		{
			disposeFlagProduct();
			
			if(_drainerFlag)
			{
				Tips.show("水盆已经创建好了",stage.mouseX-90,stage.mouseY-100,3000);
				return;
			}
			
			var p:Product2D = createSquareObject("drainer",900,800,400,0x8080ff,0,100);
			p.loadImage("assets/image/icon_shuipen.png");
			p.errorFlag = true;
			
			_drainerFlag = p;
			p.vo.container3d.visible = false;
		}
		
		/**
		 * 创建灶台定位标志
		 */
		public function createFlueFlag():void
		{
			disposeFlagProduct();
			
			if(_flueFlag)
			{
				Tips.show("灶台已经创建好了",stage.mouseX-90,stage.mouseY-100,3000);
				return;
			}
			
			var p:Product2D = createSquareObject("flue",900,2000,400,0xff8080,0,100);
			p.loadImage("assets/image/icon_zaotai.png");
			p.errorFlag = true;
			
			_flueFlag = p;
			p.vo.container3d.visible = false;
		}
		
		//清除前面没有正确放置的标志物
		private function disposeFlagProduct():void
		{
			var po:ProductObject = gvar.currProduct;
			if(po)
			{
				if(isMiddleCabinet(po) || (_drainerFlag && po==_drainerFlag.vo) || (_flueFlag && po==_flueFlag.vo))
				{
					if(!po.objectInfo.crossWall)
					{
						if(_drainerFlag && po==_drainerFlag.vo)
						{
							_drainerFlag = null;
						}
						else if(_flueFlag && po==_flueFlag.vo)
						{
							_flueFlag = null;
						}
						else
						{
							removeMiddleCabinet(po);
						}
						
						po.dispose();
						gvar.currProduct = null;
					}
				}
			}
		}
		
		//private var _middle450:Product2D;
		//private var _middle600:Product2D;
		//private var _height600:Product2D;
		private var middleCabinets:Array = [];
		
		private function addMiddleCabinet(po:ProductObject):void
		{
			middleCabinets.push(po);
			po.addEventListener("dispose",onMiddleCabinetDispose);
		}
		
		private function onMiddleCabinetDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			po.removeEventListener("dispose",onMiddleCabinetDispose);
			removeMiddleCabinet(po);
		}
		
		private function removeMiddleCabinet(po:ProductObject):void
		{
			var n:int = middleCabinets.indexOf(po);
			if(n>-1)
			{
				middleCabinets.splice(n,1);
			}
		}
		
		public function hasHeightCabinet():Boolean
		{
			for each(var po:ProductObject in middleCabinets)
			{
				if(po.objectInfo.height==2110)
				{
					return true;
				}
			}
			return false;
		}
		
		public function isMiddleCabinet(po:ProductObject):Boolean
		{
			var n:int = middleCabinets.indexOf(po);
			if(n>-1)
			{
				return true;
			}
			
			return false;
		}
		
		/**
		 * 创建450中高柜
		 */
		public function createMiddle450Flag():ProductObject
		{
			disposeFlagProduct();
			
			var p:Product2D = this.createCabinet(703,"cabinet_703_450x1390x570.pdt",450,1390,550,"text",null,-1,CrossWall.IGNORE_OBJECT_HEIGHT,"",true);
			p.errorFlag = true;
			addMiddleCabinet(p.vo);
			return p.vo;
		}
		
		/**
		 * 创建600中高柜
		 */
		public function createMiddle600Flag():ProductObject
		{
			disposeFlagProduct();
			
			var p:Product2D = this.createCabinet(705,"cabinet_705_600x1390x570.pdt",600,1390,550,"text",null,-1,CrossWall.IGNORE_OBJECT_HEIGHT,"",true);
			p.errorFlag = true;
			addMiddleCabinet(p.vo);
			return p.vo;
		}
		
		/**
		 * 创建600高柜
		 */
		public function createHeight600Flag():ProductObject
		{
			disposeFlagProduct();
			
			var p:Product2D = this.createCabinet(805,"cabinet_805_600x2110x570.pdt",600,2110,550,"text",null,-1,CrossWall.IGNORE_OBJECT_HEIGHT,"",true);
			p.errorFlag = true;
			addMiddleCabinet(p.vo);
			return p.vo;
		}
		
		/**
		 * 是否锁定定位标志
		 * @param value
		 */
		public function lockLocationFlag(value:Boolean):void
		{
			if(_flueFlag)_flueFlag.visible = !value;
			if(_drainerFlag)_drainerFlag.visible = !value;
			
			gvar.currProduct2 = null;
		}
		
		/**
		 * 清除定位标志
		 */
		public function clearLocationFlag():void
		{
			if(_flueFlag)
			{
				_flueFlag.vo.dispose();
				
				_flueFlag = null;
			}
			
			if(_drainerFlag)
			{
				_drainerFlag.vo.dispose();
				
				_drainerFlag = null;
			}
			
			gvar.currProduct2 = null;
			
			actionHistory.clear();
			
			scene.house.currFloor.updateWallMark();
		}
		
		private var actionHistory:ActionHistory = ActionHistory.getInstance();
		
		/**
		 * 删除产品
		 * @param po 删除的产品
		 * @param isRedoCMD 是否在执行重做命令
		 * @param addHistory 是否添加到动作历史中，以便执行撒销指令
		 * 
		 */
		public function deleteProduct(po:ProductObject,isRedoCMD:Boolean=false,addHistory:Boolean=true):void
		{
			if(!po)return;
			
			if(po.view2d==_drainerFlag)_drainerFlag = null;
			else if(po.view2d==_flueFlag)_flueFlag = null;
			
			var s:String = po.toJsonString(true);
			trace("deleteProduct:"+s);
			
			if(addHistory)actionHistory.addAction(ActionType.DELETE,s,isRedoCMD);//保存被删除的产品信息
			
			_deleteProduct(po);
			
			gvar.currProduct2 = null;
			currCrossWall = null;
			
			if(scene.house.currFloor)scene.house.currFloor.updateWallMark();
			
			scene.render();
		}
		
		public function deleteProductByName(name:String):void
		{
			var tpo:ProductObject = productManager.getProductByName(name);
			if(tpo)
			{
				deleteProduct(tpo,false,false);
			}
		}
		
		public function deleteAllProduct():void
		{
			ProductManager.own.clearRootProductObject();
			/*var a:Array = products.concat();
			for each(var p:Product2D in a)
			{
				_deleteProduct(p.vo);
			}*/
			
			gvar.currProduct2 = null;
			currCrossWall = null;
			
			_drainerFlag = null;
			_flueFlag = null;
			
			actionHistory.clear();
			ProductObject.resetIndex();
			
			if(scene.house.currFloor)
			{
				scene.house.currFloor.updateWallMark();
				scene.house.currFloor.wallAreaSelector.clearCabinetFlag();
			}
			
			scene.render();
		}
		
		private function _deleteProduct(po:ProductObject):void
		{
			po.dispose();
		}
		
		/**
		 * 障碍物集合
		 */
		private var obstacleDict:Dictionary = new Dictionary();
		
		private function addProduct(p:Product2D):void
		{
			p.vo.addEventListener("will_dispose",onDisposeProduct);
			p.addEventListener(MouseEvent.MOUSE_DOWN,onSelectProduct);
			//products.push(p);
		}
		
		private function onDisposeProduct(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			po.removeEventListener("will_dispose",onDisposeProduct);
			
			engineManager.removeRootChild(po.container3d);
			engineManager.removeCollisionObject(po.container3d);
			
			var p:Product2D = po.view2d;
			p.removeEventListener(MouseEvent.MOUSE_DOWN,onSelectProduct);

			removeProduct(p);
			
			/*var n:int = products.indexOf(p);
			if(n>-1)products.splice(n,1);*/
			
			if(obstacleDict[po])
			{
				delete obstacleDict[po];
			}
			
			/*if(cabinetDict[po])
			{
				delete cabinetDict[po];
			}*/
			
			if(roomPillarDict[po])
			{
				delete roomPillarDict[po];
			}
			
			if(po.objectInfo && po.objectInfo.crossWall)
			{
				var cw:CrossWall = po.objectInfo.crossWall;
				cw.removeWallObject(po.objectInfo);
				cw.dispatchSizeChangeEvent();
			}
			
			gvar.currProduct2 = null;
			
			p.dispose();
		}
		
		public function createProduct(vo:ProductObject):void
		{
			var p:Product2D = new Product2D(vo);
			addProduct(p);
			
			var wo:WallObject = vo.objectInfo;
			
			vo.productInfo.dimensions.x = wo.width;
			vo.productInfo.dimensions.y = wo.height;
			vo.productInfo.dimensions.z = wo.depth;
			
			p.border = 0x999999;
			
			var yPos:int = wo.y+wo.height;
			if(yPos>720)
			{
				scene.addProduct(p,2);
				p.fill = 0xccccaa;
			}
			else if(yPos>=80)
			{
				scene.addProduct(p,1);
				p.fill = 0xccccbb;
			}
			else
			{
				scene.addProduct(p,0);
				if(vo.modelObject)
				{
					p.fill = vo.modelObject.modelInfo.color;
				}
			}
			
			sceneHeightSize = Scene2D.sceneHeightSize;
			
			setProductPos(p.vo,wo.crossWall,wo.x,wo.y,wo.z);
			
			p.updateView();
		}
		
		//==========================================================================
		/**
		 * 是否锁定厨柜及水盆烟机灶台电器
		 * @param value
		 */
		public function lockCabinetObject(value:Boolean):void
		{
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					po.isLock = value;
				}
			}
			/*for(var po:ProductObject in cabinetDict)
			{
				//烟机不允许解锁，只能跟随灶台柜而移动，另外水槽和灶台实例不在cabinetDict字典集合中，所以此处不会将这两种产品解锁
				if(po.name!=ProductObjectName.HOOD)
				{
					po.isLock = value;
				}
			}*/
		}
		
		/**
		 * 清除所有厨柜及水盆烟机灶台电器
		 */
		public function clearAllCabinetObject():void
		{
			/*for(var vo:ProductObject in cabinetDict)
			{
				vo.dispose();
			}*/
			
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					po.dispose();
				}
			}
			
			deleteProductByName(ProductObjectName.DRAINER);
			deleteProductByName(ProductObjectName.FLUE);
			deleteProductByName(ProductObjectName.HOOD);
			
			gvar.currProduct2 = null;
			currCrossWall = null;
			
			_drainerFlag = null;
			_flueFlag = null;
			
			actionHistory.clear();
			ProductObject.resetIndex();
			
			scene.house.currFloor.updateWallMark();
		}
		
		public function setCabinet2dColor(border:uint):void
		{
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					po.view2d.border = border;
					po.view2d.updateView();
				}
			}
		}
		
		//private var cabinetDict:Dictionary = new Dictionary();
		
		public function createCabinet(infoID:int,fileURL:String,width:int,height:int,depth:int,dataFormat:String="text",cw:CrossWall=null,xPos:int=-1,yPos:uint=0,name:String="",isDrag:Boolean=true):Product2D
		{
			var p:Product2D = new Cabinet2D(infoID,fileURL,dataFormat);
			//trace("width:"+width);
			p.vo.objectInfo.width = width;
			p.vo.objectInfo.depth = depth;
			p.vo.objectInfo.height = height;
			trace("----createCabinet objectInfo：",p.vo.objectInfo);
			
			addProduct(p);
			//setCurrProduct(p);
			gvar.currProduct2 = null;
			gvar.currProduct = p.vo;
			
			//cabinetDict[p.vo] = p;
			//addCabinetDict(p.vo);
			
			if(name)p.vo.name = name;
			
			if(!cw && isDrag)
			{
				initEvent2();
			}
			
			if(yPos>720)
			{
				if(cw)scene.addProduct(p,2);
				p.border = 0x999999;
				p.fill = 0xccccaa;
				//var zPos:Number = 0;
			}
			else
			{
				if(cw)scene.addProduct(p,1);
				p.border = 0x999999;
				p.fill = 0xccccbb;
				//zPos = WallObject.distToWall;
			}
			
			initCabinet(cw,xPos,yPos,0);
			//initCabinet(cw,xPos,yPos,-1);
			trace(p.vo);
			GlobalEvent.event.dispatchProductCreatedEvent(p.vo);
			
			return p;
		}
		
		/*public function addCabinetDict(po:ProductObject):void
		{
			cabinetDict[po] = po.view2d;
		}*/
		
		public function setGroundCabinetView2D(value:Boolean):void
		{
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					if(po.position.y<100)
					{
						po.view2d.visible = value;
					}
				}
			}
			/*for(var po:ProductObject in cabinetDict)
			{
				if(po.position.y<100)
				{
					po.view2d.visible = value;
				}
			}*/
		}
		
		public function setWallCabinetView2D(value:Boolean):void
		{
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					if(po.position.y>1000)
					{
						po.view2d.visible = value;
					}
				}
			}
			/*for(var po:ProductObject in cabinetDict)
			{
				if(po.position.y>1000)
				{
					po.view2d.visible = value;
				}
			}*/
		}
		
		/**
		 * 创建横向管道
		 * @param diameter：直径，单位mm
		 * @param length：管长度，单位mm
		 * @param color：颜色
		 * @param yPos：管下沿至地面高度
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 */
		public function createHorizontalTube(diameter:uint,length:uint,color:uint,yPos:uint,zPos:uint):void
		{
			var p:Product2D = createCircularColumn("HorizontalTube",diameter,length,color,yPos,zPos,new Vector3D(0,0,90));
		}
		
		/**
		 * 创建与房间齐高的圆管（圆柱）
		 * @param diameter：直径，单位mm
		 * @param color：颜色
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 */
		public function createRoomCircularColumn(diameter:uint,color:uint,zPos:uint=0):void
		{
			var pName:String = "RoomCircularColumn";
			var height:int = scene.currFloor.vo.ceilingHeight;
			var yPos:uint = 0;
			var p:Product2D = createCircularColumn(pName,diameter,height,color,yPos,zPos);
		}
		
		/**
		 * 创建竖管道
		 * @param pName：名称
		 * @param diameter：直径，单位mm
		 * @param height：管高度，单位mm
		 * @param color：颜色
		 * @param yPos：管底至地面高度
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 * @param rotation：旋转管子
		 * @return 管子产品的二维视图
		 */
		public function createCircularColumn(pName:String,diameter:uint,height:uint,color:uint,yPos:uint,zPos:uint,rotation:Vector3D=null):Product2D
		{
			var fh:int = scene.currFloor.vo.ceilingHeight;
			if(height>fh)height = fh;
			if(yPos+height>fh)yPos = fh - height;
			
			var p:Product2D = new CircularColumn2D(pName,diameter,height,color,false,rotation);
			p.vo.objectInfo.isIgnoreObject = true;
			
			obstacleDict[p.vo] = p;
			
			addProduct(p);
			//setCurrProduct(p);
			gvar.currProduct2 = null;
			gvar.currProduct = p.vo;
			
			initEvent2();
			
			initCabinet(null,-1,yPos,zPos);
			
			return p;
		}
		
		/**
		 * 房间方柱集合
		 */
		private var roomPillarDict:Dictionary = new Dictionary();
		
		private var currRoomPillarMaterial:String;
		
		public function setRoomPillarMaterial(matName:String):void
		{
			currRoomPillarMaterial = matName;
			for(var po:ProductObject in roomPillarDict)
			{
				//RenderUtils.setMaterial(po.modelObject.meshs[0],currRoomPillarMaterial);
				po.customMaterialName = currRoomPillarMaterial;
			}
		}
		
		/**
		 * 创建与房间齐高的方柱（烟道）
		 * @param width：柱子宽度，单位mm
		 * @param depth：柱子进深，单位mm
		 * @param color：颜色
		 * @param zPos：柱子吸附到墙体时，与墙体的间距
		 */
		public function createRoomSquarePillar(width:uint,depth:uint,color:uint,zPos:uint=0,isDrag:Boolean=true):void
		{
			var pName:String = ProductObjectName.ROOM_SQUARE_PILLAR;//"RoomSquarePillar";
			var height:int = scene.currFloor.vo.ceilingHeight;
			var yPos:uint = 0;
			var p:Product2D = createSquareObject(pName,width,height,depth,color,yPos,zPos,true,isDrag);
			p.vo.objectInfo.isIgnoreObject = false;
			
			roomPillarDict[p.vo] = p;
			//RenderUtils.setMaterial(p.vo.modelObject.meshs[0],currRoomPillarMaterial);
			p.vo.customMaterialName = currRoomPillarMaterial;
		}
		
		/**
		 * 创建方形物体
		 * @param pName：名称
		 * @param width：物体宽度，单位mm
		 * @param height：物体高度，单位mm
		 * @param depth：物体进深，单位mm
		 * @param color：颜色
		 * @param yPos：物体底面至地面高度
		 * @param zPos：物体吸附到墙体时，与墙体的间距
		 * @return 物体的二维视图
		 */
		public function createSquareObject(pName:String,width:int,height:int,depth:int,color:uint,yPos:uint,zPos:uint,isActive:Boolean=false,isDrag:Boolean=true):Product2D
		{
			var fh:int = scene.currFloor.vo.ceilingHeight;
			if(height>fh)height = fh;
			if(yPos+height>fh)yPos = fh - height;
			
			var p:Product2D = new SquarePillar2D(pName,width,height,depth,color,isActive);
			p.vo.objectInfo.isIgnoreObject = true;
			
			obstacleDict[p.vo] = p;
			
			addProduct(p);
			//setCurrProduct(p);
			gvar.currProduct2 = null;
			gvar.currProduct = p.vo;
			
			if(isDrag)initEvent2();
			
			initCabinet(null,-1,yPos,zPos);
			
			return p;
		}
		
		/**
		 * 清除所有障碍物
		 */
		public function clearAllObstacle():void
		{
			for(var vo:ProductObject in obstacleDict)
			{
				vo.dispose();
				
				//products.splice(products.indexOf(vo.view2d),1);
			}
			
			actionHistory.clear();
			
			scene.house.currFloor.updateWallMark();
		}
		
		/**
		 * 是否锁定所有障碍物，锁定后将不能编辑障碍物
		 * @param value
		 */
		public function lockObstacle(value:Boolean):void
		{
			for(var vo:ProductObject in obstacleDict)
			{
				vo.isLock = value;
			}
			
			if(value && gvar.currProduct)
			{
				if(gvar.currProduct.view2d)
				{
					gvar.currProduct.view2d.selected = false;
					gvar.currProduct.view2d.updateView();
				}
				gvar.currProduct2 = null;
				currCrossWall = null;
			}
		}
		
		/**
		 * 设置物体位置
		 * @param po：物体对象
		 * @param xPos：在墙面上新位置
		 * @param yPos：物体的新高度
		 * @param zPos：离墙的距离
		 */
		public function setObjectPosition(po:ProductObject,xPos:int,yPos:int,zPos:Number):void
		{
			var cw:CrossWall = po.objectInfo.crossWall;
			if(!cw)return;
			
			xPos += cw.localHead.x + po.productInfo.dimensions.x;
			
			var x0:Number = cw.localHead.x;//wall.groundFrontHead.x;
			var x1:Number = cw.localEnd.x;//wall.groundFrontEnd.x;
			var o:WallObject = po.objectInfo;
			var tx:Number = o.x;
			o.x = xPos;
			if(cw.testObject(x0,x1,o))
			{
				xPos = o.x;
				this.setProductPos(po,cw,xPos,yPos,zPos);
			}
			else
			{
				o.x = tx;
			}
		}
		
		private function removeProduct(p:Product2D):void
		{
			if(p.parent==scene)
			{
				scene.removeChild(p);
			}
			else
			{
				var obj:WallObject = p.vo.objectInfo;
				var h:int = obj.y + obj.height;
				//trace("-----"+h,obj.y,obj.height);
				
				var level:int = h < 80 ? 0 : (h < CrossWall.WALL_OBJECT_HEIGHT ? 1 : 2);
				scene.removeProduct(p,level);
			}
		}
		
		private var isMove:Boolean;
		private function onSelectProduct(e:MouseEvent):void
		{
			var p:Product2D = e.currentTarget as Product2D;
			
			if(p.vo.isLock)return;//锁定时，不准操作
			
			if(e.ctrlKey)
			{
				gvar.currProduct2 = p.vo;
				return;
			}
			
			gvar.currProduct2 = null;
			gvar.currProduct = p.vo;
			
			var wo:WallObject = p.vo.objectInfo;
			currCrossWall = wo.crossWall;
			
			if(currCrossWall)
			{
				currCrossWall.removeWallObject(p.vo.objectInfo);
				currCrossWall.removeMiddleHeightCabinet(p.vo);
			}
			
			removeProduct(p);

			this.scene.enable = false;
			p.enable = false;
			
			isMove = false;
			
			stage = scene.stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,movingCabinet);
			stage.addEventListener(MouseEvent.MOUSE_UP,endMoveCabinet);
			
			initCabinet(currCrossWall,wo.x,wo.y,wo.z,false);
			
			scene.render();
			
			GlobalEvent.event.dispatchProductMouseDownEvent(p.vo);
		}
		
		private function initEvent2():void
		{
			this.scene.enable = false;
			gvar.currProduct.view2d.enable = false;
			
			stage = scene.stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,movingCabinet);
			stage.addEventListener(MouseEvent.CLICK,endMoveCabinet);
			
			//trace("initEvent:"+gvar.currProduct.toJsonString());
		}
		
		private function initCabinet(cw:CrossWall=null,xPos:int=-1,yPos:uint=0,zPos:uint=0,setPos:Boolean=true):void
		{
			//trace("initCabinet");
			sceneHeightSize = Scene2D.sceneHeightSize;
			
			rooms = scene.currFloor.rooms;
			
			if(!gvar.currProduct.view2d.stage)scene.addChild(gvar.currProduct.view2d);
			
			gvar.currProduct.objectInfo.x = xPos;
			gvar.currProduct.objectInfo.y = yPos;
			gvar.currProduct.objectInfo.z = zPos;
			
			//gvar.currCabinet.vo.position.y = yPos;
			
			if(!cw)
			{
				//trace("initCabinet1");
				stage = scene.stage;
				mousePoint.x = stage.mouseX;
				mousePoint.y = stage.mouseY;
				
				var localPoint:Point = scene.globalToLocal(mousePoint);
				
				gvar.currProduct.view2d.x = localPoint.x - gvar.currProduct.view2d.width * 0.5;
				gvar.currProduct.view2d.y = localPoint.y + gvar.currProduct.view2d.height * 0.5;
				
				mousePoint.x = Base2D.screenToSize(localPoint.x);
				mousePoint.y = sceneHeightSize - Base2D.screenToSize(localPoint.y);
				
				var pObj:ProductObject = gvar.currProduct;
				pObj.position.x = mousePoint.x - pObj.productInfo.dimensions.x * 0.5;
				pObj.position.z = mousePoint.y + pObj.productInfo.dimensions.z * 0.5;
				
				gvar.currProduct.position.y = gvar.currProduct.container3d.y = yPos;
			}
			else if(setPos)
			{
				setProductPos(gvar.currProduct,cw,xPos,yPos,zPos);
			}
			
			//trace("1");
			gvar.currProduct.view2d.updateView();
		}
		
		/*private function setCurrProduct(p:Product2D):void
		{
			if(gvar.currCabinet == p)return;
			
			//trace("setCurrProduct:"+p.selected);
			if(gvar.currCabinet)
			{
				//trace("currCabinet:"+currCabinet.selected);
				currCabinet.selected = false;
				currCabinet.updateView();
			}
			
			p.selected = true;
			currCabinet = p;
		}*/
		
		public function setProductPos(po:ProductObject,cw:CrossWall,xPos:int,yPos:int,zPos:Number):void
		{
			var view2d:Product2D = po.view2d;
			
			if(cw)
			{
				var wall:Wall = cw.wall;
				
				var ww:Number = wall.width*0.5 + zPos;
				
				footPoint.x = xPos;
				footPoint.y = cw.isHead?-ww:ww;
				
				wall.localToGlobal2(footPoint,footPoint);
				//trace("setProductObject:"+xPos,yPos,zPos,wall.index,footPoint);
				
				po.position.x = footPoint.x;
				po.position.z = footPoint.y;
				//po.position.y = po.container3d.y = yPos;
				
				po.objectInfo.x = xPos;
				po.objectInfo.y = yPos;
				po.objectInfo.z = zPos;
				
				var a:Number = 360 - cw.wall.angles;
				po.rotation.y = po.container3d.rotationY = cw.isHead ? a+180 : a;
				if(view2d)view2d.rotation = po.rotation.y;
				
				if(!po.objectInfo.crossWall)
				{
					cw.addWallObject(po.objectInfo);
				}
			}
			else
			{
				footPoint.x = po.position.x = xPos;
				footPoint.y = po.position.z = zPos;
			}
			
			po.position.y = po.container3d.y = yPos;
			
			if(view2d)
			{
				view2d.x = Base2D.sizeToScreen(po.position.x);
				view2d.y = Base2D.sizeToScreen(sceneHeightSize - po.position.z);
			}
			//trace("footPoint3:"+cabinet.x,cabinet.y);
			
			var house:House = House.getInstance();
			po.container3d.x = po.position.x - house.x;
			po.container3d.z = po.position.z - house.z;
		}
		
		/*public function setProductPos(cabinet:Product2D,cw:CrossWall,xPos:int,yPos:int,zPos:Number):void
		{
			setProductPos1(cabinet.vo,cw,xPos,yPos,zPos);
			
			//trace("setCabinetPos:",xPos,yPos,zPos);
			var po:ProductObject = cabinet.vo;
			if(cw)
			{
				//if(zPos<0)zPos = WallObject.distToWall;
				var ww:Number = cw.wall.width*0.5 + zPos;
				
				footPoint.x = xPos;
				footPoint.y = cw.isHead?-ww:ww;
				//trace("footPoint1:"+footPoint);
				cw.wall.localToGlobal2(footPoint,footPoint);
				//trace("footPoint2:"+footPoint);
				
				po.position.x = footPoint.x;
				po.position.z = footPoint.y;
				
				po.objectInfo.x = xPos;
				po.objectInfo.y = yPos;
				po.objectInfo.z = zPos;
				
				var a:Number = 360 - cw.wall.angles;
				cabinet.rotation = cw.isHead ? a+180 : a;
				
				po.rotation.y = po.container3d.rotationY = cabinet.rotation;
				
				if(!po.objectInfo.crossWall)
				{
					cw.addWallObject(po.objectInfo);
				}
			}
			else
			{
				footPoint.x = po.position.x = xPos;
				footPoint.y = po.position.z = zPos;
			}
			
			po.position.y = po.container3d.y = yPos;
			
			cabinet.x = Base2D.sizeToScreen(po.position.x);
			cabinet.y = Base2D.sizeToScreen(sceneHeightSize - po.position.z);
			//trace("footPoint3:"+cabinet.x,cabinet.y);
			
			var house:House = House.getInstance();
			po.container3d.x = po.position.x - house.x;
			po.container3d.z = po.position.z - house.z;
		}*/
		
		private function getWall2d(room2d:Room2D,cw:CrossWall):Wall2D
		{
			var walls:Dictionary = room2d.walls;
			for(var w:Wall2D in walls)
			{
				if(walls[w]==cw)
				{
					return w;
				}
			}
			return null;
		}
		
		//private var tmpPoint:Point = new Point();
		private var sceneHeightSize:int;
		
		private var footPoint:Point = new Point();
		
		private var mousePoint:Point = new Point();
		
		private var currCrossWall:CrossWall;
		
		public var currRoom2d:Room2D;
		
		private function movingCabinet(event:MouseEvent):void
		{
			//trace("movingCabinet");
			isMove = true;

			var mouseX0:Number = stage.mouseX;
			var mouseY0:Number = stage.mouseY;
			
			mousePoint.x = mouseX0;
			mousePoint.y = mouseY0;
			var localPoint:Point = scene.globalToLocal(mousePoint);
			//trace("mousePoint1:"+mousePoint);
			
			mousePoint.x = Base2D.screenToSize(localPoint.x);
			mousePoint.y = sceneHeightSize - Base2D.screenToSize(localPoint.y);
			//trace("mousePoint2:"+mousePoint);
			var inRoom:Boolean = false;
			if(!currCrossWall)//当前产品未吸附在墙上
			{
				for each(var room2d:Room2D in rooms)
				{
					var room:Room = room2d.vo;
					inRoom = room.hitTestPoint(mousePoint.x,mousePoint.y);
					//trace("inRoom:"+inRoom);
					if(inRoom)
					{
						currCrossWall = room.getNearestWall(mousePoint,footPoint);
						currCrossWall.addWallObject(gvar.currProduct.objectInfo);

						//currCrossWall.initTestObject();
						currRoom2d = room2d;
						break;
					}
				}
				
				//将水盆或灶台或中高柜关联到墙体视图
				if(gvar.currProduct.view2d==_drainerFlag
					|| gvar.currProduct.view2d==_flueFlag
					|| isMiddleCabinet(gvar.currProduct))
				{
					if(inRoom)
					{
						var w:Wall2D = getWall2d(currRoom2d,currCrossWall);
						if(w)
						{
							//w.selected = true;
							gvar.currProduct.view2d.wall = w;
						}
					}
				}
			}
			
			if(currCrossWall)//当前产品被吸附在某个墙上
			{
				var cw:CrossWall = currCrossWall;
				cw.removeWallObject(gvar.currProduct.objectInfo);
				
				var wall:Wall = cw.wall;
				var ww:Number = wall.width * 0.5;
				var bounds:Vector3D = gvar.currProduct.productInfo.dimensions;
				var dist:Number = wall.distToPoint(mousePoint,footPoint);//计算当前点到墙体的垂直距离，及当前垂足坐标
				if(dist<800)
				{
					wall.globalToLocal2(footPoint,footPoint);
					//trace("footPoint1:"+footPoint);
					var dx:Number = bounds.x * 0.5;
					footPoint.x += cw.isHead?dx:-dx;
					var zWall:int = gvar.currProduct.objectInfo.z;
					var dy:Number = zWall + ww;
					
					/*if(zWall>-1)
					{
						var dy:Number = zWall + ww;
					}
					else
					{
						var hz:Number = bounds.z * 0.5;
						dist -= hz;
						if(dist<ww)
						{
							dy = ww;
						}
						else if(dist>ww+WallObject.distToWall+570-bounds.z)
						{
							dy = ww+WallObject.distToWall+570-bounds.z;
						}
						else
						{
							dy = dist;
						}
					}*/
					
					footPoint.y = cw.isHead?-dy:dy;
					
					gvar.currProduct.objectInfo.x = footPoint.x;

					var result:Boolean;
					if(isMiddleCabinet(gvar.currProduct))
					{
						result = cw.testInSelectArea(gvar.currProduct.objectInfo);
						//trace(1,result);
						if(result)
						{
							result = cw.testAvoidOfWindoor(gvar.currProduct.objectInfo);
							//trace(12,result);
							if(result)
							{
								result = cw.testAddObject2(gvar.currProduct.objectInfo);
								//trace(2,result);
								if(result)
								{
									result = cw.testMiddleHeightCabinet(gvar.currProduct);
									//trace("23-----------",result);
								}
							}
						}
					}
					else if(gvar.currProduct.view2d==_drainerFlag
						|| gvar.currProduct.view2d==_flueFlag)
					{
						result = cw.testInSelectArea(gvar.currProduct.objectInfo);
						//trace(3,result);
						if(result)
						{
							result = cw.isAvoidCornerArea(gvar.currProduct.objectInfo)
							//trace(4,result);
							if(result)
							{
								result = cw.testAddObject2(gvar.currProduct.objectInfo);
								//trace(5,result);
							}
						}
					}
					else
					{
						result = cw.testAddObject(gvar.currProduct.objectInfo);
					}
					//trace("result:"+result);
					if(result)
					{
						gvar.currProduct.view2d.errorFlag = false;
						
						footPoint.x = gvar.currProduct.objectInfo.x
						//trace("footPoint2:"+footPoint);
						wall.localToGlobal2(footPoint,footPoint);
						
						gvar.currProduct.view2d.x = Base2D.sizeToScreen(footPoint.x);
						gvar.currProduct.view2d.y = Base2D.sizeToScreen(sceneHeightSize - footPoint.y);
						
						var a:Number = 360 - wall.angles;
						gvar.currProduct.view2d.rotation = cw.isHead ? a+180 : a;
						
						gvar.currProduct.position.x = footPoint.x;
						gvar.currProduct.position.z = footPoint.y;
						gvar.currProduct.rotation.y = gvar.currProduct.container3d.rotationY = gvar.currProduct.view2d.rotation;
						
						cw.addWallObject(gvar.currProduct.objectInfo);
						scene.render();
					}
					else
					{
						currCrossWall = null;
					}
				}
				else
				{
					currCrossWall = null;
				}
			}
			
			if(!currCrossWall)
			{
				gvar.currProduct.view2d.rotation = 0;
				gvar.currProduct.view2d.x = localPoint.x - gvar.currProduct.view2d.width*0.5;
				gvar.currProduct.view2d.y = localPoint.y + gvar.currProduct.view2d.height*0.5;
				
				var pObj:ProductObject = gvar.currProduct;
				pObj.position.x = Base2D.screenToSize(gvar.currProduct.view2d.x);
				pObj.position.z = sceneHeightSize - Base2D.screenToSize(gvar.currProduct.view2d.y);
				//pObj.position.x = mousePoint.x - pObj.productInfo.dimensions.x * 0.5;
				//pObj.position.z = mousePoint.y + pObj.productInfo.dimensions.z * 0.5;
				
				pObj.rotation.y = pObj.container3d.rotationY = 0;
				
				if(gvar.currProduct.view2d.wall)
				{
					/*if(!_flueFlag || !_drainerFlag || _flueFlag.wall!=_drainerFlag.wall)//水盆柜和灶台柜没有关联到同一墙体上
					{
						gvar.currProduct.view2d.wall.selected = false;
					}*/
					gvar.currProduct.view2d.wall = null;
				}
				
				gvar.currProduct.view2d.errorFlag = true;
			}
		}
		
		private function endMoveCabinet(event:MouseEvent):void
		{
			//trace("endMoveCabinet:",currCrossWall);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,movingCabinet);
			stage.removeEventListener(MouseEvent.CLICK,endMoveCabinet);
			stage.removeEventListener(MouseEvent.MOUSE_UP,endMoveCabinet);
			
			this.scene.enable = true;
			
			gvar.currProduct.view2d.enable = true;
			
			var obj:WallObject = gvar.currProduct.objectInfo;
			var h:int = obj.y + obj.height;
			//trace("-----"+h,obj.y,obj.height);
			
			var level:int = h < 80 ? 0 : (h < CrossWall.WALL_OBJECT_HEIGHT ? 1 : 2);
			scene.addProduct(gvar.currProduct.view2d,level);
			
			if(!currCrossWall)
			{
				//如果水盆或灶台没有关联到墙，则清除之
				if(gvar.currProduct.view2d==_flueFlag)
				{
					gvar.currProduct.dispose();
					_flueFlag = null;
				}
				else if(gvar.currProduct.view2d==_drainerFlag)
				{
					gvar.currProduct.dispose();
					_drainerFlag = null;
				}
				else
				{
					this.removeMiddleCabinet(gvar.currProduct);
					gvar.currProduct.dispose();
				}
				gvar.currProduct2 = null;
			}
			else
			{
				//trace("endMoveCabinet:",gvar.currProduct);
				if(isMiddleCabinet(gvar.currProduct))
				{
					currCrossWall.addMiddleHeightCabinet(gvar.currProduct);
					//trace("endMoveCabinet2:",gvar.currProduct);
				}
				
				//currCrossWall.addWallObject(gvar.currProduct.objectInfo);
				currCrossWall = null;
				
				scene.render();
				/*if(currCrossWall)
				{
				}*/
				
				/*if(!flagReady && (gvar.currProduct.view2d==_flueFlag || gvar.currProduct.view2d==_drainerFlag))//如果刚放置好定位标志
				{
					if(_flueFlag && _drainerFlag)//且定位标志已全部放置好
					{
						//GlobalEvent.event.dispatchLocationFlagReadyEvent();//派发定位标志全部放置完成事件
						flagReady = true;
					}
				}*/
				
				if(!isMove)GlobalEvent.event.dispatchProductMouseUpEvent(gvar.currProduct);
			}
		}
		
		//private var flagReady:Boolean = false;
		
		/*public function autoCreateCabinet3():void
		{
			//创建水槽柜
			if(_drainer && _drainer.vo.objectInfo.crossWall)
			{
				var ob:WallObject = _drainer.vo.objectInfo;
				var cw:CrossWall = ob.crossWall;
				cw.initTestObject();
				
				var x:Number = ob.x + 400;
				createCabinet("516","cabinet_516_800x720x570.pdt","text",cw,x);
				
				createToHead(cw,x-800);
				createToEnd(cw,x);
				
				autoCreateWallCabinet(cw,cw.localEnd.x);
			}
			
			//根据烟道所在，创建灶台柜
			if(_flue && _flue.vo.objectInfo.crossWall)
			{
				ob = _flue.vo.objectInfo;
				var cw2:CrossWall = ob.crossWall;
				
				if(cw2!=cw)//灶台柜与水盆柜不在同一个墙面上
				{
					cw2.initTestObject();
					
					if(ob.x>(cw2.localEnd.x-cw2.localHead.x)/2+cw2.localHead.x)//烟道在墙面的后半部分
					{
						//x = ob.x - ob.width;
						x = cw2.localEnd.x-570;
						
						createCabinet("526","cabinet_526_800x720x570.pdt","text",cw2,x);
						createToHead(cw2,x-800);
						autoCreateWallCabinet(cw2,x);
					}
					else//烟道在墙面的前半部分
					{
						//x = ob.x + 800;
						x = cw2.localHead.x + 570 + 800;
						createCabinet("526","cabinet_526_800x720x570.pdt","text",cw2,x);
						createToEnd(cw2,x);
						autoCreateWallCabinet(cw2,cw2.localEnd.x);
					}
				}
				else//灶台柜与水盆柜在同一个墙面上时
				{
					if(ob.x>(cw2.localEnd.x-cw2.localHead.x)/2+cw2.localHead.x)//烟道在墙面的后半部分
					{
						cw2 = cw2.endCrossWall;
						cw2.initTestObject();
						
						x = cw2.localHead.x + 570 + 800;
						createCabinet("526","cabinet_526_800x720x570.pdt","text",cw2,x);
						createToEnd(cw2,x);
						autoCreateWallCabinet(cw2,cw2.localEnd.x);
					}
					else//烟道在墙面的前半部分
					{
						cw2 = cw2.headCrossWall;
						cw2.initTestObject();
						
						x = cw2.localEnd.x - 570;
						
						createCabinet("526","cabinet_526_800x720x570.pdt","text",cw2,x);
						createToHead(cw2,x-800);
						autoCreateWallCabinet(cw2,cw2.localEnd.x - 330);
					}
				}
			}
		}*/
		
		/*private function autoCreateWallCabinet(cw:CrossWall,start:int):void
		{
			//if(cw.localEnd.x-start<330 && cw.endCrossWall.wallObjects.length>0)start=cw.localEnd.x-330;
			
			var x0:Number = cw.localHead.x;
			var dx:Number = start-x0;
			if(dx>900)
			{
				var o:Object = getCabinetData(wallCabinets);
				var width:int = o.width;
				var height:int = o.height;
				this.setTestObject(0,CrossWall.WALL_OBJECT_HEIGHT,width,height);
				var result:Boolean = cw.testAutoAddToHead(testObject,start);
				if(result)
				{
					start = testObject.x;
					
					var n:int = createWallCabinet(o,cw,start);
					autoCreateWallCabinet(cw,start-n);
				}
			}
			else
			{
				var wos:Array = [];
				cw.getWallObjectOfPos(x0,start,wos);
				if(wos.length>0)
				{
					var wo:WallObject = wos[wos.length-1];
					dx = start - wo.x;
				}
				
				if(dx>=800)
				{
					createWallCabinet(getCabinetData(wallCabinets,4),cw,start);
				}
				else if(dx>=600)
				{
					createWallCabinet(getCabinetData(wallCabinets,3),cw,start);
				}
				else if(dx>=450)
				{
					createWallCabinet(getCabinetData(wallCabinets,2),cw,start);
				}
				else if(dx>=400)
				{
					createWallCabinet(getCabinetData(wallCabinets,1),cw,start);
				}
				else if(dx>=300)
				{
					createWallCabinet(getCabinetData(wallCabinets,0),cw,start);
				}
			}
		}*/
		
		/*private function createToEnd(cw:CrossWall,start:int):void
		{
			var x1:Number = cw.localEnd.x;
			var dx:Number = x1 - start;
			if(dx>900)
			{
				var o:Object = getCabinetData(groundCabinets);
				var width:int = o.width;
				var height:int = o.height;
				this.setTestObject(0,0,width,height);
				var result:Boolean = cw.testAutoAddToEnd(testObject,start+width);
				if(result)
				{
					start = testObject.x;
					
					createGroundCabinet(o,cw,start);
					createToEnd(cw,start);
				}
			}
			else
			{
				var gos:Array = [];
				cw.getGroundObjectOfPos(start,x1,gos);
				if(gos.length>0)
				{
					var wo:WallObject = gos[0];
					dx = wo.x-wo.width-start;
				}
				
				if(dx>=800)
				{
					createGroundCabinet(getCabinetData(groundCabinets,4),cw,start+800);
				}
				else if(dx>=600)
				{
					createGroundCabinet(getCabinetData(groundCabinets,3),cw,start+500);
				}
				else if(dx>=450)
				{
					createGroundCabinet(getCabinetData(groundCabinets,2),cw,start+450);
				}
				else if(dx>=400)
				{
					createGroundCabinet(getCabinetData(groundCabinets,1),cw,start+400);
				}
				else if(dx>=300)
				{
					createGroundCabinet(getCabinetData(groundCabinets,0),cw,start+300);
				}
			}
		}*/
		
		/*private function createToHead(cw:CrossWall,start:int):void
		{
			var x0:Number = cw.localHead.x;
			var dx:Number = start-x0;
			if(dx>900)
			{
				var o:Object = getCabinetData(groundCabinets);
				var width:int = o.width;
				var height:int = o.height;
				this.setTestObject(0,0,width,height);
				var result:Boolean = cw.testAutoAddToHead(testObject,start);
				if(result)
				{
					start = testObject.x;
					
					var n:int = createGroundCabinet(o,cw,start);
					createToHead(cw,start-n);
				}
			}
			else
			{
				var gos:Array = [];
				cw.getGroundObjectOfPos(x0,start,gos);
				if(gos.length>0)
				{
					var wo:WallObject = gos[gos.length-1];
					dx = start - wo.x;
				}
				
				if(dx>=800)
				{
					createGroundCabinet(getCabinetData(groundCabinets,4),cw,start);
				}
				else if(dx>=500)
				{
					createGroundCabinet(getCabinetData(groundCabinets,3),cw,start);
				}
				else if(dx>=450)
				{
					createGroundCabinet(getCabinetData(groundCabinets,2),cw,start);
				}
				else if(dx>=400)
				{
					createGroundCabinet(getCabinetData(groundCabinets,1),cw,start);
				}
				else if(dx>=300)
				{
					createGroundCabinet(getCabinetData(groundCabinets,0),cw,start);
				}
				else if(dx>=200)
				{
					//createCabinet2(getGroundCabinetData(),cw,start);
				}
			}
		}*/
		
		/*public function autoCreateCabinet2():void
		{
			rooms = scene.currFloor.rooms;
			for each(var room2d:Room2D in rooms)
			{
				var ws:Dictionary = room2d.walls;
				for(var w:Wall2D in ws)
				{
					if(w.selected)
					{
						var cw:CrossWall = ws[w];
						var wall:Wall = cw.wall;
						var xStart:Number = cw.isHead ? wall.groundFrontHead.x : wall.groundBackHead.x;
						var xEnd:Number = cw.isHead ? wall.groundFrontEnd.x : wall.groundBackEnd.x;
						
						var cabinets:Array = w.cabinets.concat();
						var len:int = cabinets.length;
						//trace("=============="+cabinets,len>0);10/20 9:42 62597034
						
						if(len>0)
						{
							var xWall:int = cab.vo.objectInfo.x;
							var cab:Cabinet2D = cabinets[0];
							xEnd = xWall-cab.productWidth;
							//trace("cab.xWall:"+cab.xWall+" cab.productWidth:"+cab.productWidth);
							_autoCreateCabinet(cw,xStart,xEnd);
							
							for(var i:int=0;i<len-1;i++)
							{
								xStart = cabinets[i].xWall;
								cab = cabinets[i+1];
								//trace("cab.xWall:"+cab.xWall+" cab.productWidth:"+cab.productWidth);
								xEnd = xWall-cab.productWidth;
								_autoCreateCabinet(cw,xStart,xEnd);
							}
							
							cab = cabinets[len-1];
							//trace("cab.xWall:"+cab.xWall+" cab.productWidth:"+cab.productWidth);
							xStart = xWall;
							xEnd = cw.isHead ? wall.groundFrontEnd.x : wall.groundBackEnd.x;
							_autoCreateCabinet(cw,xStart,xEnd);
						}
						else
						{
							_autoCreateCabinet(cw,xStart,xEnd);
						}
					}
				}
			}
		}*/
		
		/*private function _autoCreateCabinet(cw:CrossWall,xStart:Number,xEnd:Number):void
		{
			//trace("_autoCreateCabinet xStart:"+xStart+" _xEnd:"+xEnd);
			var n:Number = xStart;
			while(n<xEnd)
			{
				var tn:Number = xEnd-n;
				if(tn>=800)
				{
					n += 800;
					createCabinet("506","cabinet_506_800x720x570.pdt","text",cw,n);
				}
				else if(tn>=500)
				{
					n += 500;
					createCabinet("504","cabinet_504_500x720x570.pdt","text",cw,n);
				}
				else if(tn>=450)
				{
					n += 450;
					createCabinet("503","cabinet_503_450x720x570.pdt","text",cw,n);
				}
				else if(tn>=400)
				{
					n += 400;
					createCabinet("502","cabinet_502_400x720x570.pdt","text",cw,n);
				}
				else if(tn>=300)
				{
					n += 300;
					createCabinet("501","cabinet_501_300x720x570.pdt","text",cw,n);
				}
				else
				{
					n = xEnd;
				}
			}
		}*/
		
		/*private var waterGroundObjects:Array;//水盆位置地柜组合
		private var waterWallObjects:Array;//水盆位置吊柜组合
		private var fireGroundObjects:Array;//灶台位置地柜组合
		private var fireWallObjects:Array;//灶台位置吊柜组合
		private var generalGroundObjects:Array;//无水盆无灶台位置地柜组合
		private var generalWallObjects:Array;//无水盆无灶台位置吊柜组合*/
		
		/*private var waterGroundGroups:XML;//水盆位置地柜组合
		private var waterWallGroups:XML;//水盆位置吊柜组合
		private var fireGroundGroups:XML;//灶台位置地柜组合
		private var fireWallGroups:XML;//灶台位置吊柜组合
		private var generalGroundGroups:XML;//无水盆无灶台位置地柜组合
		private var generalWallGroups:XML;*///无水盆无灶台位置吊柜组合
		
		/*private function initBaseGroups():void
		{
			waterGroundGroups = 
				<data>
					<core>16,17</core>
					<sides>3</sides>
					<middle>3,2</middle>
					<ends>1,0</ends>
					<corner>25</corner>
				</data>;
			
			waterWallGroups = 
				<data>
					<core>3</core>
					<sides>3</sides>
					<middle>3</middle>
					<ends>2,1,0</ends>
					<corner>9</corner>
				</data>;
			
			fireGroundGroups = 
				<data>
					<core></core>
					<sides></sides>
					<middle></middle>
					<ends></ends>
					<corner></corner>
				</data>;
			
			fireWallGroups = 
				<data>
					<core></core>
					<sides></sides>
					<middle></middle>
					<ends></ends>
					<corner></corner>
				</data>;
			generalGroundGroups = 
				<data>
					<core></core>
					<sides></sides>
					<middle></middle>
					<ends></ends>
					<corner></corner>
				</data>;
			
			generalWallGroups = 
				<data>
					<core></core>
					<sides></sides>
					<middle></middle>
					<ends></ends>
					<corner></corner>
				</data>;
		}*/
		
		public function replaceCurrCabinet():void
		{
			if(!gvar.currProduct)return;
			//productManager.replaceProductObject(gvar.currProduct,506,"cabinet_506_800x720x570.pdt","");
			productManager.replaceProductObject(gvar.currProduct,513,"cabinet_513_450x720x570.pdt","",0,0,0);
			//productManager.replaceProductObject1_2(gvar.currCabinet.vo,515,"cabinet_515_600x720x570.pdt",0,"");
			gvar.currProduct2 = null;
		}
		
		//==============================================================================================
		public function CabinetController(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("WallController是一个单例类，请用静态方法getInstance来获得类的实例。");
			}
			
			//initCabinetData();
		}
		
		//==============================================================================================
		static private var instance:CabinetController;
		
		static public function getInstance():CabinetController
		{
			instance ||= new CabinetController(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}
