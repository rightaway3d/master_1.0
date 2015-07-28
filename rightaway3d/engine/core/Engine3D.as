package rightaway3d.engine.core
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.RegularPolygonGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.ATFCubeTexture;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.CubeReflectionTexture;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.PlanarReflectionTexture;
	import away3d.utils.BitmapFilterEffects;
	
	import rightaway3d.engine.controller.CameraController;
	
	import ztc.meshbuilder.room.MaterialLibrary;
	import ztc.meshbuilder.room.RendingManager;

	public class Engine3D
	{
		
		private var container:DisplayObjectContainer;
		
		private var scene:Scene3D;
		private var root3d:ObjectContainer3D;
		
		public var view:View3D;
		public var camera:Camera3D;
		
		public var camCtrl:CameraController;
		
		public var sunLight:DirectionalLight;
		
		//public var lightPicker:StaticLightPicker;
		
		private var colorMat:ColorMaterial;
		
		private var skyBox:SkyBox;
		
		//public var pointLights:PointLights;
		//public var skyLight:PointLightBulb;
		
		private var cubeReflectionTexture:CubeReflectionTexture;
		//private var planarReflectionTexture:PlanarReflectionTexture;
		private var planarReflectionTextures:Vector.<PlanarReflectionTexture> = new Vector.<PlanarReflectionTexture>();
		
		private var rm:RendingManager;
		
		public function Engine3D(container:DisplayObjectContainer)
		{
			this.container = container;
			initStage3D();
		}
		
		private function initStage3D():void
		{
			view = new View3D();
			view.backgroundColor = container.stage.color;
			view.antiAlias = 16;//抗锯齿，可用值：2、4、16
			var lens:PerspectiveLens = new PerspectiveLens();
			lens.near = 1;//100;
			lens.far = 100000;
			lens.fieldOfView = 60;//45;
			
			view.camera.lens = lens;
			
			//view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
			view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			view.rightClickMenuEnabled = false;
			
			container.addChild(view);
			//container.addChild(new AwayStats(view));
			
			scene = view.scene;
			camera = view.camera;
			
			root3d = new ObjectContainer3D();
			root3d.name = "root";
			scene.addChild(root3d);
			
			camCtrl = new CameraController(container,camera);
			
			initLights();
			
			colorMat = createColorMaterial(0x808080);
			
			//setColorSkyBox(0x808080,0x808080,0x808080);
			rm = new RendingManager(view,"assets/resources/material.xml");
			
			startRender();
		}
		
		public function get lightPicker():StaticLightPicker
		{
			return rm.lightManager.lightPicker;
		}
		
		public function updateCubeReflection():void
		{
			trace("-----------updateCubeReflection");
//			var center:Vector3D = rm.lightManager.center.add(new Vector3D(0,0,0));
			//trace(rm.lightManager.center);
			if (rm.lightManager.center) {
				var kao:Vector3D = rm.lightManager.center.clone();
				kao.y -=300;
				MaterialLibrary.instance.updateCubeReflection(kao);
			} else {
				trace("center is null");
			}
		}
		
		public function updateLights(houseMax:Vector3D, houseMin:Vector3D):void
		{
			rm.updateLights(houseMax, houseMin);
		}
		
		public function getCubeReflectionTexture2():CubeReflectionTexture
		{
			if(!cubeReflectionTexture)
			{
				// create reflection texture with a dimension of 256x256x256
				cubeReflectionTexture = new CubeReflectionTexture(1024);
				cubeReflectionTexture.farPlaneDistance = 3000;
				cubeReflectionTexture.nearPlaneDistance = 1;
				//reflectionTexture.
				// center the reflection at (0, 100, 0) where our reflective object will be
				cubeReflectionTexture.position = new Vector3D(0, 13, 0);				
			}
			
			return cubeReflectionTexture;
		}
		
		public function getPlanarReflectionTexture2():PlanarReflectionTexture
		{
			var planarReflectionTexture:PlanarReflectionTexture = new PlanarReflectionTexture();
			planarReflectionTextures.push(planarReflectionTexture);
			
			return planarReflectionTexture;
		}
		
		public function getSkyBoxTexture():CubeTextureBase
		{
			if(skyBox)
			{
				return SkyBoxMaterial(skyBox.material).cubeMap;
			}
			
			return null;
		}
		
		public function setBitmapSkyBox(posX:BitmapData, negX:BitmapData, posY:BitmapData, negY:BitmapData, posZ:BitmapData, negZ:BitmapData):void
		{
			if(skyBox)this.scene.removeChild(skyBox);
			
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(posX, negX, posY, negY, posZ, negZ);
			
			skyBox = new SkyBox(cubeTexture);
			this.scene.addChild(skyBox);
		}
		
		public function setColorSkyBox(zenithColor:uint, horizonColor:uint, nadirColor:uint, quality:uint = 8):void
		{
			if(skyBox)this.scene.removeChild(skyBox);
			
			var cubeTexture:BitmapCubeTexture = BitmapFilterEffects.vectorSky(zenithColor, horizonColor, nadirColor, quality);
			
			skyBox = new SkyBox(cubeTexture);
			this.scene.addChild(skyBox);
		}
		
		public function setATFSkyBox(atfData:ByteArray):void
		{
			if(skyBox)this.scene.removeChild(skyBox);
			
			var skyMap:ATFCubeTexture = new ATFCubeTexture(atfData);
			
			skyBox = new SkyBox(skyMap);
			this.scene.addChild(skyBox);
		}
		
		public function startRender():void
		{
			container.stage.addEventListener(Event.ENTER_FRAME,onStageEnterFrame);			
		}
		
		public function stopRender():void
		{
			container.stage.removeEventListener(Event.ENTER_FRAME,onStageEnterFrame);
		}
		
		public function hideScene(hideBackground:Boolean):void
		{
			root3d.visible = false;
			stopRender();
			camCtrl.disable();
			view.visible = !hideBackground;
			view.render();
		}
		
		public function showScene():void
		{
			root3d.visible = true;
			startRender();
			camCtrl.enable();
			view.visible = true;
		}
		
		public function setLightColor(color:uint):void
		{
			sunLight.color = color;
			/*if(pointLights)
			{
				pointLights.lightBack.color = color;
				pointLights.lightTop.color = color;
				pointLights.lightFront.color = color;
			}*/
		}
		
		public function getSnapshot(w:int=0,h:int=0):BitmapData
		{
			var tw:int = view.width;
			var th:int = view.height;
			if(w>0 && h>0)
			{
				view.width = w;
				view.height = h;
			}
			
			var bmpData:BitmapData = new BitmapData(view.width,view.height);
			view.renderer.queueSnapshot(bmpData);
			view.render();
			
			view.width = tw;
			view.height = th;
			
			return bmpData;
		}
		
		//private var sunColor:uint = 0xAAAAA9;
		//private var sunColor:uint = 0xFFFFFF;
		//private var sunAmbient:Number = 0.4;
		//private var sunDiffuse:Number = 1;
		//private var sunSpecular:Number = 1;

		//private var skyColor:uint = 0xffffff;
		//private var skyAmbient:Number = 0.5;
		//private var skyDiffuse:Number = 0.5;
		//private var skySpecular:Number = 0.5;
		/*private var fogColor:uint = 0x333338;
		//private var fogColor:uint = 0x330000;
		private var zenithColor:uint = 0x445465;
		private var fogNear:Number = 1000;
		private var fogFar:Number = 10000;*/
		
		private function initLights():void
		{
			var a:Array = [];
			
			sunLight = new DirectionalLight(-1, -1, 1);
			sunLight.direction = new Vector3D(0, -1, 0);
			sunLight.color = 0x111111;
			sunLight.ambientColor = 0x111111;
			sunLight.diffuse = 0.1;
			sunLight.specular = 0.5;
			sunLight.ambient = 0.1;
			
			/*sunLight.shadowMapper = new NearDirectionalShadowMapper(0.2);
			sunLight.castsShadows = true;
			
			sunLight.lookAt(new Vector3D());*/

			scene.addChild(sunLight);
			
			a.push(sunLight);
			
			/*skyLight = new PointLightBulb(100,0xAAAAAA);
			skyLight.ambient = 1;
			skyLight.diffuse = 1;
			skyLight.specular = 0;
			
			skyLight.y = 2000;
			skyLight.fallOff = 10000;
			scene.addChild(skyLight);
			a.push(skyLight);
			
			pointLights ||= new PointLights();
			scene.addChild(pointLights);
			a.push(pointLights.lightFront,pointLights.lightTop,pointLights.lightBack,pointLights.lightBottom);
			*/
			//var a:Array = [sunLight];
			//lightPicker = new StaticLightPicker(a);
		}
		
		public function createColorMaterial(color:uint):ColorMaterial
		{
			var mat:ColorMaterial = new ColorMaterial(0);
			
			//mat.color = color;
			//mat.ambientColor = color;
			
			//mat.specular = 0.9;
			//mat.ambient = 0.9;
			//mat.ambient = 1;
			
			//mat.diffuseMethod = new BasicDiffuseMethod();
			//mat.lightPicker = lightPicker;
			
			//mat.smooth = true;
			//mat.bothSides = true;
			
			return mat;
		}
		
		public function setMeshColor(mesh:Mesh,color:uint):void
		{
			colorMat.color = color;
			mesh.material = colorMat;
		}
		
		public function setMeshsColor(meshs:Vector.<Mesh>,color:uint):void
		{
			colorMat.color = color;
			for each(var mesh:Mesh in meshs)
			{
				mesh.material = colorMat;
			}
		}
		
		public function addRootChild(obj:ObjectContainer3D):void
		{
			root3d.addChild(obj);
		}
		
		public function removeRootChild(obj:ObjectContainer3D):void
		{
			if(obj.parent==root3d)root3d.removeChild(obj);
		}
		
		public function enableScene():void
		{
			root3d.mouseChildren = true;
			root3d.mouseEnabled = true;
		}
		
		public function disableScene():void
		{
			root3d.mouseChildren = false;
			root3d.mouseEnabled = false;
		}
		
		public function addChildMeshs(meshs:Vector.<Mesh>,parent:ObjectContainer3D,aligns:Array,offset:Vector3D,bothSides:Boolean,bounds:Vector3D):void
		{
			//trace("Engine3D addChildMeshs:"+parent.name+" align:"+aligns+" bothSides:"+bothSides);
			
			moveCenter(meshs,aligns,offset,bounds);
			
			for each(var m:Mesh in meshs)
			{
				//trace("mesh:"+m.name);
				addChildMesh(m,parent,true,bothSides);
			}
		}
		
		/*private function turnGloblValue(v:Vector3D,obj:ObjectContainer3D):void
		{
			v.x += obj.x;
			v.y += obj.y;
			v.z += obj.z;
			if(obj.parent)
			{
				turnGloblValue(v,obj.parent);
			}
		}*/
		
		private function turnGloblValue(v:Vector3D,obj:ObjectContainer3D):void
		{
			var t:Vector3D = obj.transform.transformVector(v);
			
			v.x = t.x;
			v.y = t.y;
			v.z = t.z;
			if(obj.parent)
			{
				turnGloblValue(v,obj.parent);
			}
		}
		
		private function moveCenter(meshs:Vector.<Mesh>,aligns:Array,offset:Vector3D,bounds:Vector3D=null):void
		{
			//trace("moveCenter:"+meshs.length);
			var max:Vector3D = new Vector3D(-Infinity,-Infinity,-Infinity);
			var min:Vector3D = new Vector3D(Infinity,Infinity,Infinity);
			for each(var mesh:Mesh in meshs)
			{
				//trace("mesh:"+mesh.name,mesh.position);
				if(mesh.geometry is RegularPolygonGeometry)continue;
				//if(mesh.parent)continue;//作为其它mesh的子mesh时，略过
				
				//trace("mesh pos: "+mesh.x+" , "+mesh.y+" , "+mesh.z);
				var tmax:Vector3D = mesh.bounds.max.clone();
				var tmin:Vector3D = mesh.bounds.min.clone();
				
				//--------------------------------------------
				//使用矩阵变换来改变
				turnGloblValue(tmax,mesh);
				turnGloblValue(tmin,mesh);
				//tmax = mesh.transform.transformVector(tmax);
				//tmin = mesh.transform.transformVector(tmin);
				var t:Number;
				if(tmax.x<tmin.x)
				{
					t = tmax.x;
					tmax.x = tmin.x;
					tmin.x = t;
				}
				if(tmax.y<tmin.y)
				{
					t = tmax.y;
					tmax.y = tmin.y;
					tmin.y = t;
				}
				if(tmax.z<tmin.z)
				{
					t = tmax.z;
					tmax.z = tmin.z;
					tmin.z = t;
				}
				//--------------------------------------------
				
				//turnGloblValue(tmax,mesh);
				//turnGloblValue(tmin,mesh);
				
				if(tmax.x>max.x)max.x = tmax.x;
				if(tmax.y>max.y)max.y = tmax.y;
				if(tmax.z>max.z)max.z = tmax.z;
				
				if(tmin.x<min.x)min.x = tmin.x;
				if(tmin.y<min.y)min.y = tmin.y;
				if(tmin.z<min.z)min.z = tmin.z;
			}
			
			var dx0:Number = max.x - min.x;
			var dy0:Number = max.y - min.y;
			var dz0:Number = max.z - min.z;			
			//trace("bounds: "+dx0.toFixed(3)+","+dy0.toFixed(3)+","+dz0.toFixed(3));
			if(bounds)
			{
				bounds.x = dx0;
				bounds.y = dy0;
				bounds.z = dz0;
			}
			
			//var n:Number = dx + dy + dz;
			
			//camCtrl.cc.distance = n;
			//view.camera.lens.far = n*3;
			
			var x0:Number = (max.x+min.x)/2;
			var y0:Number = (max.y+min.y)/2;
			var z0:Number = (max.z+min.z)/2;
			
			var len:int = aligns.length;
			
			for(var i:int=0;i<len;i++)
			{
				var s:String = aligns[i];
				if(s==ModelAlign.TOP)
				{
					y0 = min.y + dy0;
				}
				else if(s==ModelAlign.BOTTOM)
				{
					y0 = min.y;
				}
				else if(s==ModelAlign.LEFT)
				{
					x0 = min.x;
				}
				else if(s==ModelAlign.RIGHT)
				{
					x0 = min.x + dx0;
				}
				else if(s==ModelAlign.FRONT)
				{
					z0 = min.z;
				}
				else if(s==ModelAlign.BACK)
				{
					z0 = min.z + dz0;
				}
			}
			
			x0 += offset.x;
			y0 += offset.y;
			z0 += offset.z;

			for each(mesh in meshs)
			{
				if(mesh.geometry is RegularPolygonGeometry)continue;
				
				if(!mesh.parent)
				{
					mesh.x -= x0;
					mesh.y -= y0;
					mesh.z -= z0;
				}
			}
		}
		
		public function addChildMesh(mesh:Mesh,parent:ObjectContainer3D=null,smooth:Boolean=true,bothSides:Boolean=true):void
		{
			if(!mesh.parent)
			{
				if(parent)parent.addChild(mesh);
				else
					root3d.addChild(mesh);
			}
			
			if(mesh.material)
			{
				//trace("mesh material:"+mesh.material);
				mesh.material.lightPicker = this.lightPicker;
				mesh.material.smooth = smooth;
				mesh.material.bothSides = bothSides;
			}
		}
		
		public function removeChildMeshs(meshs:Vector.<Mesh>,parent:ObjectContainer3D):void
		{
			for each(var m:Mesh in meshs)
			{
				removeChildMesh(m,parent);
			}
		}
		
		public function removeChildMesh(mesh:Mesh,parent:ObjectContainer3D):void
		{
			parent.removeChild(mesh);
		}
		
		public function setBackgroundColor(color:uint):void
		{
			view.backgroundColor = color;
		}
		
		public function setBackgroundImame(bmpData:BitmapData):void
		{
			view.background = new BitmapTexture(bmpData);
		}
		
		protected function onStageEnterFrame(event:Event):void
		{
			render();
		}
		
		public function render():void
		{
			camCtrl.update();
			
			//light.position = camera.position;
//			light.lookAt(new Vector3D());
			//skyLight.position = camera.position;
			
			if(cubeReflectionTexture)cubeReflectionTexture.render(view);
			//if(planarReflectionTexture)planarReflectionTexture.render(view);
			for each(var prt:* in planarReflectionTextures)
			{
				prt.render(view);
			}
			
			
			view.render();
		}
		
		public function setViewSize(w:int,h:int):void
		{
			view.width = w;
			view.height = h;
			render();
		}
		
		public function toJsonString():String
		{
			var s:String = "\"\"";
			return s;
		}
	}
}



















