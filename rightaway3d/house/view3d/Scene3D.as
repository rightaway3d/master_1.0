package rightaway3d.house.view3d
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	
	import rightaway3d.engine.core.Engine3D;
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.engine.model.ModelLoader;
	import rightaway3d.engine.parser.ModelParser;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.skybox.SkyBoxLoader;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.vo.House;

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
			engine3d.setLightColor(0xffffff);
			engine3d.camCtrl.cc.distance = 10000;
			engine3d.camCtrl.cc.minTiltAngle = -5;
			//engine3d.camera.lens.near = 1;
			//engine3d.camera.lens.far = 20000;
			engine3d.camCtrl.addEventListener("distanceChange",onDistanceChanged);
			
			/*var cm:ColorMaterial = new ColorMaterial(0x555555);
			//cm.shadowMethod = new FilteredShadowMapMethod(engine3d.sunLight);
			//cm.shadowMethod.epsilon = 0.01;
			cm.lightPicker = engine3d.lightPicker;
			cm.specular = 0;
			cm.ambient = 1;*/
			//cm.gloss
			
			/*groundGeom = new PlaneGeometry(20000,20000);
			ground = new Mesh(groundGeom,cm);
			engine3d.addRootChild(ground);
			ground.y = -28;*/
			
			//engine3d.addRootChild(new Trident());
			
			/*var box:Mesh = new Mesh(new CubeGeometry(),cm);
			engine3d.addRootChild(box);*/
			//解析产品数据，加载产品模型
			
			/*var plist:XMLList = this.getProductXML().product;
			var len:int = plist.length();
			for(var i:int=0;i<len;i++)
			{
				var p:XML = plist[i];
				productManager.parseProductObject(p);				
			}
			productManager.loadProduct();*/
		}
		
		protected function onDistanceChanged(event:Event):void
		{
			//var n:int = engine3d.camCtrl.cc.distance/400;
			//if(n<5)n=5;
			//ground.y = -n;
			//trace("distance:"+n);
		}
		
		private var i:int = 1;
		public function updateHouse(house:House):void
		{
			house3d.update(house);
			trace("house3d:"+house.width,house.height,house.depth);
			
			// ztc 更新灯光位置
			var max:Vector3D = house.max.clone();
			max.x = max.x - house.x;
			max.z = max.z - house.z;
			var min:Vector3D = house.min.clone();
			min.x = min.x - house.x;
			min.z = min.z - house.z;
			engine3d.updateLights(max,min);
			
			productManager.updateProductPosition(-house.x,-house.z);
			
			var d:int = house.width<house.depth?house.width:house.depth;
			d *= 0.5;
			
			this.engine3d.camCtrl.maxWhellDistance = d;
			this.engine3d.camCtrl.cc.distance = d*0.5;
			this.engine3d.camCtrl.cc.panAngle = house.currPanAngle;
			this.engine3d.camCtrl.cc.tiltAngle = 25;
			this.engine3d.camCtrl.cc.lookAtPosition = new Vector3D(0,house.currFloor.ceilingHeight/2,0);

			/*var ssmm:SoftShadowMapMethod = new SoftShadowMapMethod(engine3d.sunLight, 30);
			ssmm.range = 3;	// the sample radius defines the softness of the shadows
			ssmm.epsilon = .1;*/
			//ColorMaterial(ground.material).shadowMethod = new FilteredShadowMapMethod(engine3d.sunLight);
			setTimeout(function():void {
				engine3d.updateCubeReflection();
			},1000);
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