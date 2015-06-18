package rightaway3d.house.utils
{
	public class TestNumer
	{
		public function TestNumer()
		{
		}
		
		static private function find(n:Number,a:Array):int
		{
			var len:int = a.length;
			for(var i:int=0;i<len;i++)
			{
				if(n==a[i])return i;
			}
			return -1;
		}
		
		static private function matchSize(n:Number,a:Array):int
		{
			var len:int = a.length;
			for(var i:int=0;i<len;i++)
			{
				if(n<a[i])
				{
					if(i>0)
					{
						return a[i-1];
					}
					return n;
				}
			}
			return a[len-1];
		}
		
		/**
		 * 
		 * @param length
		 * @param maxs 从小到大一组数:[800,900]
		 * @param mins 从小到大一组数:[300,400,450,500]
		 * @return 
		 * 
		 */
		static public function matchGroupSize(length:Number,maxs:Array,mins:Array):Array
		{
			var lenMax:int = maxs.length;
			var lenMin:int = mins.length;
			var i:int,j:int;
			
			var alls:Array = mins.concat();
			for(i=0;i<lenMax;i++)
			{
				alls = alls.concat(maxs[i]);
			}
			
			var group:Array = [];
			var len:int = alls.length;
			
			for(i=0;i<len;i++)
			{
				var n1:int = alls[i];
				group.push({width:n1,array:[n1]});
				for(j=0;j<lenMin;j++)
				{
					var n2:int = alls[j];
					var n0:int = n1+n2;
					alls.indexOf(n0)
					if(find(n0,alls)==-1)//避免相同宽度的组合
					{
						group.push({width:n0,array:[n1,n2]});
					}
				}
			}
			
			group.sortOn("width",Array.NUMERIC);
			len = group.length;
			
			for(i=0;i<len;i++)
			{
				var o:Object = group[i];
				var n:Number = o.width;
				if(length<n)
				{
					if(i>0)
					{
						var o2:Object = group[i-1];
						var a:Array = o2.array;
						n = length-o2.width;
						a.push(n);
						return a;
					}
					else
					{
						a = [length];
						return a;
					}
				}
			}
			
			group.length = 0;
			var min0:int = mins[0];
			
			for(i=0;i<lenMax;i++)
			{
				var max:int = maxs[i];
				for(j=0;j<lenMin;j++)
				{
					var min:int = mins[j];
					var min2:int = min * 2;
					if(length>=min+max+min)
					{
						var m:int = (length - min2)/max;
						n = length - min2 - max * m;
						if(min2-max+n>=min0)//两侧柜子宽度之和大于中间柜子的宽度，且多出部分加上剩下的间隙，够再放一个最小的柜子时
						{
							min = max*0.5;
							n += min2-max;
							min2 = matchSize(n,mins);
							n -= min2;
							
							a = [min];
							addArray(a,max,m);
							a.push(min);
							a.push(min2);
							a.push(n);
						}
						else if(min-(min0-n)*0.5>min0)//两侧柜子空间可以分出部分到尾部，形成一个新的柜子空间
						{
							var tmin:int = matchSize(min-(min0-n)*0.5,mins);
							min2 = (min - tmin)*2 + n;
							min = tmin;
							tmin = matchSize(min2,mins);
							n = min2 - tmin;
							
							a = [min];
							addArray(a,max,m);
							a.push(min);
							a.push(tmin);
							a.push(n);
						}
						else
						{
							n += min;//合并尾则空隙
							min2 = matchSize(n,mins);
							n -= min2;
							
							a = [min];
							addArray(a,max,m);
							a.push(min2);
							a.push(n);
						}
						
						group.push({width:n,array:a});
					}
					else if(length>=min+max)
					{
						n = length - min - max;
						a = [min];
						a.push(max);
						a.push(n);
						
						group.push({width:n,array:a});
					}
					else
					{
						trace("what the fuch? length:"+length+" max:"+max+" min:"+min);
					}
					
					//trace("--"+a);
				}
			}
			
			group.sortOn("width",Array.NUMERIC);
			
			return group[0].array;
		}
		
		static private function addArray(a:Array,n:Number,len:int):void
		{
			for(var i:int=0;i<len;i++)
			{
				a.push(n);
			}
		}
		
		static public function test():void
		{
			var size:int = 3000;
			var step:int = 20;
			trace("--------------------------------------------------------");
			var maxs:Array = [800];
			var mins:Array = [300,400,450];//,500
			
			for(var i:int=200;i<=size;i+=step)
			{
				var a:Array = matchGroupSize(i,maxs,mins);
				trace(i+":"+a);
			}
			
			trace("--------------------------------------------------------");
			maxs = [900];
			for(i=200;i<=size;i+=step)
			{
				a = matchGroupSize(i,maxs,mins);
				trace(i+":"+a);
			}
			
			trace("--------------------------------------------------------");
			maxs = [800,900];
			for(i=200;i<=size;i+=step)
			{
				a = matchGroupSize(i,maxs,mins);
				trace(i+":"+a);
			}
			trace("--------------------------------------------------------");
		}
	}
}