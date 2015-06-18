package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	
	import org.poly2tri.Point;
	
	import rightaway3d.engine.controller.CameraController;
	
	import ztc.meshbuilder.room.CabinetTable3D;
	import ztc.meshbuilder.room.LightManager;
	import ztc.meshbuilder.room.MaterialLibrary;
	import ztc.meshbuilder.room.RenderUtils;
	import ztc.meshbuilder.room.RendingManager;

	[SWF(width=800,height=600)]
	public class MeshBuilder extends Sprite
	{
		public var view:View3D;
		public var cc:CameraController;
		
		//light objects
		private var directionalLight:DirectionalLight;
		private var directionalLight2:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		public function MeshBuilder()
		{
			view = new View3D();
			view.antiAlias = 4;
			view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
			addChild(view);
			
			
			cc = new CameraController(view.stage,view.camera);
			cc.cc.distance = 4000;
			view.camera.lens = new PerspectiveLens(70);
			view.camera.lens.far = 100000;
			
			addEventListener(Event.ENTER_FRAME,loop);
			
//			 cabinet table
			var bs:Vector.<Point> = new Vector.<Point>();
			var hs:Vector.<Point> = new Vector.<Point>();
			
			bs.push(new Point(0,1000),new Point(-300,1000),new Point(-300,0),new Point(1000,0),new Point(1000,1000),new Point(700,1000),
					new Point(700,300),new Point(0,300));
			
			hs.push(new Point(700,400),new Point(950,400),new Point(900,800),new Point(800,800));
			
			/**
			 * 创建橱柜台面Mesh: CabinetTabel3D(外圈点,洞圈点,半径,圆角段数,高)
			 * 注: 点以逆时针方向排列
			 */ 
			var cabinet:CabinetTable3D = new CabinetTable3D(bs,hs,40,8,30);
			cabinet.y = -500;
			view.scene.addChild(cabinet);
			
			//view.scene.addChild(cabinet);
			
//			var plane:Mesh = new Mesh(new PlaneGeometry(3000,3000),new ColorMaterial());
//			view.scene.addChild(plane);
//			
//			var cube:Mesh = new Mesh(new CubeGeometry(500,700,500),new ColorMaterial());
//			cube.y = 350;
//			view.scene.addChild(cube);
			
			/*
			var lm:LightManager = new LightManager(view,new Vector3D(1500,1000,1000),new Vector3D(-1500,-1000,-1000));
			
			var ml:MaterialLibrary = new MaterialLibrary('E:/work/天极/项目/欧派/库/材质库/material.xml',view,lm);
			
			ml.addEventListener('MaterialLibraryLoaded',function(e:Event):void {
				createRoom(lm);
				
				// 更新CubeReflection的渲染图
				MaterialLibrary.instance.updateCubeReflection(lm.center);
			});
			*/
			
			var houseMax:Vector3D = new Vector3D(1500,1000,1000);
			var houseMin:Vector3D = new Vector3D(-1500,-1000,-1000);
			
			// 创建 RendingManager
			var rm:RendingManager = new RendingManager(view,'E:/work/天极/项目/欧派/库/材质库/material.xml');
			
			MaterialLibrary.instance.addEventListener(Event.COMPLETE,function(e:Event):void {
				
				cabinet.material.lightPicker = rm.lightManager.lightPicker;
				RenderUtils.setMaterial(cabinet,'CL201_白流星');
				
				createRoom(rm.lightManager);
				
				// 得到墙体的默认材质名(String). types: wall|ceiling|ground|table|cabinetDoor|cabinetBody
				RenderUtils.getDefaultMaterial('wall');
				
				// 为墙体指定默认材质
				//RenderUtils.setMaterial(mySubMesh,RenderUtils.getDefaultMaterial('wall'));
				
				// 为Mesh或SubMesh指定材质 
				//RenderUtils.setMaterial(myMesh,'材质名');
					
				// 更新CubeReflection的渲染图
				MaterialLibrary.instance.updateCubeReflection(rm.lightManager.center);
				
				// 通过给定的房间的最大与最小值,更新灯光的分布及亮度 
				rm.updateLights(houseMax, houseMin);
			});
		}
		
		public function createRoom(lm:LightManager):void {
			var nz:Mesh = new Mesh(new CubeGeometry(3000,10,2000),new ColorMaterial());
			var pz:Mesh = new Mesh(new CubeGeometry(3000,10,2000),new ColorMaterial());
			var ny:Mesh = new Mesh(new CubeGeometry(3000,2000,10),new ColorMaterial());
			var py:Mesh = new Mesh(new CubeGeometry(3000,2000,10),new ColorMaterial());
			var nx:Mesh = new Mesh(new CubeGeometry(10,2000,2000),new ColorMaterial());
			var px:Mesh = new Mesh(new CubeGeometry(10,2000,2000),new ColorMaterial());
			
			var c1:Mesh = new Mesh(new CubeGeometry(400,400,550),new ColorMaterial());
			c1.x = -1300;
			c1.y = -800;
			c1.z = 800;
			
			var c2:Mesh = new Mesh(new CubeGeometry(400,400,550),new ColorMaterial());
			c2.x = -1000;
			c2.y = -800;
			c2.z = 0;
			
			var data:Vector.<Number> = nx.geometry.subGeometries[0].UVData;
			
			RenderUtils.setMaterial(px,'墙面8');
			RenderUtils.setMaterial(nx,'墙面8');
			RenderUtils.setMaterial(py,'墙面8');
			RenderUtils.setMaterial(ny,'墙面8');
			RenderUtils.setMaterial(pz,'天花板6');
			RenderUtils.setMaterial(nz,'地砖1');
			RenderUtils.setMaterial(c1,'27661D-PB古董白');
			RenderUtils.setMaterial(c2,'27661D-PB古董白');
			
			pz.y = 1000;
			nz.y = -1000;
			ny.z = -1000;
			py.z = 1000;
			ny.y = py.y = 0;
			px.x = -1500;
			nx.x = 1500;
			px.y = nx.y = 0;
			
			view.scene.addChild(px);
			view.scene.addChild(nx);
			view.scene.addChild(py);
			view.scene.addChild(ny);
			view.scene.addChild(pz);
			view.scene.addChild(nz);
			view.scene.addChild(c1);
			view.scene.addChild(c2);
		}
		
		private function getV(p:Point,y:Number = 0):Vector3D {
			return new Vector3D(p.x,y,p.y);
		}
		
		protected function loop(event:Event):void
		{
			cc.update();
			view.render();	
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			directionalLight = new DirectionalLight(0, -1, 0);
			directionalLight.castsShadows = true;
			directionalLight.color = 0xeedddd;
			directionalLight.diffuse = .5;
			directionalLight.ambient = .3;
			directionalLight.specular = 0.5;
			directionalLight.ambientColor = 0xffffff;
			
			view.scene.addChild(directionalLight);
			
			var pl:PointLight = new PointLight();
			pl.diffuse = .2;
			pl.ambient = 0;
			pl.specular = 0;
			pl.radius = 0;
			pl.fallOff = 125;
			//pl.castsShadows = true;
			pl.y = -30;
			view.scene.addChild(pl);
			
			
			lightPicker = new StaticLightPicker([directionalLight,pl]);
		}
	}
}