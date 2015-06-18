package rightaway3d.engine.light
{
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.primitives.SphereGeometry;

	public final class PointLightBulb extends PointLight
	{
		private var material:ColorMaterial;
		private var bulb:Mesh;
		
		public function PointLightBulb(radius:Number,color:uint,visible:Boolean=false)
		{
			super();
			
			material = new ColorMaterial();
			//material.addMethod(new OutlineMethod());
			material.addMethod(new RimLightMethod());
			material.lightPicker = new StaticLightPicker([this]);
			
			bulb = new Mesh(new SphereGeometry(radius),material);
			this.addChild(bulb);
			
			this.color = color;
			this.ambientColor = color;
			this.ambient = 1;
			this.radius = 0;
			this.fallOff = Number.MAX_VALUE;
			
			bulb.visible = visible;
		}
		
		public function set bulbVisible(value:Boolean):void
		{
			bulb.visible = value;
		}
		
		public function get bulbVisible():Boolean
		{
			return bulb.visible;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			bulb.visible = value;
		}
		
		override public function set color(value:uint):void
		{
			super.color = value;
			material.color = color;
		}
	}
}