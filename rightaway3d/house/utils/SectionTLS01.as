package rightaway3d.house.utils
{
	import flash.geom.Point;

	public class SectionTLS01
	{
		public var points:Vector.<Point>;
		public function SectionTLS01()
		{
			var a:Array = [
				0,0,
				-1,0,
				-1,1,
				-1.3317,1.7439,
				-2,2,
				-4,2,
				-4,16,
				-2,16,
				-1.0053,16.9858,
				-1.0374,18.0096,
				-4.4622,27.6211,
				-9.6307,37.5807,
				-15.7336,46.3194,
				-23.0382,54.1207,
				-29.4725,59.6025,
				-36.6356,64.5235,
				-41.6772,67.2924,
				-42.6331,68.5818,
				-42.7001,69.3894,
				-42.8552,70.3148,
				-44.093,72.0809,
				-44.969,72.6395,
				-46.129,72.9832,
				-46.6824,73.2439,
				-47,73.9748,
				-47,82,
				-46,83,
				-29,83,
				21,18,
				46,18,
				46,0,
				0,0
			];
			
			setPoints(a);
		}
		
		private function setPoints(a:Array):void
		{
			var len:int = a.length/2;
			points = new Vector.<Point>(len);
			for(var i:int=0;i<len;i++)
			{
				points[i] = new Point(a[i*2+1],a[i*2]);
			}
		}
	}
}