package rightaway3d.heter.utils
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.tools.helpers.MeshHelper;
	
	import rightaway3d.heter.core.LoftingData;
	import rightaway3d.heter.core.SectionData;
	import rightaway3d.heter.core.Triangle;
	
	public class Lofting3D 
	{
		
		public function Lofting3D()
		{
			super();
			
		}
		
		/**
		 *创建 放样3D 
		 * @param sectionPath 截面
		 * @param loftingPath 放样路径
		 * @param material 物体材质
		 * @param name 物体名字
		 * @param unit 单位 默认毫米
		 * @param u 手动调整 u 默认值为 1 
		 * @param v 手动调整 v 默认值为 1
		 * @param twoSided 开始双目显示  默认值为 false
		 * @param flipFaces 翻转面，法线也会随着改变  默认值为 false
		 * @return 
		 * 
		 */		
		public function createLofting3D(sectionPath:Vector.<Point>,loftingPath:Vector.<Point>,material:TextureMaterial=null,name:String="lofting3d",unit:uint=1000,u:Number=1,v:Number=1,twoSided:Boolean = false,flipFaces:Boolean=false):Mesh
		{
			
			var sectionPath3D:Vector.<Vector3D> = SectionUtil.transfromPath2DToPaht3D(sectionPath,"X");
			var loftingPath3D:Vector.<Vector3D> = SectionUtil.transfromPath2DToPaht3D(loftingPath,"Y");
			//创建基础截面
			var sectionData:SectionData = createScetion(sectionPath3D);
			//创建放样单个路径截面
			var sectionStartend:Vector.<SectionData> = createLoftingScetion(sectionData,loftingPath3D);
			var startSection:SectionData = sectionStartend[0];
			var endSection:SectionData = sectionStartend[1];
			
			//计算所有路径
			var loftingPahtLen:uint = loftingPath3D.length;
			var loftings:Vector.<LoftingData> = new Vector.<LoftingData>(loftingPahtLen-2)
			for (var i:int = 0; i < loftingPahtLen-2; i++) 
			{
				var loftingData:LoftingData = new LoftingData(sectionData,loftingPath3D[i],loftingPath3D[i+1],loftingPath3D[i+2]);
				loftings[i] = loftingData;
			}
			
			var loftlingV:Vector.<Vector.<Vector3D>> =new Vector.<Vector.<Vector3D>>();
			var p1:uint=0;
			var p2:uint=0;
			var p3:uint=0;
			var p4:uint=0;
			var loftingLen:uint = loftings.length;
			for (var k:int = 0; k < sectionData.sectionVector.length; k++) 
			{
				var v3ds:Vector.<Vector3D> = new Vector.<Vector3D>();
				for (var j:int = 0; j < loftingLen; j++) 
				{
					if(j==0)
					{
						v3ds.push(startSection.sectionVector[k]);
					}
					v3ds.push(loftings[j].endSection.sectionVector[k]);
					if(j==loftingLen-1)
					{
						v3ds.push(endSection.sectionVector[k]);
					}
				}
				
				loftlingV.push(v3ds);
			}
			return createMesh(loftlingV,material,name,unit,u,v,twoSided,flipFaces);;
		}
		/**
		 *创建截面 
		 * 
		 */		
		private function createScetion(sectionPath3D:Vector.<Vector3D>):SectionData
		{
			var sectionData:SectionData = new SectionData(sectionPath3D);
			return sectionData;
		}
		
		private function createLoftingScetion(sectionData:SectionData,loftingPath3D:Vector.<Vector3D>):Vector.<SectionData>
		{
			var startAngle:Number = SectionUtil.getRotationAngle(new Point(loftingPath3D[0].x,loftingPath3D[0].z),new Point(loftingPath3D[1].x,loftingPath3D[1].z))
			var startSection:SectionData = SectionUtil.rotationSectionData(sectionData,-startAngle);
			var len:uint = loftingPath3D.length;
			var endAngle:Number = SectionUtil.getRotationAngle(new Point(loftingPath3D[len-2].x,loftingPath3D[len-2].z),new Point(loftingPath3D[len-1].x,loftingPath3D[len-1].z));
			var _endSection:SectionData = SectionUtil.rotationSectionData(sectionData,-endAngle);
			var endSection:SectionData = SectionUtil.getSectionDataByTranslation(_endSection,loftingPath3D[len-1]);
			var sectionStartEnd:Vector.<SectionData> = new Vector.<SectionData>(2);
			sectionStartEnd[0] = startSection;
			sectionStartEnd[1] = endSection;
			return sectionStartEnd;
		}
		
		
		
		//	=====================================================创建Mesh===========================================================
		
		private function createMesh(verticesLines:Vector.<Vector.<Vector3D>>,_material:MaterialBase,name:String,unit:uint,u:Number,v:Number,twoSided:Boolean = false,flipFaces:Boolean=false):Mesh
		{
			var vertices:Vector.<Number> = new Vector.<Number>();
			var uvs:Vector.<Number> = new Vector.<Number>();
			var normals:Vector.<Number> = new Vector.<Number>();
			var tangents:Vector.<Number> = new Vector.<Number>();
			var indices:Vector.<uint> = new Vector.<uint>();
			var index:uint = 0;
			var triangles:Vector.<Triangle> = new Vector.<Triangle>;
			var trianglePoints:Vector.<Vector3D> = new Vector.<Vector3D>;
			var scentlineLen:uint = verticesLines.length;
			
			var u_d:String = 'x';
			var v_d:String = 'y';
			for (var k:int = 0; k < scentlineLen-1; k++) 
			{
				var line1:Vector.<Vector3D> = verticesLines[k];
				var line2:Vector.<Vector3D> = verticesLines[k+1];
				var LineLen:uint = line1.length;
				
				var angleYZ:Number = SectionUtil.getRotationAngle360(new Point(line1[0].y,line1[0].z),new Point(line2[0].y,line2[0].z));
				for (var i:int = 0; i < LineLen-1; i++) 
				{
					var triangle:Triangle = new Triangle();
					var triangle1:Triangle = new Triangle();
					triangle.v1 = line1[i];
					triangle.v2 = line2[i];
					triangle.v3 = line1[i+1];
					triangle1.v1 = line1[i+1];
					triangle1.v2 = line2[i];
					triangle1.v3 = line2[i+1];
					var angleXZ:Number = SectionUtil.getRotationAngle360(new Point(line1[i].x,line1[i].z),new Point(line1[i+1].x,line1[i+1].z));
					if((45<=angleYZ&&angleYZ<=135)||(225<=angleYZ&&angleYZ<=315))
					{
						u_d = 'x';
						v_d = 'z';
					}
					else 
					{
						if((45<=angleXZ&&angleXZ<=135)||(225<=angleXZ&&angleXZ<=315))
						{
							u_d = 'y';
							v_d = 'z';
						}else
						{
							u_d = 'x';
							v_d = 'y';
						}
					}
					
					var u1:Number =triangle.v1[u_d]/unit*u;
					var v1:Number =triangle.v1[v_d]/unit*v;
					var u2:Number =triangle.v2[u_d]/unit*u;
					var v2:Number =triangle.v2[v_d]/unit*v;
					var u3:Number =triangle.v3[u_d]/unit*u;
					var v3:Number =triangle.v3[v_d]/unit*v;
					var u4:Number =triangle1.v3[u_d]/unit*u;
					var v4:Number =triangle1.v3[v_d]/unit*v;
					
					uvs.push(u1,v1,u2,v2,u3,v3,u3,v3,u2,v2,u4,v4);
					triangles.push(triangle,triangle1);
				}
			}
			
			
			for each (var tri:Triangle in triangles) 
			{
				trianglePoints.push(tri.v1,tri.v2,tri.v3);
			}
			
			for (var j:int = 0; j < trianglePoints.length; j++) 
			{
				
				var v3d:Vector3D = trianglePoints[j];
				indices.push(index++);	
				vertices.push(v3d.x);
				vertices.push(v3d.y);
				vertices.push(v3d.z);
			}
			if(flipFaces)indices.reverse();
			var len:uint = indices.length;
			if(twoSided)
			{
				for (var fi:uint = 0; fi<len; fi+=3) 
				{
					indices.push(indices[fi+2], indices[fi+1], indices[fi])
				}
			}
			return  MeshHelper.build(vertices,indices,uvs,name,_material);;
		}
		
	}
}