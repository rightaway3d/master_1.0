package rightaway3d.house.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public final class Geom
	{
		/**
		 * 判断数值是否为0的参考数值
		 */
		static public var eps:Number = 1e-4;
		
		//=========================================================================================================
		/**
		 * 判断浮点是否足够小而可以作为0处理 
		 * @param x：要判断的浮点数
		 * @return true：为0，false：不为0
		 * 
		 */
		static public function zero(x:Number):Boolean
		{
			return (x > 0 ? x : -x) < eps;
		}
		
		//=========================================================================================================
		/**
		 * 计算交叉乘积(P1-P0)x(P2-P0)
		 * @param p1
		 * @param p2
		 * @param p0
		 * @return 
		 * 
		 */
		static public function xmult( p1:Point, p2:Point, p0:Point):Number
		{
			return (p1.x-p0.x)*(p2.y-p0.y)-(p2.x-p0.x)*(p1.y-p0.y);
		}
		
		//=========================================================================================================
		/**
		 * 判点是否在线段上,包括端点
		 * @param p
		 * @param l1
		 * @param l2
		 * @return 
		 * 
		 */
		static public function dot_online_in( p:Point, l1:Point, l2:Point):Boolean
		{
			return zero(xmult(p,l1,l2)) && (l1.x-p.x)*(l2.x-p.x)<eps && (l1.y-p.y)*(l2.y-p.y)<eps;
		}
		
		//=========================================================================================================
		/**
		 * 判两点在线段同侧,点在线段上返回0
		 * @param p1
		 * @param p2
		 * @param l1
		 * @param l2
		 * @return 
		 * 
		 */
		static public function same_side( p1:Point, p2:Point, l1:Point, l2:Point):Boolean
		{
			return xmult(l1,p1,l2)*xmult(l1,p2,l2)>eps;
		}
		
		//=========================================================================================================
		/**
		 * 判两直线平行
		 * @param u1:线段u顶点1
		 * @param u2:线段u顶点2
		 * @param v1:线段v顶点1
		 * @param v2:线段v顶点2
		 * @return true:平行，false:不平行
		 * 
		 */
		static public function parallel( u1:Point, u2:Point, v1:Point, v2:Point):Boolean
		{
			return zero((u1.x-u2.x)*(v1.y-v2.y)-(v1.x-v2.x)*(u1.y-u2.y));
		}
		
		//=========================================================================================================
		/**
		 * 判三点共线
		 * @param p1
		 * @param p2
		 * @param p3
		 * @return 
		 * 
		 */
		static public function dots_inline( p1:Point, p2:Point, p3:Point):Boolean
		{
			return zero(xmult(p1,p2,p3));
		}
		
		//=========================================================================================================
		/**
		 * 判两线段相交,包括端点和部分重合
		 * @param u1:线段u顶点1
		 * @param u2:线段u顶点2
		 * @param v1:线段v顶点1
		 * @param v2:线段v顶点2
		 * @return true:有交点，false:无交点
		 * 
		 */
		static public function intersect_in( u1:Point, u2:Point, v1:Point, v2:Point):Boolean
		{
			if (!dots_inline(u1,u2,v1)||!dots_inline(u1,u2,v2))
				return !same_side(u1,u2,v1,v2)&&!same_side(v1,v2,u1,u2);
			
			return dot_online_in(u1,v1,v2)||dot_online_in(u2,v1,v2)||dot_online_in(v1,u1,u2)||dot_online_in(v2,u1,u2);
		}
		
		//=========================================================================================================
		/**
		 * 计算两线段交点，计算前要先判线段是否相交,同时还是要判断是否平行!（注意：线段与线段可以不平行也不相交）
		 * @param u1:线段u顶点1
		 * @param u2:线段u顶点2
		 * @param v1:线段v顶点1
		 * @param v2:线段v顶点2
		 * @return 两线段的交点
		 * 
		 */
		static public function intersection( u1:Point, u2:Point, v1:Point, v2:Point):Point
		{
			var ret:Point=new Point(u1.x,u1.y);
			var t:Number=((u1.x-v1.x)*(v1.y-v2.y)-(u1.y-v1.y)*(v1.x-v2.x))/((u1.x-u2.x)*(v1.y-v2.y)-(u1.y-u2.y)*(v1.x-v2.x));
			ret.x+=(u2.x-u1.x)*t;
			ret.y+=(u2.y-u1.y)*t;
			return ret;
		}
		
		//=========================================================================================================
		/**
		 * 计算两点之间的距离
		 * @param x1:点1的x坐标
		 * @param y1:点1的y坐标
		 * @param x2:点2的x坐标
		 * @param y2:点2的y坐标
		 * @return 两点间的距离
		 * 
		 */
		static public function distance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			var dx:Number = x2-x1;
			var dy:Number = y2-y1;
			return Math.sqrt(dx*dx+dy*dy);
		}
		
		//=========================================================================================================
		/**
		 * 计算两点之间的距离
		 * @param p1：点1
		 * @param p2：点2
		 * @return 两点间的距离
		 * 
		 */
		static public function distance2(p1:Point,p2:Point):Number
		{
			var dx:Number = p2.x-p1.x;
			var dy:Number = p2.y-p1.y;
			return Math.sqrt(dx*dx+dy*dy);
		}
		
		//=========================================================================================================
		/**
		 * 不开方计算两点之间的距离，一般在比较数值时，使用此方法。
		 * @param p1：点1
		 * @param p2：点2
		 * @return 两点间的距离
		 * 
		 */
		static public function dist_no_sqrt(p1:Point,p2:Point):Number
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			return dx*dx + dy*dy;
		}
		//=========================================================================================================
		/**
		 * 计算给定线段延长指定距离后的点
		 * @param p1为起点
		 * @param p2为终点
		 * @param dist为延长距离，为正时为起点到终点的正向延长，为负时为起点到终点的反向延长
		 * @return 返回延长后的新点
		 * 
		 */
		static public function distent(p1:Point,p2:Point,dist:Number):Point
		{
			var angle:Number = Math.atan2(p2.y-p1.y,p2.x-p1.x);
			var x:Number = dist*Math.cos(angle);
			var y:Number = dist*Math.sin(angle);
			var p:Point;
			
			if(dist>0)
			{
				p = new Point(p2.x+x, p2.y+y);
			}
			else
			{
				p = new Point(p1.x-x, p1.y-y);
			}
			
			return p;
		}
		
		//=========================================================================================================
		/**
		 * 计算任意多边形的AABB（Axis-aligned bounding box）包围盒
		 * @param points：多边形的顶点
		 * @return 包围盒矩形
		 * 
		 */
		static public function getAABB(points:Vector.<Point>):Rectangle
		{
			var len:int = points.length;
			var i:int;
			var p:Point;
			
			var x:Number;
			var y:Number;
			var maxX:Number = -100000000;
			var minX:Number = 100000000;
			var maxY:Number = -100000000;
			var minY:Number = 100000000;
			
			for(i=0;i<len;i++)
			{
				p = points[i];
				x = p.x;
				y = p.y;
				
				if(x>maxX)
				{
					maxX = x;
				}
				if(x<minX)
				{
					minX = x;
				}
				
				if(y>maxY)
				{
					maxY = y;
				}
				if(y<minY)
				{
					minY = y;
				}
			}
			
			return new Rectangle(minX,minY,maxX-minX,maxY-minY);
		}
		
		//=========================================================================================================
		/**
		 * 计算任意多边形的面积
		 * @param points:多边形的顶点（逆时针方向）
		 * @return 多边形的面积
		 * 
		 */
		static public function getArea(points:Vector.<Point>):Number
		{
			var a:Number = 0;
			var len:int = points.length - 1;
			var i:int;
			
			for(i=0;i<len;i++)
			{
				a += points[i].x * points[i+1].y - points[i+1].x * points[i].y;
			}
			a += points[len].x * points[0].y - points[0].x * points[len].y;
			
			return a/2;
		}
		
		static public function getArea2(points:Vector.<Vertex>):Number
		{
			var a:Number = 0;
			var len:int = points.length - 1;
			var i:int;
			
			for(i=0;i<len;i++)
			{
				a += points[i].point.x * points[i+1].point.y - points[i+1].point.x * points[i].point.y;
			}
			a += points[len].point.x * points[0].point.y - points[0].point.x * points[len].point.y;
			
			return a/2;
		}
		
		//=========================================================================================================
		/**
		 * 计算点到直线的垂足交点
		 * @param p：已知点
		 * @param p1：已知直线的一端点
		 * @param p2：已知直线的另一端点
		 * @return 点到直线的垂足交点
		 * 
		 */
		static public function getFootPoint(p:Point,p1:Point,p2:Point,result:Point=null):Point
		{
			/*			double x1, y1, x2, y2, x3, y3;    
			double px = x2 - x1;
			double py = y2 - y1;
			double som = px * px + py * py;
			double u =  ((x3 - x1) * px + (y3 - y1) * py) / som;
			if (u > 1) {
			u = 1;
			}
			if (u < 0) {
			u = 0;
			}
			//the closest point
			double x = x1 + u * px;
			double y = y1 + u * py;
			*/			
			var px:Number = p2.x - p1.x;
			var py:Number = p2.y - p1.y;
			var som:Number = px * px + py * py;
			var u:Number = ((p.x - p1.x) * px + (p.y - p1.y) * py) / som;
			
			if (u > 1)
			{
				u = 1;
			}
			else if (u < 0) 
			{
				u = 0;
			}
			
			result ||= new Point();
			result.x = p1.x + u * px;
			result.y = p1.y + u * py;
			
			return result;
		}
		
		static public function getFootPoint2(p:Point,p1:Point3D,p2:Point3D,result:Point=null):Point
		{
			var px:Number = p2.x - p1.x;
			var py:Number = p2.z - p1.z;
			var som:Number = px * px + py * py;
			var u:Number = ((p.x - p1.x) * px + (p.y - p1.z) * py) / som;
			
			if (u > 1)
			{
				u = 1;
			}
			else if (u < 0) 
			{
				u = 0;
			}
			
			result ||= new Point();
			result.x = p1.x + u * px;
			result.y = p1.z + u * py;
			
			return result;
		}
		
		//=========================================================================================================
		/**
		 * 计算已知长度和旋转角度的线段的未端坐标（起点坐标默认为[0,0]）
		 * @param length：线段长度
		 * @param angle：线段旋转角度，以弧度为单位
		 * @return 线段的未坐标
		 * 
		 */
		static public function getLineEndCoord(length:Number,angle:Number):Point
		{
			var x:Number = Math.cos(angle)*length;
			var y:Number = Math.sin(angle)*length;
			return new Point(x,y);
		}
		
		//=========================================================================================================
		/**
		 * 计算两个矢量之间的夹角
		 * @param p1：矢量1的起点
		 * @param p2：矢量1的终点
		 * @param s1：矢量2的起点
		 * @param s2：矢量2的终点
		 * @return ：两个矢量的夹角，以弧度为单位
		 * 
		 */
		static public function getAngleBetween(p1:Point,p2:Point,s1:Point,s2:Point):Number
		{
			var angle1:Number = Math.atan2(p2.y-p1.y,p2.x-p1.x);
			var angle2:Number = Math.atan2(s2.y-s1.y,s2.x-s1.x);
			return angle2-angle1;
		}
		
		//=========================================================================================================
		/**
		 * 角度转弧度
		 * @param value：角度
		 * @return 弧度
		 * 
		 */
		static public function angle2Radian(value:Number):Number
		{
			return Math.PI / 180 * value;
		}
		
		/**
		 * 弧度转角度
		 * @param value：弧度
		 * @return 角度
		 * 
		 */
		static public function radian2Angle(value:Number):Number
		{
			return value * 180 / Math.PI;
		}
		
		/* 返回两直线的交点 */ 
		/*		Point LinesIntersection(Line m, Line n, int *flag) 
		{
		double d = n.A * m.B - m.A * n.B;
		if (d == 0)
		{
		*flag = 0;
		return;
		}
		Point i;
		i.x = (n.B * m.C - m.B * n.C) / d;
		i.y = (m.A * n.C - n.A * m.C) / d;
		*flag = 1;
		return i;
		}
		*/		
		//============================================================================================================
		//用三角形递归分割多边形
		public static function splitPolygonByTriangle(polygon:Vector.<Vertex>,triangles:Vector.<Triangle>):void
		{
			/*while(polygon.length>2)
			{
				_splitPolygonByTriangle(polygon,triangles);
				trace("");
			}*/
			_splitPolygonByTriangle(polygon,triangles);
		}
		//============================================================================================================
		//用三角形递归分割多边形
		private static function _splitPolygonByTriangle(polygon:Vector.<Vertex>,triangles:Vector.<Triangle>):void
		{
			var sideNum:int = polygon.length;
			//trace("_splitPolygonByTriangle:",sideNum);
			//trace(polygon);
			
			var triangle:Vector.<Vertex> = new Vector.<Vertex>(3);//取多边形的最后一个点与前两个点为新三角形的三个顶点
			triangle[0] = polygon[sideNum - 1];
			triangle[1] = polygon[0];
			triangle[2] = polygon[1];
			
			var polygon2:Vector.<Vertex> = polygon.concat();//复制多边形
			polygon2.shift();//去掉多边形的第一个顶点，为分割掉上面的三角形区域后的新多边形；
			
			var s:Number = getArea2(polygon);//总面积
			var s1:Number = getArea2(triangle);//三角形面积
			var s2:Number = getArea2(polygon2);//新多边形面积
			var ds:Number = Math.abs(s-(s1+s2));
			//trace("s:",s,s1,s2);
			//trace("ds:",ds);
			
			if(ds>0.0000001)//如果分割后的新区域面积之和不等于总面积，则把头点压到尾点继续递归
			{
				trace("面积之和不对");
				polygon.push(polygon.shift());
				//splitPolygonByTriangle(polygon,triangles);
				return;
			}
			
			if(hasIntersection2(polygon2))//如果切割线与新多边形的其它边有交点，
			{
				trace("hasIntersection:",polygon2);
				//polygon.push(polygon.shift());//把头点压到尾点继续递归
				polygon.unshift(polygon.pop());//把尾点压到头点继续递归
				//splitPolygonByTriangle(polygon,triangles);
				return;
			}
			
			//if(!antiClockWise(triangle))//如果不是逆时针方向
			//{
			//trace("antiClockWise:",triangle);
			//polygon.push(polygon.shift());
			//splitPolygonByTriangle(polygon,triangles);
			//return;
			//交换后两点顺序，变为逆时针方向
			//var p:Point = triangle[1];
			//triangle[1] = triangle[2];
			//triangle[2] = p;
			//}
			
			var t:Triangle = new Triangle();
			t.p0 = triangle[0];
			t.p1 = triangle[1];
			t.p2 = triangle[2];
			triangles.push(t);//压入分割出来的三角形
			
			//polygon.shift();
			//polygon = polygon2;
			
			if(polygon2.length>3)//新多边形的边数大于3时继续递归
			{
				_splitPolygonByTriangle(polygon2,triangles);
				return;
			}
			
			t = new Triangle();
			t.p0 = polygon2[0];
			t.p1 = polygon2[1];
			t.p2 = polygon2[2];
			triangles.push(t);//压入最后一个三角形
		}
		//==================================================================
		//判断是否逆时针方向
		private static function antiClockWise(triangle:Vector.<Point>):Boolean
		{
			//			if(xmult(triangle[1],triangle[2],triangle[0])>eps)
			//			{
			//				return true;
			//			}
			//			return false; 
			
			//判断前三个点是否为逆时针方向，如果不是，将第一个点移到最后一个点再次判断
			var dx01:Number = triangle[1].x - triangle[0].x;
			var dy01:Number = triangle[1].y - triangle[0].y;
			var dx02:Number = triangle[2].x - triangle[0].x;
			var dy02:Number = triangle[2].y - triangle[0].y;
			var a01:Number = Math.atan2(dy01,dx01);
			var a02:Number = Math.atan2(dy02,dx02);
			
			var n:Number = Math.PI*2;
			if(a01<0)a01+=n;
			if(a02<0)a02+=n;
			
			if(a01<a02)
			{
				return true;
			}
			return false;
		}
		//==================================================================
		//判断切割线(第一点与最后一点的连线)与新多边形的其它边是否有交点，不包括相邻边
		private static function hasIntersection(ps:Vector.<Point>):Boolean
		{
			var len:int = ps.length - 1;
			var l1:Point = ps[0];
			var l2:Point = ps[len];
			var i:int;
			len-=1;
			
			for(i=1;i<len;i++)
			{
				if(intersect_in(l1,l2,ps[i],ps[i+1]))
				{
					return true;
				}
			}
			
			return false;
		}
		
		private static function hasIntersection2(ps:Vector.<Vertex>):Boolean
		{
			var len:int = ps.length - 1;
			var l1:Point = ps[0].point;
			var l2:Point = ps[len].point;
			var i:int;
			len-=1;
			
			for(i=1;i<len;i++)
			{
				if(intersect_in(l1,l2,ps[i].point,ps[i+1].point))
				{
					return true;
				}
			}
			
			return false;
		}
		
		//=========================================================================================================
		/**
		 * 测试
		 * @param u1
		 * @param u2
		 * @param v1
		 * @param v2
		 * @param ans
		 * 
		 */
		static public function test(u1:Point,u2:Point,v1:Point,v2:Point,ans:Point):void
		{
			if (parallel(u1,u2,v1,v2)||!intersect_in(u1,u2,v1,v2)){
				trace("无交点!\n");
			}
			else{
				ans=intersection(u1,u2,v1,v2);
				trace("交点为:(%lf,%lf)",ans.x,ans.y);
			}
		}
	}
	
}

