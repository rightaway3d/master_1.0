package rightaway3d.house.cabinet
{
	import flash.geom.Vector3D;
	
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;

	public class CircularColumn2D extends CustomizeProduct2D
	{
		public function CircularColumn2D(pName:String,diameter:int,height:int,color:uint,isActive:Boolean=true,rot:Vector3D=null,name_en:String="")
		{
			var type:String = ModelType.CYLINDER_C;
			var po:ProductObject = ProductManager.own.createCustomizeProduct(type,pName,name_en,diameter,height,diameter,color,isActive,0,0,rot);
			ProductManager.own.addProductToScene(po);
			super(po);
		}
	}
}