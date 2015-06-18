package rightaway3d.house.cabinet
{
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;

	public class SquarePillar2D extends CustomizeProduct2D
	{
		public function SquarePillar2D(pName:String,width:int,height:int,depth:int,color:uint,isActive:Boolean=true,name_en:String="")
		{
			var type:String = ModelType.BOX_C;
			var po:ProductObject = ProductManager.own.createCustomizeProduct(type,pName,name_en,width,height,depth,color,isActive);
			
			ProductManager.own.addProductToScene(po);

			super(po);
		}
	}
}