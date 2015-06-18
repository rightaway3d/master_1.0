package ztc.meshbuilder.room
{
	import flash.geom.Point;
	
	import org.poly2tri.Point;

	public class CabinetTableTool
	{
		public function CabinetTableTool()
		{
		}
		
		static public function createCabinetTable(dangshui:Array,tablePoints:Array,holePoints:Array,
												  radius:Number=30,segment:uint=8,height:Number=40
												  /*,textureURL:String="",normalURL:String="",
												  color:uint=0xAAAADD,ambient:Number=0.8,
												  specular:Number=0.3,gloss:Number=50*/
		):CabinetTable3D
		{
			var len:int = tablePoints.length;
			var ps:Vector.<org.poly2tri.Point> = new Vector.<org.poly2tri.Point>(len);
			for(var i:int=0;i<len;i++)
			{
				var p:flash.geom.Point = tablePoints[i];
				ps[i] = new org.poly2tri.Point(p.x,p.y);
			}
			
			//trace("holePoints:"+holePoints);
			if(holePoints)
			{
				len = holePoints.length;
				var hole:Vector.<org.poly2tri.Point> = new Vector.<org.poly2tri.Point>(len);
				for(i=0;i<len;i++)
				{
					p = holePoints[i];
					hole[i] = new org.poly2tri.Point(p.x,p.y);
				}
			}
			
			len = dangshui.length;
			var ds:Vector.<org.poly2tri.Point> = new Vector.<org.poly2tri.Point>(len);
			for(i=0;i<len;i++)
			{
				p = dangshui[i];
				ds[i] = new org.poly2tri.Point(p.x,p.y);
			}
			return new CabinetTable3D(ps,hole,radius,segment,height,ds)//,textureURL,normalURL,color,ambient,specular,gloss);
		}
	}
}