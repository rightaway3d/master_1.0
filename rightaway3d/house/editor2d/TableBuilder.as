package rightaway3d.house.editor2d
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.utils.GlobalConfig;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;
	import rightaway3d.utils.Log;

	public class TableBuilder
	{
		private var productManager:ProductManager;
		private var cabinetCreator:CabinetCreator;
		private var cabinetCtrl:CabinetController;
		
		public function TableBuilder()
		{
			productManager = ProductManager.own;
			cabinetCreator = CabinetCreator.getInstance();
			cabinetCtrl = CabinetController.getInstance();
		}
		
		private var groundCabinetDict:Dictionary;
		private var wallCabinetDict:Dictionary;
		private var allCabinetDict:Dictionary;
		
		/*private function get maxAlongWidth():uint//台面两端最大出沿宽度
		{
			return GlobalConfig.instance.wallPlateWidth;
		}*/
		public function builderTable():String
		{
			cabinetCreator.clearCabinetTalbes();
			
			maxAlongWidth = GlobalConfig.instance.wallPlateWidth;
			
			groundCabinetDict = new Dictionary();
			wallCabinetDict = new Dictionary();
			allCabinetDict = new Dictionary();
			
			var msg:String = countCabinetWithWall();
			if(msg)return msg;
			
			updateCrossWallFace();
			
			sortCabinet(groundCabinetDict);
			
			var groundArea:Array = sortCrossWall(groundCabinetDict);
			if(groundArea)
			{
				var depthss:Array = [];
				var tabless:Array = resetGroundArea(groundArea,groundCabinetDict,depthss);
			//return null;
			
				cabinetCreator.createCabinetTable(tabless,depthss);//[[600,600,600],[600,600,600],[600,600,600]]);
				
				var house:House = House.getInstance();
				house.updateBounds();
				cabinetCreator.updateTableMeshsPos(house.x,house.z);
			}
			
			sortCabinet(wallCabinetDict);
			var wallArea:Array = sortCrossWall(wallCabinetDict);
			if(wallArea)
			{
				resetWallCabinetPlate(wallArea,wallCabinetDict);			
				var lines:Array = getWallCabinetTopLine(wallArea,wallCabinetDict);
				this.cabinetCreator.createTopLine(lines);
			}
			
			return null;
		}
		
		
		//更新墙面集，用于显示及导出墙面立面图
		private function updateCrossWallFace():void
		{
			var ccws:Vector.<CrossWall> = this.cabinetCreator.cabinetCrossWalls;
			ccws.length = 0;
			
			var allArea:Array = sortCrossWall(allCabinetDict);
			if(!allArea)return;
			
			var alen:int = allArea.length;
			for(var i:int=0;i<alen;i++)
			{
				var cws:Array = allArea[i];
				var clen:int = cws.length;
				for(var j:int=0;j<clen;j++)
				{
					var cw:CrossWall = cws[j];
					ccws.push(cw);
				}
			}
		}
		
		public function builderDoor():void
		{
			var cabs:Array = productManager.getProductObjectsByType(CabinetType.BODY);
			//trace("--------builderDoor:",cabs);
			for each(var po:ProductObject in cabs)
			{
				cabinetCreator.addSingleDoor(po,null,false);
			}			
		}
		
		private var alongWidth:int = 20;//台面两端出沿宽度
		private var maxAlongWidth:int = 100;
		
		//创建台面前检查，同一面墙不出现连续门洞，同一面墙上的柜子之间不能有间隙，有障碍物（烟道、方柱）除外
		//同一墙同一区域的柜子深度须一致，拐角柜只能出现在拐角处
		//同一面墙上，两个放置台面的柜子之间不能有中高柜
		/*private function testCabinet():void
		{
			
		}*/
		
		
		private function resetGroundArea(groundArea:Array,wallDict:Dictionary,depthss:Array):Array
		{
			var tables:Array;
			var depths:Array;
			var tableData:WallSubArea;
			var isAreaStart:Boolean = false;
			
			var cab0:ProductObject;
			var cab1:ProductObject;
			
			var tabless:Array = setGroundArea(groundArea,wallDict);
			setGroundLeg(tabless);
			//return null;
			
			setGroundArea2(tabless);
			
			var areaLen:int = tabless.length;
			
			for(var i:int=0;i<areaLen;i++)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				cab0 = null;
				
				depths = [];
				depthss.push(depths);
				
				for(var j:int=0;j<subLen;j++)
				{
					tableData = subs[j];
					var cw:CrossWall = tableData.cw;
					var cabs:Array = tableData.groundObjects;
					var woLen:int = cabs.length;
					isAreaStart = false;
					
					for(var k:int=0;k<woLen;k++)
					{
						//trace("i,j,k:",i,j,k);
						cab1 = cabs[k];
						var wo:WallObject = cab1.objectInfo;
						if(!isAreaStart)
						{
							if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)//当前为中高柜
							{
								var two:WallObject = cabs[k+1].objectInfo;
								if(two.height>CrossWall.GROUND_OBJECT_HEIGHT)//如果碰到连续的中高柜，则跳过前面的
								{
									continue;
								}
								
								tableData.headCabinet = cab1;
							}
							else
							{
								tableData.tableY = wo.y + wo.height;
							}
							
							if(j>0)//拐角区域
							{
								setCornerCabinet(cab0,cab1);
								tableData.x0 = cw.localHead.x;
							}
							else
							{
								this.setHeadTableData(tableData,wo,cw);
							}
							
							depths.push(this.getTableWidth(wo));
							//trace("depths:"+depths.length,depths);
							
							isAreaStart = true;
						}
						
						if(isAreaStart && tableData.headCabinet!=cab1)
						{
							tableData.x1 = wo.x;
							if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)
							{
								tableData.endCabinet = cab1;
								break;
							}
							
							if(k==woLen-1)//当前子区域最后一个柜子
							{
								if(j==subLen-1)//当前区域的尾部
								{
									this.setEndTableData(tableData,wo,cw);
								}
								else//后面还有子区域
								{
									tableData.x1 = cw.localEnd.x;
								}
							}
							
							var dz:int = 19;//地柜封板缩进距离
							if(cab0)
							{
								var w0:WallObject = cab0.objectInfo;
								var w1:WallObject = cab1.objectInfo;
								
								var dx1:Number = w1.x - w1.width;
								var dw:Number = dx1 - w0.x;
								if(dw>10)
								{
									var po:ProductObject = this.addGroundCabinetPlate(cw,dw,dx1,w0.z+w0.depth-dz,wo.height);//"地柜间隙封板",
									addAssistPlate(po,dw);
								}
							}
						}
						else if(wo.height<CrossWall.GROUND_OBJECT_HEIGHT)
						{
							tableData.tableY = wo.y + wo.height;
						}
						
						cab0 = cab1;
					}
					
					//trace("tableData.x0,tableData.x1,wall.index:"+tableData.x0,tableData.x1,cw.wall.index);
				}
			}
			
			return tabless;
		}
		
		//设置拐角柜及封板
		private function setCornerCabinet(cab0:ProductObject, cab1:ProductObject):void
		{
			var w0:WallObject = cab0.objectInfo;
			var cw0:CrossWall = w0.crossWall;
			var w1:WallObject = cab1.objectInfo;
			var cw1:CrossWall = w1.crossWall;
			var dz:int = 19;//地柜拐角封板缩进距离
			
			if(cab0.name == ProductObjectName.CORNER_CABINET)//子区域尾部是拐角柜
			{
				//计算拐角相邻柜子的面板线在拐角柜上的位置
				var n:Number = w1.z + w1.depth - (cw0.localEnd.x - w0.x);
				CabinetUtils.resetCornerProductModel(cab0,n);
				
				var d:Number = w0.z+w0.depth;
				//var ww:Number = w0.width*0.5;
				//addGroundCabinetPlate(cw0,w0.width*0.5,w0.x,d-dz,"拐角地柜右侧封板");
				/*if(cw0.localEnd.x - (w0.x-ww+maxWidth)>w1.z+w1.depth)
				{
					this.addGroundCabinetPlate(cw0,ww-3,w0.x-1.5,d-dz,"拐角地柜右侧封板",717);
				}
				else
				{
					this.addGroundCornerPlate(cw0,ww-100,w0.x,d-dz,"拐角地柜右侧封板1");
					this.addGroundCabinetPlate(cw0,100,w0.x-ww+100,d-dz,"拐角地柜右侧封板2");
				}*/
				
				tx = w1.x - w1.width;
				w = tx - cw1.localHead.x - d;
				if(w>1)// && w<=100)
				{
					var po:ProductObject = addGroundCabinetPlate(cw1,w,tx,w1.z+w1.depth-dz,w0.height);//"地柜拐角侧缝挡板",
					addAssistPlate(po,w);
				}
			}
			else if(cab1.name == ProductObjectName.CORNER_CABINET)//子区域头部是拐角柜
			{
				//计算拐角相邻柜子的面板线在拐角柜上的位置
				n = w0.z + w0.depth - (w1.x - w1.width - cw1.localHead.x);
				CabinetUtils.resetCornerProductModel(cab1,n);
				
				var w:Number = w1.width * 0.5;
				d = w1.z+w1.depth;
				//ww = w1.width*0.5;
				//addGroundCabinetPlate(cw1,w,w1.x-w,d-dz,"拐角地柜左侧封板");
				/*if(w1.x-ww-maxWidth-cw1.localHead.x>w0.z+w0.depth)
				{
					this.addGroundCabinetPlate(cw1,ww-3,w1.x-ww-1.5,d-dz,"拐角地柜左侧封板",717);
				}
				else
				{
					this.addGroundCornerPlate(cw1,ww-100,w1.x-ww-100,d-dz,"拐角地柜左侧封板1");
					this.addGroundCabinetPlate(cw1,100,w1.x-ww,d-dz,"拐角地柜左侧封板2");
				}*/
				
				var tx:Number = cw0.localEnd.x - d;
				w = tx - w0.x;
				if(w>1)// && w<=100)
				{
					po = addGroundCabinetPlate(cw0,w,tx,w0.z+w0.depth-dz,w1.height);//"地柜拐角侧缝挡板",
					addAssistPlate(po,w);
				}
			}
		}
		
		//设置厨柜分区，去掉不能放置台面的分区
		private function setGroundArea2(tabless:Array):void
		{
			var areaLen:int = tabless.length;
			for(var i:int=areaLen-1;i>=0;i--)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				for(var j:int=subLen-1;j>=0;j--)
				{
					var subArea:WallSubArea = subs[j];
					if(!hasTableCabinet(subArea))//如果子区域中不存在可放置台面的柜子，将从当前区域中去掉
					{
						subs.splice(j,1);
					}
				}
				
				if(subs.length==0)//如果当前区域为空，也将去掉
				{
					tabless.splice(i,1);
				}
			}
		}
		
		//设置柜脚挡板
		public function setGroundLeg(tabless:Array):void
		{
			var areaLen:int = tabless.length;
			for(var i:int=0;i<areaLen;i++)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				
				var sa:WallSubArea = subs[0];
				var cw1:CrossWall = sa.cw;
				var cabinets:Array = sa.groundObjects;
				
				var p10:ProductObject = cabinets[0];
				var w10:WallObject = p10.objectInfo;
				
				var p11:ProductObject = cabinets[cabinets.length-1];
				var w11:WallObject = p11.objectInfo;
				
				var isHeadPlate:Boolean = isNeedHeadPlate(cw1,w10);//柜子左侧是否需要封板
				var tx0:Number = isHeadPlate ? w10.x - w10.width + 15 : cw1.localHead.x;
				
				if(isHeadPlate)
				{
					var td:Number = this.getGroundPlateDepth(w10);
					var legPlate:ProductObject = this.addCabinetLegPlate(cw1,5,td,tx0+5,0);
				}
				
				for(var j:int=1;j<subLen;j++)
				{
					var cw0:CrossWall = cw1;
					var w00:WallObject = w10;
					var w01:WallObject = w11;
					
					sa = subs[j];
					cw1 = sa.cw;
					cabinets = sa.groundObjects;
					
					p10 = cabinets[0];
					w10 = p10.objectInfo;
					
					p11 = cabinets[cabinets.length-1];
					w11 = p11.objectInfo;
					
					tx1 = cw0.localEnd.x - this.getGroundPlateDepth(w10);
					tw = tx1 - tx0;
					tz = this.getGroundPlateDepth(w00);
					this.addCabinetLegPlate(cw0,tw,5,tx1,tz);
					
					tx0 = cw1.localHead.x + this.getGroundPlateDepth(w01);
				}
				
				var isEndPlate:Boolean = isNeedEndPlate(cw1,w11);
				var tx1:Number = isEndPlate ? w11.x - 15 : cw1.localEnd.x;
				//if(w01)tx0 = cw1.localHead.x + this.getGroundPlateDepth(w01);
				
				var tw:Number = tx1 - tx0;
				var tz:Number = this.getGroundPlateDepth(w10);
				
				this.addCabinetLegPlate(cw1,tw,5,tx1,tz);
				
				if(isEndPlate)
				{
					legPlate = this.addCabinetLegPlate(cw1,5,tz,tx1,0);
				}
			}
		}
		
		/**计算柜子左侧是否需要加侧封板*/
		public function isNeedHeadPlate(cw:CrossWall,wo:WallObject):Boolean
		{
			var dw:Number = wo.x - wo.width - cw.localHead.x;
			
			//中高柜没有贴墙放时，需要加侧封板
			if(wo.height > CrossWall.GROUND_OBJECT_HEIGHT && dw > 1)return true;
			
			//普通柜子距墙端超过100的，要加侧封板
			if(dw > maxAlongWidth)return true;
			
			return false;
		}
		
		/**计算柜子右侧是否需要加侧封板*/
		public function isNeedEndPlate(cw:CrossWall,wo:WallObject):Boolean
		{
			var dw:Number = cw.localEnd.x - wo.x;
			
			//中高柜没有贴墙放时，需要加侧封板
			if(wo.height > CrossWall.GROUND_OBJECT_HEIGHT && dw > 1)return true;
			
			//普通柜子距墙端超过100的，要加侧封板
			if(dw > maxAlongWidth)return true;
			
			return false;
		}
		
		//检查当前子分区中是否存在可创建台面的柜子
		private function hasTableCabinet(subArea:WallSubArea):Boolean
		{
			var areas:Array = subArea.groundObjects;
			var len:int = areas.length;
			for(var i:int=0;i<len;i++)
			{
				var po:ProductObject = areas[i];
				var wo:WallObject = po.objectInfo;
				if(wo.height<=720)return true;
			}
			return false;
		}
		
		//设置厨柜分区，每一块相连厨柜为一个分区
		private function setGroundArea(groundArea:Array,wallDict:Dictionary):Array
		{
			var tabless:Array = [];
			var tableData:WallSubArea;
			var tables:Array;
			var areaLen:int = groundArea.length;
			var cab0:ProductObject,cab1:ProductObject;
			var w0:WallObject,w1:WallObject;
			
			for(var i:int=0;i<areaLen;i++)
			{
				var cws:Array = groundArea[i];
				var cwLen:int = cws.length;
				
				tables = [];
				tabless.push(tables);
				//cab0 = null;
				
				for(var j:int=0;j<cwLen;j++)
				{
					var cw:CrossWall = cws[j];
					var cabs:Array = wallDict[cw];
					var woLen:int = cabs.length;
					
					cab0 = cabs[0];
					w0 = cab0.objectInfo;
					
					if(j>0)
					{
						if(w0.height>CrossWall.GROUND_OBJECT_HEIGHT//后一面墙的第一个柜子为中高柜时
							|| w1.height>CrossWall.GROUND_OBJECT_HEIGHT//前一面墙的最后一个柜子是中高柜
							|| (cab0.name!=ProductObjectName.CORNER_CABINET && cab1.name!=ProductObjectName.CORNER_CABINET))//拐角没有拐角柜
						{
							//开始新的台面分区
							tables = [];
							tabless.push(tables);
						}
					}
					
					var subArea:Array = [];
					
					tableData = new WallSubArea();
					tableData.groundObjects = subArea;
					tableData.cw = cw;
					
					tables.push(tableData);
					
					subArea.push(cab0);
					
					cab1 = cab0;//防止当前子区域只有一个柜子的情况
					w1 = w0;
					
					for(var k:int=1;k<woLen;k++)
					{
						cab1 = cabs[k];
						w1 = cab1.objectInfo;
						
						var a:Array = [];
						cw.getGroundObjectOfPos(w0.x,w1.x-w1.width,a);//计算两个柜子这间是否存在门洞
						
						var dist:Number = w1.x - w1.width - w0.x;//计算两个柜子之间的距离
						
						if(dist>800 || hasWallHole(a))//从门洞后面开始新的分区
						{
							tables = [];
							tabless.push(tables);
							
							subArea = [];
							
							tableData = new WallSubArea();
							tableData.groundObjects = subArea;
							tableData.cw = cw;
							
							tables.push(tableData);
						}
						
						cab0 = cab1;
						w0 = w1;
						
						subArea.push(cab1);
					}
				}
			}
			
			return tabless;
		}
		
		//检测数组中是否有墙洞存在
		private function hasWallHole(a:Array):Boolean
		{
			var len:int=a.length;
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = a[i];
				if(wo.object is WallHole)
				{
					return true;
				}
			}
			return false;
		}
		
		private const maxWidth:int = 90;//转角柜使用窄封板时，最大露出宽度
		
		private function resetWallCabinetPlate(wallArea:Array,wallDict:Dictionary):void
		{
			var areaLen:int = wallArea.length;
			for(var i:int=0;i<areaLen;i++)
			{
				var cws:Array = wallArea[i];
				var cwLen:int = cws.length;
				
				if(cwLen>1)
				{
					for(var j:int=1;j<cwLen;j++)
					{
						var cw0:CrossWall = cws[j-1];//前一面墙
						var cw1:CrossWall = cws[j];//当前墙
						
						var wos0:Array = wallDict[cw0];//前一面墙的所有柜子
						var wos1:Array = wallDict[cw1];//当前墙上的所有柜子
						
						var p0:ProductObject = wos0[wos0.length-1];//前一面墙的最后一个柜子
						var p1:ProductObject = wos1[0];//当前墙上的第一个柜子
						
						var w0:WallObject = p0.objectInfo;//拐角处的前一个柜子
						var w1:WallObject = p1.objectInfo;//拐角处的后一个柜子
						
						if(p0.name==ProductObjectName.CORNER_CABINET)//前一个柜子是拐角柜
						{
							//计算拐角相邻柜子的面板线在拐角柜上的位置
							var n:Number = w1.z + w1.depth - (cw0.localEnd.x - w0.x);
							CabinetUtils.resetCornerProductModel(p0,n);
							
							var tx11:Number = w1.x - w1.width;
							var tw1:Number = tx11 - cw1.localHead.x - 350;
							if(tw1>1 && tw1<=100 && cw0.localEnd.x-w0.x < 350)//侧缝宽度不超过100，且拐角柜侧面距墙不超过柜子深度
							{
								var po:ProductObject = this.addWallCabinetPlate(cw1,tw1,tx11,331,720);//,"吊柜拐角侧缝挡板"
								addAssistPlate(po,tw1);
								
								this.addWallCabinetBottomPlate(cw1,tw1,tx11);//拐角底部封板
								
								//在拐角柜的右侧创建封板
								/*if(cw0.localEnd.x - (w0.x-w0.width*0.5+maxWidth)>w1.z+w1.depth)
								{
									this.addWallCabinetPlate(cw0,400-3,w0.x-1.5,331,"拐角吊柜右侧封板",717);
								}
								else
								{
									this.addWallCornerPlate(cw0,300,w0.x,331,"拐角吊柜右侧封板1");
									this.addWallCabinetPlate(cw0,100,w0.x-300,331,"拐角吊柜右侧封板2");
								}*/
							}
							/*else
							{
								this.addWallCabinetPlate(cw0,400-3,w0.x-1.5,331,"拐角吊柜右侧封板",717);
							}*/
						}
						else if(p1.name==ProductObjectName.CORNER_CABINET)
						{
							//计算拐角相邻柜子的面板线在拐角柜上的位置
							n = w0.z + w0.depth - (w1.x - w1.width - cw1.localHead.x);
							CabinetUtils.resetCornerProductModel(p1,n);
							
							var tw0:Number = cw0.localEnd.x - w0.x - 350;
							if(tw0>1 && tw0<100 && w1.x-w1.width-cw1.localHead.x < 350)//侧缝宽度不超过100，且拐角柜侧面距墙不超过柜子深度
							{
								var tx01:Number = w0.x+tw0;
								po = this.addWallCabinetPlate(cw0,tw0,tx01,331,720);//"吊柜拐角侧缝挡板",
								addAssistPlate(po,tw0);
								
								this.addWallCabinetBottomPlate(cw0,tw0,tx01);
								
								/*if(w1.x-w1.width*0.5-maxWidth-cw1.localHead.x>w0.z+w0.depth)
								{
									this.addWallCabinetPlate(cw1,400-3,w1.x-400-1.5,331,"拐角吊柜左侧封板",717);
								}
								else
								{
									this.addWallCornerPlate(cw1,300,w1.x-500,331,"拐角吊柜左侧封板1");
									this.addWallCabinetPlate(cw1,100,w1.x-400,331,"拐角吊柜左侧封板2");
								}*/
							}
							/*else
							{
								this.addWallCabinetPlate(cw1,400-3,w1.x-400-1.5,331,"拐角吊柜左侧封板",717);
							}*/
						}
					}
				}
			}
		}
		
		//设置吊柜顶线
		private function getWallCabinetTopLine(wallArea:Array,wallDict:Dictionary):Array
		{
			var areaLen:int = wallArea.length;
			trace("------getWallCabinetTopLine areaLen:",areaLen);
			
			var group:Array = [];
			var points:Vector.<Point>;
			var cw0:CrossWall,cw1:CrossWall;
			var wos0:Array,wos1:Array;
			var p0:ProductObject,p1:ProductObject;
			var w0:WallObject,w1:WallObject;
			var minTopLineDist:int = 200;//顶线之间的最小距离
			var p:Point;
			
			for(var i:int=0;i<areaLen;i++)
			{
				cw0 = null;
				p0 = null;
				w0 = null;
				
				points = new Vector.<Point>();
				group.push(points);
				
				var cws:Array = wallArea[i];
				var cwLen:int = cws.length;
				trace(i,"cwLen:",cwLen);
				
				for(var j:int=0;j<cwLen;j++)
				{
					cw1 = cws[j];
					wos1 = wallDict[cw1];//当前墙上的所有柜子
					var woLen:int = wos1.length;
					trace("--",j,"woLen:",woLen);
					
					for(var k:int=0;k<woLen;k++)
					{
						p1 = wos1[k];//当前墙上的第一个柜子
						w1 = p1.objectInfo;//拐角处的后一个柜子
						var tx:Number = w1.x - w1.width;
						trace("----",k,"tx:",tx);
						
						if(k==0)
						{
							if(p0)//处理拐角
							{
								if(p0.name==ProductObjectName.CORNER_CABINET)
								{
									if(tx-w0.depth-cw1.localHead.x>minTopLineDist)//拐角柜与相邻柜间距过大
									{
										trace("----00")
										p = getTopLinePoint(cw0,w0.x,w0.depth-3);//结尾点
										points.push(p);
										
										if(cw0.localEnd.x-w0.x>minTopLineDist)
										{
											p = getTopLinePoint(cw0,w0.x,0);//结尾拐弯顶背墙
											points.push(p);
										}
										
										points = new Vector.<Point>();
										group.push(points);
										
										p = getTopLinePoint(cw1,tx,0);//开始拐弯顶背墙
										points.push(p);
										
										p = getTopLinePoint(cw1,tx,w1.depth-3);//开始点
										points.push(p);
									}
									else
									{
										trace("----01")
										p = getTopLinePoint(cw1,cw1.localHead.x+w0.depth-3,w1.depth-3);//拐角点
										points.push(p);
									}
								}
								else if(p1.name==ProductObjectName.CORNER_CABINET)
								{
									if(cw0.localEnd.x-w1.depth-w0.x>minTopLineDist)//拐角柜与相邻柜间距过大
									{
										trace("----02")
										p = getTopLinePoint(cw0,w0.x,w0.depth-3);//结尾点
										points.push(p);
										
										p = getTopLinePoint(cw0,w0.x,0);//结尾拐弯顶背墙
										points.push(p);
										
										points = new Vector.<Point>();
										group.push(points);//新的一组顶线
										
										if(tx-cw1.localHead.x>minTopLineDist)//第一个柜子离侧墙超过一定距离，顶线要拐弯顶背墙
										{
											p = getTopLinePoint(cw1,tx,0);
											points.push(p);
										}
										
										p = getTopLinePoint(cw1,tx,w1.depth-3);//起始点
										points.push(p);
									}
									else
									{
										trace("----03")
										p = getTopLinePoint(cw1,cw1.localHead.x+w0.depth-3,w1.depth-3);//拐角点
										points.push(p);
									}
								}
								else//拐角处没有拐角柜连接
								{
									trace("----04")
									p = getTopLinePoint(cw0,w0.x,w0.depth-3);//结尾点
									points.push(p);
									
									if(cw0.localEnd.x-w0.x>minTopLineDist)
									{
										p = getTopLinePoint(cw0,w0.x,0);//结尾拐弯顶背墙
										points.push(p);
									}
									
									points = new Vector.<Point>();
									group.push(points);
									
									if(tx-cw1.localHead.x>minTopLineDist)//第一个柜子离侧墙超过一定距离，顶线要拐弯顶背墙
									{
										p = getTopLinePoint(cw1,tx,0);
										points.push(p);
									}
									
									p = getTopLinePoint(cw1,tx,w1.depth-3);//起始点
									points.push(p);
								}
							}
							else//顶线起始位置
							{
								trace("----05")
								if(tx-cw1.localHead.x>minTopLineDist)//第一个柜子离侧墙超过一定距离，顶线要拐弯顶背墙
								{
									p = getTopLinePoint(cw1,tx,0);
									points.push(p);
								}
								p = getTopLinePoint(cw1,tx,w1.depth-3);//起始点
								points.push(p);
							}
						}
						else//除了第一个柜子后的其它柜子
						{
							if(tx-w0.x>minTopLineDist)//吊柜之间距离过大
							{
								trace("----10")
								p = getTopLinePoint(cw1,w0.x,w0.depth-3);//结尾点
								points.push(p);
								
								p = getTopLinePoint(cw1,w0.x,0);//结尾拐弯顶背墙
								points.push(p);
								
								points = new Vector.<Point>();
								group.push(points);//新的一组顶线
								
								p = getTopLinePoint(cw1,tx,0);//开始拐弯顶背墙
								points.push(p);
								
								p = getTopLinePoint(cw1,tx,w1.depth-3);//开始点
								points.push(p);
							}
							else if(w0.depth!=w1.depth)//处理两个柜子进深不一致的情况
							{
								trace("----11")
								var n:Number = (w0.depth>w1.depth) ? w0.x:tx;
								
								p = getTopLinePoint(cw1,n,w0.depth-3);//拐点1
								points.push(p);
								
								p = getTopLinePoint(cw1,n,w1.depth-3);//拐点2
								points.push(p);
							}
						}
						
						if(k==woLen-1 && j==cwLen-1)//当前组最后一个柜子
						{
							trace("----20")
							p = getTopLinePoint(cw1,w1.x,w1.depth-3);//结尾点
							points.push(p);
							
							if(cw1.localEnd.x-w1.x>minTopLineDist)
							{
								p = getTopLinePoint(cw1,w1.x,0);//结尾拐弯顶背墙
								points.push(p);
							}
						}
						else
						{
							p0 = p1;//前一面墙的最后一个柜子
							w0 = w1;//拐角处的前一个柜子
						}
					}
					
					cw0 = cw1;//前一面墙
				}
			}
			
			return group;
		}
		
		private function getTopLinePoint(cw:CrossWall,x:Number,z:Number):Point
		{
			var wall:Wall = cw.wall;
			var y:Number = cw.isHead?-(wall.width*0.5+z) : wall.width*0.5+z;
			return wall.localToGlobal2(new Point(x,y));
		}
		
		//获得标准件封板
		private function getStandardPlate(cw:CrossWall,height:int,width:int,xpos:Number,ypos:Number,zpos:Number):ProductObject
		{
			var sh:String = String(height - 3);
			var sw:String = getWidthStr(width);
			var type:String = "zhuangshi_" + sh + "x" + sw;
			var list:XMLList = CabinetLib.lib.getProductList(type,"");
			
			if(list.length()==0)return null;
			
			var po:ProductObject = productManager.createRootProductObject(list[0]);
			po.objectInfo.isIgnoreObject = true;//所有挡板不会标注尺寸
			po.isActive = false;
			cabinetCtrl.setProductPos(po,cw,xpos,ypos,zpos);
			
			return po;
		}
		
		private function getWidthStr(width:int):String
		{
			var s:String;
			if(width>48 && width<52)
				s = "50";
			else if(width>98 && width<102)
				s = "100";
			else if(width>148 && width<152)
				s = "150";
			else if(width>298 && width<302)
				s = "300";
			else if(width>398 && width<402)
				s = "400";
			else if(width>448 && width<452)
				s = "450";
			else
				s = String(width);
			
			return s;
		}
		
		private function addGroundCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,height:int):ProductObject
		{
			var yPos:Number = CrossWall.IGNORE_OBJECT_HEIGHT + 1.5;
			var po:ProductObject = getStandardPlate(cw,height,width,xPos,yPos,zPos);
			if(po)
			{
				//po.name = name;
			}
			else
			{
				var name:String = "装饰板_" + width + "x" + height;
				trace("创建非标装饰板:",name);
				po = cabinetCreator.createCabinetPlate(cw,width,height-3,16,xPos,yPos,zPos,CabinetType.DOOR_PLANK,name);
				
				po.productCode = "00000000F";
			}
			
			po.name_en = CabinetType.CORNER_PLANK;
			addPlateHandle(po,width,height);
			return po;
		}
		
		/*private function addGroundCornerPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = addCornerPlate(cw,width,xPos,CrossWall.IGNORE_OBJECT_HEIGHT,zPos,name);
			//cabinetCreator.addGroundCabinet(po);
			//var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.IGNORE_OBJECT_HEIGHT,zPos,CabinetType.BODY_PLANK,name);
			//addPlateProduct(po,width);
			setCornerCode(po,width);
			
			return po;
		}*/
		
		private function addWallCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,height:int):ProductObject
		{
			var yPos:Number = CrossWall.WALL_OBJECT_HEIGHT + 1.5;
			var po:ProductObject = getStandardPlate(cw,height,width,xPos,yPos,zPos);
			if(po)
			{
				//po.name = name;
			}
			else
			{
				var name:String = "装饰板_" + width + "x" + height
				po = cabinetCreator.createCabinetPlate(cw,width,height-3,16,xPos,yPos,zPos,CabinetType.DOOR_PLANK,name);
				
				po.productCode = "00000000F";
			}
			po.name_en = CabinetType.CORNER_PLANK;
			/*var dy:Number = (720-height)*0.5;
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,height,16,xPos,CrossWall.WALL_OBJECT_HEIGHT+dy,zPos,CabinetType.DOOR_PLANK,name);
			addPlateProduct(po,width,height);*/
			return po;
		}
		
		/*private function addWallCornerPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = addCornerPlate(cw,width,xPos,CrossWall.WALL_OBJECT_HEIGHT,zPos,name);
			//cabinetCreator.addWallCabinet(po);
			//var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.WALL_OBJECT_HEIGHT,zPos,CabinetType.BODY_PLANK,name);
			setCornerCode(po,width);

			return po;
		}*/
		
		private function addCabinetLegPlate(cw:CrossWall,width:int,depth:int,xPos:Number,zPos:Number):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,80,depth,xPos,0,zPos,CabinetType.LEG_BAFFLE,"柜腿封板");
			addLegPlateConnection(po);
			return po;
		}
		
		private function addWallCabinetBottomPlate(cw:CrossWall,width:int,xPos:Number):void
		{
			//新的处理方案是，间隙宽度不等于50[49-51]时，就不加封板
			if(width<49 || width>51)return;
			
			var list:XMLList = CabinetLib.lib.getProductList("feng_B-330","");
			if(list.length()==0)return;
			
			var po:ProductObject = productManager.createRootProductObject(list[0]);
			po.objectInfo.isIgnoreObject = true;//所有挡板不会标注尺寸
			
			po.isActive = false;
			po.name_en = CabinetType.CORNER_PLANK;
			po.type = CabinetType.BODY;
			po.customMaterialName = cabinetCreator.cabinetBodyDefaultMaterial;
			cabinetCtrl.setProductPos(po,cw,xPos,CrossWall.WALL_OBJECT_HEIGHT,0);
			
			/*var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,18,330,xPos,CrossWall.WALL_OBJECT_HEIGHT,0,CabinetType.CORNER_PLANK,"封板B-330");
			po.name_en = CabinetType.CORNER_PLANK;
			po.specifications = "330*"+width+"*18";
			po.memo = "吊柜拐角底缝挡板";
			if(width==50)
			{
				po.productCode = "MCX006004";
			}*/
			//return po;
		}
		
		/*private function setCornerCode(po:ProductObject,width:int):void
		{
			po.memo = po.name;
			
			if(width==300)
			{
				po.name = "装饰板J-300";
				//po.productCode = "MCX006001";
				//po.specifications = "720*297*18";
			}
			else if(width==350)
			{
				po.name = "装饰板J-350";
				//po.productCode = "MCX006002";
				//po.specifications = "720*347*18";
			}
		}*/
		
		/*private function addCornerPlate(cw:CrossWall,width:int,xpos:Number,ypos:Number,zpos:Number,name:String):ProductObject
		{
			if(width==300)
			{
				var id:int = 251;
				var file:String = "plank_box_251_300x720x16.pdt";
			}
			else
			{
				id = 252;
				file = "plank_box_252_350x720x16.pdt";
			}
			
			var oid:int = ProductObject.getNextIndex();
			var po:ProductObject = productManager.addProductObject(oid,name,id,file);
			
			po.customMaterialName = this.cabinetCreator.cabinetBodyDefaultMaterial;
			po.name_en = CabinetType.CORNER_PLANK;
			
			po.objectInfo.isIgnoreObject = true;//所有挡板不会标注尺寸
			
			cabinetCtrl.setProductPos(po,cw,xpos,ypos,zpos);
			
			return po;
		}*/
		
		private var subData:XML =
			<item>
				<infoID></infoID>
				<objectID>0</objectID>
				<name></name>
				<name_en/>
				<file></file>
				<dataFormat>text</dataFormat>
				<position>0,0,0</position>
				<rotation>0,0,0</rotation>
				<scale>1,1,1</scale>
				<active>false</active>
			</item>;
		
		/**
		 * 大于300宽的封板加拉手
		 * @param parent
		 * @param width
		 * @param height
		 * 
		 */		
		private function addPlateHandle(parent:ProductObject,width:int,height:int=720):void
		{
			if(width>=300)//大于300宽的封板加拉手
			{
				var dynamicProductData:XML = CabinetLib.lib.getDynamicProductData("handle");
				if(dynamicProductData)//更新动态子产品数据
				{
					var id:String = dynamicProductData.infoID;
					var file:String = dynamicProductData.file;
					subData.infoID = id;
					subData.file = file;
					var x:Number = width * 0.5;
					var y:String = String(height-60);
					subData.position = x+","+y+",8";
					var po:ProductObject = productManager.addDynamicSubProduct(parent,subData);
				}
			}
			/*if(width<=100)
			{
				if(width<=50)
				{
					subData.infoID = "275";
					subData.file = "plank_box_275_50x720x16.pdt";
				}
				else 
				{
					subData.infoID = "274";
					subData.file = "plank_box_274_100x720x16.pdt";
				}
				var po:ProductObject = productManager.addDynamicSubProduct(parent,subData);
				po.customMaterialName = parent.customMaterialName;
			}*/
			/*if(width>48 && width<52)
			{
				subData.infoID = "275";
				subData.file = "plank_box_275_50x720x16.pdt";
				var po:ProductObject = productManager.addDynamicSubProduct(parent,subData);
				po.customMaterialName = parent.customMaterialName;
			}
			else if(width>98 && width<102)
			{
				subData.infoID = "274";
				subData.file = "plank_box_274_100x720x16.pdt";
				po = productManager.addDynamicSubProduct(parent,subData);
				po.customMaterialName = parent.customMaterialName;
			}
			else
			{
				parent.specifications = height + "*" + width + "*18";//产品规格
				if(width==397 && height==717)
				{
					parent.productCode = "009";//板件物料编号
				}
				else if(width==447 && height==717)
				{
					parent.productCode = "026";//板件物料编号
				}
				else
				{
					parent.productCode = "000000000";//物料编码
				}
				//parent.unit = "平米";//单位
				//parent.type = 
				parent.name_en = CabinetType.CORNER_PLANK;
				
				if(height==720 && width>=300)//大于300宽的封板加拉手
				{
					var dynamicProductData:XML = CabinetLib.lib.getDynamicProductData("handle");
					if(dynamicProductData)//更新动态子产品数据
					{
						var id:String = dynamicProductData.infoID;
						var file:String = dynamicProductData.file;
						subData.infoID = id;
						subData.file = file;
						var n:Number = width * 0.5;
						subData.position = n+",657,8";
						po = productManager.addDynamicSubProduct(parent,subData);
					}
				}
			}*/
		}
		
		private function addAssistPlate(parent:ProductObject,width:int):void
		{
			_addAssistPlate(parent);
			
			if(width>200)
			{
				_addAssistPlate(parent);
			}
		}
		
		private function _addAssistPlate(parent:ProductObject):void
		{
			var s:String = "fuzhu_"+parent.objectInfo.height;
			var list:XMLList = CabinetLib.lib.getProductList(s,"");
			if(list.length()==0)
			{
				Log.log("====找不到辅助板："+s);
				return;
			}
			
			var po:ProductObject = productManager.createRootProductObject(list[0]);
			parent.addDynamicSubProduct(po);
			po.container3d.visible = false;
			po.isActive = false;
			
			/*var po:ProductObject = productManager.createCustomizeProduct(ModelType.BOX_C,"辅助板-50","",50,684,18,0,false);//创建辅助板
			po.type = CabinetType.CORNER_PLANK;
			po.specifications = "684*50*18";
			po.memo = "";
			po.productCode = "MCX006005";
			parent.addDynamicSubProduct(po);
			po.container3d.visible = false;*/
		}
		
		//添加踢脚线及连接件产品
		private function addLegPlateConnection(po:ProductObject):void
		{
			var w:int = po.objectInfo.width;
			var d:int = po.objectInfo.depth;
			var length:Number;
			//trace("addLegPlateConnection width,depth:",w,d);
			
			if(d>w)
			{
				subData.infoID = "1703";
				subData.file = "leg_plank_1703_jiao.pdt";
				productManager.addDynamicSubProduct(po,subData);
				length = d*0.001;//长度单位转化为米
			}
			else
			{
				length = w*0.001;//长度单位转化为米
			}
			length += 0.05;//踢脚板增加50mm的余量
			
			do{
				var n:Number;
				if(length>3)
				{
					subData.infoID = "1702";
					subData.file = "leg_plank_1702_ping.pdt";
					productManager.addDynamicSubProduct(po,subData);
					n = 3;
				}
				else
				{
					n = length;
				}
				
				subData.infoID = "1701";
				subData.file = "leg_plank_1701.pdt";
				var spo:ProductObject = productManager.addDynamicSubProduct(po,subData);
				spo.memo = String(n);
				
				length -= 3;
			}while(length>0)
		}
		
		/**计算厨柜所在台面的宽度*/
		private function getTableWidth(wo:WallObject):Number
		{
			var z:Number = wo.z + wo.depth + 30;
			//trace("getTableWidth:"+z,wo.z,wo.depth);
			return z;
		}
		/**计算踢脚线到墙面的距离*/
		public function getGroundPlateDepth(wo:WallObject):Number
		{
			var z:Number = wo.z + wo.depth - 50;
			//trace("getGroundPlateDepth:"+z,wo.z,wo.depth);
			return z;
		}
		
		private function setHeadTableData(tableData:WallSubArea,wo:WallObject,cw:CrossWall):void
		{
			//trace("setHeadTableData:"+wo.height);
			var tx0:Number = wo.x - wo.width;
			if(tx0-cw.localHead.x>maxAlongWidth)//第一个柜子与墙端的距离大于限制值
			{
				tableData.x0 = tx0 - alongWidth;
				//trace("1");
			}
			else
			{
				tableData.x0 = cw.localHead.x;//柜子与墙之间小于限制值时，会用封板封上
				//trace("2");
			}
			
			if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)//厨柜高度大于800时，作为中高柜处理
			{
				tableData.headCabinet = wo.object;
				tableData.x0 = tx0;
				//trace("3");
			}
			
			var dz:int = 19;//地柜封板缩进距离(570-550+1)
			if(tableData.x0 == cw.localHead.x)
			{
				var w:Number = tx0-tableData.x0;
				if(w>1)
				{
					var po:ProductObject = addGroundCabinetPlate(cw,w,tx0,wo.z+wo.depth-dz,wo.height);//"地柜侧缝挡板",
					addAssistPlate(po,w);
				}
			}
		}
		
		private function setEndTableData(tableData:WallSubArea,wo:WallObject,cw:CrossWall):void
		{
			//trace("setEndTableData:"+wo.height);
			var tx1:Number = wo.x;
			if(cw.localEnd.x-tx1>maxAlongWidth)
			{
				tableData.x1 = tx1 + alongWidth;
			}
			else
			{
				tableData.x1 = cw.localEnd.x;
			}
			
			if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)
			{
				tableData.endCabinet = wo.object;
				tableData.x1 = tx1;
			}
			
			var dz:int = 19;//地柜封板缩进距离(570-550+1)
			if(tableData.x1 == cw.localEnd.x)
			{
				var w:Number = tableData.x1 - tx1;
				//trace("w:"+w);
				if(w>1)
				{
					var po:ProductObject = addGroundCabinetPlate(cw,w,tableData.x1,wo.depth-dz,wo.height);//"地柜侧缝挡板",
					addAssistPlate(po,w);
				}
			}
		}
		
		//检测从startIndex位置起，gos数组中是否存在柜子
		private function hasGroundCabinet(gos:Array,startIndex:int):Boolean
		{
			var len:int = gos.length;
			for(var i:int=startIndex;i<len;i++)
			{
				var wo:WallObject = gos[i];
				var object:* = wo.object;
				if(object is ProductObject)
				{
					var po:ProductObject = object;
					if(po.productInfo.type==CabinetType.BODY)
					{
						return true;
					}
				}
				//if(wo.y+wo.height==CrossWall.GROUND_OBJECT_HEIGHT)return true;
			}
			
			return false;
		}
		
		//计算对应到墙面上的厨柜组合
		private function countCabinetWithWall():String
		{
			var cabs:Array = productManager.getProductObjectsByType(CabinetType.BODY);
			var len:int = cabs.length;
			//trace("getCabinetProduct:"+len);
			if(len==0)
			{
				return "场景中没有厨柜！";
			}
			
			for each(var po:ProductObject in cabs)
			{
				var wo:WallObject = po.objectInfo;
				var cw:CrossWall = wo.crossWall;
				if(!cw)
				{
					return "发现未吸附到墙面的厨柜："+po.productInfo.name;
				}
				
				//cabinetCreator.addSingleDoor(po);
				
				var a:Array;
				if(wo.y<CrossWall.GROUND_OBJECT_HEIGHT)//地柜
				{
					if(groundCabinetDict[cw])
					{
						a = groundCabinetDict[cw];
					}
					else
					{
						a = [];
						groundCabinetDict[cw] = a;
					}
					a.push(po);
				}
				
				//else if(wo.y>CrossWall.GROUND_OBJECT_HEIGHT)//吊柜
				if(wo.y+wo.height>CrossWall.WALL_OBJECT_HEIGHT+100)//吊柜
				{
					if(wallCabinetDict[cw])
					{
						a = wallCabinetDict[cw];
					}
					else
					{
						a = [];
						wallCabinetDict[cw] = a;
					}
					a.push(po);
				}
				
				if(!allCabinetDict[cw])
				{
					allCabinetDict[cw] = cw;
				}
			}
			
			return null;
		}
		
		private function sortCabinet(cabDict:Dictionary):void
		{
			for each(var a:Array in cabDict)
			{
				a.sortOn("objectX",Array.NUMERIC);
			}
		}
		
		private function sortCrossWall(cabDict:Dictionary):Array
		{
			var a:Array = [];
			for(var cw:CrossWall in cabDict)
			{
				a.push(cw);
			}
			
			var len:int = a.length;
			if(len==1)return [a];
			
			var cw0:CrossWall;
			var cw1:CrossWall;
			var cw2:CrossWall;
			
			if(len==2)
			{
				cw0 = a[0];
				cw1 = a[1];
				
				if(cw0.endCrossWall==cw1)return [a];
				if(cw0.headCrossWall==cw1)return [[cw1,cw0]];
				return [[cw1],[cw0]];
			}
			
			if(len==3)
			{
				cw0 = a[0];
				cw1 = a[1];
				cw2 = a[2];
				//012*
				//021*
				//102*
				//120
				//210
				//201*
				if(cw0.endCrossWall==cw1 && cw1.endCrossWall==cw2)return [a];
				if(cw0.endCrossWall==cw2 && cw2.endCrossWall==cw1)return [[cw0,cw2,cw1]];
				
				if(cw1.endCrossWall==cw0 && cw0.endCrossWall==cw2)return [[cw1,cw0,cw2]];
				if(cw1.endCrossWall==cw2 && cw2.endCrossWall==cw0)return [[cw1,cw2,cw0]];
				
				if(cw2.endCrossWall==cw1 && cw1.endCrossWall==cw0)return [[cw2,cw1,cw0]];
				if(cw2.endCrossWall==cw0 && cw0.endCrossWall==cw1)return [[cw2,cw0,cw1]]
			}
			
			return null;
		}
		
		//==================================================
		static private var _own:TableBuilder;
		static public function get own():TableBuilder
		{
			return _own ||= new TableBuilder();
		}
	}
}