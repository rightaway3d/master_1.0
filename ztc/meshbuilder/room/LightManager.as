package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.SphereGeometry;

	public class LightManager
	{
		public static var instance:LightManager = null;
		
		public var lightPicker:StaticLightPicker;
		public var rowNum:uint = 2;
		public var colNum:uint = 2;
		public var layNum:uint = 1;
		public var center:Vector3D;
		
		private var view:View3D;
		
		private var max:Vector3D;
		private var min:Vector3D;
		private var width:Number;
		private var length:Number;
		private var height:Number;
		private var maxLen:Number;
		public var ceilingLightPos:Vector3D;
		
		// lights
		public var lightArray:Array = [];
		public var ceilingLight:PointLight;
		public var topLight:DirectionalLight;
		public var bottomLight:DirectionalLight;
		
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
			
			ceilingLight.radius = 350;
			
			ceilingLight.color = 0xFFFEF9;
			ceilingLight.specular = 1;
			ceilingLight.diffuse = 0.3;
			ceilingLight.ambient = 0.1;
			ceilingLight.ambientColor = 0xFDF9D7;
			
			// Top Light
			topLight = new DirectionalLight(0,-1,0);
			topLight.ambient = 0;
			topLight.specular = 0;
			topLight.diffuse = 0.25;
			
			topLight.color = 0xDDEDFB;
			
			// bottom Light
//			bottomLight = new DirectionalLight(0,1,0);
//			bottomLight.ambient = 0;
//			bottomLight.specular = 0;
//			bottomLight.diffuse = 0;
//			bottomLight.color = 0xDDEDFB;
			
			lightArray.push(ceilingLight,topLight);
			view.scene.addChild(ceilingLight);
//			view.scene.addChild(bottomLight);
			
			// light Matrix
			for (var i:int = 0;i < rowNum * colNum * layNum; i++) {
				var pl:PointLight = new PointLight();
				
				pl.ambient = pl.specular = 0;
				pl.diffuse = lightMatrixIntensity;
				pl.color = 0xECF4F4;
				
				pl.radius = 0;
				
				lightArray.push(pl);
				view.scene.addChild(pl);
			}
			
			lightPicker = new StaticLightPicker(lightArray);
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
			this.length = max.z - min.z;
			this.height = max.y - min.y;
			var tmpMax:Number = length > width ? length : width;
			this.maxLen = tmpMax > height ? tmpMax : height;
			
			// 计算顶灯的位置
			ceilingLightPos = center.add(new Vector3D(0,height / 2 - 50));
			ceilingLight.position = ceilingLightPos;
			ceilingLight.fallOff = maxLen * 1.1;
			
			// 行与列的互换
			if (width > length) {
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
			baseY = center.y - (height) / 2 + ySpace;
			
			zSpace = length / (rowNum + 1);
			baseZ = center.z - (length) / 2 + zSpace;
			
			var index:uint = 2;
			for (var i:int = 0; i < rowNum; i ++) {
				for (var j:int = 0; j < colNum; j ++) {
					for (var k:int = 0; k < layNum; k++) {
						// 创建基础灯
						var pl:PointLight = lightArray[index];
						
						pl.fallOff = maxLen / 1;
						
						pl.x = baseX + xSpace * j;
						pl.y = baseY + ySpace * k;
						pl.z = baseZ + zSpace * i;
						
						index ++;
						
//						var m:Mesh = new Mesh(new SphereGeometry(20),new ColorMaterial());
//						m.x = pl.x;
//						m.y = pl.y;
//						m.z = pl.z;
//						view.scene.addChild(m);
					}
				}
			}
		}
	}
}