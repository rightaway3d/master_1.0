package ztc.meshbuilder.room
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	import away3d.containers.View3D;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.CubeReflectionTexture;
	
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * 材质库
	 */
	public class MaterialLibrary extends EventDispatcher
	{
		// 基本路径
		public var baseUrl:String = "";
		
		public static var instance:MaterialLibrary = null;
		
		private var xml:XML;
		
		public var defaultValue:Object;
		public var cubeMaps:Object;
		public var materials:Object;
		
		private var cubeMapsCount:uint = 0;
		private var materialsCount:uint = 0;
		private var cmc:uint = 0;
		private var mc:uint = 0;
		
		public var xmlLoaded:Boolean = false;
		
		// 实时反射CubeReflectionTexture
		public var crt:CubeReflectionTexture;
		public var view:View3D;
		public var lightManager:LightManager;
		
		public var evt:Event = new Event(Event.COMPLETE);
		
		private var realList:Vector.<TextureMaterial> = new Vector.<TextureMaterial>();
		
		//public function MaterialLibrary(xmlUrl:String,view:View3D, lightManager:LightManager = null,cubeRelfectionTextureSize = 512)
		public function MaterialLibrary(view:View3D, lightManager:LightManager = null,cubeRelfectionTextureSize = 512)
		{
			instance = this;
//			RenderUtils.loadXML(xmlUrl,analyseXML);
			
			defaultValue = new Object();
			cubeMaps = new Object();
			materials = new Object();
			
			this.lightManager = lightManager;
			
			this.view = view;
			crt = new CubeReflectionTexture(cubeRelfectionTextureSize);
		}
		
		public function loadLibrary(xmlUrl:String):void
		{
			RenderUtils.loadXML(xmlUrl,analyseXML);
			realList.length = 0;
		}
		
		/**
		 * 分析XML
		 */
		private function analyseXML(xml:XML):void {
			baseUrl = xml.baseUrl;
			if (baseUrl.lastIndexOf('/') != baseUrl.length - 1) {
				baseUrl += '/';
			}
			
			this.xml = xml;
			
			// default value
			defaultValue['color'] = xml.defaultValue.color;
			defaultValue['specular'] = xml.defaultValue.specular;
			defaultValue['gloss'] = xml.defaultValue.gloss;
			defaultValue['repeat'] = xml.defaultValue.repeat;
			defaultValue['fresnel'] = xml.defaulteValue.fresnel;
			defaultValue['fresnelPower'] = xml.defaultValue.fresnelPower;
			defaultValue['reflection'] = xml.defaultValue.reflection;
			
			// 将CubeMaps对就的XML内容记录在CubeMaps上
			var cms:XMLList = xml.cubeMaps.children();
			for each(var c:XML in cms) {
				cubeMaps[c.@name + '_xml'] = c;
			}
			
			// 把Mateiral对应的XML内容记录在Materials上
			var mats:XMLList = xml.materials.children();
			for each(var x:XML in mats) {
				materials[x.@name + '_xml'] = x;
			}
			
			// 材质库数据已经载入完成
			xmlLoaded = true;
			trace("----MaterialLibraryLoadComplete----");
			
			// 触发载入完成事件
			dispatchEvent(evt);
		}
		
		/**
		 * 创建Bitmap Cube Texture
		 */
		private function createCubeMap(xml:XML,complete:Function = null):void {
			var loadedCnt:uint = 0;
			
			for each( var n:XML in xml.children()) {
				// 闭包
				(function(n:XML):void {
					RenderUtils.loadTexture(this.baseUrl + n,function(bmptex:BitmapTexture):void {
						cubeMaps[xml.@name + '_' + n.name()] = bmptex.bitmapData;
						loadedCnt ++;
						
						// 6张图片都下载完成
						if (loadedCnt == 6) {
							// bitmap cube texture
							cubeMaps[xml.@name] = new BitmapCubeTexture(
								cubeMaps[xml.@name + '_px'],
								cubeMaps[xml.@name + '_nx'],
								cubeMaps[xml.@name + '_py'],
								cubeMaps[xml.@name + '_ny'],
								cubeMaps[xml.@name + '_pz'],
								cubeMaps[xml.@name + '_nz']
							);
							
							// 调用回调方法
							complete(cubeMaps[xml.@name]);
						}
					});
				})(n);
			}
		}
		
		public function getMaterialPrice(name:String):Number
		{
			// 得到此材质对应的XML数据
			//var xml:XML = XML(materials[name + '_xml']);
			
			// 如果输入的材质不在材质库之内
			/*if (xml == '') {
				trace('MaterialLibrary ERROR: 输入的材质( '+name+' )不在材质库之内');
				return 0;
			}
			
			var price:Number = 31;
			if(xml.price!=undefined)
			{
				price = xml.price;
			}*/
			var s:String = getMaterialAttribute(name,"price");
			if(isNaN(Number(s)))return 0;
			return Number(s);
		}
		
		public function getMaterialAttribute(name:String,att:String):String
		{
			// 得到此材质对应的XML数据
			var xml:XML = XML(materials[name + '_xml']);
			var s:String = "";
			
			// 如果输入的材质不在材质库之内
			if (xml == '') {
				trace('MaterialLibrary ERROR: 输入的材质( '+name+' )不在材质库之内');
				return s;
			}
			
			if(xml[att]!=undefined)
			{
				s = xml[att];
			}
			return s;
		}
		
		/**
		 * 创建普通材质
		 */
		public function getMaterialData(name:String):Object
		{
			// 先从materials上得到此材质
			var mat:TextureMaterial = materials[name];
			
			// 得到此材质对应的XML数据
			var xml:XML = XML(materials[name + '_xml']);
			
			// 如果输入的材质不在材质库之内
			if (xml == '') {
				trace('MaterialLibrary ERROR: 输入的材质( '+name+' )不在材质库之内');
				return null;
			}
			
			var scaleU:String = xml.scaleU == '' ? this.xml.defaultValue.scaleU : xml.scaleU;
			var scaleV:String = xml.scaleV == '' ? this.xml.defaultValue.scaleV : xml.scaleV;
			
			//trace('1u: ' + scaleU + ' 1v: ' + scaleV);
			
			// 先判断此材质是否已经创建,如果为null,则创建些材质
			if (mat == null) {
				// 创建材质
				mat = new TextureMaterial();
				mat.mipmap = false;
				
				if(lightManager != null) {
					//mat.shadowMethod = new HardShadowMapMethod(lightManager.ceilingLight);
					mat.lightPicker = lightManager.lightPicker;
				}
				
				// 将创建好的材质存入materials里面 
				materials[name] = mat;
				
				// 设置些材质的属性
				mat.color = xml.color == '' ? this.xml.defaultValue.color : xml.color;
				mat.specular = xml.specular == '' ? this.xml.defaultValue.specular : xml.specular;
				mat.gloss = xml.gloss == '' ? this.xml.defaultValue.gloss : xml.gloss;
				mat.repeat = xml.repeat == '' ? this.xml.defaultValue.repeat : xml.repeat;
				//mat.alpha = 0.5;
				
				mat.ambient = (xml.ambient == '' || xml.ambient == undefined) ? this.xml.defaultValue.ambient : xml.ambient;
				
				var reflection:String = xml.reflection == '' ? this.xml.defaultValue.reflection : xml.reflection;	
				var fresnel:String = xml.fresnel == '' ? this.xml.defaultValue.fresnel : xml.fresnel;	
				var cubeMap:String = xml.cubeMap;
				
				// textures
				var diffuseMapUrl:String = xml.diffuseMap;
				var specularMapUrl:String = xml.specularMap;
				var normalMapUrl:String = xml.normalMap;
				
				if (diffuseMapUrl != '') {
					RenderUtils.loadTexture(baseUrl + diffuseMapUrl,function(tex:BitmapTexture):void {
						mat.texture = tex;
					});
				}
				
				if (specularMapUrl != '') {
					RenderUtils.loadTexture(baseUrl + specularMapUrl,function(tex:BitmapTexture):void {
						mat.specularMap = tex;
					});
				}
				
				if (normalMapUrl != '') {
					RenderUtils.loadTexture(baseUrl + normalMapUrl,function(tex:BitmapTexture):void {
						mat.normalMap = tex;
					});
				}
				
				
				
				// 如果有CubMap
				if (cubeMap != '') {
					// 假反射
					if (cubeMap != 'real') {
						// 先从 CubeMaps 上得到此CubeMap
						var cm:BitmapCubeTexture = cubeMaps[name];
						
						// 如果还未创建此CubeMap
						if (cm == null) {
							var cmXML:XML = cubeMaps[cubeMap + '_xml'];
							createCubeMap(cmXML,function(cubeTex:BitmapCubeTexture):void {
//								if (fresnel == 'true') {
//									var method:FresnelEnvMapMethod = new FresnelEnvMapMethod(cubeTex,Number(reflection));
//									method.fresnelPower = defaultValue['fresnelPower'];
//									mat.addMethod(method);	
//								} else if (fresnel == 'false') {
//									mat.addMethod(new EnvMapMethod(cubeTex,Number(reflection)));
//								}
								
								addCubeMethod(cubeMap,cubeTex,(fresnel == 'true'), mat,Number(reflection));
							});
						} else {
							addCubeMethod(cubeMap,cm,(fresnel == 'true'), mat,Number(reflection));
						}
					} else {
						var cr:CubeReflectionTexture = cubeMaps[name];
//						if (fresnel == 'true') {
//							var method:FresnelEnvMapMethod = new FresnelEnvMapMethod(crt,Number(reflection));
//							method.fresnelPower = defaultValue['fresnelPower'];
//							mat.addMethod(method);	
//						} else if (fresnel == 'false') {
//							mat.addMethod(new EnvMapMethod(crt,Number(reflection)));
//						}
						
						addCubeMethod(name,crt,(fresnel == 'true'), mat,Number(reflection));
						
						realList.push(mat);
					}
				}
			}
			
			return {
				material:mat,
				scaleU:Number(scaleU),
				scaleV:Number(scaleV)
			};
		}
		
		public var methods:Object = new Object();
		public function addCubeMethod(name:String, cubeTex:*, isFresnel:Boolean,mat:TextureMaterial,reflection:Number):void {
			var ct:* = methods[name];
			
			if (!ct) {
				if (isFresnel) {
					var m:FresnelEnvMapMethod = new FresnelEnvMapMethod(cubeTex,Number(reflection));
					m.fresnelPower = defaultValue['fresnelPower'];
					methods[name] = m;
				} else {
					methods[name] = new EnvMapMethod(cubeTex,Number(reflection));
				}
			}
			mat.name = name;
			
			mat.addMethod(methods[name]);
		}
		
		/**
		 * 重新渲染CubeReflection
		 */
		public function updateCubeReflection(position:Vector3D=null):void {
			if(position != null)
				crt.position = position;
			
			for each(var item:TextureMaterial in realList) {
				//trace(item + ' ' +item.name + ' ' + methods[item.name]);
				item.removeMethod(methods[item.name]);
			}
			
			//var lens:PerspectiveLens = new PerspectiveLens(100);
			//trace(PerspectiveLens(view.camera.lens).fieldOfView);
			
			//var oldLens:PerspectiveLens = PerspectiveLens(view.camera.lens);
			//view.camera.lens = lens;
			crt.render(view);
			//view.render();
			//view.camera.lens = oldLens;
			
			for each(item in realList) {
				item.addMethod(methods[item.name]);
			}
			
		}
	}
}