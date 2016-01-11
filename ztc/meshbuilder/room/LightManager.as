package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.containers.View3D;
	import away3d.lights.PointLight;
	import away3d.lights.ThreePointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.SoftShadowMapMethod;

	public class LightManager
	{
		public static var instance:LightManager = null;
		
		public var lightPicker:StaticLightPicker;
		public var rowNum:uint = 2;
		public var colNum:uint = 1;
		public var layNum:uint = 2;
		
		public var center:Vector3D;
		
		private var view:View3D;
		
		private var max:Vector3D;
		private var min:Vector3D;
		private var width:Number;
		private var depth:Number;
		private var height:Number;
		private var maxLen:Number;
		public var ceilingLightPos:Vector3D;
		
		// lights
		public var lightArray:Array = [];
		private var pointLights:Array = [];
		
		public var ceilingLight:PointLight;
		public var floorLight:PointLight;
		
		//public var topLight:DirectionalLight;
		//public var bottomLight:DirectionalLight;
		
		private var _softShadowMethod:SoftShadowMapMethod;
		
		private var lightMatrixIntensity:Number = 0.3;
		
		public function LightManager(view:View3D, max:Vector3D = null, min:Vector3D = null)
		{
			instance = this;
			
			this.view = view;
			
			createLight();
			
			if (max && min) 
				update(max,min);
		}
		
		private function createLight():void
		{
			// 创建顶灯
			ceilingLight = new PointLight();
			
			ceilingLight.radius = 0;//3350;//
			
			//ceilingLight.color = 0xFFFEF9;
			ceilingLight.specular = 1;
			ceilingLight.diffuse = 0.4;
			ceilingLight.ambient = 0.4;
			//ceilingLight.ambientColor = 0xFDF9D7;
			//ceilingLight.castsShadows = true;
			
			away3d.lights.ThreePointLight
			
			// 创建顶灯
			floorLight = new PointLight();
			
			floorLight.radius = 0;//3350;//
			
			floorLight.color = 0xFFFEF9;
			floorLight.specular = 0;
			floorLight.diffuse = 0.1;
			floorLight.ambient = 0.1;
			floorLight.ambientColor = 0xFDF9D7;
			//floorLight.castsShadows = true;
			
			// Top Light
			/*topLight = new DirectionalLight(0,-1,0);
			topLight.ambient = 0.1;
			topLight.specular = 0.1;
			topLight.diffuse = 0.25;
			topLight.castsShadows = true;*/
			
			//topLight.color = 0xDDEDFB;
			//topLight.ambientColor = 0xFDF9D7;
			
			// bottom Light
//			bottomLight = new DirectionalLight(0,1,0);
//			bottomLight.ambient = 0;
//			bottomLight.specular = 0;
//			bottomLight.diffuse = 0;
//			bottomLight.color = 0xDDEDFB;
			
			lightArray.push(ceilingLight,floorLight);
			//lightArray.push(topLight,ceilingLight);
			//lightArray.push(topLight);
			//view.scene.addChild(topLight);
			view.scene.addChild(ceilingLight);
			view.scene.addChild(floorLight);
//			view.scene.addChild(bottomLight);
			
			/*_softShadowMethod = new SoftShadowMapMethod(topLight, 5);
			_softShadowMethod.range = 8;	// the sample radius defines the softness of the shadows
			_softShadowMethod.epsilon = 1;*/
			
			// light Matrix
			//var len:int = rowNum * colNum * layNum;
			var len:int = 4;
			for (var i:int = 0;i < len; i++) {
				var pl:PointLight = new PointLight();
				
				pl.specular = 0;//0.2;//
				pl.ambient = 0.1;
				pl.diffuse = 0.1;//lightMatrixIntensity;
				
				pl.color = 0xECF4F4;
				pl.ambientColor = 0xFDF9D7;
				
				pl.radius = 0;//100;//
				
				lightArray.push(pl);
				pointLights.push(pl);
				view.scene.addChild(pl);
			}
			
			lightPicker = new StaticLightPicker(lightArray);
		}
		
		public function getDefaultShadowMethod():SoftShadowMapMethod
		{
			return _softShadowMethod;
		}
		
		/**
		 * 更新灯光的位置与亮度
		 */
		public function update(max:Vector3D, min:Vector3D):void {
			this.max = max;
			this.min = min;
			
			// 得到中心点
			center = max.add(min);
			center.scaleBy(0.5);
			
			this.width = max.x - min.x;
			this.depth = max.z - min.z;
			this.height = max.y - min.y;
			
			var tmpMax:Number = depth > width ? depth : width;
			this.maxLen = tmpMax > height ? tmpMax : height;
			
			// 计算顶灯的位置
			ceilingLightPos = center.add(new Vector3D(0,height / 2 + 150));//50
			
			maxLen = width * depth;// * height;
			
			ceilingLight.position = ceilingLightPos;
			ceilingLight.fallOff = maxLen;// * 2;//1.1;
			
			ceilingLightPos = ceilingLightPos.clone();
			ceilingLightPos.y = -3000;
			
			floorLight.position = ceilingLightPos;
			//floorLight.fallOff = maxLen;// * 2//1.1;
			
			//trace("--light position:",pointLights.length,ceilingLight.position,floorLight.position);
			//return;
			if(pointLights.length==4)
			{
				var dx:int,dz:int;
				var dy1:int = 80 + 360,dy2:int = 1390 + 360;
				
				if(width>depth)
				{
					dx = width * 0.25;
				}
				else
				{
					dz = depth * 0.25;
				}
				
				setPointLight(pointLights[0],dx,dy1,dz,0);
				setPointLight(pointLights[1],dx,dy2,dz,0);
				setPointLight(pointLights[2],-dx,dy1,-dz,0);
				setPointLight(pointLights[3],-dx,dy2,-dz,0);
			}
			else
			{
				// 行与列的互换
				/*if (width > depth) {
					var t:uint = rowNum;
					rowNum = colNum;
					colNum = t;
				}
				
				// 定位灯阵
				// 定位需要的数据
				var baseX:Number,baseY:Number,baseZ:Number;
				var xSpace:Number,ySpace:Number,zSpace:Number;
				
				xSpace = width / (colNum + 1);
				baseX = center.x - (width) / 2 + xSpace;
				
				ySpace = height / (layNum + 1);
				//baseY = center.y - (height) / 2 + ySpace;
				baseY = center.y - (height) / 3;// - ySpace;
				
				zSpace = depth / (rowNum + 1);
				baseZ = center.z - (depth) / 2 + zSpace;
				
				//var index:uint = 2;
				var index:uint = 0;
				for (var i:int = 0; i < rowNum; i ++) {
					for (var j:int = 0; j < colNum; j ++) {
						for (var k:int = 0; k < layNum; k++) {
							// 创建基础灯
							//var pl:PointLight = lightArray[index];
							var pl:PointLight = pointLights[index];
							
							//pl.fallOff = maxLen / 1;
							//pl.fallOff = maxLen;
							pl.fallOff = maxLen;
							
							pl.x = baseX + xSpace * j;
							pl.y = baseY + ySpace * k;//1100;//
							pl.z = baseZ + zSpace * i;
							
							index ++;
							
							var m:Mesh = new Mesh(new SphereGeometry(20),new ColorMaterial());
							m.x = pl.x;
							m.y = pl.y;
							m.z = pl.z;
							view.scene.addChild(m);
						}
					}
				}*/
				//trace("----------light length:"+index);
			}
		}
		
		private function setPointLight(light:PointLight,dx:int,y:int,dz:int,fallOff:int):void
		{
			light.y = y;
			light.x += dx;
			light.z += dz;
			light.fallOff = fallOff;
			
			/*trace("light.position:",light.position);
			
			var m:Mesh = new Mesh(new SphereGeometry(20),new ColorMaterial());
			m.x = light.x;
			m.y = light.y;
			m.z = light.z;
			view.scene.addChild(m);*/
		}
		
	}
}