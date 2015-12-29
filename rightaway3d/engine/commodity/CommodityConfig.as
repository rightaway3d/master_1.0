package rightaway3d.engine.commodity
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	
	import rightaway3d.engine.core.Engine3D;
	import rightaway3d.engine.core.EngineController;
	import rightaway3d.engine.material.MaterialInfo;
	import rightaway3d.engine.model.MirrorInfo;
	import rightaway3d.engine.model.ModelLoader;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.skybox.SkyBoxLoader;
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.ui.button.ButtonBar;
	import rightaway3d.ui.panel.PanelShow3D;
	
	import ztc.ui.AlignMode;
	import ztc.ui.AnimateType;
	import ztc.ui.ShowButton;

	public class CommodityConfig
	{
		//public var commodity:Commodity;
		public var engineController:EngineController;
		
		private var productManager:ProductManager;
		
		private var panel:PanelShow3D;
		
		private var engine3d:Engine3D;
		
		private var defData:DefaultData;
		
		/**
		 * 是否显示简单版本，简单版本将不会显示外观按钮组，视角按钮组及功能点按钮组
		 */
		private var isSimple:Boolean;
		
		public function CommodityConfig(panel:PanelShow3D,engine3d:Engine3D)
		{
			this.panel = panel;
			this.engine3d = engine3d;
			
			defData = new DefaultData();
			
			productManager = ProductManager.own;
		}
		
		public function load(url:String,isSimple:Boolean):void
		{
			this.isSimple = isSimple;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onCommodityLoaded);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(new URLRequest(url));
		}
		
		protected function onCommodityLoaded(event:Event):void
		{
			//trace("------------------onCommodityLoaded");
			var urlLoader:URLLoader = event.currentTarget as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE,onCommodityLoaded);

			var xml:XML = new XML(urlLoader.data);
			
			//加载公司logo
			var companyLogo:String = xml.companyLogo;
			if(companyLogo)this.loadCompanyLogo(companyLogo);
			
			//加载产品logo
			var productLogo:String = xml.productLogo;
			if(productLogo)this.loadProductLogo(productLogo);
			
			var guide:String = xml.guide;
			if(guide)
			{
				panel.guideAlign = xml.guide.@align;
				panel.guideHorizontal = xml.guide.@horizontal;
				panel.guideVertical = xml.guide.@vertical;
				this.loadGuide(guide);
			}
			
			//读取初始化参数
			var initData:XML = xml.init[0];
			defData.update(initData);
			
			panel.animationPanelTextColor = defData.animationPanelTextColor;
			
			//设置3D场景背景颜色
			engine3d.setBackgroundColor(defData.backgroundColor);
			
			//设置3D场景灯光颜色
			//if(defData.lightColor>0)engine3d.setLightColor(defData.lightColor);
			
			//加载背景图片
			if(defData.backgroundImage)loadBackground(defData.backgroundImage);
			
			//加载天空盒图片
			if(defData.skyboxType == "color")
			{
				var te:Array = defData.skyboxTextures;
				engine3d.setColorSkyBox(te[0],te[1],te[2],te[3]?te[3]:8);
			}
			else if(defData.skyboxType == "image")
			{
				var loader:SkyBoxLoader = new SkyBoxLoader();
				loader.load(defData.skyboxTextures);
				loader.addEventListener("all_loaded",onSkyBoxAllLoaded);
			}
			
			//解析产品数据，加载产品模型
			var plist:XMLList = xml.scene.product;
			var len:int = plist.length();
			for(var i:int=0;i<len;i++)
			{
				var p:XML = plist[i];
				productManager.parseProductObject(p);				
			}
			productManager.loadProduct();
			
			//添加镜子
			if(xml.scene.mirror!=undefined)
			{
				var mlist:XMLList = xml.scene.mirror;
				len = mlist.length();
				var mrs:Vector.<MirrorInfo> = new Vector.<MirrorInfo>();
				
				for(i=0;i<len;i++)
				{
					var mr:MirrorInfo = new MirrorInfo(mlist[i]);
					mrs.push(mr);
				}
				
				engineController.addMirrors(mrs);
			}
			
			//侦听模型全部加载结束事件
			ModelLoader.own.addEventListener("all_model_loaded",onAllModelLoaded);
			
			setBooth();
			setGround();
			
			//engine3d.camCtrl.cc.minPanAngle = 80;
			//engine3d.camCtrl.cc.maxTiltAngle = 60;
			engine3d.camCtrl.cc.minTiltAngle = defData.minTilt;
			
			if(!isSimple)
			{
				//创建外观按钮组
				if(xml.outward!=undefined)
				{
					var outwardXML:XML = xml.outward[0];
					createButtonBar(outwardXML,"outward");
				}
				
				//创建视角按钮组
				if(xml.view!=undefined)
				{
					var viewXML:XML = xml.view[0];
					createButtonBar(viewXML,"view");
				}
				
				//创建功能点按钮组
				if(xml.point!=undefined)
				{
					var pointXML:XML = xml.point[0];
					createButtonBar(pointXML,"point");
					
					//创建返回按钮
					var btnData:XML = xml.returnBtn[0];
					var border:int = btnData.@border;			
					var btn:ShowButton = createButton(btnData.base[0],btnData.item[0]);
					panel.setReturnButton(btn,border,null);
				}
			}
			
			//更新视图
			panel.updateView(panel.stage.stageWidth,panel.stage.stageHeight);
		}
		
		
		protected function onSkyBoxAllLoaded(event:Event):void
		{
			var loader:SkyBoxLoader = event.currentTarget as SkyBoxLoader;
			var a:Array = loader.bitmaps;
			engine3d.setBitmapSkyBox(a[0],a[1],a[2],a[3],a[4],a[5]);
		}
		
		protected function onAllModelLoaded(event:Event):void
		{
			ModelLoader.own.removeEventListener("all_model_loaded",onAllModelLoaded);
			
			engine3d.camCtrl.tweenTo(defData.camPan,defData.camTilt,defData.camDistance,defData.camLookAtPoint);
			
			engine3d.camCtrl.autoRotation = defData.autoRotation;
			engine3d.camCtrl.autoRotationStep = defData.rotationStep;
		}
		
		//========================================================================================================
		private function loadBackground(url:String):void
		{
			//trace("loadBackground:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onBGLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onBGLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onBGLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			engine3d.setBackgroundImame(BMP.scaleBmpData(bmp.bitmapData));
			
			loaderInfo.loader.unload();
		}
		
		//========================================================================================================
		private function loadCompanyLogo(url:String):void
		{
			//trace("loadCompanyLogo:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompanyLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onCompanyLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onCompanyLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			bmp.smoothing = true;
			
			panel.setCompanyLogo(bmp,20);
			
			loaderInfo.loader.unload();
		}
		
		//========================================================================================================
		private function loadProductLogo(url:String):void
		{
			//trace("loadProductLogo:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onProductLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onProductLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onProductLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			bmp.smoothing = true;
			
			panel.setProductLogo(bmp,20);
			
			loaderInfo.loader.unload();
		}
		
		//========================================================================================================
		private function loadGuide(url:String):void
		{
			//trace("loadProductLogo:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onGuideLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onGuideLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onGuideLoaded);
			
			var o:DisplayObject = loaderInfo.content;
			if(o is Bitmap)Bitmap(o).smoothing = true;
			
			panel.setGuide(o);
			
			loaderInfo.loader.unload();
		}
		
		//========================================================================================================
		//设置圆柱形展台
		private function setBooth():void
		{
			if(!defData.boothRadius)return;
			
			var r:Number = defData.boothRadius;
			var n:int = r/2;
			if(n<16)n=16;
			
			var h:Number = defData.boothHeight;
			var mesh:Mesh = new Mesh(new CylinderGeometry(r,r,h,n));
			//var mesh:Mesh = new Mesh(new PlaneGeometry(r*2,r*2,1,1,true,false));
			//mesh.scale = new Vector3D(2,2,2);
			//mesh.scale(2);
			mesh.position = defData.boothPosition;
			mesh.y += h/2 + 1;
			//mesh.y = -200;
			
			var m:ColorMaterial = engine3d.createColorMaterial(defData.boothColor);
			
			engine3d.addRootChild(mesh);
			//m.addMethod(new EnvMapMethod(engine3d.getReflectionTexture(),1));
			var fresnelMethod : FresnelEnvMapMethod = new FresnelEnvMapMethod(engine3d.getCubeReflectionTexture2());
			fresnelMethod.normalReflectance = 1;
			fresnelMethod.fresnelPower = 2;
			m.addMethod(fresnelMethod);
			
			mesh.material = m;
		}
		
		private function setGround():void
		{
			var w:int = defData.groundLength;
			var h:int = defData.groundWidth;
			if(w<=0 || h<=0)return;
			
			var pg:PlaneGeometry = new PlaneGeometry(w,h,1,1,true,true);
			pg.scaleUV(defData.groundRepeatLength,defData.groundRepeatWidth);
			
			var mesh:Mesh = new Mesh(pg);
			mesh.position = defData.groundPosition;
			
			var mat:TextureMaterial = new TextureMaterial();
			mat.color = defData.groundColor;
			mat.repeat = true;
			mat.ambient = 0.5;
			//mat.gloss = 3;
			mat.specular = 0.1;
			
			//trace("-------------------"+defData.fogNear, defData.fogFar, defData.fogColor);
			if(defData.fogFar>0)mat.addMethod(new FogMethod(defData.fogNear, defData.fogFar, defData.fogColor));
			
			mesh.material = mat;
			
			engine3d.addChildMesh(mesh,null,true,false);
			//engine3d.addRootChild(mesh);
			
			if(defData.groundTextureURL)
			{
				new MaterialInfo(mat,defData.groundTextureURL,defData.groundNormalMapURL,defData.groundSpecularMapURL);
			}
		}
		
		//========================================================================================================
		private function createButtonBar(data:XML,name:String):void
		{
			var base:XML = data.base[0];
			var buttons:XML = data.buttons[0];
			
			var bar:ButtonBar = new ButtonBar();
			bar.name = name;
			bar.type = buttons.@type;
			bar.distance = buttons.@distance;
			
			if(buttons.@useArea!=undefined)
			{
				bar.useArea = buttons.@useArea;
				//trace("createButtonBar useArea:"+buttons.@useArea+" useAre:"+bar.useArea);
			}
			
			var align:AlignMode = AlignMode.getAlignMode(buttons.@align);
			bar.align = align?align:AlignMode.BOTTOM;
			
			bar.border = buttons.@border;
			bar.cornersRound = buttons.@cornersRound;
			
			panel.addButtonBar(bar);
			
			var items:XMLList = buttons.item;
			var len:int = items.length();
			for(var i:int=0;i<len;i++)
			{
				var item:XML = items[i];
				var btn:ShowButton = createButton(base,item);
				bar.addButton(btn);
			}
		}
		
		private function createButton(base:XML,item:XML):ShowButton
		{
//			var type:String = base.type;
			var w:int = base.btnWidth;
			var h:int = base.btnHeight;
			var iconSize:uint = base.iconSize;
			var r:int = base.roundWidth;
			var a:Number = base.alpha;
			var fontSize:int = base.fontSize;
			var fontColor:uint = base.fontColor;
			var aniType:String = base.animationType;
			var capAlign:String = base.captionAlign;
			var tipsAlign:String = base.tipsAlign;
			
			var icon:String = item.icon;
			var cap:String = item.caption;
			var tips:String = item.tips;
			var tipsDelay:int = base.tips.@delay;
			var action:XML = item.action[0];
			
			var normalType:String = base.normal.@type;
			var normalValue:String = base.normal;
			var overType:String = base.over.@type;
			var overValue:String = base.over;
			var selectType:String = base.select.@type;
			var selectValue:String = base.select;
			
			var btn:ShowButton = new ShowButton(w,h,cap,icon,tips);
			btn.data = action;
			
			btn.backgroundAlpha = a>0?a:defData.buttonAlpha;
			btn.fontSize = fontSize>0?fontSize:defData.fontSize;
			btn.fontColor = fontColor>0?fontColor:defData.fontColor;
			
			btn.normalMapFileName = normalType=="image"?normalValue:null;
			btn.hoverMapFileName = overType=="image"?overValue:null;
			btn.selectedMapFileName = selectType=="image"?selectValue:null;
			
			btn.normalColor = normalType=="color"?(uint(normalValue)>0?uint(normalValue):defData.buttonNormalColor):0;
			btn.hoverColor = overType=="color"?(uint(overValue)>0?uint(overValue):defData.buttonOverColor):0;
			btn.selectedColor = selectType=="color"?(uint(selectValue)>0?uint(selectValue):defData.buttonSelectColor):0;
			
			var ani:AnimateType = AnimateType.getAnimateType(aniType);
			btn.animateType = ani?ani:AnimateType.BACKGROUND_ALPHA;
			btn.roundAngleWidth = r;
			
			var align:AlignMode = AlignMode.getAlignMode(tipsAlign);
			btn.tooltipAlign = align?align:AlignMode.TOP;
			btn.tooltipDelay = tipsDelay;
			
			align = AlignMode.getAlignMode(capAlign);
			btn.textAlign = align?align:AlignMode.CENTER;
			
			btn.iconSize = iconSize;
			
			return btn;
		}
	}
}

import flash.geom.Vector3D;

class DefaultData
{
	public var lightColor:uint = 0;
	
	public var animationPanelTextColor:uint;
	public var backgroundColor:uint;
	public var backgroundImage:String;
	public var buttonNormalColor:uint;
	public var buttonOverColor:uint;
	public var buttonSelectColor:uint;
	public var buttonAlpha:Number;
	public var fontSize:int;
	public var fontColor:uint;
	
	public var camPan:Number;
	public var camTilt:Number;
	public var minTilt:Number;
	public var camDistance:int;
	public var camLookAtPoint:Vector3D;
	public var autoRotation:Boolean;
	public var rotationStep:Number = 0;
	
	public var skyboxType:String;
	public var skyboxTextures:Array;
	
	public var boothRadius:Number;
	public var boothHeight:Number;
	public var boothColor:uint;
	public var boothPosition:Vector3D;
	
	public var groundColor:uint;
	public var groundLength:int;
	public var groundWidth:int;
	public var groundPosition:Vector3D;
	public var groundRepeatLength:Number;
	public var groundRepeatWidth:Number;
	public var groundTextureURL:String;
	public var groundNormalMapURL:String;
	public var groundSpecularMapURL:String;
	
	public var fogColor:uint;
	public var fogNear:int;
	public var fogFar:int=0;
	
	public var lightInfo:*;
	
	public function update(xml:XML):void
	{
		this.backgroundImage = xml.backgroundImage?xml.backgroundImage:null;
		
		var theme:XML = xml.theme[0];
		
		this.animationPanelTextColor = theme.animationPanelTextColor!=undefined?theme.animationPanelTextColor:0xffffff;
		
		this.lightColor = theme.lightColor!=undefined?theme.lightColor:0;
		//trace("-----------lightColor:"+lightColor.toString(16));
		this.backgroundColor = theme.backgroundColor;
		this.buttonNormalColor = theme.buttonNormalColor;
		this.buttonOverColor = theme.buttonOverColor;
		this.buttonSelectColor = theme.buttonSelectColor;
		this.buttonAlpha = theme.buttonAlpha;
		this.fontSize = theme.fontSize;
		this.fontColor = theme.fontColor;
		
		var c:XML = xml.camera[0];
		this.camPan = c.pan;
		this.camTilt = c.tilt;
		this.minTilt = c.minTilt;
		this.camDistance = c.distance;
		
		var s:String = c.lookAt;
		var a:Array = s.split("|");
		this.camLookAtPoint = new Vector3D(a[0],a[1],a[2]);
		
		if(c.autoRotation != undefined)
		{
			s = c.autoRotation;
			this.autoRotation = s=="true"?true:false;
			if(autoRotation)
			{
				this.rotationStep = c.autoRotation.@step;
			}
		}
		
		if(xml.skybox!=undefined)
		{
			this.skyboxType = xml.skybox.@type;
			
			s = xml.skybox;
			this.skyboxTextures = s.split(",");
		}
		
		if(xml.booth!=undefined)
		{
			var b:XML = xml.booth[0];
			this.boothRadius = b.radius;
			this.boothHeight = b.height;
			this.boothColor = b.color;
			
			s = b.position;
			a = s.split("|");
			this.boothPosition = new Vector3D(a[0],a[1],a[2]);
		}
		
		if(xml.ground!=undefined)
		{
			var g:XML = xml.ground[0];
			
			s = g.size;
			a = s.split("x");
			this.groundLength = a[0];
			this.groundWidth = a[1];
			
			s = g.position;
			a = s.split("|");
			this.groundPosition = new Vector3D(a[0],a[1],a[2]);
			
			s = g.repeat;
			a = s.split("x");
			this.groundRepeatLength = a[0];
			this.groundRepeatWidth = a[1];
			
			this.groundTextureURL = g.texture?g.texture:null;
			this.groundNormalMapURL = g.normalMap?g.normalMap:null;
			this.groundSpecularMapURL = g.specularMap?g.specularMap:null;
			
			this.groundColor = g.color;
			
			if(g.fog!=undefined)
			{
				var f:XML = g.fog[0];
				this.fogColor = f.color;
				this.fogNear = f.near;
				this.fogFar = f.far;
			}
		}
	}
}



















































