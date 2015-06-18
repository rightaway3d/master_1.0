package rightaway3d.engine.light
{
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;

	public class PointLights extends ObjectContainer3D
	{
		public var lightFront:PointLightBulb;
		public var lightTop:PointLightBulb;
		public var lightBack:PointLightBulb;
		public var lightBottom:PointLightBulb;
		
		public function PointLights()
		{
			lightFront = new PointLightBulb(100,0xFFFFFF);
			lightFront.position = new Vector3D(-10000,2000,-7000);
			lightFront.ambient = 0.1;
			lightFront.diffuse = 0.1;
			lightFront.specular = 0.1;
			addChild(lightFront);
			lightFront.bulbVisible = true;
			
			lightBack = new PointLightBulb(100,0xFFFFFF);
			lightBack.position = new Vector3D(10000,2000,7000);
			lightBack.ambient = 0.1;
			lightBack.diffuse = 0.1;
			lightBack.specular = 0.1;
			addChild(lightBack);
			lightBack.bulbVisible = true;
			
			lightTop = new PointLightBulb(100,0xFFFFFF);
			lightTop.position = new Vector3D(1000,10000,-1000);			
			lightTop.ambient = 0.05;
			lightTop.diffuse = 0.05;
			lightTop.specular = 0.1;
			lightTop.fallOff = 10000;
			addChild(lightTop);
			lightTop.bulbVisible = true;
			
			lightBottom = new PointLightBulb(100,0xFFFFFF);
			lightBottom.position = new Vector3D(-1000,-10000,1000);			
			lightBottom.ambient = 0.05;
			lightBottom.diffuse = 0.05;
			lightBottom.specular = 0.1;
			addChild(lightBottom);
			lightBottom.bulbVisible = true;
		}
}
}