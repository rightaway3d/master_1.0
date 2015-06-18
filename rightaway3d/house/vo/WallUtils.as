package rightaway3d.house.vo
{
	public class WallUtils
	{
		static public function sortWallObject(x0:Number,x1:Number,objects:Array):Array
		{
			var a:Array = [];
			a.push(x0);
			var len:int = objects.length;
			//trace("sortWallObjects:"+objects);
			for(var i:int=0;i<len;i++)
			{
				var o:WallObject = objects[i];
				var x00:Number = o.x - o.width;
				if(x00-x0>1)
				{
					a.push(x00);
				}
				x0 = o.x;
				
				if(o.width>1)a.push(x0);
			}
			
			if(x1-x0>1)a.push(x1);
			
			return a;
		}
	}
}