package rightaway3d.heter.utils
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import away3d.core.math.Vector3DUtils;
	
	import rightaway3d.heter.core.SectionData;
	import rightaway3d.heter.core.degreesToRadians;
	import rightaway3d.heter.core.radiansToDegrees;
	
	public class SectionUtil
	{
		public function SectionUtil()
		{
		}
		/**
		 * 旋转截面所有点信息 
		 * @param _sectionData
		 * @param angle
		 * @return 
		 * 
		 */		
		public static function rotationSectionData(_sectionData:SectionData,angle:Number):SectionData
		{
			var length:uint = _sectionData.sectionVector.length;
			var v3ds:Vector.<Vector3D> = new Vector.<Vector3D>(length);
			var v3dss:Vector.<Vector3D> = _sectionData.sectionVector;
			
			for (var i:int = 0; i < length; i++) 
			{
				var v3dOld:Vector3D = new Vector3D(v3dss[i].x,v3dss[i].y,v3dss[i].z)
				var v3d:Vector3D = Vector3DUtils.rotatePoint(v3dOld,new Vector3D(0,angle,0));
				v3ds[i] = v3d;
			}
			var data:SectionData = new SectionData(v3ds);
			return data;
		}
		
		/**
		 *平移截面所有点 
		 * @param _sectionData
		 * @param translation
		 * @return 
		 * 
		 */		
		public static function getSectionDataByTranslation(_sectionData:SectionData,translation:Vector3D):SectionData
		{
			var len:uint = _sectionData.sectionVector.length;
			var _sectionLineDataVectors:Vector.<Vector3D> = new Vector.<Vector3D>(len); 
			
			for (var i:int = 0; i < len; i++) 
			{
				var v:Vector3D =_sectionData.sectionVector[i];
				var section0:Vector3D = new Vector3D(v.x,v.y,v.z);;
				var v3d:Vector3D = new Vector3D();
				v3d.x =	section0.x+translation.x ;
				v3d.y = section0.y ;
				v3d.z = section0.z +translation.z;
				_sectionLineDataVectors[i] = v3d;
			}
			var data:SectionData = new SectionData(_sectionLineDataVectors);
			return data;
		}
		/**
		 *通过距离 角度 的大角度坐标 
		 * @param orgin
		 * @param _angle
		 * @param distance
		 * @param type
		 * @return 
		 * 
		 */		
		public static function getVectot3DByAngle(orgin:Vector3D,_angle:Number,distance:Number = 10,type:String="Y"):Vector3D
		{
			var v3d:Vector3D = new Vector3D();
			if(type=="Y")
			{
				var point:Point = distanceAndAngleToPoint(distance,_angle,new Point(orgin.x,orgin.z));
				v3d.x = point.x;
				v3d.y = orgin.y;
				v3d.z = point.y;
			}
			return v3d;
		}
		
		/**
		 *截面路径从2D空间点坐标转换为3D空间坐标 
		 * @return 
		 * 
		 */		
		public static function transfromPath2DToPaht3D(path:Vector.<Point>,type:String="Z"):Vector.<Vector3D>
		{
			var len:uint = path.length;
			var vector3DPath:Vector.<Vector3D> = new Vector.<Vector3D>(len);
			
			for (var i:int = 0; i < len; i++) 
			{
				var v3d:Vector3D;
				if(type=="X")
				{
					v3d = new Vector3D(0,path[i].x,path[i].y);
				}else if(type=="Y")
				{
					v3d = new Vector3D(path[i].x,0,path[i].y);
				}else
				{
					v3d = new Vector3D(path[i].x,path[i].y);
					
				}
				vector3DPath[i] = v3d; 
			}
			return vector3DPath;
			
		}
		
		
		/**
		 *通过距离和角度求坐标 
		 * @param distance 距离长度
		 * @param angle 角度
		 * @param original 起始点
		 * @return 
		 * 
		 */		
		public static function distanceAndAngleToPoint(distance:Number,angle:Number,original:Point):Point
		{
			var point:Point = new Point;
			
			//			trace("点 线:"+angle)
			/*if(Math.abs(angle)>0||angle<-90)
			{
			angle-= 90;
			}else{
			//				angle =angle;
			}*/
			
			point.x  = original.x+distance*Math.cos(degreesToRadians(angle));
			point.y  = original.y+distance*Math.sin(degreesToRadians(angle));
			return point;
		}
		/**
		 *返回两点间的角度(180) 
		 * @param start
		 * @param end
		 * @return 
		 * 
		 */		
		public static function getRotationAngle(start:Point, end:Point):Number
		{
			
			var wx:Number = end.x-start.x;
			var hy:Number = end.y-start.y;
			var angle:Number = radiansToDegrees(Math.atan2(hy,wx));
			return angle;
		}
		
		/**
		 * 返回两点间的角度(360)
		 * @param start 起始点
		 * @param end 结束点
		 * @return 角度
		 * 
		 */		
		public static function getRotationAngle360(start:Point, end:Point) : Number
		{
			var angle:Number= 	getRotationAngle(start,end);
			if(angle<0)
			{
				angle = 360+angle
			}
			return angle;
		}
		
		/**
		 *判断两条线短是否相交 
		 * @param a
		 * @param b
		 * @param c
		 * @param d
		 * @return Object[crosspoint,state]
		 * 
		 */		
		public static function getIntersection(a:Point,b:Point,c:Point,d:Point):Object
		{
			var object:Object = new Object;
			var intersection:Point = new Point(0,0);
			
			if (Math.abs(b.y - a.y) + Math.abs(b.x - a.x) + Math.abs(d.y - c.y) + Math.abs(d.x - c.x) == 0)
			{
				if ((c.x - a.x) + (c.y - a.y) == 0)
				{
					trace("ABCD是同一个点！");
				}
				else
				{
					trace("AB是一个点，CD是一个点，且AC不同！");
				}
				object.state = 0;
				return object;
			}
			
			if (Math.abs(b.y - a.y) + Math.abs(b.x - a.x) == 0)
			{
				if ((a.x - d.x) * (c.y - d.y) - (a.y - d.y) * (c.x - d.x) == 0)
				{
					trace("A、B是一个点，且在CD线段上！");
				}
				else
				{
					trace("A、B是一个点，且不在CD线段上！");
				}
				object.state = 0;
				return object;
			}
			if (Math.abs(d.y - c.y) + Math.abs(d.x - c.x) == 0)
			{
				if ((d.x - b.x) * (a.y - b.y) - (d.y - b.y) * (a.x - b.x) == 0)
				{
					trace("C、D是一个点，且在AB线段上！");
				}
				else
				{
					trace("C、D是一个点，且不在AB线段上！");
				}
				object.state = 0;
				return object;
			}
			
			if ((b.y - a.y) * (c.x - d.x) - (b.x - a.x) * (c.y - d.y) == 0)
			{
//				trace("线段平行，无交点！");
				object.state = 0;
				return object;
			}
			
			intersection.x = ((b.x - a.x) * (c.x - d.x) * (c.y - a.y) -   
				c.x * (b.x - a.x) * (c.y - d.y) + a.x * (b.y - a.y) * (c.x - d.x)) /   
				((b.y - a.y) * (c.x - d.x) - (b.x - a.x) * (c.y - d.y));
			intersection.y = ((b.y - a.y) * (c.y - d.y) * (c.x - a.x) - c.y  
				* (b.y - a.y) * (c.x - d.x) + a.y * (b.x - a.x) * (c.y - d.y))  
				/ ((b.x - a.x) * (c.y - d.y) - (b.y - a.y) * (c.x - d.x));
			
			if ((intersection.x - a.x) * (intersection.x - b.x) <= 0  
				&& (intersection.x - c.x) * (intersection.x - d.x) <= 0  
				&& (intersection.y - a.y) * (intersection.y - b.y) <= 0  
				&& (intersection.y - c.y) * (intersection.y - d.y) <= 0)
			{
				
				object.state = 1;
				object.crosspoint = intersection;
				return object;
				//				return 1;// '相交  
			}
			else
			{
				//trace("线段相交于虚交点(" + intersection.x + "," + intersection.y + ")！");
				object.state = -1;
				object.crosspoint = intersection;
				return object;
				//				return -1;// '相交但不在线段上  
			}
		}
	}
}