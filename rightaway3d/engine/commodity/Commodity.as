package rightaway3d.engine.commodity
{
//	import rightaway3d.engine.product.ProductManager;
//	import rightaway3d.engine.product.ProductObject;

	public class Commodity
	{
		/*public var modelBaseURL:String;
		public var mifBaseURL:String;
		public var cdtBaseURL:String;
		public var btnBaseURL:String;
		public var mcBaseURL:String;*/
		
//		public var infoID:String;
//		public var ObjectID:String;
		
		public var commodityID:String;
		
		public var name:String;
		public var name_en:String;
		public var factory:String;
		public var merchant:String;
		public var brand:String;
		public var type:String;
		public var tag:String;
		public var memo:String;
		
//		public var product:ProductObject;
		
		public function Commodity()
		{
		}
		
		/*public static function parser(info:XML):Commodity
		{
			var c:Commodity = new Commodity();
			c.infoID = info.infoID;
			c.ObjectID = info.objectID;
			c.name = info.name;
			c.name_en = info.name_en;
			c.factory = info.factory;
			c.merchant = info.merchant;
			c.brand = info.brand;
			c.type = info.type;
			c.tag = info.tag;
			c.memo = info.memo;
			
			var pos:String = info.pos;
			var a:Array = pos.split(",");
			
			var p:ProductObject = ProductManager.own.creatObject(c.infoID,info.file);
			p.x = a[0]?a[0]:0;
			p.y = a[1]?a[1]:0;
			p.z = a[2]?a[2]:0;
			p.rx = a[3]?a[3]:0;
			p.ry = a[4]?a[4]:0;
			p.rz = a[5]?a[5]:0;
			
			p.commodityInfo = c;//产品和商品信息一对一挷定关系，子产品的商品信息怎么办?
			c.product = p;
			
			return c;
		}*/
	}
}



























