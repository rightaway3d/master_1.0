package rightaway3d.test
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.VertexAnimator;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.bounds.BoundingSphere;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.SubMesh;
	import away3d.debug.AwayStats;
	import away3d.entities.JointObject;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.primitives.SphereGeometry;
	import away3d.sea3d.animation.MeshAnimation;
	import away3d.sea3d.animation.SkeletonAnimation;
	import away3d.sea3d.animation.VertexAnimation;
	import away3d.textures.BitmapTexture;
	import away3d.textures.CubeReflectionTextureTarget;
	import away3d.textures.PlanarReflectionTextureTarget;
	import away3d.tools.helpers.MeshHelper;
	import away3d.tools.utils.Bounds;
	import away3d.utils.Cast;
	
	import rightaway3d.engine.controller.CameraController;
	import rightaway3d.engine.light.PointLights;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationPlayer;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.modules.ActionModuleDebug;
	import sunag.sea3d.modules.HelperModule;
	import sunag.sea3d.modules.PhysicsModule;
	import sunag.sea3d.modules.RTTModule;
	import sunag.sea3d.modules.SoundModuleDebug;

	public final class ModelViewer extends EventDispatcher
	{
		[Embed(source="/../assets/background_light.jpg")]
		public static var BG:Class;
		
		private var container:DisplayObjectContainer;
		
		private var view:View3D;
		private var animPlayer:AnimationPlayer;
		private var seaConfig:DefaultConfig;
		private var sea3d:SEA3D;
		private var rttModule:RTTModule;
		private var root3d:ObjectContainer3D;
		
		public var product:ObjectContainer3D;
		
		public var camCtrl:CameraController;
		private var light:DirectionalLight;
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var lightPicker:StaticLightPicker;
		private var colorMat:ColorMaterial;
		
		private var meshs:Vector.<Mesh>;
		private var currMesh:Mesh;
		private var bmp:Bitmap;
		
		public function ModelViewer(container:DisplayObjectContainer,stats:Boolean=true)
		{
			this.container = container;
			initStage3D(stats);
		}
		
		private function initStage3D(stats:Boolean):void
		{
			view = new View3D(null,null,null,false,Context3DProfile.BASELINE_EXTENDED);
			container.addChildAt(view,0);
			
			view.backgroundColor = container.stage.color;
			view.background = Cast.bitmapTexture(BG);
			view.antiAlias = 4;
			
			view.camera.lens.near = 1;
			view.camera.lens.far = 20000;
			if(view.stage3DProxy)
			{
				view.stage3DProxy.stage3D.addEventListener(Event.CONTEXT3D_CREATE,onContext3DCreated);
			}
			else
			{
				container.addEventListener(Event.ENTER_FRAME,onCheckStage3D);
			}
			
			scene = view.scene;
			camera = view.camera;
			if(stats)container.addChild(new AwayStats(view));
			
			animPlayer = new AnimationPlayer();
			//animPlayer.play("root",-12,20);
		
			root3d = new ObjectContainer3D();
			scene.addChild(root3d);
			
			product = new ObjectContainer3D();
			root3d.addChild(product);
			
			seaConfig = new DefaultConfig();
			seaConfig.forceMorphCPU = false;
			//seaConfig.player = animPlayer;
			//seaConfig.container = root3d;
			
			sea3d = new SEA3D(seaConfig);
			sea3d.addModule(new SoundModuleDebug());
			sea3d.addModule(new HelperModule());			
			sea3d.addModule(rttModule = new RTTModule());
			sea3d.addModule(new ActionModuleDebug(view));
			
			//sea3d.addModule(new PhysicsModule(physicsWorld));
			
			sea3d.addEventListener(SEAEvent.COMPLETE,onSeaComplete);
			
			camCtrl = new CameraController(view.stage,camera);
			
			initLights();
			createColorMaterial();
			
			//createSphere();
			//test();
		}
		
		protected function onCheckStage3D(event:Event):void
		{
			if(view.stage3DProxy)
			{
				view.stage3DProxy.stage3D.addEventListener(Event.CONTEXT3D_CREATE,onContext3DCreated);
				container.removeEventListener(Event.ENTER_FRAME,onCheckStage3D);
			}
		}
		
		protected function onContext3DCreated(event:Event):void
		{
			//trace("onContext3DCreated");
			this.dispatchEvent(event);
		}
		
		public function createSphere():TextureMaterial
		{
			view.camera.lens.far = 40000;
			camCtrl.cc.minTiltAngle = -20;
			camCtrl.cc.maxTiltAngle = 20;
			
			var mat:TextureMaterial = new TextureMaterial();
			var mesh:Mesh = new Mesh(new SphereGeometry(10000,64,64,true),mat);
			//new MaterialInfo(mat,name);
			//mat.lightPicker = lightPicker;
			//mat.bothSides = true;
			MeshHelper.invertFaces(mesh,true);
			root3d.addChild(mesh);
			
			return mat;
		}
		
		/*public function createSphere3(name:String="09.jpg"):void
		{
			view.camera.lens.far = 40000;
			camCtrl.cc.minTiltAngle = -80;
			camCtrl.cc.maxTiltAngle = 20;
			
			var mat:TextureMaterial = new TextureMaterial();
			var mesh:Mesh = new Mesh(new SphereGeometry(10000,64,64,true),mat);
			new MaterialInfo(mat,name);
			//mat.lightPicker = lightPicker;
			//mat.bothSides = true;
			MeshHelper.invertFaces(mesh,true);
			root3d.addChild(mesh);
		}*/
		
		/*public function createSphere2(bmpData:BitmapData):void
		{
			trace("createSphere2:"+bmpData.width,bmpData.height);
			view.camera.lens.far = 40000;
			camCtrl.cc.minTiltAngle = -80;
			camCtrl.cc.maxTiltAngle = 40;
			
			var mat:TextureMaterial = new TextureMaterial(new BitmapTexture(bmpData));
			var mesh:Mesh = new Mesh(new SphereGeometry(10000,64,64,true),mat);
			//new MaterialInfo(mat,name);
			//mat.lightPicker = lightPicker;
			//mat.bothSides = true;
			MeshHelper.invertFaces(mesh,true);
			root3d.addChild(mesh);
		}*/
		
		/*private function test():void
		{
			trace("5,-400:"+CameraController.getNearestDegree(5,-400));
			trace("-500,400:"+CameraController.getNearestDegree(-500,400));
			trace("400,-5:"+CameraController.getNearestDegree(400,-5));
			trace("-5,400:"+CameraController.getNearestDegree(-5,400));
			trace("-400,5:"+CameraController.getNearestDegree(-400,5));
			trace("300,50:"+CameraController.getNearestDegree(300,50));
			trace("50,300:"+CameraController.getNearestDegree(50,300));
			trace("-350,350:"+CameraController.getNearestDegree(-350,350));
		}*/
		
		private function initLights():void
		{
			light = new DirectionalLight();
			light.direction = new Vector3D(0, -1, 0);
			light.castsShadows = false;
			//light.color = 0xeedddd;
			light.color = 0xffffff;
			light.diffuse = .5;
			light.ambient = .5;
			light.specular = 0.5;
			//light.ambientColor = 0x808090;
			light.ambientColor = 0xffffff;
			
			scene.addChild(light);
			
			var a:Array = [];
			a.push(light);
			
			var defaultLights:PointLights = new PointLights();
			a.push(defaultLights.lightFront,defaultLights.lightTop,defaultLights.lightBack,defaultLights.lightBottom);
			
			lightPicker = new StaticLightPicker(a);
		}

		
		
		private function showMaterial2():void
		{
			var mat:MaterialBase = sea3d.getMaterial("jeep_body");//kuang_mat
			//trace("mat:"+mat);
			if(mat is TextureMaterial)
			{
				TextureMaterial(mat).color = 0xffffff;
			}
			if(mat is ColorMaterial)
			{
				ColorMaterial(mat).color = 0xff0000;
			}
			//var tm:TextureMaterial = mat as TextureMaterial;
			//if(tm)showMaterial(tm);
		}
		
		private function addEvent(meshs:Vector.<Mesh>):void
		{
			for each(var mesh:Mesh in meshs)
			{
				mesh.mouseChildren = mesh.mouseEnabled = true;
				mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMesMouseDown);
			}			
		}
		
		protected function onMesMouseDown(event:MouseEvent3D):void
		{
			
			var mesh:Mesh = event.object as Mesh;
			if(mesh!=currMesh)
			{
				if(currMesh)currMesh.showBounds = false;
				mesh.showBounds = true;
				currMesh = mesh;
				//trace("currMesh:"+mesh.name);
				//trace("material:"+mesh.material);
				
				if(mesh.material is ColorMaterial)
				{
					tm = null;
					var sms:Vector.<SubMesh> = mesh.subMeshes;
					for each(var sm:SubMesh in sms)
					{
						//trace("submesh:"+sm);
						//trace("sm material:"+sm.material);
						if(sm.material is TextureMaterial)
						{
							tm = sm.material as TextureMaterial;
							break;
						}
					}
					if(tm)
					{
						showMaterial(tm);
					}
					else
					{
						var cm:ColorMaterial = mesh.material as ColorMaterial;
						cm.color = Math.random() * 0xffffff;
						//trace("cm.alpha:"+cm.alpha);
						//trace("cm.normalMap:"+cm.normalMap);
						//trace("cm.specularMap:"+cm.specularMap);						
					}					
				}
				else if(mesh.material is TextureMaterial)
				{
					var tm:TextureMaterial = mesh.material as TextureMaterial;
					showMaterial(tm);
				}
			}
			else
			{
				mesh.showBounds = false;
				currMesh = null;
				if(bmp && bmp.stage)this.container.removeChild(bmp);
			}
		}
		
		private function showMaterial(tm:TextureMaterial):void
		{
			//trace("texture:"+tm.texture);
			//trace("ambientTexture:"+tm.ambientTexture);
			//trace("normalMap:"+tm.normalMap);
			//trace("specularMap:"+tm.specularMap);
			if(tm.texture is BitmapTexture)
			{
				var bt:BitmapTexture = tm.texture as BitmapTexture;
				bmp ||= new Bitmap();
				bmp.bitmapData = bt.bitmapData;
				if(!bmp.stage)this.container.addChild(bmp);
			}
		}
		
		private function turnGloblValue(v:Vector3D,obj:ObjectContainer3D):void
		{
			v.x += obj.x;
			v.y += obj.y;
			v.z += obj.z;
			if(obj.parent)
			{
				turnGloblValue(v,obj.parent);
			}
		}
		
		public var size:Vector3D = new Vector3D();
		
		private function moveCenter(meshs:Vector.<Mesh>):void
		{
			var max:Vector3D = new Vector3D(-Infinity,-Infinity,-Infinity);
			var min:Vector3D = new Vector3D(Infinity,Infinity,Infinity);
			for each(var mesh:Mesh in meshs)
			{
				/*trace("mesh:"+mesh.name);
				trace("mesh pos: "+mesh.x+" , "+mesh.y+" , "+mesh.z);
				trace("mesh material:"+mesh.material);*/
				/*var sms:Vector.<SubMesh> = mesh.subMeshes;
				for each(var sm:SubMesh in sms)
				{
					trace("submesh:"+sm);
					trace("sm material:"+sm.material);
				}*/
				var tmax:Vector3D = mesh.bounds.max.clone();
				var tmin:Vector3D = mesh.bounds.min.clone();
				/*tmax.x += mesh.x;
				tmax.y += mesh.y;
				tmax.z += mesh.z;*/
				turnGloblValue(tmax,mesh);
				
				/*tmin.x += mesh.x;
				tmin.y += mesh.y;
				tmin.z += mesh.z;*/
				turnGloblValue(tmin,mesh);
				
				if(tmax.x>max.x)max.x = tmax.x;
				if(tmax.y>max.y)max.y = tmax.y;
				if(tmax.z>max.z)max.z = tmax.z;
				
				if(tmin.x<min.x)min.x = tmin.x;
				if(tmin.y<min.y)min.y = tmin.y;
				if(tmin.z<min.z)min.z = tmin.z;
			}
			
			var dx:Number = max.x - min.x;
			var dy:Number = max.y - min.y;
			var dz:Number = max.z - min.z;
			
			size.x = dx;
			size.y = dy;
			size.z = dz;
			
			//trace("bounds: "+fixNumber(dx,4)+","+fixNumber(dy,4)+","+fixNumber(dz,4));
			trace("<dimensions>"+fixNumber(dx,4)+","+fixNumber(dy,4)+","+fixNumber(dz,4)+"</dimensions>")
			
			var n:Number = dx + dy + dz;
			//n = 1000;
			camCtrl.cc.distance = n;
			view.camera.lens.far = n*3;
			
			var x0:Number = (max.x+min.x)/2;
			var y0:Number = (max.y+min.y)/2;
			var z0:Number = (max.z+min.z)/2;
			//trace("center: "+x0+" , "+y0+" , "+z0);
			
			var b:Boolean = false;
			for each(mesh in meshs)
			{
				if(!mesh.parent)
				{
					mesh.x -= x0;
					mesh.y -= y0;
					mesh.z -= z0;
				}
			}
		}
		
		private function fixNumber(n:Number,fix:int):String
		{
			var p:int = Math.pow(10,fix);
			var i:int = n * p;
			n = i/p;
			return String(n);
		}
		
		/*private function setLight(meshs:Vector.<Mesh>):void
		{
			for each(var mesh:Mesh in meshs)
			{
				if(mesh.material)mesh.material.lightPicker = this.lightPicker;
			}
		}*/
		
		private function createColorMaterial():void
		{
			colorMat = new ColorMaterial(0x00ff00);
			
			colorMat.specular = 0.9;
			colorMat.ambient = 0.9;
			colorMat.ambientColor = 0x555555;
			//colorMat.ambientColor = 0xffffff;
			colorMat.ambient = 1;
			colorMat.diffuseMethod = new BasicDiffuseMethod();
			colorMat.lightPicker = lightPicker;
			
			colorMat.smooth = true;
			colorMat.bothSides = true;
		}
		
		protected function renderReflections():void
		{
			for each(var cube:CubeReflectionTextureTarget in rttModule.cubeReflections)			
			{
				cube.backgroundColor = view.backgroundColor;
				cube.render(view);	
			}
			
			for each(var planar:PlanarReflectionTextureTarget in rttModule.planarReflections)			
			{
				planar.backgroundColor = view.backgroundColor;
				planar.render(view);			
			}
		}
		
		protected function onSeaComplete(event:SEAEvent):void
		{
			//trace("onSeaComplete");
			
			var mts:Vector.<MaterialBase> = sea3d.materials;
			for each(var mt:MaterialBase in mts)
			{
				mt.smooth = true;
				mt.bothSides = true;
				mt.lightPicker = lightPicker;
				//TextureMaterial(mt).
				if(mt.name=="Tesla_Model_S_2014_windows")
				{
				//trace(mt.name);
					TextureMaterial(mt).alpha = 0.8;
					TextureMaterial(mt).specular = 1;
				}
			}
			
			/*var cs:Vector.<CubeReflectionTextureTarget> = rttModule.cubeReflections;
			for each(var cr:CubeReflectionTextureTarget in cs)
			{
				cr.render(view);
			}*/
			meshs = sea3d.meshes;
			/*meshs = new Vector.<Mesh>(sea3D.meshes.length);
			var meshDict:Dictionary = new Dictionary();
			for(var i:int=0;i<meshs.length;i++)
			{
				//trace("animator0:"+sea3D.meshes[i].animator);
				var m1:Mesh = sea3D.meshes[i];
				var m2:Mesh = m1.clone() as Mesh;
				meshs[i] = m2;
				root3d.addChild(m2);
				meshDict[m1] = m2;
			}*/
			//root3d.addChildren(meshs);
			moveCenter(meshs);
			
			var b:Boolean = false;
			for each(var m:Mesh in meshs)
			{
				//var s:String = m.name;
				//if(s!="Tesla_Model_S_2014_trunk_lid_detail_2" && s!="Tesla_Model_S_2014_trunk_lid_detail_4")
				if(!m.parent)
					product.addChild(m);
			}
			//trace("object3d:"+sea3d.objects3d);
			//moveCenter(sea3d.objects3d);
			//setLight(meshs);
			
			//setMaterial(meshs);
			//addEvent(meshs);
			
			for each(var mesh:Mesh in sea3d.vertexAnimations)
			{
				var va:VertexAnimator = mesh.animator as VertexAnimator;
				
				va.play(VertexAnimationSet(va.animationSet).animations[0].name);
				
				/*if (VertexAnimationSet(va.animationSet).animations.length > maxAnmSet)
					maxAnmSet = VertexAnimationSet(va.animationSet).animations.length;*/
			}
			
			for each(mesh in sea3d.skeletonAnimations)
			{
				var skl:SkeletonAnimator = mesh.animator as SkeletonAnimator;
				
				skl.play(SkeletonAnimationSet(skl.animationSet).animations[0].name);
				
				/*if (SkeletonAnimationSet(skl.animationSet).animations.length > maxAnmSet)
					maxAnmSet = SkeletonAnimationSet(skl.animationSet).animations.length;*/
			}
			
			for each(var jointObject:JointObject in sea3d.jointObjects)
			{
				jointObject.autoUpdate = true;
			}
			
			//trace("animations:"+sea3d.animations);
			/*if(sea3d.animations && sea3d.animations.length>0)
			{
				//var anms:Vector.<Animation> = new Vector.<Animation>();
				for each(var ani:Animation in sea3d.animations)
				{
					if(ani is MeshAnimation)
					{*/
						/*var manm:MeshAnimation = ani as MeshAnimation;
						var m:Mesh = meshDict[manm.mesh];
						var anm:MeshAnimation = new MeshAnimation(manm.animationSet,m);
						anm.name = manm.name;
						
						anm.autoUpdate = manm.autoUpdate;
						anm.blendMethod = manm.blendMethod;
						
						anm.relative = manm.relative;
						
						animPlayer.addAnimation(anm);
						trace("anm:"+anm);*/
						
						/*animPlayer.addAnimation(ani);
						
					}
					//animPlayer.addAnimation(ani);
				}
				animPlayer.play("root",0);
				trace("time:"+animPlayer.time);
				trace("duration:"+animPlayer.duration);
				trace("position:"+animPlayer.position);
				trace("timeScale:"+animPlayer.timeScale);
			}*/
			
			//playSequence(0);
			
			renderReflections();
			//flash.utils.setTimeout(showMaterial2,2000);
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/*private function playSequence(value:int):void
		{			
			var duration:uint = 0;
			
			for each(var anm:Animation in sea3d.animations)
			{
				if (anm is SkeletonAnimation)
				{
					var skl:SkeletonAnimator = SkeletonAnimation(anm).animator;		
					
					if (value < SkeletonAnimationSet(skl.animationSet).animations.length)
					{						
						var sklNode:SkeletonClipNode = SkeletonAnimationSet(skl.animationSet).animations[value] as SkeletonClipNode;
						
						anm.play(sklNode.name, .3);
						//skl.play(sklNode.name, new CrossfadeTransition(.3));
						
						if (!sklNode.looping) 
							skl.reset(sklNode.name);
						
						if (duration < sklNode.totalDuration)
							duration = sklNode.totalDuration;
					}
				}
				else if (anm is VertexAnimation)
				{
					var va:VertexAnimator = VertexAnimation(anm).animator;	
					
					if (value < VertexAnimationSet(va.animationSet).animations.length)
					{
						var vaNode:VertexClipNode = VertexAnimationSet(va.animationSet).animations[value] as VertexClipNode;
						
						anm.play(vaNode.name, .3);
						//va.play(vaNode.name, new CrossfadeTransition(.3));
						
						if (!vaNode.looping) 
							skl.reset(vaNode.name);
						
						if (duration < vaNode.totalDuration)
							duration = vaNode.totalDuration;
					}
				}
				else if (value < anm.animations.length)		
				{
					anm.play( anm.animations[value].name, .3 );
					
					if (!anm.getNodeByName(anm.animations[value].name).repeat)
					{
						anm.reset( anm.animations[value].name );
					}
					
					if (duration < anm.animations[value].duration)
						duration = anm.animations[value].duration;
				}
			}
		}*/
		
		/*if (duration > 0)
		{
		player.duration = duration;
		AnimationPlayer(player.target).sunag::_duration = duration;
		}*/
		
		/*private function getAnimationDuration(animations:Vector.<Animation>,value:int=0):void
		{			
			var duration:uint = 0;
			
			for each(var anm:Animation in animations)
			{
				if (anm is SkeletonAnimation)
				{					
					var skl:SkeletonAnimator = SkeletonAnimation(anm).animator;					
					if (value < SkeletonAnimationSet(skl.animationSet).animations.length)
					{						
						var sklNode:SkeletonClipNode = SkeletonAnimationSet(skl.animationSet).animations[value] as SkeletonClipNode;
						
						//anm.play(sklNode.name, .3);
						//skl.play(sklNode.name, new CrossfadeTransition(.3));
						
						//if (!sklNode.looping) 
						//skl.reset(sklNode.name);
						
						if (duration < sklNode.totalDuration)
							duration = sklNode.totalDuration;
					}
				}
				else if (anm is VertexAnimation)
				{
					var va:VertexAnimator = VertexAnimation(anm).animator;	
					
					if (value < VertexAnimationSet(va.animationSet).animations.length)
					{
						var vaNode:VertexClipNode = VertexAnimationSet(va.animationSet).animations[value] as VertexClipNode;
						
						//anm.play(vaNode.name, .3);
						//va.play(vaNode.name, new CrossfadeTransition(.3));
						
						//if (!vaNode.looping) 
						//skl.reset(vaNode.name);
						
						if (duration < vaNode.totalDuration)
							duration = vaNode.totalDuration;
					}
				}
				else if (value < anm.animations.length)		
				{
					
					if (duration < anm.animations[value].duration)
						duration = anm.animations[value].duration;
				}
			}
			
			//trace("duration:"+duration);
		}*/
		
		private function setMaterial(meshs:Vector.<Mesh>):void
		{
			colorMat.color = Math.random()*0xFFFFFF;
			for each(var mesh:Mesh in meshs)
			{
				mesh.material = colorMat;
			}
		}
		
		public var isTextFile:Boolean = false;
		
		public function loadModel(fileName:String,type:String,baseURL:String):void
		{
			var url:String = baseURL + "\\" + fileName;
			trace("");
			trace("");
			//trace("loadModel:"+url);
			trace("file:"+fileName);
			trace("");
			if(type=="sea")
			{
				sea3d.dispose();
				//sea3d.load(new URLRequest(url),true);
				//camCtrl.reset();
				load(url);
			}
			
			isTextFile = (type=="dae")?true:false;
				
		}
		
		private function load(url):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onModelLoaded);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest(url));
		}
		
		private function onModelLoaded(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE,onModelLoaded);
			//trace("bytesize:"+loader.data.length);
			trace("<byteSize>"+loader.data.length+"</byteSize>")
			sea3d.loadBytes(loader.data);
		}
		
		public function get data():ByteArray
		{
			return sea3d.data;
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
		
		public function update():void
		{
			camCtrl.update();
			
			light.position = camera.position;
			light.lookAt(new Vector3D());
			//light.direction = new Vector3D(Math.sin(getTimer()/10000)*150000, 1000, Math.cos(getTimer()/10000)*150000);
			
			if(sea3d)renderReflections();
			view.render();
		}
		
		public function setViewSize(w:int,h:int):void
		{
			view.width = w;
			view.height = h;
		}
	}
}



















