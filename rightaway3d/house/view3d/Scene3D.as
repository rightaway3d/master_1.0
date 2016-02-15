package rightaway3d.house.view3d
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	
	import rightaway3d.engine.core.Engine3D;
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.engine.model.ModelLoader;
	import rightaway3d.engine.parser.ModelParser;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.skybox.SkyBoxLoader;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.utils.GlobalConfig;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallObject;

	public class Scene3D extends Sprite
	{
		public function Scene3D()
		{
			//trace("---------------Scene3D");
			super();
			if(stage)
			{
				init();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,init);
			}
		}
		
		public var engineManager:EngineManager;
		
		private var modelLoader:ModelLoader;
		private var modelParser:ModelParser;
		private var productManager:ProductManager;
		
		public var engine3d:Engine3D;
		
		public var house3d:House3D;
		
		//private var groundGeom:PlaneGeometry;
		//private var ground:Mesh;
		
		private function init(event:Event=null):void
		{
			//trace("---------------Scene3D init");
			if(event)this.removeEventListener(Event.ADDED_TO_STAGE,init);
			
			engine3d = new Engine3D(this);
			
			modelLoader = ModelLoader.own;
			
			modelParser = ModelParser.own;
			
			engineManager = new EngineManager(engine3d,modelLoader,modelParser);
			
			productManager = ProductManager.own;
			
			house3d = new House3D();
			engine3d.addRootChild(house3d);
			house3d.engine3d = engine3d;
			house3d.engineManager = engineManager;
			
			engineManager.rootContainer = house3d;
			
			engine3d.setBackgroundColor(0x0);
			//engine3d.setLightColor(0xffffff);
			engine3d.camCtrl.cc.distance = 10000;
			engine3d.camCtrl.cc.minTiltAngle = -5;
			//engine3d.camera.lens.near = 1;
			//engine3d.camera.lens.far = 20000;
			//engine3d.camCtrl.addEventListener("distanceChange",onDistanceChanged);
		}
		
		/*protected function onDistanceChanged(event:Event):void
		{
			//var n:int = engine3d.camCtrl.cc.distance/400;
			//if(n<5)n=5;
			//ground.y = -n;
			//trace("distance:"+n);
		}*/
		
		private function updateLight(house:House):void
		{
			// ztc 更新灯光位置
			var max:Vector3D = house.max.clone();
			max.x = max.x - house.x;
			max.z = max.z - house.z;
			var min:Vector3D = house.min.clone();
			min.x = min.x - house.x;
			min.z = min.z - house.z;
			
			engine3d.updateLights(max,min);
		}
		
		private function getCameraDistance(house:House):Number
		{
			var d:int = house.width<house.depth?house.width:house.depth;
			d *= 0.5;
			return d;
		}
		
		private function _updateHouse(house:House):void
		{
			house3d.update(house);
			//trace("house3d:"+house.width,house.height,house.depth);
			updateLight(house);
			
			productManager.updateProductPosition(-house.x,-house.z);
		}
		
		public function updateHouse(house:House):void
		{
			_updateHouse(house);
			reset(house);
			setCameraOfWalls();
			/*var d:Number = getCameraDistance(house);
			setCamera(d,house.currPanAngle);*/
			
			//this.engine3d.camCtrl.cc.
			//engine3d.render(false);
			
			/*var ssmm:SoftShadowMapMethod = new SoftShadowMapMethod(engine3d.sunLight, 30);
			ssmm.range = 3;	// the sample radius defines the softness of the shadows
			ssmm.epsilon = .1;*/
			//ColorMaterial(ground.material).shadowMethod = new FilteredShadowMapMethod(engine3d.sunLight);
		}
		
		private function setCamera(dist:Number,panAngle:Number):void
		{
			trace("setCamera:",dist,panAngle);
			this.engine3d.camCtrl.maxWhellDistance = dist;
			this.engine3d.camCtrl.cc.distance = dist;
			this.engine3d.camCtrl.cc.panAngle = panAngle;
			this.engine3d.camCtrl.cc.tiltAngle = 0;//85;//25;
			this.engine3d.camCtrl.cc.lookAtPosition = new Vector3D(0,1200,0);//house.currFloor.ceilingHeight/2
		}
		
		public function update():Boolean
		{
			trace("update:",index,walls.length);
			
			if(index>=walls.length)return false;
			
			var wall:Wall = walls[index++];
			var d:Number = wall.length;
			var a0:Number = (540-wall.angles)%360;
			
			setCamera(d,a0);
			
			/*var a:Number = (540-wall.angles)%360;
			engine3d.camCtrl.cc.panAngle = a;
			engine3d.camCtrl.cc.lookAtPosition = new Vector3D(0,1200,0);*/
			engine3d.render(false);
			
			return true;
		}
		
		private var index:int;
		private var walls:Array;
		
		public function reset(house:House):void
		{
			walls = [];
			var cws:Vector.<CrossWall> = house.currFloor.rooms[0].walls;
			for each(var cw:CrossWall in cws)
			{
				if(hasCabinet(cw))
				{
					walls.push(cw.wall);
				}
			}
			
			if(walls.length==0)//如果当前场景还没有放置厨柜，则任取一墙作为默认角度
			{
				walls.push(cws[0].wall);
			}
			
			index = 0;
		}
		
		private function setCameraOfWalls(hideWalls:Array=null):void
		{
			if(walls.length==1)
			{
				var w0:Wall = walls[0];
				if(hideWalls)hideWalls.push(w0.frontCrossWall.headCrossWall.headCrossWall.wall);
				
				var d:Number = w0.length;
				var a0:Number = (540-w0.angles)%360;
				
				setCamera(d,a0);
			}
			else if(walls.length==2)
			{
				var w1:Wall = walls[0];
				var w2:Wall = walls[1];
				
				if(w1.frontCrossWall.headCrossWall == w2.frontCrossWall
					|| w1.frontCrossWall.endCrossWall == w2.frontCrossWall)
				{
					var a1:Number = (540-w1.angles)%360;
					var a2:Number = (540-w2.angles)%360;
					a0 = (a1+a2)*0.5;
					d = (w1.length + w2.length)*0.5;
					setCamera(d,a0);
					
					if(hideWalls)
					{
						if(w1.frontCrossWall.headCrossWall == w2.frontCrossWall)
						{
							hideWalls.push(w2.frontCrossWall.headCrossWall.wall);
							hideWalls.push(w2.frontCrossWall.headCrossWall.headCrossWall.wall);
						}
						else
						{
							hideWalls.push(w1.frontCrossWall.headCrossWall.wall);
							hideWalls.push(w1.frontCrossWall.headCrossWall.headCrossWall.wall);
						}
					}
				}
				else
				{
					w0 = w1.frontCrossWall.endCrossWall.wall;
					
					if(hideWalls)hideWalls.push(w0.frontCrossWall.headCrossWall.headCrossWall.wall);
					
					d = w0.length>w1.length ? w0.length : w1.length;
					
					a0 = (540-w0.angles)%360;
					
					setCamera(d,a0);
				}
			}
			else if(walls.length==3)
			{
				w0 = getMiddleWall(walls);
				
				if(hideWalls)hideWalls.push(w0.frontCrossWall.headCrossWall.headCrossWall.wall);
				
				w1 = w0.frontCrossWall.headCrossWall.wall;
				
				d = w0.length>w1.length ? w0.length : w1.length;
				a0 = (540-w0.angles)%360;
				
				setCamera(d,a0);
			}
		}
		
		public function getSnapshot(house:House,isReset:Boolean=true,forceRender:Boolean=true,w:int=1200,h:int=900):BitmapData
		{
			house.updateBounds();
			_updateHouse(house);
			
			if(isReset)reset(house);
			//var d:Number = getCameraDistance(house) * 2;
			
			var hideWalls:Array = [];
			
			if(forceRender)
			{
				setCameraOfWalls(hideWalls);
				
				house3d.setWallsVisible(hideWalls,false);
				
				engine3d.render(false);
			}
			
			var bd:BitmapData = engine3d.getSnapshot(w,h);
			
			house3d.setWallsVisible(hideWalls,true);
			
			return bd;
		}
		
		private function getMiddleWall(walls:Array):Wall
		{
			var w0:Wall = walls[0];
			var w1:Wall = walls[1];
			var w2:Wall = walls[2];
			
			if((w1.frontCrossWall.endCrossWall.wall==w0 && w2.frontCrossWall.headCrossWall.wall==w0)
			|| (w1.frontCrossWall.headCrossWall.wall==w0 && w2.frontCrossWall.endCrossWall.wall==w0))
				return w0;
			
			if((w0.frontCrossWall.endCrossWall.wall==w1 && w2.frontCrossWall.headCrossWall.wall==w1)
			|| (w0.frontCrossWall.headCrossWall.wall==w1 && w2.frontCrossWall.endCrossWall.wall==w1))
				return w1;
			
			if((w0.frontCrossWall.endCrossWall.wall==w2 && w1.frontCrossWall.headCrossWall.wall==w2)
			|| (w0.frontCrossWall.headCrossWall.wall==w2 && w1.frontCrossWall.endCrossWall.wall==w2))
				return w2;
			
			return null;
		}
		
		private function hasCabinet(cw:CrossWall):Boolean
		{
			if(_hasCabinet(cw.groundObjects))return true;
			if(_hasCabinet(cw.wallObjects))return true;
			return false;
		}
		
		private function _hasCabinet(wos:Array):Boolean
		{
			for each(var wo:WallObject in wos)
			{
				if(wo.object is ProductObject)
				{
					if(ProductObject(wo.object).view2d)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		public function updateView(w:int,h:int):void
		{
			if(engine3d)engine3d.setViewSize(w,h);
		}
		
		public function loadSkyBoxTextures(urls:Array):void
		{
			var loader:SkyBoxLoader = new SkyBoxLoader();
			loader.load(urls);
			loader.addEventListener("all_loaded",onSkyBoxAllLoaded);
		}
		
		private function onSkyBoxAllLoaded(event:Event):void
		{
			var loader:SkyBoxLoader = event.currentTarget as SkyBoxLoader;
			var a:Array = loader.bitmaps;
			engine3d.setBitmapSkyBox(a[0],a[1],a[2],a[3],a[4],a[5]);
		}
		
		private var cabinetCreator:CabinetCreator = CabinetCreator.getInstance();
		
		public function toJsonString():String
		{
			var house:House = House.getInstance();
			var s:String = "{";
			s += "\"engine\":" + engine3d.toJsonString() + ",";
			s += "\"house\":" + house.toJsonString() + ",";
			s += "\"config\":" + GlobalConfig.instance.toJsonString() + ",";
			s += "\"cabinetTable\":" + cabinetCreator.getCabinetTableData() + ",";
			s += "\"products\":" + productManager.getRootProductJsonString();
			s += "}";
			return s;
		}
		
		private function getEngineJsonString():void
		{
		}
		
		/*private function getProductList():XMLList
		{
			var xml:XML = 	<list>
								<product>
									<infoID>501</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_501_300x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>300x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>502</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_502_400x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>400x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>503</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_503_450x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>450x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>504</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_504_500x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>500x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>506</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_506_800x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>800x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>507</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_507_900x720x570.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>900x720x570</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>511</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_511_300x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>300x720x330</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>512</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_512_400x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>400x720x330</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>513</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_513_450x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>450x720x330</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>515</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_515_600x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>600x720x330</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>516</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_516_800x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>800x720x330</dimensions>
									<image></image>
								</product>
								<product>
									<infoID>517</infoID>
									<name>name</name>
									<name_en>name_en</name_en>
									<file>cabinet_517_900x720x330.pdt</file>
									<dataFormat>text</dataFormat>
									<dimensions>900x720x330</dimensions>
									<image></image>
								</product>
							</list>;
			return xml.product;
		}*/
		
		/*private function getProductXML():XML
		{
			var xml:XML =
				<scene>
					<product>
						<infoID>501</infoID>
						<objectID>1</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_501_300x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1850,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>502</infoID>
						<objectID>2</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_502_400x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1500,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>503</infoID>
						<objectID>3</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_503_450x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1050,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>504</infoID>
						<objectID>4</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_504_500x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-550,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>506</infoID>
						<objectID>6</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_506_800x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>0,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>507</infoID>
						<objectID>7</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_507_900x720x570.pdt</file>
						<dataFormat>text</dataFormat>
						<position>850,0,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>511</infoID>
						<objectID>11</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_511_300x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1850,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>512</infoID>
						<objectID>12</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_512_400x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1500,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>513</infoID>
						<objectID>13</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_513_450x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-1050,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>515</infoID>
						<objectID>15</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_515_600x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>-550,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>516</infoID>
						<objectID>16</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_516_800x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>100,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
					<product>
						<infoID>517</infoID>
						<objectID>17</objectID>
						<name>name</name>
						<name_en>name_en</name_en>
						<file>cabinet_517_900x720x330.pdt</file>
						<dataFormat>text</dataFormat>
						<position>950,1000,-1800</position>
						<rotation>0,0,0</rotation>
						<scale>1,1,1</scale>
						<active>true</active>
					</product>
				</scene>;
			
			return xml;
		}*/
	}
}