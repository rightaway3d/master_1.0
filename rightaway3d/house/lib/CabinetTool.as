package rightaway3d.house.lib
{
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.house.utils.TestNumer;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	public class CabinetTool
	{
		//private var pm:ProductManager = ProductManager.own;
		
		private var cornerMinDist:int = 170;//拐角柜至墙的最小距离
		
		//===============================================================================================================
		private var lib:CabinetLib = CabinetLib.lib;
		
		/**
		 * 根据指定条件，获取一个最优的地柜厨柜组合
		 * 
		 */
		public function getGroundCabinetGroup(cw:CrossWall,x0:Number,x1:Number,drainer_:Product2D,flue_:Product2D,ster_:Object,oven_:Object,headCorner_:Boolean,endCorner_:Boolean):Array
		{
			var type:String = "groundCabinet";
			var kind:String;
			var flagPos:String;
			var space_:int = x1 - x0;
			
			if(drainer_ && flue_)//水盆和灶台出现在同一区间时，之间要区分左右
			{
				if(drainer_.vo.objectInfo.x<flue_.vo.objectInfo.x)
				{
					kind = "drainer_flue";//水盆在左，灶台在右
				}
				else
				{
					kind = "flue_drainer";//灶台在左，水盆在右
				}
				
				flagPos = Pos.BOTH_ENDS;//水盆和灶台在两端
			}
			else if(drainer_)
			{
				kind = "drainer";//水盆柜组合中没有烤箱
				oven_ = null;
				
				flagPos = getFlagPosition(x0,x1,drainer_.vo.objectInfo,headCorner_,endCorner_);
			}
			else if(flue_)
			{
				kind = "flue";//灶台组合中没有消毒柜
				ster_ = null;
				
				flagPos = getFlagPosition(x0,x1,flue_.vo.objectInfo,headCorner_,endCorner_);
			}
			else
			{
				kind = "general";//一般组合中没有消毒柜和烤箱
				ster_ = null;
				oven_ = null;
			}
			
			trace("-----------getGroundCabinetGroup:");
			trace("区间长度:"+space_+"="+x0+"-"+x1);
			/*trace("水盆:"+drainer_);
			trace("灶台："+flue_);
			trace("消毒柜:"+ster_);
			trace("烤箱:"+oven_);
			trace("头部转角柜:"+headCorner_);
			trace("尾部转角柜:"+endCorner_);*/
			
			if(headCorner_)
			{
				if(x0-cw.localHead.x<cornerMinDist)//转角柜至墙的间距至少为100
				{
					var n:Number = cw.localHead.x + cornerMinDist - x0;
				}
				else
				{
					n = 0;
				}
				space_ -= 900 + n;//区间首端要放置转角柜时，让出转角柜的空间
			}
			
			if(endCorner_)
			{
				if(cw.localEnd.x-x1<cornerMinDist)//转角柜至墙的间距至少为100
				{
					n = x1 + cornerMinDist - cw.localEnd.x;
				}
				else
				{
					n = 0;
				}
				space_ -= 900 + n;//区间尾端要放置转角柜时，让出转角柜的空间
			}
			
			trace("区间长度2:"+space_);
			
			var list:XMLList = lib.getCabinetGroup(type,kind,space_,drainer_,flue_,ster_,oven_);
			
//			trace("list"+list);
			var len:int = list.length();
			if(len==0 && kind != "general")
			{
				ster_ = null;
				oven_ = null;
				list = lib.getCabinetGroup(type,kind,space_,drainer_,flue_,ster_,oven_);//去掉电器，重新计算组合
				len = list.length();
				if(len==0)throw new Error("找不到指定的模板，或者当前空间["+space_+"]不足模板设备所需，请回到上一步重新设置！");
			}
			
			if(len>0)
			{
				var groups:Array = sortXML(list);
				
				var xml:XML = groups[groups.length-1];//暂时只取最大的一个
				//trace(xml);
				
				var groupList:XMLList = xml.group.cabinet;
				//trace("groupList:"+groupList);
				if(ster_)//存在消毒柜时，添加消毒柜数据
				{
					var txml:XML = groupList.(flag=="sterilizer")[0];
					txml.item = ster_;
					txml.item.name = ProductObjectName.STERILIZER;//设置消毒柜产品标识
				}
				
				if(oven_)//存在烤箱时，添加烤箱数据
				{
					txml = groupList.(flag=="oven")[0];
					txml.item = oven_;
					txml.item.name = ProductObjectName.OVEN;//设置烤箱产品标识
				}
				
				var standardSize:int = xml.standardSize;
				
				var needSpace:int = xml.minSpace;
			}
			else
			{
				needSpace = 0;
			}
			
			var moreSpace:int = space_ - needSpace;
			
			//var num:int = moreSpace / standardSize;//数量
			//var more:int = moreSpace % standardSize;//剩余量
			
			var addList:Array = TestNumer.matchGroupSize(moreSpace,bigCabinets,smallCabinets);
			addList.pop();//最后一个值为匹配后剩余值，这里去掉
			
			//trace("group:"+addList);
			
			//开始找出最优组合
			var group:Array = getGroupData(groupList,addList,flagPos,"ground_",kind);
			if(headCorner_ || endCorner_)
			{
				var corner:XML = lib.getDictionaryData("ground_corner");
				if(headCorner_)group.unshift(corner.copy());//在首部加入拐角柜
				if(endCorner_)group.push(corner.copy());//在尾部加入拐角柜
			}
			
			//trace(group);
			
			return group;
		}
		
		public function getWallCabinetGroup(cw:CrossWall,x0:Number,x1:Number,headCorner_:Boolean,endCorner_:Boolean):Array
		{
			var type:String = "wallCabinet";
			var kind:String = "general";
			var flagPos:String = Pos.BOTH_ENDS;
			var space_:int = x1 - x0;
			
			/*trace("-----------getWallCabinetGroup:");
			trace("区间长度:"+space_+"="+x0+"-"+x1);
			trace("头部转角柜:"+headCorner_);
			trace("尾部转角柜:"+endCorner_);*/
			
			if(headCorner_)
			{
				space_ -= 800;//区间首端要放置转角柜时，让出转角柜的空间
			}
			if(endCorner_)
			{
				space_ -= 800;//区间尾端要放置转角柜时，让出转角柜的空间
			}
			
//			trace("区间长度2:"+space_);
			
			var drainer_:Product2D,flue_:Product2D,ster_:Object,oven_:Object;
			var list:XMLList = lib.getCabinetGroup(type,kind,space_,drainer_,flue_,ster_,oven_);
			
			//trace(list);
			var len:int = list.length();
			if(len==0)
			{
				trace("当前空间不够放置模板设备，将进行自动匹配！");
				needSpace = 0;
			}
			else
			{
				var groups:Array = sortXML(list);
				
				var xml:XML = groups[groups.length-1];//暂时只取最大的一个
				var groupList:XMLList = xml.group.cabinet;
				//trace("groupList:"+groupList);
				
				var standardSize:int = xml.standardSize;
				
				var needSpace:int = xml.minSpace;
			}
			
			var moreSpace:int = space_ - needSpace;
			
			//var num:int = moreSpace / standardSize;//数量
			//var more:int = moreSpace % standardSize;//剩余量
			
			var addList:Array = TestNumer.matchGroupSize(moreSpace,bigCabinets,smallCabinets2);
			addList.pop();//最后一个值为匹配后剩余值，这里去掉
			
			//trace("group:"+addList);
			
			//开始找出最优组合
			var group:Array = getGroupData(groupList,addList,flagPos,"wall_",kind);
			if(headCorner_ || endCorner_)
			{
				var corner:XML = lib.getDictionaryData("wall_corner");
				if(headCorner_)group.unshift(corner.copy());//在首部加入拐角柜
				if(endCorner_)group.push(corner.copy());//在尾部加入拐角柜
			}
			
			//trace(group);
			
			return group;
		}
		
		private function getGroupData(groupList:XMLList,addList:Array,flagPos:String,cabType:String,kind:String):Array
		{
			//trace("flagPos:"+flagPos);
			
			var doorType:String = cabType + "cabinet";
			
			var a:Array = [];
			var len:int = 0;
			
			if(groupList)len = groupList.length();
			
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = groupList[i];
				a.push(xml);
			}
			
			len = addList.length;
			
			for(i=0;i<len;i++)
			{
				var addWidth:int = addList[i];
				var key:String = cabType+String(addWidth);
				xml = lib.getDictionaryData(key);
				
				if(flagPos==Pos.END)
				{
					a.unshift(xml);
					//addDoor(xml,doorType,"left",addWidth);
				}
				else if(flagPos==Pos.HEAD)
				{
					a.push(xml);
					//addDoor(xml,doorType,"right",addWidth);
				}
				else
				{
					if(i%2==0)
					{
						a.push(xml);
						//addDoor(xml,doorType,"right",addWidth);
					}
					else
					{
						a.unshift(xml);
						//addDoor(xml,doorType,"left",addWidth);
					}
				}
			}
			return a;
		}
		
		/*private function addDoor(parent:XML,type_:String,kind_:String,size:int):void
		{
			//trace("addDoor:",type_,kind_,size);
			if(size<800)
			{
				var door:XML = CabinetLib.lib.getDoor(type_,kind_,size);
				parent.door = door;
			}
			else
			{
				parent.kind = kind_;
			}
			//var door:XML = CabinetLib.lib.getDoor("ground_cabinet","left",900);
		}*/
		
		/**
		 * 获取普通柜门数据
		 * @param po
		 * @return 
		 * 
		 */
		public function getDoorData(po:ProductObject,direction:String):XMLList
		{
			var type:String,kind:String,size:String;
			
			var wo:WallObject = po.objectInfo;
			//trace("getdoor dimensions:",po.productInfo.dimensions);
			//trace("wo:",wo);
			var a:String,b:String;
			
			if(wo.y<1000)
			{
				type = "ground_cabinet";//地柜
				a = "地";
			}
			else
			{
				type = "wall_cabinet";//吊柜
				a = "吊";
			}
			
			var cw:CrossWall = wo.crossWall;
			var center:Number = cw.validLength*0.5+cw.localHead.x;//墙体中心位置
			var dx:Number = wo.x - wo.width*0.5;//产品的中心位置
			
			if((!direction && dx<center) || direction=="left")
			{
				kind = "left";//左开门
				b = "左";
			}
			else
			{
				kind = "right";//右开门
				b = "右";
			}
			
			//中高柜用型号来匹配
			size = wo.height<1000 ? wo.width+"x"+wo.height+"x"+wo.depth : po.productInfo.productModel;
			
			var list:XMLList = CabinetLib.lib.getDoor(type,kind,size);
			var len:int = list.length();
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = list[i];
				xml.memo = a+b;
			}
			
			return list;
		}
		
		/**
		 * 获取中高柜门数据
		 * @param po
		 * @return 
		 * 
		 */
		public function getMiddleDoorData(po:ProductObject):XMLList
		{
			var type:String,kind:String,productModel:String;
			
			var wo:WallObject = po.objectInfo;
			
			type = "ground_cabinet";//地柜
			
			var cw:CrossWall = wo.crossWall;
			var center:Number = cw.validLength*0.5+cw.localHead.x;//墙体中心位置
			var dx:Number = wo.x - wo.width*0.5;//产品的中心位置
			
			if(dx<center)kind = "left";//左开门
			else kind = "right";//右开门
			
			productModel = po.productInfo.productModel;
			//trace("getMiddleDoorData productModel:"+productModel);
			
			return CabinetLib.lib.getDoors(type,kind,productModel);
		}
		
		/**
		 * 计算水盆或灶台在区间中的放置位置，分别为middle[中间]，head[首端]，end[尾端]
		 * @param x0
		 * @param x1
		 * @param flag
		 * @return 
		 * 
		 */
		private function getFlagPosition(x0:Number,x1:Number,flag:WallObject,headCorner_:Boolean,endCorner_:Boolean):String
		{
			//if(headCorner_)x0 += 900;
			//if(endCorner_)x1 -= 900;
			
			var all:Number = x1 - x0;
			var middleArea:Number = flag.width * 2;
			if(middleArea>=all)return Pos.MIDDLE;//空间小于1800时，直接放中间
			
			var d:Number = (all-middleArea)/2;
			var tx0:Number = x0 + d;
			var tx1:Number = tx0 + middleArea;
			
			if(flag.x > tx1)return Pos.END;//放尾端
			if(flag.x - flag.width < tx0)return Pos.HEAD;//放首端
			
			return Pos.MIDDLE;//在中间
		}
		
		private var bigCabinets:Array = [800,900];
		private var smallCabinets:Array = [300,400,450];//,500
		private var smallCabinets2:Array = [300,400,450];//,600
		
		private function sortXML(list:XMLList):Array
		{
			var a:Array = [];
			var len:int = list.length();
			for(var i:int=0;i<len;i++)
			{
				var xml:XML = list[i];
				a.push(xml);
			}
			a.sortOn("minSpace",Array.NUMERIC);
			//trace("sortlist:"+a);
			
			return a;
		}
		
		//==============================================================================================
		static private var instance:CabinetTool;
		
		static public function get tool():CabinetTool
		{
			instance ||= new CabinetTool(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
		public function CabinetTool(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("CabinetTool 是一个单例类，请用静态属性lib来获得类的实例。");
			}
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}

class Pos
{
	static public const MIDDLE:String = "middle";
	static public const HEAD:String = "head";
	static public const END:String = "end";
	static public const BOTH_ENDS:String = "bothEnds";
}


