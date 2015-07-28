package rightaway3d.house.lib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import rightaway3d.URLTool;
	
	[Event(name="complete", type="flash.events.Event")]

	public class CabinetLib extends EventDispatcher
	{
		public var libReady:Boolean = false;
		
		//==============================================================================================

		public function getCabinetGroup(type_:String,kind_:String,space_:int,drainer_:Object,flue_:Object,ster_:Object,oven_:Object):XMLList
		{
			var hasDrainer:String = drainer_?"true":"false";
			var hasFlue:String = flue_?"true":"false";
			var hasSter:String = ster_?"true":"false";
			var hasOven:String = oven_?"true":"false";
			
			trace("getCabinetGroup type:"+type_+" kind:"+kind_+" space:"+space_+" 水盆："+hasDrainer+" 灶台："+hasFlue+" 消毒柜："+hasSter+" 烤箱："+hasOven);
			
			var list:XMLList = groupList.(type==type_ && kind==kind_ && minSpace<=space_ && drainer==hasDrainer
				&& flue==hasFlue && sterilizer==hasSter && oven==hasOven);
			
			return list;
		}
		
		public function getDictionaryData(key_:String):XML
		{
			var list:XMLList = dictList.(key==key_);
			if(list.length()==0)
			{
				throw new Error("找不到指定的厨柜："+key_);
			}
			
			return list[0].cabinet[0];
		}
		
		public function getCabinetData(id_:String):XML
		{
			var list:XMLList = cabinetsList.(id==id_);
			if(list.length()==0)
			{
				throw new Error("找不到指定的厨柜："+id_);
			}
			
			return list[0];
		}
		
		public function getDoor(type_:String,kind_:String,size_:String):XMLList
		{
			var list:XMLList = doorsList.(type==type_ && kind==kind_ && matching==size_);
			if(list.length()==0)
			{
				throw new Error("找不到指定的厨柜门："+type_+","+kind_+","+size_);
			}
			
			return list;
		}
		
		public function getDoors(type_:String,kind_:String,productModel:String):XMLList
		{
			//trace("productModel:"+productModel);
			var list:XMLList = doorsList.(type==type_ && kind==kind_ && matching==productModel);
			if(list.length()==0)
			{
				throw new Error("找不到指定的厨柜门："+type_+","+kind_+","+productModel);
			}
			
			return list;
		}
		
		public function getReplaceList(targets:Array):Array
		{
			//trace("targets:"+targets);
			var len:int = replaceList.length();
			for(var i:int=0;i<len;i++)
			{
				//trace("i:"+i);
				var idList:XMLList = replaceList[i].ids;
				var len2:int = idList.length();
				for(var j:int=0;j<len2;j++)
				{
					//trace("j:"+j);
					var s:String = idList[j];
					var ids:Array = s.split(",");
					//trace("replacelist:"+ids);
					if(isEqualArray(targets,ids))
					{
						return _getReplaceList(idList,j);
					}
				}
			}
			
			return null;
		}
		
		private function _getReplaceList(list:XMLList,ext:int):Array
		{
			//trace("---------getReplaceList:");
			var a:Array = [];
			var len:int=list.length();
			for(var i:int=0;i<len;i++)
			{
				//trace("i:"+i);
				var idsxml:XML = list[i];
				var justBeReplaced:Boolean = idsxml.@justBeReplaced=="true"?true:false;
				//justBeReplaced(只能被替换)定义了一种单向替换逻辑，即某种产品被此属性的产品替换后，就不能再用此属性的产品把原产品替换回来了
				//justBeReplaced为true时，表示此产品列表只能被替换，而不能用于替换
				if(!justBeReplaced && i!=ext)
				{
					var b:Array = [];
					a.push(b);
					
					var s:String = idsxml.toString();
					var ids:Array = s.split(",");
					var len2:int=ids.length;
					for(var j:int=0;j<len2;j++)
					{
						var id:String = ids[j];
						var xml:XML = getCabinetData(id);
						//trace(xml);
						b.push(xml);
					}
				}
			}
			//trace("-----------");
			return a;
		}
		
		private function isEqualArray(a1:Array,a2:Array):Boolean
		{
			var len:int=a1.length;
			if(len!=a2.length)return false;
			if(len==1 && a1[0]==a2[0])return true;
			if(len==2)
			{
				if(a1[0]==a2[0] && a1[1]==a2[1])return true;
				if(a1[0]==a2[1] && a1[1]==a2[0])return true;
			}
			return false;
		}
		
		public function getDynamicProductList():Array
		{
			return dynamicProductList.concat();
		}
		
		public function getDynamicProductData(name:String):XML
		{
			if(dynamicSubProduct[name]!=undefined)
			{
				return dynamicSubProduct[name][0];
			}
			return null;
		}
		
		public function setDynamicProductData(name:String,infoID:int,file:String):void
		{
			if(dynamicSubProduct[name]!=undefined)
			{
				var xml:XML = dynamicSubProduct[name][0];
			}
			else
			{
				xml = <{name}></{name}>;
				dynamicSubProduct.appendChild(xml);
			}
			
			xml.infoID = infoID;
			xml.file = file;
		}
		
		public function getProductTypeList():XML
		{
			return productTypeList;
		}
		
		public function getProductList(type_:String,cate_:String):XMLList
		{
			var list:XMLList = cabinetsList.(type==type_ && cate==cate_);
			return list;
		}
		
		//==============================================================================================
		private var libXML:XML;
		private var groupList:XMLList;
		private var dictList:XMLList;
		private var cabinetsList:XMLList;
		private var doorsList:XMLList;
		private var replaceList:XMLList;
		
		private var productTypeList:XML;
		
		private var dynamicSubProduct:XML;
		private var dynamicProductList:Array;
		
		private function loadData():void
		{
			var url:String = "config/cabinet_group.xml";
			URLTool.LoadURL(url,onLoaded,onLoadError);
		}
		
		private function onLoaded(data:String):void
		{
			trace("onCabinetLibLoaded");
			XML.ignoreComments = false;
			libXML = new XML(data);
			groupList = libXML.groups.kind.item;
			dictList = libXML.dictionary.item;
			cabinetsList = libXML.cabinets.item;
			doorsList = libXML.doors.kind.kind.door;
			replaceList = libXML.replaces.item;
			//trace(cabinetsList);
			//trace(doorsList);
			productTypeList = libXML.productTypeList[0];

			dynamicSubProduct = libXML.dynamicSubProduct[0];
			var s:String = dynamicSubProduct.list;
			dynamicProductList = s.split(",");
			trace("dynamicProductList:"+dynamicProductList);
			
			libReady = true;
			
			this.dispatchEvent(new Event("complete"));
			//test();
		}		
		
		private function test():void
		{
			//var list:XMLList = libXML.groups.kind.item;
//			var list2:XMLList = groupList.(group_id==3 && type=="wallCabinet");
			//var list2:XMLList = getCabinetGroup("groundCabinet","drainer",2000,{},null,{},null);
			//trace("list:"+list2);
			//trace(getDictionaryData("ground_400"));
			//trace(getCabinetData("501"));
			
			//trace(getDoor("ground_cabinet","left",400));
			//getReplaceList([]);
			//trace(getProductList("handle",""));
		}
		
		private function onLoadError(data:Object):void
		{
			trace("CabinetLib Load Data Error:"+data);
		}
		
		//==============================================================================================
		static private var instance:CabinetLib;
		
		static public function get lib():CabinetLib
		{
			instance ||= new CabinetLib(new InstanceClass());
			return instance;
		}
		
		//==============================================================================================
		public function CabinetLib(value:InstanceClass)
		{
			if(!value)
			{
				throw new Error("CabinetLib是一个单例类，请用静态属性lib来获得类的实例。");
			}
			
			loadData();
		}
		
		//==============================================================================================
	}
}

class InstanceClass{}

