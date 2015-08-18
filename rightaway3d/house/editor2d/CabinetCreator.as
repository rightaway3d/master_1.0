package rightaway3d.house.editor2d
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import away3d.core.pick.PickingColliderType;
	import away3d.events.MouseEvent3D;
	
	import rightaway3d.engine.action.PropertyAction;
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductInfoLoader;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.lib.CabinetTool;
	import rightaway3d.house.utils.Geom;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.ObstacleType;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallArea;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;
	
	import ztc.meshbuilder.room.CabinetTable3D;
	import ztc.meshbuilder.room.CabinetTableTool;
	import ztc.meshbuilder.room.MaterialLibrary;

	public class CabinetCreator
	{
		private var productManager:ProductManager = ProductManager.own;
		
		private var cabinetCtr:CabinetController = CabinetController.getInstance();
		
		private var _cabinetTableDefaultMaterial:String;
		
		public function get cabinetTableDefaultMaterial():String
		{
			return _cabinetTableDefaultMaterial;
		}
		
		//设置默认材质时，要重新设置当前已经创建的台面
		public function set cabinetTableDefaultMaterial(value:String):void
		{
			_cabinetTableDefaultMaterial = value;
			for each(var ct:CabinetTable3D in tableMeshs)
			{
				ct.setMaterial(value);
			}
		}
		
		private var _cabinetBodyDefaultMaterial:String;
		
		public function get cabinetBodyDefaultMaterial():String
		{
			return _cabinetBodyDefaultMaterial;
		}
		
		//设置默认材质时，要重新设置当前已经创建的柜体
		public function set cabinetBodyDefaultMaterial(value:String):void
		{
			_cabinetBodyDefaultMaterial = value;
			ProductInfo.defaultMaterialDict[CabinetType.BODY_PLANK] = value;
			productManager.setProductMaterial(CabinetType.BODY_PLANK,value);
		}
		
		
		/*private var _cabinetDoorDefaultMaterial:String;
		
		public function get cabinetDoorDefaultMaterial():String
		{
			return _cabinetDoorDefaultMaterial;
		}*/
		
		//设置默认材质时，要重新设置当前已经创建的柜门
		public function setCabinetDoorDefaultMaterial(value:String):void
		{
			//_cabinetDoorDefaultMaterial = value;
			//ProductInfo.customMaterialDict[CabinetType.DOOR_PLANK] = value;
			//productManager.setProductMaterial(CabinetType.DOOR_PLANK,value);
			groundCabinetDoorMaterial = value;
			wallCabinetDoorMaterial = value;
		}
		
		private var groundCabinetDoorMat:String;
		
		//设置所有地柜门及封板材质
		public function set groundCabinetDoorMaterial(matName:String):void
		{
			groundCabinetDoorMat = matName;
			ProductInfo.defaultMaterialDict[CabinetType.DOOR_PLANK+CrossWall.IGNORE_OBJECT_HEIGHT] = matName;
			//setCabinetsDoorMaterial(sceneGroundCabinets,matName);
			
			var a:Array = this.productManager.getProductObjectsByType(CabinetType.DOOR_PLANK);
			
			for each(var po:ProductObject in a)
			{
				var rpo:ProductObject = ProductManager.own.getRootParent(po);
				if(rpo.objectInfo.y<CrossWall.GROUND_OBJECT_HEIGHT)
				{
					setCabinetDoorsMaterial(po,matName);
				}
			}
		}
		
		public function get groundCabinetDoorMaterial():String
		{
			return groundCabinetDoorMat;
		}
		
		private var wallCabinetDoorMat:String;
		
		//设置所有吊柜门及封板材质
		public function set wallCabinetDoorMaterial(matName:String):void
		{
			wallCabinetDoorMat = matName;
			ProductInfo.defaultMaterialDict[CabinetType.DOOR_PLANK+CrossWall.WALL_OBJECT_HEIGHT] = matName;
			//setCabinetsDoorMaterial(sceneWallCabinets,matName);
			
			var a:Array = this.productManager.getProductObjectsByType(CabinetType.DOOR_PLANK);
			
			for each(var po:ProductObject in a)
			{
				var rpo:ProductObject = ProductManager.own.getRootParent(po);
				if(rpo.objectInfo.y>CrossWall.GROUND_OBJECT_HEIGHT)
				{
					setCabinetDoorsMaterial(po,matName);
				}
			}
		}
		
		public function get wallCabinetDoorMaterial():String
		{
			return wallCabinetDoorMat;
		}
		
		private function setCabinetsDoorMaterial(cabs:Array,matName:String):void
		{
			for each(var po:ProductObject in cabs)
			{
				setCabinetDoorsMaterial(po,matName);
			}
		}
		
		//设置一个厨柜中所有门的材质
		public function setCabinetDoorsMaterial(po:ProductObject,matName:String):void
		{
			trace("--name:"+po.name);
			/*if(po.modelObject)
			{
				setDoorMaterial(po,matName);
			}
			else
			{
				if(po.subProductObjects)setDoorsMaterial(po.subProductObjects,matName);
				if(po.dynamicSubProductObjects)setDoorsMaterial(po.dynamicSubProductObjects,matName);
			}*/
			//有模型，或者没有模型也没有子产品
			if(po.modelObject || (!po.subProductObjects && !po.dynamicSubProductObjects))setDoorMaterial(po,matName);
			if(po.subProductObjects)setDoorsMaterial(po.subProductObjects,matName);
			if(po.dynamicSubProductObjects)setDoorsMaterial(po.dynamicSubProductObjects,matName);
		}
		
		private function setDoorsMaterial(pos:Vector.<ProductObject>,matName:String):void
		{
			for each(var po:ProductObject in pos)
			{
				//trace("------setDoorsMaterial name,name_en,mat:"+po.name,po.name_en,matName);
				setCabinetDoorsMaterial(po,matName);
			}
		}
		
		//设置当前门的材质
		public function setDoorMaterial(po:ProductObject,matName:String):void
		{
			trace("------name,type:",po.name,po.type);
			if(po.type==CabinetType.DOOR_PLANK)
			{
				po.customMaterialName = matName;
			}
		}
		
		/*
		自动创建规则
		总体规则：统一性，对称性，大尺寸（900）优先
		细则：
		1,柜与柜之间不留间隙
		2,电器中指定电烤箱时，电烤箱柜放置于灶台位置，与灶台保持中心对齐
		3,一般情况下，灶台左右各放置一个300的拉篮柜
		4,灶台下如果是电烤箱，必须左右都放置拉篮柜
		5,灶下如果不放置电器则默认放置800或900碗盘拉篮柜
		6,灶台下放置双开门灶台柜时，如果空间不够，可以只放置一个或不放置拉篮柜
		7,抽油烟机与灶台保持中心对齐，与左右吊柜最小间距30mm
		8,水盆和灶台放置于同一面墙时，水盆和灶台之间要尽可能的远
		9,默认有一个抽屉柜，空间允许情况下放置与水盆柜同规格的二平分抽屉柜，
		否则放置小小大抽屉柜，优先放置600，其次450，如果不够450，则不放置抽屉柜。
		10,消毒柜：指定的电器之中有消毒柜时，放置此柜，一般位于水盆柜的左边或右边
		11,转角柜至邻墙间距至少100（600-（900-400）），转角柜门外面与相邻墙地柜侧板的最小间距为50
		12,柜体拐角处封板默认为50mm，柜体与墙之间距离不得小于30mm
		13,上翻门吊柜：默认放一个
		14,转角吊柜：转角柜至邻墙间距紧贴，转角柜门外面与相邻墙吊柜侧板的最小间距为50
		15,拐角挡板，柜腿挡板
		16,左开门右开门
		
		17，开门方向怎么定?
		18，缝隙挡板规格位置？
		19，柜腿挡板规格位置？
		
		要先解决的问题：
		1，台面挡门(ok)
		2，缝隙问题
		3，水盆灶台同墙处理（ok）
		4，可指定电器设备型号（还差电器）
		*/
		/*
		自动创建算法
		设置房间尺寸
		设置门窗
		选择墙体，设置放置厨柜的区域范围
		放置水盆灶台定位标志
		设置每个选择区域的首尾标志：首或尾是否有拐角柜，首或尾的障碍物类型
		根据区域间的衔接情况，及中间有门分割情况，计算独立分区
		对每个区域根据根据障碍物进行分段
		对每个分段设置首尾标志：首或尾是否有拐角柜，首或尾的障碍物类型
		对分段的首或尾的障碍物类型为墙洞的，作缩进处理
		生成地柜组合
		对分段首或尾没有障碍物的（NULL)的，要调整分段尺寸，使当前端的台面出沿30mm
		根据地柜组合尺寸及分段首尾障碍物类型，计算地柜组合位置
		调整水盆灶台及烟机位置
		加载地柜及水盆灶台烟机
		计算台面数据及水盆挖洞位置，创建台面
		
		根据烟机窗户及其它障碍物，对吊柜区域进行分段
		对每个分段设置首尾标志：首或尾是否有拐角柜，首或尾的障碍物类型
		对分段的首或尾的障碍物类型为墙洞的，作缩进处理
		生成吊柜组合
		根据吊柜组合尺寸及分段首尾障碍物类型，计算吊柜组合位置
		加载吊柜
		
		布置地柜前，要对墙体按障碍物及门进行分段
		布置吊柜前，要对墙体按障碍物、门及窗进行分段
		创建台面前，要对地柜进行区域划分
		地柜
		根据整体布局指定拐角柜
		根据水盆灶台定位标志位置，初步指定水盆灶台柜位置
		匹配水盆灶台的柜体型号及相关电器柜与拉篮柜
		根据墙面可用长度，初步指定厨柜列表
		匹配合适型号的抽屉柜
		整体位置调整，合并缝隙
		根据多余缝隙，个别调整厨柜型号
		创建台面
		
		0，由用户定位水盆和灶台的位置
		1，系统自动设计厨柜，并细微调整水盆和灶台的位置
		2,电器中指定电烤箱时，电烤箱柜放置于灶台位置，与灶台保持中心对齐
		3,一般情况下，灶台左右各放置一个300的拉篮柜
		4,灶台下如果是电烤箱，必须左右都放置拉篮柜
		5,灶下如果不放置电器则默认放置800或900碗盘拉篮柜
		6,灶台下放置双开门灶台柜时，如果空间不够，可以只放置一个或不放置拉篮柜
		7,抽油烟机与灶台保持中心对齐，与左右吊柜最小间距30mm
		8,水盆和灶台放置于同一面墙时，水盆和灶台之间要尽可能的远
		9,默认有一个抽屉柜，空间允许情况下放置与水盆柜同规格的二平分抽屉柜，
		否则放置小小大抽屉柜，优先放置600，其次450，如果不够450，则不放置抽屉柜。
		10,消毒柜：指定的电器之中有消毒柜时，放置此柜，一般位于水盆柜的左边或右边
		11,转角柜至邻墙间距至少100（600-（900-400）），转角柜门外面与相邻墙地柜侧板的最小间距为50
		12,柜体拐角处封板默认为50mm，柜体与墙之间距离不得小于30mm
		13,上翻门吊柜：默认放一个
		14,转角吊柜：转角柜至邻墙间距紧贴，转角柜门外面与相邻墙吊柜侧板的最小间距为50
		
		吊柜
		根据整体布局指定拐角柜
		根据灶台位置确定烟机位置
		放置上翻门吊柜
		放置其它厨柜
		*/
		
		private var drainerData:Object;
		private var flueData:Object;
		private var cookerHoodData:Object;
		private var sterilizerData:Object;
		private var ovenData:Object;

		private var flueFlag:Product2D;
		private var drainerFlag:Product2D;

		/**
		 * 自动创建厨柜
		 * @param drainer：水盆数据
		 * @param flue：灶台数据
		 * @param cookerHood：烟机数据
		 * @param sterilizer：消毒柜数据
		 * @param oven：烤箱数据
		 * 
		 */
		public function autoCreateCabinet(drainer:Object,flue:Object,cookerHood:Object,sterilizer:Object=null,oven:Object=null):void
		{
			/*trace("-------------autoCreateCabinet:");
			trace("flueProduct:"+this.flueProduct);
			trace("drainerProduct:"+this.drainerProduct);
			trace("drainer:"+drainer);
			trace("flue:"+flue);
			trace("cookerHood:"+cookerHood);
			trace("sterilizer:"+sterilizer);
			trace("oven:"+oven);*/
			
			flueFlag = cabinetCtr.flueFlag;
			drainerFlag = cabinetCtr.drainerFlag;
			
			if(!flueFlag || !drainerFlag)
			{
				throw new Error("请放置"+(!drainerFlag?"水盆":"灶台")+"到已选择的区域上");
				return;
			}
			
			var generalWall:Wall2D;//一般墙体，既没有灶台也没有水盆关联
			//var generalWall:Wall2D;//一般墙体，既没有灶台也没有水盆关联
			var generalCrossWall:CrossWall;
			var walls:Dictionary = cabinetCtr.currRoom2d.walls;
			
			for(var w:Wall2D in walls)
			{
				if(w.vo.selectorArea)//从厨房的已选中墙体中，找出一般墙体，用来创建无灶台无水盆的厨柜组合
				{
					if(w!=flueFlag.wall && w!=drainerFlag.wall)
					{
						if(generalWall)
						{
							throw new Error("只能有一面墙不放置水盆和灶台");
							return;//只允许有一个一般墙体
						}
						
						generalWall = w;
						generalCrossWall = walls[w];
					}
				}
			}
			
			drainerData = drainer;
			flueData = flue;
			cookerHoodData = cookerHood;
			sterilizerData = sterilizer;
			ovenData = oven;
			
			var flueCrossWall:CrossWall = walls[flueFlag.wall];
			var drainerCrossWall:CrossWall = walls[drainerFlag.wall];
			
			if(!generalCrossWall)//没有一般墙体
			{
				if(flueCrossWall == drainerCrossWall)//水盆和灶台放置于同一面墙体
				{
					trace("水盆和灶台放置于同一面墙体");
					setCameraPanAngle(flueCrossWall.wall);
					_autoCreateCabinet([[drainerCrossWall]]);
				}
				else//水盆和灶台放置于不同墙体
				{
					if(drainerCrossWall.endCrossWall==flueCrossWall && flueCrossWall.headCrossWall==drainerCrossWall)
					{
						trace("水盆-->灶台");
						setCameraPanAngle(drainerCrossWall.wall,flueCrossWall.wall);
						_autoCreateCabinet([[drainerCrossWall,flueCrossWall]]);
					}
					else if(flueCrossWall.endCrossWall==drainerCrossWall && drainerCrossWall.headCrossWall==flueCrossWall)
					{
						trace("灶台-->水盆");
						setCameraPanAngle(drainerCrossWall.wall,flueCrossWall.wall);
						_autoCreateCabinet([[flueCrossWall,drainerCrossWall]]);
					}
					else//两个墙面不相交
					{
						trace("两个墙面不相交:灶台-水盆");
						setCameraPanAngle(flueCrossWall.wall);
						_autoCreateCabinet([[flueCrossWall],[drainerCrossWall]]);
					}
				}
			}
			else
			{
				trace("一般墙体");
				if(flueCrossWall == drainerCrossWall)//水盆和灶台放置于同一面墙体
				{
					trace("水盆和灶台放置于同一面墙体");
					if(generalCrossWall.headCrossWall==drainerCrossWall && drainerCrossWall.endCrossWall==generalCrossWall)
					{
						trace("水盆,灶台-->一般墙体");
						setCameraPanAngle(generalCrossWall.wall,flueCrossWall.wall);
						_autoCreateCabinet([[drainerCrossWall,generalCrossWall]]);
					}
					else if(generalCrossWall.endCrossWall==drainerCrossWall && drainerCrossWall.headCrossWall==generalCrossWall)
					{
						trace("一般墙体-->水盆,灶台");
						setCameraPanAngle(generalCrossWall.wall,flueCrossWall.wall);
						_autoCreateCabinet([[generalCrossWall,drainerCrossWall]]);
					}
					else//两个墙面不相交
					{
						trace("两个墙面不相交:水盆,灶台-一般墙体");
						setCameraPanAngle(flueCrossWall.wall);
						_autoCreateCabinet([[drainerCrossWall],[generalCrossWall]]);
					}
				}
				else//水盆和灶台放置于不同墙体
				{
					if(drainerCrossWall.endCrossWall==flueCrossWall && flueCrossWall.endCrossWall==generalCrossWall)
					{
						trace("水盆-->灶台-->一般墙体");
						setCameraPanAngle(flueCrossWall.wall);
						_autoCreateCabinet([[drainerCrossWall,flueCrossWall,generalCrossWall]]);
					}
					else if(flueCrossWall.endCrossWall==drainerCrossWall && drainerCrossWall.endCrossWall==generalCrossWall)
					{
						trace("灶台-->水盆-->一般墙体");
						setCameraPanAngle(drainerCrossWall.wall);
						_autoCreateCabinet([[flueCrossWall,drainerCrossWall,generalCrossWall]]);
					}
					else if(drainerCrossWall.endCrossWall==generalCrossWall && generalCrossWall.endCrossWall==flueCrossWall)
					{
						trace("水盆-->一般墙体-->灶台");
						setCameraPanAngle(generalCrossWall.wall);
						_autoCreateCabinet([[drainerCrossWall,generalCrossWall,flueCrossWall]]);
					}
					else if(flueCrossWall.endCrossWall==generalCrossWall && generalCrossWall.endCrossWall==drainerCrossWall)
					{
						trace("灶台-->一般墙体-->水盆");
						setCameraPanAngle(generalCrossWall.wall);
						_autoCreateCabinet([[flueCrossWall,generalCrossWall,drainerCrossWall]]);
					}
					else if(generalCrossWall.endCrossWall==drainerCrossWall && drainerCrossWall.endCrossWall==flueCrossWall)
					{
						trace("一般墙体-->水盆-->灶台");
						setCameraPanAngle(drainerCrossWall.wall);
						_autoCreateCabinet([[generalCrossWall,drainerCrossWall,flueCrossWall]]);
					}
					else if(generalCrossWall.endCrossWall==flueCrossWall && flueCrossWall.endCrossWall==drainerCrossWall)
					{
						trace("一般墙体-->灶台-->水盆");
						setCameraPanAngle(flueCrossWall.wall);
						_autoCreateCabinet([[generalCrossWall,flueCrossWall,drainerCrossWall]]);
					}
					else
					{
						trace("这是什么情况");
					}
				}
			}
		}
		
		private var tableMeshs:Vector.<CabinetTable3D> = new Vector.<CabinetTable3D>();
		
		private var houseDX:Number = 0;
		private var houseDZ:Number = 0;
		
		//更新台面位置
		public function updateTableMeshsPos(dx:Number,dz:Number):void
		{
			houseDX = dx;
			houseDZ = dz;
			
			for each(var ct:CabinetTable3D in tableMeshs)
			{
				ct.x = -dx;
				ct.z = -dz;
				//trace("updateTableMeshsPos:"+ct.x,ct.z);
			}
			
			flueProduct = getProduct(ProductObjectName.FLUE);
			if(flueProduct)
			{
				flueProduct.container3d.x = flueProduct.position.x - dx;
				flueProduct.container3d.z = flueProduct.position.z - dz;
			}
			
			drainerProduct = getProduct(ProductObjectName.DRAINER);
			if(drainerProduct)
			{
				drainerProduct.container3d.x = drainerProduct.position.x - dx;
				drainerProduct.container3d.z = drainerProduct.position.z - dz;
			}
		}
		
		//切换台面的显示状态
		public function switchCabinetTableVisible():void
		{
			for each(var ct:CabinetTable3D in tableMeshs)
			{
				ct.visible = !ct.visible;
				//trace("ct.visible:"+ct.visible);
			}
			
			/*flueProduct = getProduct(ProductObjectName.FLUE);
			if(flueProduct)
			{
				flueProduct.container3d.visible = ct.visible;
			}*/
			
			/*drainerProduct = getProduct(ProductObjectName.DRAINER);
			if(drainerProduct)
			{
				drainerProduct.container3d.visible = ct.visible;
			}*/
		}
		
		//添加台面到三维显示
		private function addTableMeshs():void
		{
			for each(var ct:CabinetTable3D in tableMeshs)
			{
				cabinetCtr.engineManager.addRootChild(ct);
			}
		}
		
		/*
		gttm：柜体台面，body：柜体小计，door：门板小计，table：台面小计
		wjdq：五金及电器，wjxj：五金配件小计，dqxj：电器配件小计
		total：合计金额
		name:部件名称，guige:规格，price:单价，num：数量，subtotal：金额，other；备注
		*/		
		public function getCabinetList():String
		{
			var subtotal:Object = {};
			var cps:String = getCabinetDoorData(CabinetType.CORNER_PLANK,subtotal);
			
			var s:String = "{";
			s += "\"gttm\":{";
			s += "\"list\":["+getProductsData(CabinetType.BODY,subtotal);
			s += getCabinetDoorData(CabinetType.DOOR_PLANK,subtotal) + ",";
			if(cps)s += cps + ",";
			s += getTableData(subtotal)+"],";
			s += "\"body\":"+getNum(subtotal,CabinetType.BODY)+",";
			s += "\"door\":"+getNum(subtotal,CabinetType.DOOR_PLANK)+",";
			s += "\"table\":"+getNum(subtotal,CabinetType.TABLE)+"},";
			s += "\"wjdq\":{";
			s += "\"list\":["+getDeviceData(subtotal)+"],";
			s += "\"wjxj\":"+getWujinSubtotal(subtotal)+",";
			s += "\"dqxj\":"+getDeviceSubtotal(subtotal);
			s += "},";
			
			_totalPrice = getTotal(subtotal);
			
			s += "\"total\":"+_totalPrice;
			s += "}";
			
			//trace("getCabinetList:"+_totalPrice);
			//trace(s);
			return s;
		}
		
		public function getProductList():String
		{
			var subtotal:Object = {};
			var s:String = "[";
			s += getProductsData(CabinetType.BODY,subtotal);
			s += getCabinetDoorData(CabinetType.DOOR_PLANK,subtotal) + ",";
			s += getCabinetDoorData(CabinetType.CORNER_PLANK,subtotal) + ",";
			s += getTableData(subtotal)+",";
			s += getDeviceData(subtotal);
			s += "]";
			
			_totalPrice = getTotal(subtotal);
			trace("getProductList:"+_totalPrice);
			return s;
		}
		
		public function getERPData(userID:String,userName:String,address:String,phone:String,startTime:String,endTime:String):String
		{
			var operation:String = "";//操作标志
			var statusCode:String = "";//状态编码
			var statusText:String = "";//状态描述
			var orderCode:String = "";//订单编号
			var discount:Number = 0;//订单折扣
			var paid:Number = 0;//已付款
			var orderOther:String = "";//订单备注
			
			var s:String = "{";
				s += "\"operation\":\"" + operation + "\",";
				
				s += "\"status\":{";
					s += "\"code\":\"" + statusCode + "\",";
					s += "\"text\":\"" + statusText + "\"";
				s += "},";
				
				s += "\"custom\":{";
					s += "\"custcode\":\"" + userID + "\",";
					s += "\"custname\":\"" + userName + "\",";
					s += "\"address\":\"" + address + "\",";
					s += "\"custphone\":\"" + phone + "\"";
				s += "},";
				
				var subtotal:Object = {};
				s += "\"orderdetail\":[";
					s += getProductsData(CabinetType.BODY,subtotal);
					s += getCabinetDoorData(CabinetType.DOOR_PLANK,subtotal) + ",";
					s += getCabinetDoorData(CabinetType.CORNER_PLANK,subtotal) + ",";
					s += getTableData(subtotal)+",";
					s += getDeviceData(subtotal);
				s += "],";
				
				_totalPrice = getTotal(subtotal);//订单总价
				trace("getERPData:"+_totalPrice);
				
				s += "\"orderinfo\":{";
					s += "\"startTime\":\"" + startTime + "\",";
					s += "\"endTime\":\"" + endTime + "\",";
					s += "\"ordercode\":\"" + orderCode + "\",";
					s += "\"total\":\"" + _totalPrice + "\",";
					s += "\"discount\":\"" + discount + "\",";
					s += "\"paid\":\"" + statusCode + "\",";
					s += "\"other\":\"" + orderOther + "\"";
				s += "}";
			s += "}";
			
			return s;
		}
		
		private var _totalPrice:Number = 0;
		public function getTotalPrice():Number
		{
			trace("getTotalPrice:"+_totalPrice);
			return _totalPrice;
		}
		
		private function getTotal(subtotal:Object):Number
		{
			var n:Number = 0;
			for each(var t:Number in subtotal)
			{
				n += t;
			}
			return n;
		}
		
		//电器配件小计柜门板:
		private function getDeviceSubtotal(subtotal:Object):Number
		{
			var n:Number = 0;
			n += getNum(subtotal,CabinetType.DRAINER);
			n += getNum(subtotal,CabinetType.FLUE);
			n += getNum(subtotal,CabinetType.HOOD);
			n += getNum(subtotal,CabinetType.OVEN);
			n += getNum(subtotal,CabinetType.STERILIZER);
			return n;
		}
		
		//五金配件小计
		private function getWujinSubtotal(subtotal:Object):Number
		{
			var n:Number = 0;
			n += getNum(subtotal,CabinetType.HANDLE);
			n += getNum(subtotal,CabinetType.LEG);
			n += getNum(subtotal,CabinetType.DRAWER);
			n += getNum(subtotal,CabinetType.BASKET);
			return n;
		}
		
		private function getNum(subtotal:Object,type:String):Number
		{
			return subtotal[type]?subtotal[type]:0;
		}
		
		private function getDeviceData(subtotal:Object):String
		{
			var s:String = "";
			s += getProductsData(CabinetType.DRAINER,subtotal);
			s += getProductsData(CabinetType.FLUE,subtotal);
			s += getProductsData(CabinetType.HOOD,subtotal);
			s += getProductsData(CabinetType.DRAWER,subtotal);
			s += getProductsData(CabinetType.BASKET,subtotal);
			s += getProductsData(CabinetType.OVEN,subtotal);
			s += getProductsData(CabinetType.STERILIZER,subtotal);
			s += getProductsData(CabinetType.HANDLE,subtotal);
			s += getLetPlankData(subtotal);
			s += getProductsData(CabinetType.LEG_PLANK_CONNECTION,subtotal);
			s += getIncreaseProductData(subtotal);
			s = s.slice(0,-1);
			return s;
		}
		
		private function getCabinetDoorData(productType:String,subtotal:Object):String
		{
			//var productType:String = CabinetType.DOOR_PLANK;
			subtotal[productType] = 0;
			
			maxDoorArea = 0;
			doorColor = "";
			
			//var infos:Array = productManager.getProductsByType(productType);
			//var len:int = infos.length;
			var n:Number = 0;
			var s:String = "";
			//for(var i:int=0;i<len;i++)
			//{
				//var info:ProductInfo = infos[i];
				//var pos:Array = info.getProductObjects();
				var pos:Array = productManager.getProductObjectsByType(productType);
				var plen:int = pos.length;
				trace("getCabinetDoorData:"+plen,productType,pos);
				//if(info.name!=CabinetType.BAFFLE && plen>0)
				if(plen>0)
				{
					var dict:Dictionary = new Dictionary();
					for(var j:int=0;j<plen;j++)
					{
						var po:ProductObject = pos[j];
						if(po.name_en!=CabinetType.BAFFLE)
						{
							var matName:String = po.customMaterialName + (po.parentProductObject?po.parentProductObject.memo:"");//memo信息为地（吊）左（右）
							matName = po.name + "|" + po.specifications + "|" + matName;
							trace("________matName:",matName);
							var a:Array;
							if(dict[matName])
							{
								a = dict[matName];
							}
							else
							{
								a = [];
								dict[matName] = a;
							}
							a.push(po);
						}
					}
					
					for each(a in dict)
					{
						s += getDoorData(a,subtotal) + ",";
					}
				}
			//}
			if(s.length>0)s = s.slice(0,-1);
			return s;
		}
		
		/*public function getDoorColor():String
		{
			//getCabinetDoorData({});
			return doorColor;
		}*/
		
		private var maxDoorArea:Number = 0;
		private var doorColor:String = "";//门板色调
		private var doorURL:String = "";//门板材质图片地址
		
		private function getDoorData(pos:Array,subtotal:Object):String
		{
			var productType:String = CabinetType.DOOR_PLANK;//下单数据中，所有封板类型统一使用
			
			var plen:int = pos.length;
			var po:ProductObject = pos[0];
			var info:ProductInfo = po.productInfo;
			
			var name:String = po.customMaterialName;//this._cabinetDoorDefaultMaterial;
			
			var matLib:MaterialLibrary = MaterialLibrary.instance;
			var price:Number = matLib.getMaterialPrice(name);
			
			var d:Vector3D = info.dimensions;
			trace(info.name+":"+d+" num:"+plen);
			
			var n:Number;
			if(d.x == 18)n = d.y * d.z;
			else if(d.y == 18)n = d.x * d.z;
			else
				n = d.x * d.y;
			
			n *= plen;
			var t:int = Math.ceil(n / 1000);
			
			n = t/1000; //单位转换为平米,精确到小数点后3位数
			
			//trace("部件名称："+"门板"+" 规格："+name+" 单价："+price+" 数量："+n+" 金额："+price*n+" 备注："+"");
			var total:Number = price*n;
			var c:int = Math.ceil(total*100);
			total = c/100;//保留两位小数
			subtotal[productType] += total;
			
			var id:int = info.infoID;
			var productName:String = po.name;//info.name;//matLib.getMaterialAttribute(name,"productModel");
			var productModel:String = matLib.getMaterialAttribute(name,"productName");
			var specifications:String = "["+(po.specifications?po.specifications:d.x+"x"+d.y+"x18")+"]x"+plen;//matLib.getMaterialAttribute(name,"specifications");
			if(po.parentProductObject && po.parentProductObject.memo)specifications += "("+po.parentProductObject.memo+")";//标注地柜吊柜左右开门
			
			var productCode:String = matLib.getMaterialAttribute(name,"productCode");
			if(productCode)
			{
				var c1:String = productCode.substr(0,4);
				var c2:String = po.productCode && po.productCode.length==3?po.productCode:"0XX";
				var c3:String = productCode.substr(5,2);
				productCode = c1 + c2 + c3;
			}
			else
			{
				productCode = "000000000";
			}
			
			var materialName:String = matLib.getMaterialAttribute(name,"materialName");
			var materialDscp:String = matLib.getMaterialAttribute(name,"materialDscp");
			var unit:String = matLib.getMaterialAttribute(name,"unit");
			var other:String = info.memo;//matLib.getMaterialAttribute(name,"other");
			var image:String = matLib.baseUrl + matLib.getMaterialAttribute(name,"diffuseMap");
			
			if(total>maxDoorArea)
			{
				maxDoorArea = total;
				doorColor = productModel + "-" + materialDscp;
				doorURL = image;
			}
			
			return toOrderJson3(id,productName,productType,productModel,specifications,productCode,materialName,materialDscp,unit,price,n,total,name,image);

			//return toOrderJson1("门板","平方米",price,n,total,name);
		}
/*		
		"productID":1001,
		"productName":"产品名称",
		"productType":"产品类型",
		"productModel":"产品型号",
		"specifications":"产品规格",
		"productCode":"物料编码",
		"materialName":"材质名称",
		"materialDscp":"材质描述",
		"unit":"单位",
		"price":10,
		"count":1,
		"subtotal":10,
		"other":"备注"
*/		
		private function getProductsData(type:String,subtotal:Object):String
		{
			var s:String = "";
			var infos:Array = productManager.getProductsByType(type);
			var len:int = infos.length;
			//trace("getProductsData type1:"+type+" num:"+len);
			
			for(var i:int=0;i<len;i++)
			{
				var info:ProductInfo = infos[i];
				//var plen:int = info.getProductObjects().length;
				var plen:int = getOrderProductNum(info);
				//trace("getProductsData type2:"+type+" num:"+plen);
				if(plen>0)
				{
					var total:Number = info.price*plen;
					var c:int = Math.ceil(total*100);
					total = c/100;//保留两位小数
					
					if(subtotal[type])
					{
						subtotal[type] += total;
					}
					else
					{
						subtotal[type] = total;
					}
					
					s += toOrderJson3(info.infoID,info.name,info.type,info.productModel,info.specifications,info.productCode,"","",
						info.unit,info.price,plen,total,info.memo,info.image3dURL) + ",";
					//s += toOrderJson1(info.name,info.specifications,info.price,plen,total,info.memo) + ",";
					//trace("部件名称："+info.name+" 规格："+info.specifications+" 单价："+info.price+" 数量："+plen+" 金额："+info.price*plen+" 备注："+info.memo);
				}
			}
			return s;
		}
		
		//获取柜腿封板（踢脚线）数据
		private function getLetPlankData(subtotal:Object):String
		{
			var type:String = CabinetType.LEG_PLANK;
			var s:String = "";
			//var infos:Array = productManager.getProductsByType(type);
			//var len:int = infos.length;
			
			//for(var i:int=0;i<len;i++)
			//{
				//var info:ProductInfo = infos[i];
				//var pos:Array = info.getProductObjects();
				var pos:Array = productManager.getProductObjectsByType(type);
				var plen:int = pos.length;
				//var plen:int = getOrderProductNum(info);
				//trace("getProductsData type2:"+type+" num:"+plen);
				for(var j:int=0;j<plen;j++)
				{
					var po:ProductObject = pos[j];
					var info:ProductInfo = po.productInfo;
					
					var num:Number = Number(po.memo);
					var total:Number = info.price*num;
					var c:int = Math.ceil(total*100);
					total = c*0.01;//保留两位小数
					
					if(subtotal[type])
					{
						subtotal[type] += total;
					}
					else
					{
						subtotal[type] = total;
					}
					
					s += toOrderJson3(info.infoID,info.name,info.type,info.productModel,info.specifications,info.productCode,"","",
						info.unit,info.price,num,total,info.memo,info.image3dURL) + ",";
					//s += toOrderJson1(info.name,info.specifications,info.price,plen,total,info.memo) + ",";
					//trace("部件名称："+info.name+" 规格："+info.specifications+" 单价："+info.price+" 数量："+plen+" 金额："+info.price*plen+" 备注："+info.memo);
				}
			//}
			return s;
		}
		
		//获取增项产品数据
		private function getIncreaseProductData(subtotal:Object):String
		{
			var type:String = CabinetType.INCREASE_PRODUCT;
			var s:String = "";
			var pos:Array = productManager.getProductObjectsByType(type);
			var plen:int = pos.length;
			
			for(var i:int=0;i<plen;i++)
			{
				var po:ProductObject = pos[i];
				var info:ProductInfo = po.productInfo;
				
				var num:Number = Number(po.memo);
				var total:Number = po.price*num;
				var c:int = Math.ceil(total*100);
				total = c*0.01;//保留两位小数
				
				if(subtotal[type])
				{
					subtotal[type] += total;
				}
				else
				{
					subtotal[type] = total;
				}
				
				s += toOrderJson3(info.infoID,po.name,po.type,po.productModel,po.specifications,po.productCode,"","",
					po.unit,po.price,num,total,info.memo,po.image3dURL) + ",";
			}
			return s;
		}
		
		//获取添加到订单的产品数量
		private function getOrderProductNum(info:ProductInfo):int
		{
			var n:int = 0;
			if(info.type==CabinetType.BODY && info.subProductInstances.length==0)return n;//只有一个子产品的厨柜为装饰板，不加入产品清单
			
			var pos:Array = info.getProductObjects();
			//trace("getOrderProductNum:"+pos.length);
			for each(var po:ProductObject in pos)
			{
				//trace("isOrder:"+po.isOrder);
				if(po.isOrder)n++;
			}
			return n;
		}
		
		public function getTableData(subtotal:Object):String
		{
			var name:String = this._cabinetTableDefaultMaterial;
			var n:Number = 0;
			for each(var ct:CabinetTable3D in tableMeshs)
			{
				n += ct.getArea();
			}
			
			var lib:MaterialLibrary = MaterialLibrary.instance;
			var price:Number = lib.getMaterialPrice(name);
			n /= 0.6;//将面积转换为长度（延米)
			
			var total:Number = price*n;
			var c:int = Math.ceil(total*100);
			total = c/100;//保留两位小数
			
			var productType:String = CabinetType.TABLE;
			subtotal[productType] = total;
			//return toOrderJson1("台面","米",price,n,total,name);
			
			var id:int = 0;
			var productName:String = lib.getMaterialAttribute(name,"productName");
			var productModel:String = lib.getMaterialAttribute(name,"productModel");
			var specifications:String = lib.getMaterialAttribute(name,"specifications");
			var productCode:String = lib.getMaterialAttribute(name,"productCode");
			var materialName:String = lib.getMaterialAttribute(name,"materialName");
			var materialDscp:String = lib.getMaterialAttribute(name,"materialDscp");
			var unit:String = lib.getMaterialAttribute(name,"unit");
			var other:String = lib.getMaterialAttribute(name,"other");
			var image:String = lib.baseUrl + lib.getMaterialAttribute(name,"diffuseMap");
			
			return toOrderJson3(id,productName,productType,productModel,specifications,productCode,materialName,materialDscp,unit,price,n,total,name,image);
		}
		
		//[name:部件名称，guige:规格，price:单价，num：数量，subtotal：金额，other；备注]
		/*private function toOrderJson(name:String,guige:String,price:Number,num:Number,subtotal:Number,other:String):String
		{
			var s:String = "{";
			s += "\"name\":\""+name+"\",";
			s += "\"guige\":\""+guige+"\",";
			s += "\"price\":"+price+",";
			s += "\"num\":"+num+",";
			s += "\"subtotal\":"+subtotal+",";
			s += "\"other\":\""+other+"\"";
			s += "}";
			trace("部件名称："+name+" 规格："+guige+" 单价："+price+" 数量："+num+" 金额："+subtotal+" 备注："+other);
			
			return s;
		}*/
		
		private function toOrderJson3(productID:int,productName:String,productType:String,productModel:String,specifications:String,productCode:String,
									  materialName:String,materialDscp:String,unit:String,price:Number,count:Number,subtotal:Number,other:String,image:String):String
		{
			var s:String = "{";
			s += "\"productID\":"+productID+",";
			s += "\"productName\":\""+productName+"\",";
			s += "\"productType\":\""+productType+"\",";
			s += "\"productModel\":\""+productModel+"\",";
			s += "\"specifications\":\""+specifications+"\",";
			s += "\"productCode\":\""+productCode+"\",";
			s += "\"materialName\":\""+materialName+"\",";
			s += "\"materialDscp\":\""+materialDscp+"\",";
			s += "\"unit\":\""+unit+"\",";
			s += "\"price\":"+price+",";
			s += "\"count\":"+count+",";
			s += "\"subtotal\":"+subtotal+",";
			s += "\"other\":\""+other+"\",";
			s += "\"image\":\""+image+"\"";
			s += "}";
			//trace("部件名称："+name+" 规格："+guige+" 单价："+price+" 数量："+num+" 金额："+subtotal+" 备注："+other);
			trace("-----------------");
			trace(
				"\nproductID:产品编号:"+productID,
				"\nproductName:产品名称:"+productName,
				"\nproductType:产品类型:"+productType,
				"\nproductModel:产品型号:"+productModel,
				"\nspecifications:产品规格:"+specifications,
				"\nproductCode:物料编码:"+productCode,
				"\nmaterialName:材质名称:"+materialName,
				"\nmaterialDscp:材质描述:"+materialDscp,
				"\nunit:单位:"+unit,
				"\nprice:单价:"+price,
				"\ncount:数量:"+count,
				"\nsubtotal:合计金额:"+subtotal,
				"\nother:备注:"+other,
				"\nimage:产品图片:"+image
			);
			trace("");
			return s;
		}
		
		//清除台面
		private function removeTableMeshs():void
		{
			while(tableMeshs.length>0)
			{
				var ct:CabinetTable3D = tableMeshs.pop();
				ct.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
				ct.removeEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
				ct.disposeWithAnimatorAndChildren();
			}
		}
		
		public function clear():void
		{
			removeTableMeshs();
			
			flueProduct = getProduct(ProductObjectName.FLUE);
			if(flueProduct)
			{
				flueProduct.dispose();
				flueProduct = null;
			}
			
			drainerProduct = getProduct(ProductObjectName.DRAINER);
			if(drainerProduct)
			{
				drainerProduct.dispose();
				drainerProduct = null;
			}
			
			for each(var po:ProductObject in plateDict)
			{
				po.dispose();
				delete plateDict[po];
			}
			
			this.sceneGroundCabinets.length = 0;
			this.sceneWallCabinets.length = 0;
		}
		
		/**
		 * 清除所有挡板、封板
		 */
		public function claerAllPlate():void
		{
			//trace("clearAllPlate");
			//productManager.deleteProductObjectsByType(CabinetType.BAFFLE);
			productManager.deleteProductObjectsByEnName(CabinetType.BAFFLE);
			productManager.deleteProductObjectsByEnName(CabinetType.CORNER_PLANK);
		}
		
		/**
		 * 清除所有单开门柜的门板，包括拐角柜的封板
		 */
		public function clearAllSingleDoor():void
		{
			var a:Array = productManager.getProductsByType(CabinetType.BODY);
			for each(var pi:ProductInfo in a)//遍历厨柜信息
			{
				var pos:Array = pi.getProductObjects();
				for each(var po:ProductObject in pos)//遍历厨柜实例
				{
					clearSingleDoor(po);
				}
			}
		}
		
		public function clearSingleDoor(po:ProductObject):void
		{
			var spos:Vector.<ProductObject> = po.dynamicSubProductObjects;
			if(spos && spos.length==1)//厨柜中只有一个动态子产品（门）
			{
				var spo:ProductObject = spos[0];
				//单开门只有两个动态子产品（门板和拉手）
				if((!spo.subProductObjects || spo.subProductObjects.length==0) && spo.dynamicSubProductObjects && spo.dynamicSubProductObjects.length==2)						{
					spo.dispose();
					spos.pop();
				}
			}
			else if(po.objectInfo.height>800)//高柜，中高柜
			{
				if(spos)deleteDoor(spos);
				//if(po.subProductObjects)deleteDoor(po.subProductObjects);
			}
		}
		
		private function deleteDoor(spos:Vector.<ProductObject>):void
		{
			//trace("len:"+spos.length);
			var a:Array = [];
			for each(var spo:ProductObject in spos)
			{
				//trace("type:"+spo.productInfo.type);
				if(spo.productInfo.type==CabinetType.DOOR)//删除掉中高柜及高柜的门
				{
					a.push(spo);
				}
			}
			for each(spo in a)
			{
				spo.dispose();
			}
		}
		
		/**
		 * 清除厨柜台面及封板、单开门门板
		 */
		public function clearCabinetTalbes():void
		{
			removeTableMeshs();
			claerAllPlate();
			//clearSingleDoor();
		}
		
		private function createTableMesh(dangshui:Array,points:Array,holes:Array=null,r:int=1,segment:uint=8,height:Number=40):void
		{
			var ct:CabinetTable3D = CabinetTableTool.createCabinetTable(dangshui,points,holes,r,segment,height);//,textureURL,normalURL,color,ambient,specular,gloss);
			//ct.material.lightPicker = engineManager.engine3d.lightPicker;
			
			//RenderUtils.setMaterial(ct,RenderUtils.getDefaultMaterial("table"));
			ct.setMaterial(this.cabinetTableDefaultMaterial);
			
			ct.y = 800;
			//ct.visible = false;
			//trace("tableMesh:"+m);
			tableMeshs.push(ct);
			
			ct.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			ct.mouseEnabled = ct.mouseChildren = true;
			
			ct.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			ct.addEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
		}
		
		private var isMouseDown:Boolean;
		private var isMouseMove:Boolean;
		
		private function onMouseDown(e:MouseEvent3D):void
		{
			isMouseDown = true;
			isMouseMove = false;
			GlobalEvent.event.dispatchCabinetTableMouseDownEvent(tableMeshs);
			cabinetCtr.scene.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			isMouseMove = true;
		}
		
		private function onMouseUp(e:MouseEvent3D):void
		{
			cabinetCtr.scene.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			if(!isMouseDown || isMouseMove)return;//如果鼠标不在此模型上按下，或者发生了移动，则不执行此后动作
			isMouseDown = false;
			
			var n:int = getTimer();
			//trace(n-lastTime);
			if(n-lastTime<1000)
			{
				dispatchCabinetTableMouseUpEvent();
				//trace("tableMouseUpEvent:"+(n-lastTime));
				lastTime = 0;
			}
			else
			{
				lastTime = n;
			}
		}
		
		public function dispatchCabinetTableMouseUpEvent():void
		{
			GlobalEvent.event.dispatchCabinetTableMouseUpEvent(tableMeshs);
		}
		
		public function getCabinetTableData():String
		{
			var s:String = "{";
			s += "\"tables\":[";
			var len:int = tableMeshs.length;
			for(var i:int=0;i<len;i++)
			{
				var ct:CabinetTable3D = tableMeshs[i];
				s += ct.toJsonString() + (i<len-1?",":"");
			}
			s += "]";
			
			/*drainerProduct = getProduct(ProductObjectName.DRAINER);
			if(drainerProduct)s += getCookerProductData("drainerProduct",drainerProduct);*/
			
			/*flueProduct = getProduct(ProductObjectName.FLUE);
			if(flueProduct)s += getCookerProductData("flueProduct",flueProduct);*/
			s += "}";
			return s;
		}
		
		private function getCookerProductData(name:String,po:ProductObject):String
		{
			var s:String = ",\""+name+"\":" + po.toJsonString();
			return s;
		}
		
		/**
		 * 还原台面
		 * @param cabinetTable
		 * 
		 */
		public function createCabinetTable(cabinetTable:Object):void
		{
			//removeTableMeshs();
			
			var tables:Array = cabinetTable.tables;
			
			for each(var ctData:Object in tables)
			{
				var border:Array = getPointsArray(ctData.border);
				var dangshui:Array = getPointsArray(ctData.dangshui);
				if(ctData.hole)var hole:Array = getPointsArray(ctData.hole);
				var radius:Number = ctData.radius;
				var segment:Number = ctData.segment;
				var height:Number = ctData.height;
				var materialName:String = ctData.materialName;
				this.cabinetTableDefaultMaterial = materialName;
				
				createTableMesh(dangshui,border,hole,radius,segment,height);//,textureURL,normalURL,color,ambient,specular,gloss);
			}
			
			addTableMeshs();
			
			//drainerProduct = getProduct(ProductObjectName.DRAINER);
			//flueProduct = getProduct(ProductObjectName.FLUE);
			
			/*if(cabinetTable.drainerProduct!=undefined)
			{
				drainerProduct = productManager.parseProductObject(cabinetTable.drainerProduct);
				//drainerProduct.container3d.visible = false;
			}
			
			if(cabinetTable.flueProduct!=undefined)
			{
				flueProduct = productManager.parseProductObject(cabinetTable.flueProduct);
				//flueProduct.container3d.visible = false;
			}*/
		}
		
		private function getProduct(name:String):ProductObject
		{
			return productManager.getProductByName(name);
		}
		
		private function getPointsArray(a:Array):Array
		{
			var ps:Array = [];
			var len:int = a.length;
			for(var i:int=0;i<len;i++)
			{
				var o:Object = a[i];
				var p:Point = new Point(o.x,o.y);
				ps.push(p);
			}
			return ps;
		}
		
		private var cabinetTabless:Array;
		private var tableDepthss:Array;
		
		/**
		 * 计算台面数据
		 * @param tables：当前厨房有1个或2个独立的台面，
		 * 1个台面时，台面依靠1～3个相邻墙面创建而成，
		 * 2个独立台面时，每个台面依靠1个不与其它墙面相邻的墙面创建而成
		 * @param holes：与独立台面上每个墙面对应的洞口标志
		 * @param depth：台面深度
		 * @param holeWidth：洞口默认宽度
		 * @param holeDepth：洞口默认深度
		 * 
		 */
		private function _autoCreateCabinet(tables:Array,depth:int=600,holeWidth:int=700,holeDepth:int=400):void
		{
			var tss:Array = setGroundCabinetArea(tables);
			
			createGroundCabinetArea(tss);
			
			//createCabinetTable3(tss,[[600,600,600],[600,600,600],[600,600,600]]);
			
			setWallCabinetArea(tss);
			
			createWallCabinetArea(tss);
			
			cabinetCtr.scene.render();
			
			flash.utils.setTimeout(buiderTable,1);
		}
		
		private function buiderTable():void
		{
			var ploader:ProductInfoLoader = ProductInfoLoader.own;
			if(ploader.hasNotLoaded)
			{
				ploader.addEventListener("all_complete",_buiderTable);
			}
			else
			{
				_buiderTable();
			}
		}
		
		private function _buiderTable(e:Event=null):void
		{
			if(e)ProductInfoLoader.own.removeEventListener("all_complete",_buiderTable);
			
			TableBuilder.own.builderTable();
			TableBuilder.own.builderDoor();
		}
		
		public function updateCabinetTable():void
		{
			trace("updateCabinetTable");
			
			if(!cabinetTabless)return;
			
			this.removeTableMeshs();
			createCabinetTable3(cabinetTabless,tableDepthss);
			updateTableMeshsPos(houseDX,houseDZ);
		}
		
		/**
		 * 设置吊柜
		 * 
		 */
		private function setWallCabinetArea(tabless:Array):void
		{
			setWallCabinetArea1(tabless);
			setWallCabinetArea2(tabless);
		}
		
		private function setWallCabinetArea1(tabless:Array):void
		{
			var tlen:int = tabless.length;
			for(var i:int=0;i<tlen;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var tlen2:int = tables.length;
				for(var j:int=0;j<tlen2;j++)//组成台面的每个子分区
				{
					var tableData:WallSubArea = tables[j];
					var cw:CrossWall = tableData.cw;
					var x0:Number = tableData.x0;
					var x1:Number = tableData.x1;
					var headCorner:Boolean = tableData.headCorner;
					var endCorner:Boolean = tableData.endCorner;
					var headType:String = tableData.headType;
					var endType:String = tableData.endType;
					var headCabinet:ProductObject = tableData.headCabinet;
					var endCabinet:ProductObject = tableData.endCabinet;
					
					//对吊柜子分区域再细分区，用窗户，烟机及烟道等障碍物进行分隔
					setWallObjectArea(tableData,cw,x0,x1,headCorner,endCorner,headType,endType,headCabinet,endCabinet);
				}
			}
		}
		
		private function setWallCabinetArea2(tabless:Array):void
		{
			var tlen:int = tabless.length;
			var subArea0:WallSubArea;
			
			var cornerCabinetWidth:int = 800;//拐角吊柜宽度
			var cornerDepth:int = 350;//拐角吊柜深度
			var cornerDist:int = 400;//拐角吊柜避让距离
			
			for(var i:int=0;i<tlen;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var tlen2:int = tables.length;
				subArea0 = null;
				
				for(var j:int=0;j<tlen2;j++)//组成台面的每个子分区
				{
					var tableData:WallSubArea = tables[j];
					var wos:Array = tableData.wallObjects;
					var tlen3:int = wos.length;
					for(var k:int=0;k<tlen3;k++)
					{
						var subArea1:WallSubArea = wos[k];
						//当前区域以拐角柜开始，或者头部顶在前面的拐角柜上
						if(subArea0 && (subArea0.endCorner || subArea0.endType==ObstacleType.CORNER_CABINET || subArea0.endType==ObstacleType.OBJECT_CORNER_CABINET
							|| subArea1.headCorner || subArea1.headType==ObstacleType.CORNER_CABINET || subArea1.headType==ObstacleType.OBJECT_CORNER_CABINET))
						{
							var area0EndX:Number = subArea0.cw.localEnd.x;//前墙尾点值
							var area1HeadX:Number = subArea1.cw.localHead.x;//当前墙首点值
							if(subArea0.length<cornerCabinetWidth && subArea1.length<cornerCabinetWidth)//拐角两边都不够放置拐角柜时，只在较长的一边放置其它吊柜
							{
								if(subArea0.length>subArea1.length)
								{
									subArea0.endCorner = false;
									subArea0.endType = ObstacleType.OBJECT;
									
									subArea1.enable = false;
								}
								else
								{
									subArea0.enable = false;
									
									subArea1.headCorner = false;
									subArea1.headType = ObstacleType.OBJECT;
								}
							}
							else if(subArea0.endCorner && subArea1.headType!=ObstacleType.CORNER_CABINET && subArea1.headType!=ObstacleType.OBJECT_CORNER_CABINET)
							{
								subArea0.endCorner = false;
							}
							else if(subArea1.headCorner && subArea0.endType!=ObstacleType.CORNER_CABINET && subArea0.endType!=ObstacleType.OBJECT_CORNER_CABINET)
							{
								subArea1.headCorner = false;
							}
							else if(area0EndX-subArea0.x1>=cornerDepth && subArea1.x0-area1HeadX>=cornerDepth)//拐角区域放置了超过350x350的障碍物时，取消拐角柜
							{
								subArea0.endCorner = false;
								subArea0.endType = ObstacleType.OBJECT_WALL;
								
								subArea1.headCorner = false;
								subArea1.headType = ObstacleType.OBJECT_WALL;
							}
							else if(area0EndX-subArea0.x1>=cornerDepth && subArea1.x0-area1HeadX<cornerDepth)//障碍物宽的一面对着拐角柜
							{
								if(subArea0.x1>area0EndX-cornerDist)subArea0.x1=area0EndX-cornerDist;
								if(subArea0.length<300)subArea0.enable = false;
								
								if(subArea1.length<cornerCabinetWidth)
								{
									subArea0.endCorner = false;
									subArea0.endType = ObstacleType.OBJECT;
									
									subArea1.headCorner = false;
									subArea1.headType = ObstacleType.OBJECT;
									
									if(subArea1.x0<cornerDist+area1HeadX)subArea1.x0=cornerDist+area1HeadX;
									if(subArea1.length<300)subArea1.enable = false;
								}
								else
								{
									subArea0.endCorner = false;
									subArea0.endType = ObstacleType.CORNER_CABINET;
									
									subArea1.headCorner = true;
									subArea1.headType = ObstacleType.OBJECT;
								}
							}
							else if(area0EndX-subArea0.x1<cornerDepth && subArea1.x0-area1HeadX>=cornerDepth)//障碍物宽的一面对着拐角柜
							{
								if(subArea0.length<cornerCabinetWidth)
								{
									subArea0.endCorner = false;
									subArea0.endType = ObstacleType.OBJECT;
									
									if(subArea0.x1>area0EndX-cornerDist)subArea0.x1=area0EndX-cornerDist;
									if(subArea0.length<300)subArea0.enable = false;
									
									subArea1.headCorner = false;
									subArea1.headType = ObstacleType.OBJECT;
								}
								else
								{
									subArea0.endCorner = true;
									subArea0.endType = ObstacleType.OBJECT;
									
									subArea1.headCorner = false;
									subArea1.headType = ObstacleType.CORNER_CABINET;
								}
								
								if(subArea1.x0<cornerDist+area1HeadX)subArea1.x0=cornerDist+area1HeadX;
								if(subArea1.length<300)subArea1.enable = false;
							}
							else if(subArea0.length>subArea1.length)//空间较大的一面放置拐角柜
							{
								subArea0.endCorner = true;
								subArea0.endType = area0EndX-subArea0.x1<1?ObstacleType.WALL:ObstacleType.OBJECT;
								
								subArea1.headCorner = false;
								subArea1.headType = ObstacleType.CORNER_CABINET;
								
								if(subArea1.x0<cornerDist+area1HeadX)subArea1.x0=cornerDist+area1HeadX;
								if(subArea1.length<300)subArea1.enable = false;
							}
							else//空间较大的一面放置拐角柜
							{
								subArea0.endCorner = false;
								subArea0.endType = ObstacleType.CORNER_CABINET;
								
								if(subArea0.x1>area0EndX-cornerDist)subArea0.x1=area0EndX-cornerDist;
								if(subArea0.length<300)subArea0.enable = false;
								
								subArea1.headCorner = true;
								subArea1.headType = subArea1.x0-area1HeadX<1?ObstacleType.WALL:ObstacleType.OBJECT;
							}
						}
						
						subArea0 = subArea1;
					}
				}
			}
		}
		
		/**
		 * 根据障碍物来调整台面分区中的厨柜区域的分段
		 * @param tabless
		 * 
		 */
		private function createGroundCabinetArea(tabless:Array):void
		{
			var tlen:int = tabless.length;
			for(var i:int=0;i<tlen;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var tlen2:int = tables.length;
				for(var j:int=0;j<tlen2;j++)//组成台面的每个墙面
				{
					var tableData:WallSubArea = tables[j];
					var cw:CrossWall = tableData.cw;
					var groundObjects:Array = tableData.groundObjects;//墙面被障碍分隔成的区间
					var glen:int = groundObjects.length;
					var beforeX1:Number;
					for(var k:int=0;k<glen;k++)
					{
						var o:WallSubArea = groundObjects[k];
						if(!o.enable)continue;
						
						var x0:Number = o.x0;
						var x1:Number = o.x1;
						var d:* = o.drainerFlag;
						var f:* = o.flueFlag;
						var hc:Boolean = o.headCorner;
						var ec:Boolean = o.endCorner;
						var ht:String = o.headType;
						var et:String = o.endType;
						var ho:ProductObject = o.headCabinet;
						var eo:ProductObject = o.endCabinet;
						
						var dx0:int=0,dx1:int=0;
						//trace("x0,x1:",x0,x1);
						if(ho)
						{
							dx0 += ho.objectInfo.width;
							if(ht==ObstacleType.HOLE)dx0+=50;//中高柜让门5cm
							
							addMiddleDoor(ho);
						}
						else if(ht==ObstacleType.NULL)//如果区域首端没有障碍物，厨柜从台面缩进3cm出沿
						{
							dx0+=30;
						}
						else if(ht==ObstacleType.HOLE)//如果区域首端障碍物为门洞，
						{
							dx0+=50;//台面让门5cm
							dx0+=30;//台面出沿3cm
						}
						else if(ht==ObstacleType.WALL)//如果区域首端顶墙，
						{
							dx0+=40;//厨柜让墙4cm
						}
						
						if(eo)
						{
							dx1 -= eo.objectInfo.width;
							if(et==ObstacleType.HOLE)dx1-=50;//中高柜让门5cm
							
							addMiddleDoor(eo);
						}
						else if(et==ObstacleType.NULL)//如果区域尾端没有障碍物，厨柜从台面缩进3cm出沿
						{
							dx1-=30;
						}
						else if(et==ObstacleType.HOLE)//如果区域尾端障碍物为门洞，
						{
							dx1-=50;//台面让门5cm
							dx1-=30;//台面出沿3cm
						}
						else if(et==ObstacleType.WALL)//如果区域尾端顶墙，
						{
							dx1-=40;//厨柜让墙4cm
						}
						trace("dx0,dx1:",dx0,dx1);
						
						var cs:Array = CabinetTool.tool.getGroundCabinetGroup(cw,x0+dx0,x1+dx1,d,f,this.sterilizerData,this.ovenData,hc,ec);
						//o.cabinets = cs;
						
						//var aw:Number = x1-x0;//当前分段有效长度
						var gw:int = getGroupWidth(cs);//当前分段中所放置的厨柜组长度
						trace("gw:",gw);
						var startOffset:Number = getStartOffset(cw,x0,x1,ht,et,hc,ec,gw,tableData,o);
//						var startOffset:Number = getStartOffset(cw,x0+dx0,x1+dx1,ht,et,hc,ec,gw,tableData,o)+dx0;
						
						x0 = o.x0;
						x1 = o.x1;
						ht = o.headType;
						et = o.endType;
						//trace("x0,x1:",x0,x1);
						
						var bx1:Number = (glen>1 && k>0)?beforeX1:0;
						loadGroundCabinet(x0,x1,startOffset,cs,cw,d,f,ht,et,hc,ec,ho,eo,bx1);
						
						beforeX1 = x0+startOffset+gw;
						//调整台面在门洞两边的厨柜上的出沿尺寸
						/*if(ht==ObstacleType.HOLE)//分区从门洞开始
						{
							tableData.x0 = x0 + startOffset - 30;//从厨柜的左则伸出30mm
						}*/
						
						/*if(et==ObstacleType.HOLE)//分区到门洞结束
						{
							tableData.x1 = x0 + startOffset + gw + 30;//从厨柜的右则伸出30mm
						}*/
					}
				}
			}
		}
		
		//添加中高柜柜门
		private function addMiddleDoor(cabinet:ProductObject):void
		{
			var doors:XMLList = CabinetTool.tool.getMiddleDoorData(cabinet);
			var len:int = doors.length();
			for(var i:int=0;i<len;i++)
			{
				ProductManager.own.addDynamicSubProduct(cabinet,doors[i]);
			}
		}
		
		private var cornerMinDist:int = 170;//拐角柜至墙的最小距离
		
		/**
		 * 地柜摆放位置偏移量
		 */
		private function getStartOffset(cw:CrossWall,x0:Number,x1:Number,ht:String,et:String,hc:Boolean,ec:Boolean,gw:Number,tableData:WallSubArea,areaData:WallSubArea):Number
		{
			var aw:Number = x1-x0;//当前分段有效长度
			var startOffset:Number = 0;
			
			var ho:ProductObject = areaData.headCabinet;
			var eo:ProductObject = areaData.endCabinet;
			
			var hw:Number = ho?ho.objectInfo.width:0;
			var ew:Number = eo?eo.objectInfo.width:0;
			var yPos:int = CrossWall.IGNORE_OBJECT_HEIGHT;
			
			if(ho && eo)//首尾皆是中高柜
			{
				if(et==ht || (ht==ObstacleType.HOLE && et==ObstacleType.NULL) || (et==ObstacleType.HOLE && ht==ObstacleType.NULL))
				{
					if(ht==ObstacleType.HOLE)x0+=50;
					if(et==ObstacleType.HOLE)x1-=50;//遇门洞避让5cm
					
					x0+=hw;//避开首端中高柜的位置
					x1-=ew;//避开尾端中高柜的位置
					
					startOffset = (x1-x0-gw)/2;//填满厨柜后的剩下空间，两头平均分
					
					x0 += startOffset;
					x1 -= startOffset;//去掉首尾间隙
					
					x0-=hw;
					x1+=ew;//再把中高柜放到有效空间里
					
					//trace("getStartOffset:",x0,x1,startOffset,gw);
					
					tableData.x0 = areaData.x0 = x0;
					tableData.x1 = areaData.x1 = x1;//更新有效空间的起止位置
					tableData.headType = areaData.headType = ObstacleType.NULL;
					tableData.endType = areaData.endType = ObstacleType.NULL;
					
					startOffset = hw;//起始位置避开首端中高柜
					
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
				else if(ht==ObstacleType.HOLE || ht==ObstacleType.NULL || ht==ObstacleType.OBJECT)
				{
					x0 = x1 - gw - hw - ew;//厨柜开始位置
					tableData.x0 = areaData.x0 = x0;
					tableData.headType = areaData.headType = ObstacleType.NULL;
					startOffset = hw;//起始位置避开首端中高柜
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
				}
				else if(et==ObstacleType.HOLE || et==ObstacleType.NULL || et==ObstacleType.OBJECT)
				{
					startOffset = hw;
					x1 = x0 + gw + hw + ew;//台面结束位置
					tableData.endType = areaData.endType = ObstacleType.NULL;
					tableData.x1 = areaData.x1 = x1;
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
			}
			else if(ho)//头部有中高柜
			{
				if(((ht==ObstacleType.HOLE || ht==ObstacleType.NULL) && (et==ObstacleType.HOLE || et==ObstacleType.NULL))
						|| (ht==ObstacleType.OBJECT && et==ObstacleType.OBJECT && !ec))//居中
				{
					if(ht==ObstacleType.HOLE)x0+=50;
					if(et==ObstacleType.HOLE)x1-=50;//遇门洞避让5cm
					
					x0+=hw;//避开首端中高柜的位置
					
					if((et==ObstacleType.HOLE || et==ObstacleType.NULL))x1+=30;//台面出沿
					
					startOffset = (x1-x0-gw)/2;//填满厨柜后的剩下空间，两头平均分
					
					x0 += startOffset;
					x1 -= startOffset;//去掉首尾间隙
					
					x0-=hw;//再把中高柜放到有效空间里
					
					//trace("getStartOffset:",x0,x1,startOffset,gw);
					
					tableData.x0 = areaData.x0 = x0;
					tableData.x1 = areaData.x1 = x1;//更新有效空间的起止位置
					tableData.headType = areaData.headType = ObstacleType.NULL;
					tableData.endType = areaData.endType = ObstacleType.NULL;
					
					startOffset = hw;//起始位置避开首端中高柜
					
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
				}
				else if(ec || et==ObstacleType.CORNER_CABINET || ht==ObstacleType.OBJECT || (et==ObstacleType.OBJECT && cw.localEnd.x-x1>1000))//尾部顶拐角柜或墙,对齐到尾端
				{
					if(ec && cw.localEnd.x-x1<cornerMinDist)//转角柜至墙的间距至少为170
					{
						x1 = cw.localEnd.x - cornerMinDist;
					}
					x0 = x1 - gw - hw - ew;//厨柜开始位置
					tableData.x0 = areaData.x0 = x0;
					tableData.headType = areaData.headType = ObstacleType.NULL;
					startOffset = hw;//起始位置避开首端中高柜
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
				}
				else//对齐到首端
				{
					startOffset = hw;
					x1 = x0 + gw + hw + ew;//台面结束位置
					tableData.endType = areaData.endType = ObstacleType.NULL;
					tableData.x1 = areaData.x1 = x1;
					//cabinetCtr.setCabinetPos(eo,cw,x1,0,0);//重新定位尾端中高柜位置
				}
			}
			else if(eo)//尾部有中高柜
			{
				if(((ht==ObstacleType.HOLE || ht==ObstacleType.NULL) && (et==ObstacleType.HOLE || et==ObstacleType.NULL))
					|| (ht==ObstacleType.OBJECT && et==ObstacleType.OBJECT && !hc))//居中
				{
					if(ht==ObstacleType.HOLE)x0+=50;
					if(et==ObstacleType.HOLE)x1-=50;//遇门洞避让5cm
					
					x1-=ew;//避开首端中高柜的位置
					
					if((ht==ObstacleType.HOLE || ht==ObstacleType.NULL))x0-=30;//台面出沿
					
					startOffset = (x1-x0-gw)/2;//填满厨柜后的剩下空间，两头平均分
					
					x0 += startOffset;
					x1 -= startOffset;//去掉首尾间隙
					
					x1+=ew;//再把中高柜放到有效空间里
					
					//trace("getStartOffset:",x0,x1,startOffset,gw);
					
					tableData.x0 = areaData.x0 = x0;
					tableData.x1 = areaData.x1 = x1;//更新有效空间的起止位置
					tableData.headType = areaData.headType = ObstacleType.NULL;
					tableData.endType = areaData.endType = ObstacleType.NULL;
					
					startOffset = (ht==ObstacleType.HOLE || ht==ObstacleType.NULL)?30:0;//起始位置
					
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
				else if(hc || ht==ObstacleType.CORNER_CABINET || et==ObstacleType.OBJECT || (ht==ObstacleType.OBJECT && x0-cw.localHead.x>1000))//头部顶拐角柜或墙,对齐到头端
				{
					if(hc && x0-cw.localHead.x<cornerMinDist)//转角柜至墙的间距至少为170
					{
						startOffset = cw.localHead.x+cornerMinDist-x0;
					}
					else
					{
						startOffset = 0;
					}
					x1 = x0 + startOffset + gw + hw + ew;//台面结束位置
					tableData.endType = areaData.endType = ObstacleType.NULL;
					tableData.x1 = areaData.x1 = x1;
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
				else//对齐到尾端
				{
					x0 = x1 - gw - hw - ew;//厨柜开始位置
					tableData.x0 = areaData.x0 = x0;
					tableData.headType = areaData.headType = ObstacleType.NULL;
					startOffset = 0;//起始位置
					//cabinetCtr.setCabinetPos(ho,cw,x0+hw,0,0);//重新定位首端中高柜位置
				}
			}
			else if(ht==et || 
				(ht==ObstacleType.HOLE && et==ObstacleType.NULL) || 
				(et==ObstacleType.HOLE && ht==ObstacleType.NULL))//墙洞，转角柜，墙，障碍物
			{
				startOffset = (aw - gw - hw - ew)/2;//如果某一端有中高柜，也要计算进去
				if(ht==ObstacleType.HOLE || ht==ObstacleType.NULL)//台面两端都没有障碍物，或者皆为门洞时，厨柜居中，两端各出沿3cm
				{
					x0 += startOffset;//厨柜开始位置
					x1 -= startOffset;//厨柜结束位置
					
					if(ho)
					{
						startOffset = hw;//起始位置避开首端中高柜
						cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
					}
					else
					{
						x0 -= 30;//台面开始位置
						startOffset = 30;
					}
					
					if(eo)
					{
						cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
					}
					else
					{
						x1 += 30;//台面结束位置
					}
					
					tableData.x0 = areaData.x0 = x0;
					tableData.x1 = areaData.x1 = x1;
					
				}
				else if(hc!=ec)
				{
					if(hc)//转角柜开头
					{
						if(eo && et==ObstacleType.WALL)//尾部中高柜贴墙侧墙放置
						{
							startOffset = x1-gw-ew;
						}
						else//尾部是其它障碍物
						{
							if(x0-cw.localHead.x<cornerMinDist)//转角柜至墙的间距至少为170
							{
								startOffset = cw.localHead.x+cornerMinDist-x0;
							}
							else
							{
								startOffset = 0;
							}
							
							if(eo)//中高柜要避开障碍物，
							{
								x1 = x0+startOffset+gw+ew;
								cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
								tableData.x1 = areaData.x1 = x1;
								tableData.endType = areaData.endType = ObstacleType.NULL;
							}
						}
					}
					else if(ec)//转角柜结尾
					{
						if(ho && ht==ObstacleType.WALL)//开头的中高柜贴墙
						{
							startOffset = hw;
						}
						else
						{
							if(cw.localEnd.x-x1<cornerMinDist)//转角柜至墙的间距至少为170
							{
								x1 = cw.localEnd.x - cornerMinDist;
							}
							
							if(ho)
							{
								startOffset = hw;
								x0 = x1 - gw - hw;
								tableData.x0 = areaData.x0 = x0;
								cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
								tableData.headType = areaData.headType = ObstacleType.NULL;
							}
							else
							{
								startOffset = x1 - gw - x0;
							}
						}
					}
				}
				//else如果两头都是拐角柜，直接居中，两头也不会出现中高柜
			}
			/*else if(ho)
			{
				
			}
			else if(eo)
			{
				
			}*/
			else if(et==ObstacleType.CORNER_CABINET//尾部顶着拐角柜
				|| ((et==ObstacleType.OBJECT || et==ObstacleType.OBJECT_CORNER_CABINET)//尾部顶着障碍物，或者顶着障碍物的拐角柜
					&& ht!=ObstacleType.CORNER_CABINET))//并且头部不是拐角柜，尾端不留间隙
			{
				var dx:Number = x1 - gw;//厨柜开始位置
				if(ht==ObstacleType.HOLE || ht==ObstacleType.NULL)//台面首端没有障碍物，或者为门洞时，出沿3cm
				{
					if(ho)//头部有中高柜
					{
						x0 = x1 - gw - hw;
						startOffset = hw;
						cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
						tableData.headType = areaData.headType = ObstacleType.NULL;
					}
					else
					{
						x0 = x1 - gw - 30;//台面开始位置出沿3cm
						startOffset = 30;
					}
					
					tableData.x0 = areaData.x0 = x0;
					
				}
				else if(ho && (et==ObstacleType.CORNER_CABINET || ht==ObstacleType.OBJECT))//开头的中高柜贴墙,尾部顶在拐角柜上
				{
					x0 = x1 - gw - hw;
					startOffset = hw;
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
					tableData.headType = areaData.headType = ObstacleType.NULL;
					tableData.x0 = areaData.x0 = x0;
				}
				else if(ho && ht==ObstacleType.WALL)//开头的中高柜贴墙
				{
					startOffset = hw;
				}
				else if(eo && et==ObstacleType.OBJECT)
				{
					if(hc && x0-cw.localHead.x<cornerMinDist)//转角柜至墙的间距至少为170
					{
						startOffset = cw.localHead.x+cornerMinDist-x0;
					}
					x1 = x0 + startOffset + gw + ew;
					tableData.x1 = areaData.x1 = x1;
					tableData.endType = areaData.endType = ObstacleType.NULL;
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
				else
				{
					startOffset = dx - x0;
				}
			}
			else if(ht==ObstacleType.CORNER_CABINET || ht==ObstacleType.OBJECT || ht==ObstacleType.OBJECT_CORNER_CABINET)//首端不留间隙
			{
				startOffset = 0;
				if(et==ObstacleType.HOLE || et==ObstacleType.NULL)//台面首端没有障碍物，或者为门洞时，出沿3cm
				{
					if(eo)//尾部有中高柜
					{
						x1 = x0 + gw + ew;
						cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
					}
					else
					{
						x1 = x0 + gw + 30;//台面结束位置
					}
				}
				else if(ho)//头部有中高柜时，必然是顶着障碍物，尾部顶墙，可能尾部有拐角柜
				{
					tx1 = x1;
					if(ec)//尾部有拐角柜
					{
						if(cw.localEnd.x-x1<cornerMinDist)//转角柜至墙的间距至少为170
						{
							var tx1:Number = cw.localEnd.x - cornerMinDist;
						}
					}
					startOffset = hw;
					x0 = tx1 - gw - hw;
					tableData.x0 = areaData.x0 = x0;
					cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
					tableData.headType = areaData.headType = ObstacleType.NULL;
				}
				else if(eo)//尾部有中高柜
				{
					x1 = x0 + gw + ew;
					cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
				}
				
				tableData.x1 = areaData.x1 = x1;
			}
			else if(et==ObstacleType.WALL)//尾端至墙4cm间隙
			{
				var tw:int = ec?cornerMinDist:40;
				dx = x1 - gw - tw;//厨柜开始位置
				if(ht==ObstacleType.HOLE || ht==ObstacleType.NULL)//台面首端没有障碍物，或者为门洞时，出沿3cm
				{
					if(ho)//头部有中高柜
					{
						x0 = dx - hw;
						startOffset = hw;
						cabinetCtr.setProductPos(ho,cw,x0+hw,yPos,0);//重新定位首端中高柜位置
					}
					else
					{
						x0 = dx - 30;//台面开始位置
						startOffset = 30;
					}
					
					tableData.x0 = areaData.x0 = x0;
				}
				else
				{
					startOffset = dx - x0;
				}
			}
			else if(ht==ObstacleType.WALL)//首端至墙4cm间隙
			{
				startOffset = hc?cornerMinDist:40;
				if(et==ObstacleType.HOLE || et==ObstacleType.NULL)//台面首端没有障碍物，或者为门洞时，出沿3cm
				{
					if(eo)//尾部有中高柜
					{
						x1 = x0 + gw + ew;
						cabinetCtr.setProductPos(eo,cw,x1,yPos,0);//重新定位尾端中高柜位置
					}
					else
					{
						x1 = x0 + startOffset + gw + 30;//台面结束位置
					}
					
					tableData.x1 = areaData.x1 = x1;
				}
			}
			else//未处理的意外情况
			{
				trace("未处理的意外情况 ht,et,hc,ec:",ht,et,hc,ec);
			}
			trace("x0,x1,aw,gw,startOffset,ht,et,hc,ec,hw,ew:",x0,x1,aw,gw,startOffset,ht,et,hc,ec,hw,ew);
			
			return startOffset;
		}
		
		private var plateDict:Dictionary = new Dictionary();
		
		/**
		 * 创建厨柜封板
		 * 
		 */
		public function createCabinetPlate(cw:CrossWall,width:int,height:int,depth:int,xPos:Number,yPos:Number,zPos:Number,ctype:String,name:String):ProductObject
		{
			//trace("width,height,depth,xPos,yPos,zPos,ctype,name:",width,height,depth,xPos,yPos,zPos,ctype,name);
			var mtype:String = ModelType.BOX_C;
			var enName:String = CabinetType.BAFFLE;
			var po:ProductObject = ProductManager.own.createCustomizeProduct(mtype,name,enName,width,height,depth,0xffffff,false);
			//po.productInfo.name = enName;
			//po.productInfo.type = ctype;
			//po.type = enName;
			//po.name_en = enName;
			po.type = ctype;
			
			if(ctype==CabinetType.DOOR_PLANK)
				po.customMaterialName = yPos>CrossWall.GROUND_OBJECT_HEIGHT?wallCabinetDoorMat:groundCabinetDoorMat;//_cabinetDoorDefaultMaterial;
			else if(ctype==CabinetType.BODY_PLANK || ctype==CabinetType.CORNER_PLANK)
				po.customMaterialName = _cabinetBodyDefaultMaterial;
			else
				po.customMaterialName = "柜脚挡板";
			
			po.objectInfo.isIgnoreObject = true;//所有挡板不会标注尺寸
			
			if(cw)
			{
				ProductManager.own.addProductToScene(po);
				
				/*var n:int = cw.wall.width*0.5+zPos;
				zPos = cw.isHead?-n:n;
				var p:Point = new Point(xPos,zPos);
				cw.wall.localToGlobal2(p,p);
				
				po.position.x = p.x;
				po.position.y = yPos;
				po.position.z = p.y;
				
				var a:Number = 360 - cw.wall.angles;
				po.rotation.y = po.container3d.rotationY = cw.isHead ? a+180 : a;
				
				var wo:WallObject = po.objectInfo;
				wo.x = xPos;
				wo.y = yPos;
				wo.z = zPos;
				wo.crossWall = cw;
			}
			else
			{
				po.position.x = xPos;
				po.position.y = yPos;
				po.position.z = zPos;*/
			}
			this.cabinetCtr.setProductPos(po,cw,xPos,yPos,zPos);
			
			plateDict[po] = po;
			
			return po;
		}
		
		/**
		 * 创建吊柜
		 * 
		 */
		private function createWallCabinetArea(tabless:Array):void
		{
			var tlen:int = tabless.length;
			for(var i:int=0;i<tlen;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var tlen2:int = tables.length;
				
				var bothEndProducts:Array = null;
				
				for(var j:int=0;j<tlen2;j++)//组成台面的每个墙面
				{
					var tableData:WallSubArea = tables[j];
					var cw:CrossWall = tableData.cw;
					var wallObjects:Array = tableData.wallObjects;//墙面被障碍分隔成的区间
					var glen:int = wallObjects.length;
					
					for(var k:int=0;k<glen;k++)
					{
						var o:WallSubArea = wallObjects[k];
						if(!o.enable)continue;//如果当前区域不可用，则跳过
						
						var x0:Number = o.x0;
						var x1:Number = o.x1;
						var hc:Boolean = o.headCorner;
						var ec:Boolean = o.endCorner;
						var ht:String = o.headType;
						var et:String = o.endType;
						
						var ho:ProductObject = o.headCabinet;
						var eo:ProductObject = o.endCabinet;
						if(ho)x0+=ho.objectInfo.width;
						if(eo)x1-=eo.objectInfo.width;
						
						//trace(k," createWallCabinetArea x0,x1,hc,ec,ht,et:",x0,x1,hc,ec,ht,et);
						
						var cs:Array = CabinetTool.tool.getWallCabinetGroup(cw,x0,x1,hc,ec);
						//o.cabinets = cs;
						
						var aw:Number = x1-x0;
						var gw:int = getGroupWidth(cs);
						
						var startOffset:Number = getStartOffset2(cw,x0,x1,ht,et,hc,ec,aw,gw);
						
						var p01:ProductObject=null,p02:ProductObject=null;
						var po:ProductObject;
						
						/*if(ht==ObstacleType.CORNER_CABINET)//当前的柜子首端顶着另一边的拐角柜
						{
							var w:Number = x0+startOffset-cw.wall.width*0.5-347;//计算挡板宽度
							//var w:Number = 50;
							p01 = this.createCabinetPlate(cw,w,720,16,x0+startOffset,CrossWall.WALL_OBJECT_HEIGHT,331,CabinetType.DOOR_PLANK,"吊柜拐角侧缝挡板");//创建拐角缝挡板
							addWallCabinet(p01);
							
							p02 = this.createCabinetPlate(cw,w,10,330,x0+startOffset,CrossWall.WALL_OBJECT_HEIGHT,0,CabinetType.BODY_PLANK,"吊柜拐角底缝挡板");//创建拐角缝底挡板
							//addWallCabinet(po);
							//trace("bothEndProducts1:"+bothEndProducts);
							if(bothEndProducts)
							{
								po = bothEndProducts[1];//前面尾部的拐角柜
								po.addSlaveProduct(p01);
								po.addSlaveProduct(p02);
							}
						}*/
						
						bothEndProducts = loadWallCabinet(x0+startOffset,cs,cw);
						//trace("bothEndProducts0:"+bothEndProducts);
						
						/*if(p01)
						{
							po = bothEndProducts[0];//当前头部的柜子关联到封板
							po.addSlaveProduct(p01);
							po.addSlaveProduct(p02);
						}
						
						if(p11)//当前头部的柜子关联到拐角前面尾部的封板
						{
							po = bothEndProducts[0];//当前头部的柜子
							po.addSlaveProduct(p11);
							po.addSlaveProduct(p12);
						}*/
						
						/*var p11:ProductObject=null,p12:ProductObject=null;
						
						if(et==ObstacleType.CORNER_CABINET)//最尾部顶着拐角柜
						{
							//w = 50;
							var tx:Number = cw.localEnd.x - 347;
							w = tx - (x0+startOffset+gw);
							p11 = this.createCabinetPlate(cw,w,720,16,tx,CrossWall.WALL_OBJECT_HEIGHT,331,CabinetType.DOOR_PLANK,"吊柜拐角侧缝挡板");//创建拐角缝挡板
							addWallCabinet(p11);
							
							p12 = this.createCabinetPlate(cw,w,10,330,tx,CrossWall.WALL_OBJECT_HEIGHT,0,CabinetType.BODY_PLANK,"吊柜拐角底缝挡板");//创建拐角缝底挡板
							//addWallCabinet(po);
							
							po = bothEndProducts[1];//当前尾部的柜子关联到封板
							if(po)
							{
								po.addSlaveProduct(p11);
								po.addSlaveProduct(p12);
							}
						}*/
					}
				}
			}
		}
		
		private function loadWallCabinet(start:Number,list:Array,cw:CrossWall):Array
		{
			//trace("loadWallCabinet");
			var len:int = list.length;
			var a:Array = [];
			
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = list[i];
				var id:String = xml.id;
				var width:int = xml.width;
				start += width;
				
				var type:String = xml.flag;
				var po:ProductObject = null;
				//trace(i," type,start:"+type,start);
				var isCornerCabinet:Boolean = false;
				if(i==0 && type=="corner" && start<1500)
				{
					//trace(""+type,start);
					/*po = this.createCabinetPlate(cw,400,720,16,start-400,CrossWall.WALL_OBJECT_HEIGHT,331,CabinetType.DOOR_PLANK,"拐角吊柜左侧封板");//在吊柜拐角柜左侧创建封板
					addWallCabinet(po);
					var door:XML = CabinetLib.lib.getDoor("wall_cabinet","left","800x720x350")[0];//在吊柜拐角柜右侧放置左开门
					*/
					isCornerCabinet = true;
				}
				else if(i==len-1 && type=="corner")
				{
					/*po = this.createCabinetPlate(cw,400,720,16,start,CrossWall.WALL_OBJECT_HEIGHT,331,CabinetType.DOOR_PLANK,"拐角吊柜右侧封板");//在吊柜拐角柜右侧创建封板
					addWallCabinet(po);
					door = CabinetLib.lib.getDoor("wall_cabinet","right","800x720x350")[0];//在吊柜拐角柜左侧放置右开门
					*/
					isCornerCabinet = true;
				}
				/*else if(xml.door)
				{
					door= xml.door[0];
				}
				else
				{
					door = null;
				}*/
				var door:XML = null;
				
				xml = CabinetLib.lib.getCabinetData(id);
				var p:Product2D = this.createWallCabinet(xml,cw,start,door);
				addWallCabinet(p.vo);
				
				if(isCornerCabinet)
				{
					p.vo.name = ProductObjectName.CORNER_CABINET;
				}
				
				if(po)
				{
					p.vo.addSlaveProduct(po);
				}
				
				if(i==0)a[0]=p.vo;//首端拐角柜
				if(i==len-1)a[1]=p.vo;//尾端拐角柜
			}
			return a;
		}
		
		private function loadGroundCabinet(x0:Number,x1:Number,offset:int,list:Array,cw:CrossWall,
										   drainerFlag_:Product2D,flueFlag_:Product2D,
										   ht:String,et:String,
										   hc:Boolean,ec:Boolean,
										   ho:ProductObject,eo:ProductObject,
										   beforeX1:Number):void
		{
			var start:Number = x0 + offset;
			var len:int = list.length;
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = list[i];
				var id:String = xml.id;
				var type:String = xml.flag;
				var width:int = xml.width;
				start += width*0.5;
				
				var elec:XML = xml.item?xml.item[0]:null;//电器
				//trace("----elec:"+elec);
				
				if(drainerFlag_ && type=="drainer")
				{
					//trace("---------drainer:"+xml);
					setProductPos(drainerFlag_,cw,start);
					
					o = drainerData?drainerData:getCabinetData(cookerProducts,2);
					drainerProduct = addCookerProduct(o,cw,drainerFlag_.vo,ProductObjectName.DRAINER);
					drainerProduct.isLock = true;
				}
				
				//type为drawer抽屉柜时，抽屉柜的宽度要为800或900才能放置灶台
				if(flueFlag_ && ((type=="drawer" && width>799) || type=="oven"))//灶台下放置抽屉柜或烤箱
				{
					setProductPos(flueFlag_,cw,start);
					
					var o:Object = cookerHoodData?cookerHoodData:getCabinetData(cookerProducts,1);//抽油烟机
					hoodProduct = createWallCabinet(o,cw,start+o.width*0.5,null,ProductObjectName.HOOD);
					hoodProduct.vo.isLock = true;
					
					o = flueData?flueData:getCabinetData(cookerProducts,3);
					flueProduct = addCookerProduct(o,cw,flueFlag_.vo,ProductObjectName.FLUE);
					flueProduct.isLock = true;
				}
				
				var isCornerCabinet:Boolean = false;
				if(i==0 && type=="corner")
				{
					//var door:XML = CabinetLib.lib.getDoor("ground_cabinet","left","900x720x570")[0];
					isCornerCabinet = true;
				}
				else if(i==len-1 && type=="corner")
				{
					//door = CabinetLib.lib.getDoor("ground_cabinet","right","900x720x570")[0];
					isCornerCabinet = true;
				}
				/*else if(xml.door!=undefined)
				{
					door = xml.door[0];
				}
				else
				{
					door = null;
				}*/
				
				start += width*0.5;
				xml.x = start;
				//trace(i+":"+xml.x);
				
				xml = CabinetLib.lib.getCabinetData(id);
				
				var door:XML = null;
				var p:Product2D = this.createGroundCabinet(xml,cw,start,door,elec);
				addGroundCabinet(p.vo);
				
				if(drainerFlag_ && type=="drainer")
				{
					p.vo.name = ProductObjectName.DRAINER_CABINET;//水盆柜标识
				}
				else if(flueFlag_ && ((type=="drawer" && width>799) || type=="oven"))//灶台下放置抽屉柜或烤箱
				{
					p.vo.name = ProductObjectName.FLUE_CABINET;//灶台柜标识
				}
				else if(isCornerCabinet)
				{
					p.vo.name = ProductObjectName.CORNER_CABINET;
				}
				
				//this.createCabinetPlate(cw,width,80,5,start,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//创建柜腿挡板
			}
			
			return;
			/*
			//trace("list:"+list);
			var xml0:XML = list[0];
			var type0:String = xml0.flag;
			var width0:int = xml0.width;
			trace("type0,ht:"+type0,ht);
			
			if(hc && type0=="corner")//当前组第一个柜子为拐角柜
			{
				tx0 = xml0.x-450-1.5;
				//trace("xml0.x:"+xml0.x);
				//trace("-----head x:"+tx0);
				//productManager.createCustomizeProduct();
				var po:ProductObject = this.createCabinetPlate(cw,450,720,16,tx0,80,551,CabinetType.DOOR_PLANK,"拐角地柜左侧封板");//在插角地柜左侧创建封板
				addGroundCabinet(po);
			}
			else if(ht==ObstacleType.CORNER_CABINET || ht==ObstacleType.OBJECT_CORNER_CABINET)//当前的柜子顶着另一边的拐角柜
			{
//				var w:Number = x0-cw.wall.width*0.5-550+offset;//计算挡板宽度-1.5
				var w:Number = x0+offset-570-cw.localHead.x;
				//trace("--------xxx------",w,x0,offset);
				po = this.createCabinetPlate(cw,w,720,16,x0+offset,80,551,CabinetType.DOOR_PLANK,"地柜拐角侧缝挡板");//创建拐角缝挡板
				addGroundCabinet(po);
				//this.createCabinetPlate(cw,w+30,80,5,x0+offset,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//创建拐角腿挡板，长度延伸30,至相邻插角地柜的柜腿挡板
			}
			else if(ht==ObstacleType.WALL)//柜子顶墙
			{
				w = offset;//x0-cw.wall.width*0.5+
				if(w>1)//柜子与墙之间有间隙
				{
					if(!ho)
					{
						po = this.createCabinetPlate(cw,w,720,16,x0+offset,80,551,CabinetType.DOOR_PLANK,"地柜侧缝挡板");//柜子顶墙或障碍物时，缝隙封板
						addGroundCabinet(po);
					}
					//this.createCabinetPlate(cw,w,80,5,x0+offset,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
				}
			}
			else if(ht==ObstacleType.OBJECT || ht==ObstacleType.MIDDLE_OBJECT || ht==ObstacleType.CABINET_OBJECT || ht==ObstacleType.MIDDLE_CABINET_OBJECT)//当前组第一个柜子顶在障碍物上(烟道，立柱)
			{
				var tx:Number = ho?x1:beforeX1>0?beforeX1:cw.localHead.x;
				w = x0 - tx + offset;
				
				trace("------headObject tx,w:"+tx,w);
				if(!ho)
				{
					po = this.createCabinetPlate(cw,w,720,16,x0+offset,80,551,CabinetType.DOOR_PLANK,"地柜侧缝挡板");//柜子顶墙或障碍物时，缝隙封板
					addGroundCabinet(po);
					//this.createCabinetPlate(cw,w,80,5,x0+offset,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
				}
				else
				{
					//this.createCabinetPlate(cw,w,80,5,x0+offset,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
				}
			}
			else if(ht==ObstacleType.HOLE || ht==ObstacleType.NULL)//柜子顶门边或者什么都不靠
			{
				if(ho)
				{
					//this.createCabinetPlate(cw,offset,80,5,x0+offset,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
					//this.createCabinetPlate(cw,5,80,520,x0+10,0,0,CabinetType.LEG_BAFFLE,"柜腿封板");//柜子头上什么都没有时，侧面柜腿封板
				}
				else
				{
					//this.createCabinetPlate(cw,10,80,520,x0+offset+10,0,0,CabinetType.LEG_BAFFLE,"柜腿封板");//柜子头上什么都没有时，侧面柜腿封板
				}
			}
			
			var xml1:XML = list[len-1];
			var type1:String = xml1.flag;
			var width1:int = xml1.width;
			var tx1:Number = xml1.x;
			trace("----et:"+et,x1,tx1);
			
			if(ec && type1=="corner")//当前组最后一个柜子为拐角柜
			{
				var tx0:Number = tx1 - width1 + 450 + 1.5;//拐角柜门右则位置
				//trace("xml1.x:"+xml1.x);
				//trace("-----end x:"+tx0);
				po = this.createCabinetPlate(cw,450,720,16,tx0+450,80,551,CabinetType.DOOR_PLANK,"拐角地柜右侧封板");//在插角地柜右侧创建封板
				addGroundCabinet(po);
			}
			else if(et==ObstacleType.CORNER_CABINET || et==ObstacleType.OBJECT_CORNER_CABINET)//最尾部顶着拐角柜
			{
				//w = x1-tx1+50;+1.5
				w = cw.localEnd.x - tx1 - 570;
				po = this.createCabinetPlate(cw,w,720,16,tx1+w,80,551,CabinetType.DOOR_PLANK,"地柜拐角侧缝挡板");//创建拐角缝挡板
				addGroundCabinet(po);
				//this.createCabinetPlate(cw,w,80,5,tx1+w,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//创建拐角腿挡板，长度与插角地柜等长
			}
			else if(et==ObstacleType.WALL)// || et==ObstacleType.OBJECT)
			{
				x1 = eo?x1:cw.localEnd.x;
				w = x1 - tx1;
				if(w>1)
				{
					if(!eo)
					{
						po = this.createCabinetPlate(cw,w,720,16,x1,80,551,CabinetType.DOOR_PLANK,"地柜侧缝挡板");//柜子顶墙或障碍物时，缝隙封板
						addGroundCabinet(po);
					}
					//this.createCabinetPlate(cw,w,80,5,x1,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
				}
			}
			else if(et==ObstacleType.OBJECT || ht==ObstacleType.CABINET_OBJECT)// || et==ObstacleType.OBJECT)
			{
				x1 = eo?x1:cw.localEnd.x;
				w = x1 - tx1;
				trace("------endObject x1,w:"+x1,w);

				if(w<1000 && w>1)
				{
					if(!eo)
					{
						po = this.createCabinetPlate(cw,w,720,16,x1,80,551,CabinetType.DOOR_PLANK,"地柜侧缝挡板");//柜子顶墙或障碍物时，缝隙封板
						addGroundCabinet(po);
					}
					//this.createCabinetPlate(cw,w,80,5,x1,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
				}
			}
			else if(et==ObstacleType.HOLE || et==ObstacleType.NULL)//柜子顶门边或者什么都不靠
			{
				if(eo)
				{
					w = x1 - tx1;
					//this.createCabinetPlate(cw,w,80,5,x1,0,520,CabinetType.LEG_BAFFLE,"柜腿挡板");//柜子顶墙或障碍物时，柜腿封板
					//this.createCabinetPlate(cw,5,80,520,x1,0,0,CabinetType.LEG_BAFFLE,"柜腿封板");//柜子头上什么都没有时，侧面柜腿封板
				}
				else
				{
					//this.createCabinetPlate(cw,10,80,520,tx1,0,0,CabinetType.LEG_BAFFLE,"柜腿封板");//柜子头上什么都没有时，侧面柜腿封板
				}
			}
			*/
		}
		
		//
		/**
		 * 加载吊柜作为地柜用（用于填充障碍物前空隙）
		 * @param cw：当前所在墙体
		 * @param x0：起始位置
		 * @param x1：结束位置
		 * @return ：新的开始位置
		 * 
		 */
		private function loadWallCabinetForGround(cw:CrossWall,x0:Number,x1:Number):Number
		{
			return 0;
		}
		
		private function setProductPos(p:Product2D,cw:CrossWall,x:Number):void
		{
			var wo:WallObject = p.vo.objectInfo;
			x += wo.width*0.5;
			cabinetCtr.setProductPos(p.vo,cw,x,wo.y,wo.z);
			wo.x = x;
		}
		
		public function addCabinet(po:ProductObject):void
		{
			if(po.position.y<1000)//地柜
			{
				addGroundCabinet(po);
			}
			else//吊柜
			{
				addWallCabinet(po);
			}
		}
		
		public function addGroundCabinet(po:ProductObject):void
		{
			sceneGroundCabinets.push(po);
			po.addEventListener("dispose",onProductDispose);
		}
		
		public function addWallCabinet(po:ProductObject):void
		{
			sceneWallCabinets.push(po);
			po.addEventListener("dispose",onProductDispose);
		}
		
		private function onProductDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			removeProduct(sceneGroundCabinets,po);
			removeProduct(sceneWallCabinets,po);
		}
		
		private function removeProduct(cabs:Array,po:ProductObject):void
		{
			var n:int = cabs.indexOf(po);
			if(n>-1)
			{
				cabs.splice(n,1);
			}
		}
		
		/**
		 * 吊柜摆放位置偏移量
		 * 
		 */
		private function getStartOffset2(cw:CrossWall,x0:Number,x1:Number,ht:String,et:String,hc:Boolean,ec:Boolean,aw:Number,gw:Number):Number
		{
			var startOffset:Number = 0;
			if(hc!=ec)//有一端是拐角柜
			{
				if(hc)startOffset = 0;
				else
					startOffset = x1 - gw - x0;
			}
			else if(ht==et)//墙洞，转角柜，墙，障碍物
			{
				startOffset = (aw-gw)/2;
			}
			/*else if(ht==ObstacleType.HOLE)//当障碍物为墙洞时，已经让出了到墙洞的间隙
			{
				startOffset = 50;
			}*/
			else if(et==ObstacleType.CORNER_CABINET || et==ObstacleType.OBJECT_CORNER_CABINET || et==ObstacleType.OBJECT || et==ObstacleType.WALL || et==ObstacleType.NULL)
			{
				startOffset = aw - gw;
			}
			return startOffset;
		}
		
		private function getGroupWidth(cs:Array):int
		{
			var n:int = 0;
			var len:int = cs.length;
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = cs[i];
				var w:int = xml.width;
				n += w;
			}
			return n;
		}
		
		/**
		 * 根据门洞来调整台面分区
		 * @param tables 初始台面分区，每个台面分区由1个或2个以上相连的墙面组成
		 * @param flags 水盆和灶台的定位标志，与每个台面分区相对应，每个台面分区最多可能有2个定位标志，相应的，其它的台面分区就不会有定位标志了
		 * @return
		 * [[{cw:CrossWall,x0,x1,flags:[flag,flag],flueFlag,drainerFlag,headCorner,endCorner,
		 * 		groundObjects:[{x0,x1,headCorner,endCorner,headType,endType,flueFlag,drainerFlag,flags:[flag,flag],cabinets:[{id,width,data,type,x},{}]},{}],
		 * 		  wallObjects:[{x0,x1,headCorner,endCorner,headType,endType,flueFlag,drainerFlag,flag,			   cabinets:[{id,width,data,type,x},{}]},{}]},
		 * 	{cw...}],
		 * [...]]
		 * 
		 * cw：当前台面分区中的一个墙面，x0：墙面有效区域的起始位置，x1：墙面有效区域的结束位置，
		 * 
		 * flags：水盆灶台的定位标志，在以后挖水盆洞时还要用到
		 * 
		 * groundObjects：可放置地柜的区间列表，x0：区间开始，x1：区间结束，headCorner、endCorner：区间的首尾是否放置转角柜，
		 * 										headType、endType：区间首尾端的障碍物类型，
		 * 										flags：水盆灶台定位标志，放置水盆及灶台模型时，定位用
		 * 										cabinets：区间内要放置的厨柜列表，
		 * 												id：厨柜的id编号 width：厨柜的宽度 data：相关的产品数据 type：相关的产品类型 x：厨柜的位置
		 * 
		 *   wallObjects：可放置吊柜的区间列表，x0：区间开始，x1：区间结束，headCorner、endCorner：区间的首尾是否放置转角柜，
		 * 										headType、endType：区间首尾端的障碍物类型，
		 * 										flag：灶台定位标志，放置烟机模型时，定位用
		 * 										cabinets：区间内要放置的厨柜列表，
		 * 												id：厨柜的id编号 width：厨柜的宽度 data：相关的产品数据 type：相关的产品类型 x：厨柜的位置
		 * 
		 * 障碍物类型(wall：厨柜顶墙,hole：墙洞,cabinet：邻墙的拐角柜,object：其它的障碍物)
		 * 相关的产品数据：水盆，灶台，烟机，消毒柜，烤箱
		 * 相关产品的类型：drainer,flue,cookerHood,sterilizer,oven
		 */
		private function setGroundCabinetArea(tables:Array):Array
		{
			setGroundCabinetArea1(tables);
			var tss:Array = setGroundCabinetArea2(tables);
			setGroundCabinetArea3(tss);
			return tss;
		}
		
		/**
		 * 当前场景中放置厨柜的所有墙面
		 */
		public var cabinetCrossWalls:Vector.<CrossWall> = new Vector.<CrossWall>();
		
		private function setGroundCabinetArea1(tables:Array):void
		{
			cabinetCrossWalls.length = 0;
			
			var wa0:WallArea;
			
			var tlen:int = tables.length;
			
			for(var i:int=0;i<tlen;i++)
			{
				var cws:Array = tables[i];//组成台面的墙面
				var clen:int = cws.length;
				
				wa0 = null;
				
				for(var j:int=0;j<clen;j++)
				{
					var cw:CrossWall = cws[j];
					cabinetCrossWalls.push(cw);
					
					var wall:Wall = cw.wall;
					var areas:Array = wall.selectorArea;//每面墙体上的选择区域
					var len:int = areas.length;
					
					for(var k:int=0;k<len;k++)
					{
						var wa:WallArea = areas[k].vo;
						
						if(!wa.enable)//低于容纳台面区域的最小长度时，将跳过
						{
							wa0 = null;
							continue;
						}
						
						if(k>0)wa0 = null;
						
						if(wa0)//与当前区域相连的前区域，处理拐角
						{
							//trace(k+"---------------------");
							//var tx0:Number = wa0.x1 - wa0.x0;
							//var tx1:Number = wa.x1 - wa.x0;
							/*var tx0:Number = getEndLength(wa0.wall.frontCrossWall);
							var tx1:Number = getHeadLength(wa.wall.frontCrossWall);
							
							if(wa0.headCorner)tx0 -= 1070;//前区域头部有拐角柜900+170
							if(tx0>tx1)
							{
								wa0.endCorner = true;//前区域尾部放拐角柜
								wa0.endType1 = ObstacleType.WALL;//前区域拐角柜顶墙
								
								wa.headCorner = false;
								wa.headType1 = ObstacleType.CORNER_CABINET;//此区域头部顶前区域尾部拐角柜
							}+
							else
							{
								wa0.endCorner = false;
								wa0.endType1 = ObstacleType.CORNER_CABINET;//前区域尾部顶此区域头部拐角柜
								
								wa.headCorner = true;//此区域头部放拐角柜
								wa.headType1 = ObstacleType.WALL;//此区域拐角柜顶墙
							}*/
							wa0.endCorner = true;//前区域尾部放拐角柜
							wa0.endType1 = ObstacleType.WALL;//前区域拐角柜顶墙
							
							wa.headCorner = false;
							wa.headType1 = ObstacleType.CORNER_CABINET;//此区域头部顶前区域尾部拐角柜
						}
						else
						{
							/*if(!wa.headType1)
							{
								wa.headCorner = false;
								wa.headType1 = k==0?ObstacleType.WALL:ObstacleType.HOLE;
								trace("x0:",wa.x0,wa.minX);
								if(wa.x0-wa.minX>=WallArea.MinDist)wa.headType1 = ObstacleType.NULL;
							}*/
							wa.headType1 = wa.x0-wa.minX>=WallArea.MinDist?ObstacleType.NULL:wa.headType0;
						}
						
						/*if(!wa.endType1)
						{
							wa.endCorner = false;
							wa.endType1 = k==len-1?ObstacleType.WALL:ObstacleType.HOLE;
							trace("x1:",wa.x1,wa.maxX);
							if(wa.maxX-wa.x1>=WallArea.MinDist)wa.endType1 = ObstacleType.NULL;
						}*/
						wa.endType1 = wa.maxX-wa.x1>=WallArea.MinDist?ObstacleType.NULL:wa.endType0;
						
						//trace("------ht,et:",wa.headType1,wa.endType1);
						
						wa0 = wa;
					}
				}
			}
		}
		
		private function setGroundCabinetArea3(tabless:Array):void
		{
			//trace("setGroundCabinetArea3:");
			var tlen:int = tabless.length;
			var subArea0:WallSubArea;
			
			var cornerCabinetWidth:int = 900;//拐角地柜宽度
			var cornerDepth:int = 570;//拐角地柜深度
			var cornerDist:int = 620;//拐角地柜避让距离
			
			for(var i:int=0;i<tlen;i++)
			{
				//trace("i:",i);
				var tables:Array = tabless[i];//每个独立台面分区
				var tlen2:int = tables.length;
				subArea0 = null;
				
				for(var j:int=0;j<tlen2;j++)//组成台面的每个子分区
				{
					//trace("j:"+j);
					var tableData:WallSubArea = tables[j];
					var gos:Array = tableData.groundObjects;
					var tlen3:int = gos.length;
					
					for(var k:int=0;k<tlen3;k++)
					{
						var subArea1:WallSubArea = gos[k];
						//trace(k," x0,x1,hc,ec,ht,et:",subArea1.x0,subArea1.x1,subArea1.headCorner,subArea1.endCorner,subArea1.headType,subArea1.endType);
						
						//前面区域的柜子以拐角柜结束，或者当前区域以拐角柜开始
						if(subArea0 && (subArea0.endCorner || subArea1.headCorner))
						{
							var area0EndX:Number = subArea0.cw.localEnd.x;//前墙尾点值
							var area1HeadX:Number = subArea1.cw.localHead.x;//当前墙首点值
							//拐角有障碍物时，计算拐角柜的放置位置
							//障碍物宽的一面对着拐角柜
							if(area0EndX-subArea0.x1>=cornerDepth && subArea1.x0-area1HeadX<cornerDepth)
							{
								//trace(1);
								subArea0.endCorner = false;
								//拐角柜放置在空间比较大的一边
								if(subArea0.x1>area0EndX-cornerDist)
								{
									subArea0.x1=area0EndX-cornerDist;
									subArea0.endType = ObstacleType.CORNER_CABINET;
								}
								else
								{
									subArea0.endType = ObstacleType.OBJECT_CORNER_CABINET;
								}
								
								//if(subArea0.length<300)subArea0.enable = false;
								if(subArea0.length<300)
								{
									subArea0.enable = false;
									if(j>0)
									{
										ta = tables[j-1];
										var a:Array = ta.groundObjects;
										var alen:int = a.length;
										if(subArea0==a[alen-1])
										{
											ta = a[alen-2];
											ta.endType = ObstacleType.OBJECT_CORNER_CABINET;
										}
									}
									
								}
								
								subArea1.headCorner = true;
								subArea1.headType = ObstacleType.OBJECT;
								//subArea1.x0 = area1HeadX\
							}
							else if(area0EndX-subArea0.x1<cornerDepth && subArea1.x0-area1HeadX>=cornerDepth)//障碍物宽的一面对着拐角柜
							{
								//trace(2);
								subArea0.endCorner = true;
								subArea0.endType = ObstacleType.OBJECT;
								
								subArea1.headCorner = false;
								
								if(subArea1.x0<cornerDist+area1HeadX)
								{
									subArea1.x0=cornerDist+area1HeadX;
									subArea1.headType = ObstacleType.CORNER_CABINET;
								}
								else
								{
									subArea1.headType = ObstacleType.OBJECT_CORNER_CABINET;
								}
								//if(subArea1.length<300)subArea1.enable = false;
								if(subArea1.length<300)
								{
									subArea1.enable = false;
									
									var ta:WallSubArea = gos[k+1];
									{
										if(ta)
										{
											ta.headType = ObstacleType.OBJECT_CORNER_CABINET;
										}
									}
								}
							}
							else
							{
								var len0:Number = subArea0.headCorner?subArea0.length-cornerCabinetWidth:subArea0.length;
								if(len0>subArea1.length)//空间较大的一面放置拐角柜
								{
									//trace(3);
									subArea0.endCorner = true;
									subArea0.endType = area0EndX-subArea0.x1<1?ObstacleType.WALL:ObstacleType.OBJECT;
									
									subArea1.headCorner = false;
									subArea1.headType = ObstacleType.CORNER_CABINET;
									
									if(subArea1.x0<cornerDist+area1HeadX)subArea1.x0=cornerDist+area1HeadX;
									if(subArea1.length<300)
									{
										subArea1.enable = false;
										
										ta = gos[k+1];
										{
											if(ta)
											{
												ta.headType = ObstacleType.OBJECT_CORNER_CABINET;
											}
										}
									}
								}
								else//空间较大的一面放置拐角柜
								{
									//trace(4);
									subArea0.endCorner = false;
									subArea0.endType = ObstacleType.CORNER_CABINET;
									
									if(subArea0.x1>area0EndX-cornerDist)
									{
										//trace(5,subArea0.x0,subArea1.x1);
										subArea0.x1=area0EndX-cornerDist;
									}
									
									if(subArea0.length<300)
									{
										//trace(6,subArea0.x0,subArea1.x1);
										subArea0.enable = false;
										//if(j>0)
										//{
											ta = tables[j-1];
											a = ta.groundObjects;
											alen = a.length;
											//if(subArea0==a[alen-1])
											//{
												ta = a[alen-2];
												ta.endCorner = false;
												ta.endType = ObstacleType.OBJECT_CORNER_CABINET;
											//}
										//}
									}
									
									subArea1.headCorner = true;
									subArea1.headType = subArea1.x0-area1HeadX<1?ObstacleType.WALL:ObstacleType.OBJECT;
								}
							}
						}
						
						subArea0 = subArea1;
					}
				}
			}
		}
		
		private function setGroundCabinetArea2(tables:Array):Array
		{
			var tss:Array = [];
			var ts:Array;
			var needCreateSubArea:Boolean;//是否需要创建新台面分区
			
			var tlen:int = tables.length;
			for(var i:int=0;i<tlen;i++)
			{
				var cws:Array = tables[i];//组成台面的墙面
				var clen:int = cws.length;
				
				for(var j:int=0;j<clen;j++)
				{
					var cw:CrossWall = cws[j];
					var wall:Wall = cw.wall;
					var areas:Array = wall.selectorArea;
					var len:int = areas.length;
					
					for(var k:int=0;k<len;k++)
					{
						var wa:WallArea = areas[k].vo;
						
						if(!wa.enable)//低于容纳台面区域的最小长度时，将跳过
						{
							if(k==len-1 && j<clen-1)//在同一个分区里，前一面墙的最后一个区域不可用时，下一面墙将是一个独立分区的开始
							{
								needCreateSubArea = true;
							}
							continue;
						}
						
						if(j==0 || k>0 || needCreateSubArea)
						{
							needCreateSubArea = false;
							
							ts = [];//创建新的台面分区
							tss.push(ts);
						}
						
						addTableSubarea(ts,cw,wa.x0,wa.x1,wa.headCorner,wa.endCorner,wa.headType1,wa.endType1,wa.headCabinet,wa.endCabinet);
						//addTableSubarea(ts,cw,wa);
					}
				}
			}
			
			return tss;
		}
		
		/**
		 * 从障碍物中去掉中高柜及高柜
		 * @param obs
		 * 
		 */
		private function removeMiddleCabinetOfObstacle(obs:Array):void
		{
			var len:int = obs.length;
			//trace("removeMiddleCabinetOfObstacle:"+len);
			for(var i:int=len-1;i>-1;i--)
			{
				var wo:WallObject = obs[i];
				if(this.cabinetCtr.isMiddleCabinet(wo.object))//障碍物属于中高柜或高柜
				{
					obs.splice(i,1);
				}
			}
		}

		/**
		 * 设置一个台面分区中的一个墙面的数据
		 * @param ts：当前的台面分区
		 * @param cw：当前墙面
		 * @param x0：墙面有效区域的起始位置
		 * @param x1：墙面有效区域的结束位置
		 * @param flags：水盆灶台的定位标志，要检测是否在有效区域内
		 * @param headCorner：墙首是否放置转角柜
		 * @param endCorner：墙尾是否放置转角柜
		 * @param headType：区域首端分隔物类型
		 * @param endType：区域尾端分隔物类型
		 * 
		 */
		private function addTableSubarea(ts:Array,cw:CrossWall,x0:Number,x1:Number,
										 headCorner:Boolean,endCorner:Boolean,
										 headType:String,endType:String,
										 headCabinet:ProductObject,endCabinet:ProductObject):void
		//private function addTableSubarea(ts:Array,cw:CrossWall,wa:WallArea):void
		{
			trace("--addTableArea:");
			var tableData:WallSubArea = getCabinetAreaData(cw,x0,x1,headCorner,endCorner,headType,endType,headCabinet,endCabinet);
			
			ts.push(tableData);
			
			trace("--addSubArea:");
			/*if(headCabinet)
			{
				//headType = isHeightCabinet(headCabinet)?ObstacleType.HEIGHT_CABINET:ObstacleType.MIDDLE_CABINET;
				headType = ObstacleType.MIDDLE_CABINET;//无论高柜中高柜，在地柜中统一处理为中高柜
				x0 += headCabinet.objectInfo.width;
			}*/
			/*if(endCabinet)
			{
				//endType = isHeightCabinet(endCabinet)?ObstacleType.HEIGHT_CABINET:ObstacleType.MIDDLE_CABINET;
				endType = ObstacleType.MIDDLE_CABINET;//无论高柜中高柜，在地柜中统一处理为中高柜
				x1 -= endCabinet.objectInfo.width;
			}*/
			//var tableData:Object = {cw:cw,x0:x0,x1:x1,headCorner:headCorner,endCorner:endCorner,headType:headType,endType:endType};//
			/*setGroundObjectArea(tableData,cw,x0,x1,headCorner,endCorner,headType,endType);
		}
		private function setGroundObjectArea(tableData:WallSubArea,cw:CrossWall,x0:Number,x1:Number,headCorner:Boolean,endCorner:Boolean,headType:String,endType:String):void
		{*/
			var groundObjects:Array = [];
			tableData.groundObjects = groundObjects;
			
			var objects:Array = [];
			
			//trace("before init");
			//cw.initTestObject();
			//trace("after init");
			cw.getGroundObjectOfPos(x0,x1,objects);//查找区间内已经存在的物体，并作为障碍物来区隔当前墙面区域
			removeMiddleCabinetOfObstacle(objects);
			
			var alen:int = objects.length;
			trace("ground objects:",alen);
			
			var tx0:Number,tx1:Number;
			var headCorner2:Boolean,endCorner2:Boolean;
			var headType2:String,endType2:String;
			var headCabinet2:ProductObject,endCabinet2:ProductObject;
			
			tx0 = x0;
			headCorner2 = headCorner;
			headType2 = headType;
			headCabinet2 = headCabinet;
			
			if(alen==0)//区域内没有障碍物
			{
				tx1 = x1;
				endCorner2 = endCorner;
				endType2 = endType;
				endCabinet2 = endCabinet;
				
				var o:WallSubArea = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
				groundObjects.push(o);
			}
			else//有障碍物，计算第一个区间
			{
				var wo1:WallObject = objects[0];//第一个障碍物
				//trace("wo:"+wo);
				tx1 = wo1.x - wo1.width;
				endCorner2 = false;
				endType2 = ObstacleType.OBJECT;
				endCabinet2 = null;
				
				if(tx1-tx0>=300)//判断空间是否可以放置最小规格厨柜
				{
					//trace("1");
					o = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
					groundObjects.push(o);
				}
			}
			//bu,cu,du,fu,gu,hu,ju,ku,lu,mu,nu,pu,qu,ru,su,tu,wu,xu,yu,zu
			if(alen>0)//计算障碍物后面的区间
			{
				for(var i:int=1;i<alen;i++)//障碍物之间的区间
				{
					tx0 = wo1.x;//前一个障碍物的位置为当前区域的开始位置
					
					var wo2:WallObject = objects[i];//当前障碍物
					
					tx1 = wo2.x - wo2.width;//结束位置错开了当前的障碍物宽度
					
					if(tx1-tx0>=300)
					{
						headType2 = narrowCabinetEnable(wo1)?ObstacleType.CABINET_OBJECT:ObstacleType.OBJECT;
						headCabinet2 = null;
						
						if(!o)//前面区间不够放置厨柜
						{
							headCorner2 = headCorner;
							headCabinet2 = headCabinet;
							if(headType==ObstacleType.CORNER_CABINET)//隔着障碍物顶着拐角柜
							{
								headType2 = ObstacleType.OBJECT_CORNER_CABINET;
							}
						}
						else
						{
							headCorner2 = false;
							headType2 = o.endType = narrowCabinetEnable(wo1)?ObstacleType.MIDDLE_CABINET_OBJECT:ObstacleType.MIDDLE_OBJECT;
						}
						endCorner2 = false;
						endType2 = ObstacleType.OBJECT;
						endCabinet2 = null;

						
						//trace("2");
						o = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
						groundObjects.push(o);
					}
					
					wo1 = wo2;
				}
				
				//障碍物最后面的区间
				tx0 = wo1.x;
				tx1 = x1;
				
				if(tx1-tx0>=300)
				{
					//headCorner2 = false;
					//headType2 = ObstacleType.OBJECT;
					headType2 = narrowCabinetEnable(wo1)?ObstacleType.CABINET_OBJECT:ObstacleType.OBJECT;
					headCabinet2 = null;
					
					if(!o)//前面区间不够放置厨柜
					{
						headCabinet2 = headCabinet;
						headCorner2 = headCorner;
						if(headType==ObstacleType.CORNER_CABINET)//隔着障碍物顶着拐角柜
						{
							headType2 = ObstacleType.OBJECT_CORNER_CABINET;
						}
					}
					else
					{
						headCorner2 = false;
						headType2 = o.endType = narrowCabinetEnable(wo1)?ObstacleType.MIDDLE_CABINET_OBJECT:ObstacleType.MIDDLE_OBJECT;
						//headType2 = ObstacleType.MIDDLE_OBJECT;
						//o.endType = ObstacleType.MIDDLE_OBJECT;
					}
					
					endCorner2 = endCorner;
					endType2 = endType;
					endCabinet2 = endCabinet;
					
					//trace("3");
					o = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
					groundObjects.push(o);
				}
				else if(o)//重新设置前一区间的尾部标志
				{
					o.endCorner=endCorner;
					o.endCabinet = endCabinet;
					if(endType==ObstacleType.CORNER_CABINET)//如果尾部顶着另一边墙上的拐角柜
					{
						o.endType = ObstacleType.OBJECT_CORNER_CABINET;
					}
				}
			}
		}
		
		//判断在障碍物前是否可以放置窄（吊）柜
		//常规地柜进深550，吊柜进深330，只有吊柜进深小于等于220时，才够放置吊柜填缝
		private function narrowCabinetEnable(object:WallObject):Boolean
		{
			return object.depth>220?false:true;
		}
		
		//设置厨柜区间数据
		private function getCabinetAreaData(cw:CrossWall,x0:Number,x1:Number,
											headCorner:Boolean,endCorner:Boolean,
											headType:String,endType:String,
											headCabinet:ProductObject,endCabinet:ProductObject):WallSubArea
		{
			var o:WallSubArea = new WallSubArea();
			
			o.cw = cw;
			o.x0 = x0;
			o.x1 = x1;
			o.headCorner = headCorner;
			o.endCorner = endCorner;
			o.headType = headType;
			o.endType = endType;
			
			o.drainerFlag = testLocationFlag(drainerFlag.vo,cw,x0,x1)?drainerFlag:null;
			o.flueFlag = testLocationFlag(flueFlag.vo,cw,x0,x1)?flueFlag:null;
			o.headCabinet = headCabinet;
			o.endCabinet = endCabinet;
			
			trace("----getCabinetAreaData x0,x1,hc,ec,ht,et,ho,eo:"+x0,x1,headCorner,endCorner,headType,endType,Boolean(headCabinet),Boolean(endCabinet));
			
			return o;
		}
		
		/**
		 * 测试定位标志是否完整的放在墙面的指定区间内
		 * @param flag
		 * @param cw
		 * @param x0
		 * @param x1
		 * @return 
		 * 
		 */
		private function testLocationFlag(flag:ProductObject,cw:CrossWall,x0:Number,x1:Number):Boolean
		{
			if(!flag)return false;
			var o:WallObject = flag.objectInfo;
			if(!o || o.crossWall!=cw)return false;
			if(x0-(o.x-o.width)>0.1 || o.x-x1>0.1)return false;//此处只考虑了墙面为正面的情况
			return true;
		}
		
		/**
		 * 判断指定产品是否为高柜
		 * @param po
		 * @return 
		 * 
		 */
		private function isHeightCabinet(po:ProductObject):Boolean
		{
			trace("-----isHeightCabinet:"+po);
			
			if(!po)return false;
			
			return true;//吊柜对中高柜也要避让
			
			var wo:WallObject = po.objectInfo;
			if(wo.height>CrossWall.WALL_OBJECT_HEIGHT)//产品的高度超过吊柜的下沿
			{
				return true;
			}
			
			return false;
		}
		
		/**
		 * 设置吊柜区间
		 * 对吊柜子分区域再细分区，用窗户，烟机及烟道等障碍物进行分隔
		 * 
		 */
		private function setWallObjectArea(tableData:WallSubArea,cw:CrossWall,x0:Number,x1:Number,
										   headCorner:Boolean,endCorner:Boolean,
										   headType:String,endType:String,
										   headCabinet:ProductObject,endCabinet:ProductObject):void
		{
			var wallObjects:Array = [];
			tableData.wallObjects = wallObjects;
			//trace("-----------setWallObjectArea-----------");
			trace("----setWallObjectArea1:");
			
			/*if(headType==ObstacleType.CORNER_CABINET)//首端相邻墙放置拐角柜
			{
				x0 += 350+50;//起始位置让出拐角柜的空间
			}*/
			
			/*if(endType==ObstacleType.CORNER_CABINET)//尾端相邻墙放置拐角柜
			{
				x1 -= 400;//结束位置让出拐角柜的空间
			}*/
			
			var minValidWidth:int = 350;
			
			var objects:Array = [];
			cw.getWallObjectOfPos(x0,x1,objects);//查找区间内已经存在的物体，并作为障碍物来区隔当前墙面区域
			var alen:int = objects.length;
			
			//trace(alen,"objects:"+objects);
			
			var hasHole:Boolean = false;//标志当前分隔区域的障碍物里，是否有门洞或烟机，或者障碍物的进深超过吊柜的进深
			
			var tx0:Number,tx1:Number;
			var headCorner2:Boolean,endCorner2:Boolean;
			var headType2:String,endType2:String;
			var headCabinet2:ProductObject,endCabinet2:ProductObject;
			
			tx0 = x0;
			headCorner2 = headCorner;
			headType2 = headType;
			headCabinet2 = isHeightCabinet(headCabinet)?headCabinet:null;
			
			if(alen==0)//区域内没有障碍物
			{
				tx1 = x1;
				endCorner2 = endCorner;
				endType2 = endType;
				endCabinet2 = isHeightCabinet(endCabinet)?endCabinet:null;
			}
			else//有障碍物，计算第一个区间
			{
				var wo:WallObject = objects[0];
				tx1 = wo.x - wo.width;
				endCorner2 = false;
				endType2 = getWallObjectType(wo);
				endCabinet2 = null;
				
				if(endType2==ObstacleType.HOLE || endType2==ObstacleType.HOOD || wo.depth>350)
				{
					hasHole = true;
					if(endType2==ObstacleType.HOLE)
					{
						tx1 -= 50;
					}
				}
			}
			
			if(tx1-tx0>=minValidWidth)//判断空间是否可以放置最小规格厨柜
			{
				var o:WallSubArea = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
				//var o:Object = {x0:tx0,x1:tx1,headCorner:headCorner2,endCorner:endCorner2,headType:headType2,endType:endType2};
				wallObjects.push(o);
				//traceObj(o,"1");
			}
			
			if(alen>0)//计算障碍物后面的区间
			{
				headCabinet2 = null;
				for(var i:int=1;i<alen;i++)//障碍物之间的区间
				{
					if(o)
					{
						headCorner2 = false;
						headType2 = endType2;
					}
					else if(hasHole)
					{
						headCorner2 = false;
						headType2 = endType2;
					}
					else//前面区域没有足够的空间放置吊柜，并且中间也没有窗洞和烟机分隔，也没有进深超过吊柜进深的障碍物
					{
						headCorner2 = headCorner;
						headType2 = headType;
					}
					endCabinet2 = null;
					
					tx0 = wo.x;
					if(endType2==ObstacleType.HOLE)
					{
						tx0 += 50;
					}
					
					wo = objects[i];
					tx1 = wo.x - wo.width;
					
					endType2 = getWallObjectType(wo);
					if(endType2==ObstacleType.HOLE)
					{
						tx1 -= 50;
					}
					
					if(endType2==ObstacleType.HOLE || endType2==ObstacleType.HOOD || wo.depth>350)
					{
						hasHole = true;
					}
					if(tx1-tx0>=minValidWidth)
					{
						endCorner2 = false;
						
						o = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
						//o = {x0:tx0,x1:tx1,headCorner:headCorner2,endCorner:endCorner2,headType:headType2,endType:endType2};
						wallObjects.push(o);
						//traceObj(o,"2");
					}
				}
				
				//障碍物最后面的区间
				tx0 = wo.x;
				tx1 = x1;
				if(endType2==ObstacleType.HOLE)
				{
					tx0 += 50;
				}
				
				if(tx1-tx0>=minValidWidth)
				{
					if(o)
					{
						headCorner2 = false;
						headType2 = endType2;
					}
					else if(hasHole)
					{
						headCorner2 = false;
						headType2 = endType2;
					}
					else//前面区域没有足够的空间放置吊柜，并且中间也没有窗洞和烟机分隔，也没有进深超过吊柜进深的障碍物
					{
						headCorner2 = headCorner;
						headType2 = headType;
					}
					
					endCorner2 = endCorner;
					endType2 = endType;
					endCabinet2 = isHeightCabinet(endCabinet)?endCabinet:null;
					
					o = getCabinetAreaData(cw,tx0,tx1,headCorner2,endCorner2,headType2,endType2,headCabinet2,endCabinet2);
					//o = {x0:tx0,x1:tx1,headCorner:headCorner2,endCorner:endCorner2,headType:headType2,endType:endType2};
					wallObjects.push(o);
					//traceObj(o,"3");
				}
				else if(o && !hasHole)//重新设置前一区间的尾部标志
				{
					o.endCorner=endCorner;
					o.endType = endType;
					//traceObj(o,"4");
				}
			}
		}
		
		/*private function traceObj(o:Object,flag:String):void
		{
			trace("---traceObj:"+flag);
			for(var s:String in o)
			{
				trace(s+":"+o[s]);
			}
		}*/
		
		private function getWallObjectType(wo:WallObject):String
		{
			var type:String;
			if(wo.object is WallHole)//窗口
			{
				type = ObstacleType.HOLE;
			}
			else
			{
				var po:ProductObject = wo.object;
				if(po && po.view2d == hoodProduct)//烟机
				{
					type = ObstacleType.HOOD;
				}
				else
				{
					type = ObstacleType.OBJECT;
				}
			}
			return type;
		}
		
		public function createCabinetTable3(tabless:Array,depthss:Array):void
		{
			trace("createCabinetTable3");
			cabinetTabless = tabless;
			tableDepthss = depthss;
			
			//var depth:int=600;
			var tlen:int = tabless.length;
			for(var i:int=0;i<tlen;i++)
			{
				var tables:Array = tabless[i];//每个独立台面分区
				var depths:Array = depthss[i];
				trace("depths:",depths);
				
				var points:Array = [];
				var dangshui:Array = [];
				
				var tableData:WallSubArea = tables[0];
				var cw:CrossWall = tableData.cw;
					
				var x0:Number = tableData.x0;
				var x1:Number = tableData.x1;
				trace("0:",x0,x1);
				if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
				if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
				
				var h:Point3D = cw.localHead.clone();
				h.x = x0;
				
				var e:Point3D = h.clone();
				e.x = x1;
				
				var head:Point = new Point();
				var end:Point = new Point();
				
				var depth:int=depths[0];
				offsetCrossWall(cw,depth,head,end,h,e);
				
				var p:Point = cw.isHead?head:end;
				points.push(p);
				//var headType:String = tableData.headType;
				/*if(headType!=ObstacleType.HOLE && headType!=ObstacleType.NULL)
				{
					dangshui.push(p);//挡水的第一个点坐标（为台面外沿，挡水终点坐标）
				}*/
				//dangshui.unshift(p);
				
				var tlen2:int = tables.length;
				for(var j:int=1;j<tlen2;j++)//组成台面的每个墙面
				{
					tableData = tables[j];
					cw = tableData.cw;
					x0 = tableData.x0;
					x1 = tableData.x1;
					trace(j+":",x0,x1,cw.wall.index);
					
					if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
					if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
					
					h = cw.localHead.clone();
					h.x = x0;
					e = h.clone();
					e.x = x1;
					
					var head2:Point = new Point();
					var end2:Point = new Point();
					
					depth=depths[j];
					offsetCrossWall(cw,depth,head2,end2,h,e);
					
					var cp:Point = Geom.intersection(head,end,head2,end2);//计算台面外沿相交点坐标
					trace("cp:"+cp,h,e);
					points.push(cp);
					
					head = head2;
					end = end2;
				}
				
				p = cw.isHead?end:head;
				points.push(p);
				//var endType:String = tableData.endType;
				/*if(endType!=ObstacleType.HOLE && endType!=ObstacleType.NULL)
				{
					dangshui.push(p);//台面外沿，挡水起始坐标
				}*/
				//dangshui.unshift(p);
				
				p = turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));
				points.push(p);
				dangshui.push(p);//台面内沿起始点，挡水坐标点
				//dangshui.unshift(p);
				
				for(j=tlen2-2;j>=0;j--)
				{
					tableData = tables[j];
					
					cw = tableData.cw;
					x0 = tableData.x0;
					x1 = tableData.x1;
					
					if(tableData.headCabinet)x0+=tableData.headCabinet.objectInfo.width;
					if(tableData.endCabinet)x1-=tableData.endCabinet.objectInfo.width;
					
					h = cw.localHead.clone();
					h.x = x0;
					e = h.clone();
					e.x = x1;
					
					p = turnPoint3d(cw.isHead?cw.wall.localToGlobal(e):cw.wall.localToGlobal(h));
					points.push(p);
					dangshui.push(p);//台面内沿拐角点，挡水坐标点
					//dangshui.unshift(p);
				}
				
				p = turnPoint3d(cw.isHead?cw.wall.localToGlobal(h):cw.wall.localToGlobal(e));
				points.push(p);
				dangshui.push(p);//台面内沿最后一个点，挡水坐标点
				//dangshui.unshift(p);
				
				/*if(headType!=ObstacleType.HOLE && headType!=ObstacleType.NULL)
				{
					dangshui.push(dangshui.shift());//将一开始取到点放到最后的位置，形成一个沿墙的逆时针挡水起止点
				}*/
				//dangshui.unshift(dangshui.pop());
				trace("points:"+points);
				trace("dangshui:"+dangshui);
				
				//trace(points);
				
				if(isDrainerArea(tables))//检测是否为放置水盆的区域
				{
					var holeWidth:int = drainerProduct.objectInfo.width;
					var holeDepth:int = drainerProduct.objectInfo.depth;
					
					//var flag:WallObject = drainerFlag.vo.objectInfo;
					var flag:WallObject = drainerProduct.objectInfo;
					
					var wall:Wall = drainerProduct.objectInfo.crossWall.wall;
					var ww:Number = wall.width*0.5 + depth*0.5;
					//var ww:Number = drainerFlag.wall.vo.width*0.5 + depth*0.5;
					
					var x:int = flag.x-flag.width*0.5;
					var y:int = flag.crossWall.isHead?-ww:ww;
					
					var dx:int = holeWidth*0.5;
					var dy:int = holeDepth*0.5;
					
					var p1:Point = new Point(x+dx,y+dy);
					var p2:Point = new Point(x-dx,y+dy);
					var p3:Point = new Point(x-dx,y-dy);
					var p4:Point = new Point(x+dx,y-dy);
					
					//var wall:Wall = drainerFlag.wall.vo;
					wall.localToGlobal2(p1,p1);
					wall.localToGlobal2(p2,p2);
					wall.localToGlobal2(p3,p3);
					wall.localToGlobal2(p4,p4);
					
					var hole:Array = [p1,p2,p3,p4];
					trace("hole:"+hole);
					
					createTableMesh(dangshui,points,hole,30);
				}
				else
				{
					createTableMesh(dangshui,points);
				}
			}
			
			addTableMeshs();
		}
		
		private function isDrainerArea(tables:Array):Boolean
		{
			drainerProduct = getProduct(ProductObjectName.DRAINER);
			trace("isDrainerArea drainerProduct:"+drainerProduct);
			if(!drainerProduct)return false;
			
			var o:WallObject = drainerProduct.objectInfo;
			trace("isDrainerArea cw:"+o.crossWall);
			for each(var tableData:Object in tables)
			{
				var cw:CrossWall = tableData.cw;
				var x0:Number = tableData.x0;
				var x1:Number = tableData.x1;
				trace("x0,x1,o.x,o.width:",x0,x1,o.x,o.width);
				
				if(o.crossWall==cw && o.x-o.width>x0 && x1>o.x)return true;//此处只考虑了墙面为正面的情况
				//if(o.crossWall==cw && o.x>x0 && o.x<x1)return true;//此处只考虑了墙面为正面的情况
			}
			trace("isDrainerArea2");
			return false;
		}
		
		//三维点转换为二维点，去掉了高度信息
		private function turnPoint3d(p3d:Point3D):Point
		{
			return new Point(p3d.x,p3d.z);
		}
		
		/**
		 * 计算从一个墙面向外偏移指定距离后的线段位置（全局坐标位置）
		 * @param cw：指定的墙面
		 * @param offset：偏移距离
		 * @param head：偏移后的坐标
		 * @param end：偏移后的坐标
		 * @param h
		 * @param e
		 * 
		 */
		private function offsetCrossWall(cw:CrossWall,offset:int,head:Point,end:Point,h:Point3D,e:Point3D):void
		{
			//var h:Point3D = cw.localHead;
			head.x = h.x;
			head.y = h.z>0?h.z+offset:h.z-offset;
			cw.wall.localToGlobal2(head,head);
			
			//var e:Point3D = cw.localEnd;
			end.x = e.x;
			end.y = e.z>0?e.z+offset:e.z-offset;
			cw.wall.localToGlobal2(end,end);
		}
		
		public function addCookerProduct(o:Object,cw:CrossWall,flagProduct:ProductObject,name_:String,isHood:Boolean=false):ProductObject
		{
			var id:int = o.id;
			var file:String = o.file;
			var width:int = o.width;
			var height:int = o.height;
			var depth:int = o.depth;
			var name:String = name_?name_:o.name;
			
			var oid:int = ProductObject.getNextIndex();
			
			var vo:ProductObject = productManager.addProductObject(oid,name,id,file);
			
			var wo:WallObject = new WallObject();
			wo.object = vo;
			vo.objectInfo = wo;
			vo.isLock = true;
			
			wo.width = width;
			wo.height = height;
			wo.depth = depth;
			wo.isIgnoreObject = !isHood;//true;
			
			setCookerProduct(cw,flagProduct,vo,isHood);
			
			return vo;
		}
		
		//type:hood,drainer,flue
		public function setCookerProduct(cw:CrossWall,flagProduct:ProductObject,po:ProductObject,isHood:Boolean=false):void
		{
			var flagObject:WallObject = flagProduct.objectInfo;
			var wo:WallObject = po.objectInfo;
			
			if(!cw)//如果定位标志没有吸附到墙面上
			{
				//if(wo.crossWall)wo.crossWall.removeWallObject(wo);
				return;
			}
			
			var x:Number = flagObject.x-flagObject.width*0.5;//定位放置产品的中心x位置
			//var x2:Number = isHood?x+wo.width*0.5:x;
			var x2:Number = x+wo.width*0.5;
			
			//var n:int = cw.wall.width*0.5+(isHood?0:300);//定位放置产品的中心y位置
			var n:int = isHood?0:(600-wo.depth)*0.5;//定位放置产品的y位置
			
			wo.x = x2;//x + wo.width*0.5;
			wo.z = n;
			
			n += cw.wall.width*0.5;//从墙体的轴心开始计算
			var y:Number = cw.isHead?-n:n;
			
			var p:Point = new Point(x2,y);
			cw.wall.localToGlobal2(p,p);
			
			po.position.x = p.x;
			po.position.y = isHood?CrossWall.WALL_OBJECT_HEIGHT:CrossWall.GROUND_OBJECT_HEIGHT+40;//840:柜台高度加上台面厚度;
			po.position.z = p.y;
			
			wo.y = po.position.y;
			
			var a:Number = 360 - cw.wall.angles;
			po.rotation.y = po.container3d.rotationY = cw.isHead ? a+180 : a;
			//wo.x = x;
			
			if(wo.crossWall)
			{
				var tcw:CrossWall = wo.crossWall;
				tcw.removeWallObject(wo);
				tcw.dispatchSizeChangeEvent();
			}
			
			cw.addWallObject(wo);
			cw.dispatchSizeChangeEvent();
		}
		
		public var hoodProduct:Product2D;
		public var flueProduct:ProductObject;
		public var drainerProduct:ProductObject;
		
		/**
		 * 添加新橱柜前，检测所添加区段是否可用，
		 * 如不可用，检查区段中的物体所在，并避让后，检测新区段是否可用
		 * 直到有可用区段，添加入新橱柜
		 * 
		 */
		private function createGroundCabinet(o:Object,cw:CrossWall,x:int,door:XML=null,elec:XML=null,name:String=null):Product2D
		{
			var id:int = o.id;
			var file:String = o.file;
			if(!name)name=file;
			var width:int = o.width;
			var height:int = o.height;
			var depth:int = o.depth;
			//trace("------createGroundCabinet:"+width);
			var p:Product2D = cabinetCtr.createCabinet(id,file,width,height,depth,"text",cw,x,CrossWall.IGNORE_OBJECT_HEIGHT,name,false);
			p.vo.productInfo.type = CabinetType.BODY;
			//if(door)//动态添加门
			//{
				//productManager.addDynamicSubProduct(p.vo,door);
				//addSingleDoor(p.vo,null);
			//}
			
			if(elec)//动态添加电器
			{
				//trace("item:"+elec);
				var sub:XML =
					<item>
						<infoID></infoID>
						<objectID>0</objectID>
						<name></name>
						<name_en/>
						<file></file>
						<dataFormat>text</dataFormat>
						<position>300,18,551</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</item>;
				//电器柜宽600mm，底板厚18mm，电器置于底板上，左右居中，前脸对齐于柜外沿

				var elecID:int = elec.id;
				var elecName:String = elec.name;
				var elecFile:String = elec.file;
				//var h:int = elec.height;
				trace("elecName:"+elecName);
				//h = 720-h+20;
				//trace("h1:"+h);
				
				//var yPos:Number = 800-h;
				//trace("yPos:"+yPos);
				
				sub.infoID = elecID;
				sub.name = elecName;
				sub.file = elecFile;
				var subpo:ProductObject = productManager.addDynamicSubProduct(p.vo,sub);
				//trace(subpo.name);
				//trace(productManager.getObject(p.vo.objectID));
				//trace(productManager.getObject(subpo.objectID));
				//productManager.createCustomizeProduct(ModelType.BOX_C,"",600,720-h,16,
				//var po:ProductObject = this.createCabinetPlate(null,600,h,16,0,yPos,600,CabinetType.DOOR_PLANK);//在电器柜上方0创建封板
				//var po:ProductObject = this.createCabinetPlate(null,600,720,16,0,80,550,CabinetType.DOOR_PLANK);//在电器柜上方0创建封板
				//productManager.addDynamicSubProduct(p.vo,po);

				//trace("sub:"+sub);
			}
			return p;
		}
		
		private var directionDict:Dictionary = new Dictionary();
		
		/**
		 * 为单开门地柜添加门
		 * 
		 */
		public function addSingleDoor(po:ProductObject,direction:String):void
		{
			if(po.productInfo.isReady)
			{
				_addSingleDoor(po,direction);
			}
			else
			{
				directionDict[po] = direction;
				po.productInfo.addEventListener("ready",onAddSingleDoor);
			}
		}
		
		private function onAddSingleDoor(e:Event):void
		{
			var direction:String = directionDict[po];
			delete directionDict[po];

			var info:ProductInfo = e.currentTarget as ProductInfo;
			info.removeEventListener("ready",onAddSingleDoor);
			
			var pos:Array = info.getProductObjects();
			for each(var po:ProductObject in pos)
			{
				_addSingleDoor(po,direction);
			}
		}
		
		private function _addSingleDoor(po:ProductObject,direction:String):void
		{
			var s:String = po.productInfo.productModel.slice(0,3);
			if(s=="A30" || s=="A40" || s=="A45" || s=="AJ9"//地柜
				|| s=="B30" || s=="B40" || s=="B45" || s=="BJ8"//吊柜
				|| s=="C45" || s=="C60" || s=="CK/"//中高柜
				|| s=="D60" || s=="DK/" || s=="DZ6")//高柜
			{
				var doorList:XMLList = CabinetTool.tool.getDoorData(po,direction);
				var len:int = doorList.length();
				for(var i:int=0;i<len;i++)
				{
					var doorData:XML = doorList[i];
					var spo:ProductObject = ProductManager.own.addDynamicSubProduct(po,doorData);
					//doAction(spo);
				}
			}
		}
		
		private function doAction(po:ProductObject):void
		{
			if(po.isActive && po.actions)
			{
				//trace("id:"+pObj.id);
				for each(var action:PropertyAction in po.actions)
				{
					//trace("action:"+action);
					action.run();
				}
			}
		}
		
		private function createWallCabinet(o:Object,cw:CrossWall,x:int,door:XML=null,name:String=null):Product2D
		{
			var id:int = o.id;
			var file:String = o.file;
			if(!name)name=file;
			var width:int = o.width;
			var height:int = o.height;
			var depth:int = o.depth;
			//this.setTestObject(0,CrossWall.WALL_OBJECT_HEIGHT,width,height);
			//trace("------createWallCabinet"+width);
			var p:Product2D = cabinetCtr.createCabinet(id,file,width,height,depth,"text",cw,x,CrossWall.WALL_OBJECT_HEIGHT,name,false);
			
			if(name!=ProductObjectName.HOOD)p.vo.productInfo.type = CabinetType.BODY;
			//if(door)
			//{
				//productManager.addDynamicSubProduct(p.vo,door);
				//addSingleDoor(p.vo,null);
			//}
			return p;
		}
		
		/**
		 * 设置相机默认角度
		 */
		private function setCameraPanAngle(w1:Wall,w2:Wall=null):void
		{
			var house:House = House.getInstance();
			var a1:Number = (540-w1.angles)%360;
			if(w2)
			{
				var a2:Number = (540-w2.angles)%360;
				house.currPanAngle = (a1+a2)/2;
			}
			else
			{
				house.currPanAngle = a1;
			}
		}
		
		private var bigCabinets:Array = [800,900];
		private var smallCabinets:Array = [300,400,450];//,500
		private var smallCabinets2:Array = [300,400,450];//,600
		
		private function getCabinetData(cabinets:Array,index:int=-1):Object
		{
			index = (index<0 || index>cabinets.length-1) ? int(Math.random()*cabinets.length) : index;
			var o:Object = cabinets[index];
			//var h:int = o.height;
			//if(h>720)o=getCabinetData();
			return o;
		}
		
		//场景中的地柜（包括封板）
		private var sceneGroundCabinets:Array = [];
		//场景中的吊柜（包括封板）
		private var sceneWallCabinets:Array = [];
		
		private var groundCabinets:Array;
		
		private var wallCabinets:Array;
		
		private var cookerProducts:Array;
		
		private var groundWidthDict:Dictionary = new Dictionary();
		
		private var wallWidthDict:Dictionary = new Dictionary();
		
		private function initCabinetData():void
		{
			groundCabinets = [
				{id:"501",file:"cabinet_501_300x720x570.pdt" ,width:"300",height:"720" ,name:"单门地柜"},//0
				{id:"502",file:"cabinet_502_400x720x570.pdt" ,width:"400",height:"720" ,name:"单门地柜"},//1
				{id:"503",file:"cabinet_503_450x720x570.pdt" ,width:"450",height:"720" ,name:"单门地柜"},//2
				{id:"504",file:"cabinet_504_500x720x570.pdt" ,width:"500",height:"720" ,name:"单门地柜"},//3
				{id:"506",file:"cabinet_506_800x720x570.pdt" ,width:"800",height:"720" ,name:"双门地柜"},//4
				{id:"507",file:"cabinet_507_900x720x570.pdt" ,width:"900",height:"720" ,name:"双门地柜"},//5
				{id:"513",file:"cabinet_513_450x720x570.pdt" ,width:"450",height:"720" ,name:"小小大抽屉柜"},//6
				{id:"515",file:"cabinet_515_600x720x570.pdt" ,width:"600",height:"720" ,name:"小小大抽屉柜"},//7
				{id:"546",file:"cabinet_546_800x720x570.pdt" ,width:"800",height:"720" ,name:"二平分抽屉地柜"},//8
				{id:"547",file:"cabinet_547_900x720x570.pdt" ,width:"900",height:"720" ,name:"二平分抽屉地柜"},//9
				{id:"525",file:"cabinet_525_600x720x570.pdt" ,width:"600",height:"720" ,name:"消毒柜"},//10
				{id:"510",file:"cabinet_510_200x720x570.pdt" ,width:"200",height:"720" ,name:"调味拉篮柜"},//11
				{id:"511",file:"cabinet_511_300x720x570.pdt" ,width:"300",height:"720" ,name:"调味拉篮柜"},//12
				{id:"512",file:"cabinet_512_400x720x570.pdt" ,width:"400",height:"720" ,name:"调味拉篮柜"},//13
				{id:"536",file:"cabinet_536_800x720x570.pdt" ,width:"800",height:"720" ,name:"二平分拉篮柜"},//14
				{id:"537",file:"cabinet_537_900x720x570.pdt" ,width:"900",height:"720" ,name:"二平分拉篮柜"},//15
				{id:"516",file:"cabinet_516_800x720x570.pdt" ,width:"800",height:"720" ,name:"双门水槽柜"},//16
				{id:"517",file:"cabinet_517_900x720x570.pdt" ,width:"900",height:"720" ,name:"双门水槽柜"},//17
				{id:"526",file:"cabinet_526_800x720x570.pdt" ,width:"800",height:"720" ,name:"双门炉台柜"},//18
				{id:"527",file:"cabinet_527_900x720x570.pdt" ,width:"900",height:"720" ,name:"双门炉台柜"},//19
				{id:"703",file:"cabinet_703_450x1390x570.pdt",width:"450",height:"1390",name:"单木门中高柜"},//20
				{id:"705",file:"cabinet_705_600x1390x570.pdt",width:"600",height:"1390",name:"单木门中高柜"},//21
				{id:"805",file:"cabinet_805_600x2110x570.pdt",width:"600",height:"2110",name:"门+门高柜"},//22
				{id:"715",file:"cabinet_715_600x1390x570.pdt",width:"600",height:"1390",name:"烤箱、微波炉功能柜"},//23
				{id:"815",file:"cabinet_815_600x2110x570.pdt",width:"600",height:"2110",name:"烤箱、微波炉功能柜"},//24
				{id:"557",file:"cabinet_557_900x720x570.pdt" ,width:"900",height:"720" ,name:"单门转角地柜"}//25
			];
			
			groundWidthDict[300] = 0;
			groundWidthDict[400] = 1;
			groundWidthDict[450] = 2;
			//groundWidthDict[500] = 3;
			groundWidthDict[600] = 10;
			groundWidthDict[800] = 4;
			groundWidthDict[900] = 5;
			
			wallCabinets = [
				{id:"601",file:"cabinet_601_300x720x330.pdt",width:"300",height:"720",name:"单门吊柜"},//0
				{id:"602",file:"cabinet_602_400x720x330.pdt",width:"400",height:"720",name:"单门吊柜"},//1
				{id:"603",file:"cabinet_603_450x720x330.pdt",width:"450",height:"720",name:"单门吊柜"},//2
				{id:"605",file:"cabinet_605_600x720x330.pdt",width:"600",height:"720",name:"单门吊柜"},//3
				{id:"606",file:"cabinet_606_800x720x330.pdt",width:"800",height:"720",name:"双门吊柜"},//4
				{id:"607",file:"cabinet_607_900x720x330.pdt",width:"900",height:"720",name:"双门吊柜"},//5
				{id:"616",file:"cabinet_616_800x720x330.pdt",width:"800",height:"720",name:"双上翻门吊柜"},//6
				{id:"617",file:"cabinet_617_900x720x330.pdt",width:"900",height:"720",name:"双上翻门吊柜"},//7
				{id:"615",file:"cabinet_615_600x720x330.pdt",width:"600",height:"720",name:"微波炉吊柜"},//8
				{id:"626",file:"cabinet_626_800x720x330.pdt",width:"800",height:"720",name:"单门转角吊柜"}//9
				//{id:"1101",file:"cooker_hood_1101.pdt",width:"800",height:"700",name:"抽油烟机"},//10
				//{id:"1102",file:"cooker_hood_1102_CXW-268-L1.pdt",width:"896",height:"860",name:"抽油烟机"}//11
			];
			
			wallWidthDict[300] = 0;
			wallWidthDict[400] = 1;
			wallWidthDict[450] = 2;
			//wallWidthDict[600] = 3;
			wallWidthDict[800] = 4;
			wallWidthDict[900] = 5;
			
			cookerProducts = [
				{id:"1101",file:"cooker_hood_1101_CXW-200-TD-5.pdt",width:"800",height:"700",name:"抽油烟机"},//0
				{id:"1102",file:"cooker_hood_1102_CXW-268-P.pdt",width:"896",height:"860",name:"抽油烟机"},//1
				{id:"1203",file:"drainer_1203_JBS2T_OLCE309.pdt",width:"792",height:"526",depth:"455",name:"水盆"},//2
				{id:"1301",file:"flue_1301_GP1310Z1.pdt",width:"713",height:"50",depth:"435",name:"灶台"},//3
				{id:"1305",file:"flue_1305_GP090.pdt",width:"778",height:"49",depth:"445",name:"灶台"}//4
			];
		}
		
		//==============================================================================================
		public function CabinetCreator(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("WallController是一个单例类，请用静态方法getInstance来获得类的实例。");
			}
			
			initCabinetData();
		}
		
		//==============================================================================================
		static private var instance:CabinetCreator;
		private var lastTime:int;
		
		static public function getInstance():CabinetCreator
		{
			instance ||= new CabinetCreator(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}

