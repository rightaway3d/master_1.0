package rightaway3d.heter.core
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import rightaway3d.heter.utils.SectionUtil;
	
	public class LoftingData
	{
		public var startSection:SectionData;
		public var endSection:SectionData;
		public var sectionData:SectionData;
		public var endVector3d:Vector3D;
		public var startVectot3d:Vector3D;
		public var endNextVector3d:Vector3D;
		
		public var length:uint;
		public var distance:Number
		
		public function LoftingData(_sectionData:SectionData,_startVector3d:Vector3D,_endVector3d:Vector3D,_endNextVector:Vector3D)
		{
			sectionData = _sectionData;
			startVectot3d = _startVector3d;
			endVector3d = _endVector3d;
			endNextVector3d = _endNextVector;
			length = sectionData.sectionVector.length;
			createLofting();
		}
		
		
		public function createLofting():void
		{
			var line1:Vector.<SectionData> = createLoftingLine(startVectot3d,endVector3d);
			var line2:Vector.<SectionData> = createLoftingLine(endVector3d,endNextVector3d)
			endSection = calculationCrossSctionData(line1,line2,endVector3d);
		}
		
		private function createLoftingLine(startV:Vector3D,endV:Vector3D):Vector.<SectionData>
		{
			var startAngle:Number = SectionUtil.getRotationAngle(new Point(startV.x,startV.z),new Point(endV.x,endV.z));
			var distance:Number = Vector3D.distance(startV,endV);
			var startEnd:Vector3D = SectionUtil.getVectot3DByAngle(startV,startAngle,distance);
			var dx:Number = startEnd.x-startV.x
			var dz:Number = startEnd.z-startV.z
			var _startSectionData:SectionData = SectionUtil.rotationSectionData(sectionData,-startAngle);
			var startSectionData:SectionData = SectionUtil.getSectionDataByTranslation(_startSectionData,new Vector3D(startV.x,0,startV.z));
			var _endSectionData:SectionData =SectionUtil.rotationSectionData(sectionData,-startAngle);
			var endSectionData:SectionData =SectionUtil.getSectionDataByTranslation(_endSectionData,new Vector3D(dx+startV.x,0,dz+startV.z));
			var sectionLine:Vector.<SectionData> = new Vector.<SectionData>(2);
			sectionLine[0] = startSectionData;
			sectionLine[1] = endSectionData;
			return sectionLine;
		}
		
		
		private function calculationCrossSctionData(startSectionLine:Vector.<SectionData>,endSectionLine:Vector.<SectionData>,_startVec:Vector3D):SectionData
		{
			
			var line1:SectionData = startSectionLine[0];
			var line2:SectionData = startSectionLine[1];
			var line3:SectionData = endSectionLine[0];
			var line4:SectionData = endSectionLine[1];
			var _sectionDataVector:Vector.<Vector3D> = new Vector.<Vector3D>(length);
			for (var i:int = 0; i < length; i++) 
			{
				var a:Point = new Point(Number((line1.sectionVector[i].x).toFixed(2)),Number(line1.sectionVector[i].z.toFixed(2)));
				var b:Point = new Point(Number(line2.sectionVector[i].x.toFixed(2)),Number(line2.sectionVector[i].z.toFixed(2)));
				var d:Point = new Point(Number(line3.sectionVector[i].x.toFixed(2)),Number(line3.sectionVector[i].z.toFixed(2)));
				var c:Point = new Point(Number(line4.sectionVector[i].x.toFixed(2)),Number(line4.sectionVector[i].z.toFixed(2)));
				var obj:Object = SectionUtil.getIntersection(a,b,c,d);                  
				if(obj.crosspoint)
				{
					var crossPoint:Point = obj.crosspoint;
					
					_sectionDataVector[i] = v3d;
				}else
				{
					crossPoint = new Point(line3.sectionVector[i].x,line3.sectionVector[i].z)
				}
				var v3d:Vector3D = new Vector3D(crossPoint.x,line1.sectionVector[i].y,crossPoint.y);
				_sectionDataVector[i] = v3d;
			}
			var sectionDataCross:SectionData = new SectionData(_sectionDataVector);
			return sectionDataCross;
		}
	}
}