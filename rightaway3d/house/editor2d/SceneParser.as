package rightaway3d.house.editor2d
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Floor;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.HousePoint;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.utils.Base64;

	public class SceneParser
	{
		public function SceneParser()
		{
		}
		
		//=========================================================================================================================
		/**
		 * 解析经过编码的数据
		 * @param s
		 * 
		 */
		public function parseEncodeString(s:String):Floor
		{
			s = decodeString(s);
			return parseJsonString(s);
		}
		
		/**
		 * 解析Json格式数据
		 * @param s
		 * 
		 */
		public function parseJsonString(s:String):Floor
		{
			trace(s);
			var o:Object = JSON.parse(s);
			//traceObject(o);
			return parseJsonObject(o);
			/*try
			{
			}
			catch(e:*)
			{
				trace("==Json data parse failed:"+e);
				trace("==scene data:"+s);
			}
			return null;*/
		}
		
		static public function traceObject(object:Object,s:String=""):void
		{
			s += "  ";
			for(var key:String in object)
			{
				var o:Object = object[key];
				trace(s+"{"+key+":"+o+"}");
				traceObject(o,s);
			}
		}
		
		//=========================================================================================================================
		/**
		 * 解析Json数据导出的Object
		 * @param data
		 * 
		 */
		public function parseJsonObject(data:Object):Floor
		{
			var engineData:Object = data.engine;
			var houseData:Object = data.house;
			var products:Array = data.products;
			var cabinetTable:Object = data.cabinetTable;
			
			var wallDict:Dictionary = new Dictionary();
			
			parseEngineData(engineData);
			var v:Floor = parseHouseData(houseData,wallDict);
			parseProductData(products);
			parseCabinetTable(cabinetTable);
			
			return v;
		}
		
		private var cabinetCreator:CabinetCreator = CabinetCreator.getInstance();
		
		private function parseCabinetTable(cabinetTables:Object):void
		{
			cabinetCreator.createCabinetTable(cabinetTables);
		}
		
		//解析户型数据
		private function parseHouseData(o:Object,wallDict:Dictionary):Floor
		{
			var fs:Array = o.floors;//楼层数组
			//var len:int = fs.length;
			
			var f:Object = fs[0];
			var floor:Floor = new Floor();
			
			floor.index = f.index;
			Floor.setNextIndex(floor.index);
			
			floor.name = f.name;
			floor.groundHeight = f.groundHeight;
			floor.ceilingHeight = f.ceilingHeight;
			floor.ceilingThickness = f.ceilingThickness;
			floor.wallWidth = f.wallWidth;
			floor.doorSillHeight = f.doorSillHeight;
			floor.doorHeight = f.doorHeight;
			floor.windowSillHeight = f.windowSillHeight;
			floor.windowHeight = f.windowHeight;

			var housePointDict:Dictionary = new Dictionary();
			
			//创建房间点
			parseHousePoint(f.groundPoints,floor.groundPoints,housePointDict);
			
			//创建墙体
			//添加墙洞
			parseWalls(f.walls,floor,housePointDict,wallDict);
			
			//生成房间
			parseRooms(f.rooms,floor,wallDict);
			
			//创建地面天花板
			//
			
			House.getInstance().addFloor(floor);
			
			return floor;
		}
		
		//解析房间数据
		private function parseRooms(roomsData:Array,floor:Floor,wallDict:Dictionary):void
		{
			var rooms:Vector.<Room> = floor.rooms;
			for each(var r:Object in roomsData)
			{
				var room:Room = new Room();
				rooms.push(room);
				room.floor = floor;
				
				room.index = r.index;
				room.name = r.name;
				
				room.groundMaterialName = r.groundMaterial;
				room.ceilingMaterialName = r.ceilingMaterial;
				//room.groundSpecular = r.groundSpecular;
				
				//room.ceilingTextureURL = r.ceilingTextureURL;
				//room.ceilingNormalURL = r.ceilingNormalURL;
				//room.ceilingSpecular = r.ceilingSpecular;
				
				parseRoomCrossWall(r.walls,room,wallDict);
			}
		}
		
		//解析房间相交墙面数据
		private function parseRoomCrossWall(wallsData:Array,room:Room,wallDict:Dictionary):void
		{
			var walls:Vector.<CrossWall> = room.walls;
			var len:int = wallsData.length;
			for(var i:int=0;i<len;i++)
			{
				var w:Object = wallsData[i];
				var index:int = w.index;
				var isHead:String = w.isHead;
				
				var wall:Wall = wallDict[index];
				wall.countCrossWall();
				
				var cw:CrossWall = isHead=="true"?wall.frontCrossWall:wall.backCrossWall;
				walls.push(cw);
				cw.room = room;
			}
		}
		
		//解析墙体数据
		private function parseWalls(wallsData:Array,floor:Floor,housePointDict:Dictionary,wallDict:Dictionary):void
		{
			for each(var w:Object in wallsData)
			{
				var wall:Wall = new Wall();
				floor.addWall(wall);
				
				wall.index = w.index;
				Wall.setNextIndex(wall.index);
				wallDict[wall.index] = wall;
				
				wall.name = w.name;
				wall.width = w.width;
				
				var index:int = w.groundHead;
				var hp:HousePoint = housePointDict[index];
				hp.crossWalls.push(wall.frontCrossWall);
				wall.groundHeadPoint = hp;
				
				index = w.groundEnd;
				hp = housePointDict[index];
				hp.crossWalls.push(wall.backCrossWall);
				wall.groundEndPoint = hp;
				
				parseWallHoles(w.holes,wall);
				
				parseWallMaterial(w.frontCrossWall,wall.frontCrossWall);
				parseWallMaterial(w.backCrossWall,wall.backCrossWall);
				
				wall.updateLength();
			}
		}
		
		//解析墙体材质
		private function parseWallMaterial(matData:Object,cw:CrossWall):void
		{
			cw.materialName = matData.material;
			//cw.normalURL = matData.normal;
		}
		
		//解析墙洞数据
		private function parseWallHoles(holesData:Array,wall:Wall):void
		{
			for each(var hd:Object in holesData)
			{
				var wh:WallHole = new WallHole();
				wh.width = hd.width;
				wh.height = hd.height;
				wh.x = hd.x;
				wh.y = hd.y;
				wh.modelThickness = hd.thickness;
				wh.modelType = hd.type;
				wh.modelURL = hd.url;
				
				wall.addHole(wh);
				trace("-----------wh:",wh.objectInfo);
			}
		}
		
		//解析房间点
		private function parseHousePoint(pointsData:Array,hps:Vector.<HousePoint>,housePointDict:Dictionary):void
		{
			for each(var pd:Object in pointsData)
			{
				var hp:HousePoint = new HousePoint();
				hp.index = pd.index;
				HousePoint.setNextIndex(hp.index);
				
				hp.point.x = pd.x;
				hp.point.y = pd.y;
				hp.point.z = pd.z;

				//trace("hp:"+hp.toJsonString());
				hps.push(hp);
				
				housePointDict[hp.index] = hp;
			}
		}
		
		private var productManager:ProductManager = ProductManager.own;
		private var cc:CabinetController = CabinetController.getInstance();
		
		//解析产品数据
		private function parseProductData(products:Array):void
		{
			//traceObject2(products);
			products.sortOn("objectID",Array.NUMERIC);
			var len:int = products.length;
			for(var i:int=0;i<len;i++)
			{
				trace("");
				var p:Object = products[i];
				trace("objectID1:",p.objectID);
				parseProduct(p);
			}
			
			/*for each(var p:Object in products)
			{
				parseProduct(p);
			}*/
		}
		
		public function parseProduct(p:Object):ProductObject
		{
			var po:ProductObject = productManager.parseProductObject(p);
			
			if(p.view2d=="true")cc.createProduct(po);
			
			if(po.productInfo.infoID>0 && po.position.y==0)//纠正之前保存的地柜位置
			{
				po.position.y = 80;
				po.container3d.y = 80;
				po.objectInfo.y = 80;
				
				if(po.dynamicSubProductObjects)
				{
					var dpos:Vector.<ProductObject> = po.dynamicSubProductObjects;
					for each(po in dpos)
					{
						po.position.y -= 80;
						po.container3d.y -= 80;
						if(po.objectInfo)po.objectInfo.y -= 80;
					}
				}
			}
			//trace("objectID2:",po.objectID);
			return po;
		}
		
		//解析引擎数据
		private function parseEngineData(o:Object):void
		{
			
		}
		
		//=========================================================================================================================
		public function encodeString(s:String):String
		{
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(s);//转换成二进制
			//trace("data length1:"+ba.length);
			
			ba.compress();//压缩数据
			//trace("data length2:"+ba.length);
			
			s = Base64.encodeByteArray(ba);//Base64编码
			//trace("data length0:"+s.length+"::"+s);
			
			return s;
		}
		
		public function decodeString(s:String):String
		{
			var ba:ByteArray = Base64.decodeToByteArray(s);//Base64解码
			ba.uncompress();//解压缩
			//trace("data length3:"+ba.length);
			
			s = ba.toString();//转成字符串
			//trace("data length4:"+s.length);
			
			return s;
		}
		//==================================================
		static private var _own:SceneParser;
		static public function get own():SceneParser
		{
			_own = _own || new SceneParser();
			return _own;
		}
		//=========================================================================================================================
	}
}