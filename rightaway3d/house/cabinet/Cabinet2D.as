package rightaway3d.house.cabinet
{
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.house.view2d.Product2D;

	public class Cabinet2D extends Product2D
	{
		public function Cabinet2D(infoID:int,fileURL:String,dataFormat:String="text")
		{
			var vo:ProductObject = ProductManager.own.addProductObject(ProductObject.getNextIndex(),"Cabinet",infoID,fileURL,dataFormat);
			super(vo);
		}
	}
}