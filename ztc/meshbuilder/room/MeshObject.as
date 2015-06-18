package ztc.meshbuilder.room
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.lightpickers.StaticLightPicker;

	/**
	 * Mesh 物体的父类
	 */
	public class MeshObject
	{
		// Mesh
		public var mesh:Mesh;
		
		// 宽
		public var width:Number = 1500;
		// 高
		public var height:Number = 1000;
		// 厚度
		public var depth:Number = 150;
		// 框的宽度
		public var frameWidth:Number = 100;
		
		// 点集
		public var verticeData:Vector.<Vector3D> ;
		// 索引集
		public var indiceData:Vector.<uint> ;
		
		public function MeshObject()
		{
			verticeData = new Vector.<Vector3D>();
			indiceData = new Vector.<uint>();
		}
		
		/**
		 * 创建框,窗框,门框,回字型框
		 */
		public static function frameBuilder(width:Number,
											height:Number,
											depth:Number,
											frameWidth:Number,
											close:Boolean=true,
											smooth:Boolean= false,
											x_offset:Number = 0,
											y_offset:Number = 0,
											z_offset:Number = 0):Array {
			// 提拱的顶点数组
			var verticeData:Vector.<Number> = new Vector.<Number>();
			// 索引数组
			var indiceData:Vector.<uint> = new Vector.<uint>();
			
			// 真正的顶点数组(要比verticeData多,因为我们需要的是有棱角的Mesh)
			var realVerticeData:Vector.<Number>;
			// 真正的索引数组,因为索引需要根据计算出来的真正的顶点数组进行改变
			var realIndiceData:Vector.<uint>;
			
			// 16 个点
			var d:Number = depth / 2;
			
			verticeData.push(0,-height,-d);
			verticeData.push(frameWidth,close ? -height + frameWidth : -height,-d);
			verticeData.push(frameWidth,close ? -height + frameWidth : -height,d);
			verticeData.push(0,-height,d);
			
			verticeData.push(0,0,-d);
			verticeData.push(frameWidth,-frameWidth,-d);
			verticeData.push(frameWidth,-frameWidth,d);
			verticeData.push(0,0,d);
			
			verticeData.push(width,0,-d);
			verticeData.push(width - frameWidth,-frameWidth,-d);
			verticeData.push(width - frameWidth,-frameWidth,d);
			verticeData.push(width,0,d);
			
			verticeData.push(width,-height,-d);
			verticeData.push(width - frameWidth,close ? -height + frameWidth : -height,-d);
			verticeData.push(width - frameWidth,close ? -height + frameWidth : -height,d);
			verticeData.push(width,-height,d);
			
			// offset
			for (var j:int = 0; j < verticeData.length; j+= 3) {
				verticeData[j] += x_offset;
				verticeData[j + 1] += y_offset;
				verticeData[j + 2] += z_offset;
			}
			
			var capBegin:Boolean = false;
			var capEnd:Boolean = false;
			// 面的索引
			for (var i:int = 0; i < 4; i++) 
			{
				capBegin = capEnd = false;
				if (i < 3) {
					if (!close) { // 如果不是闭合的框,两头需要封口
						if (i == 0) {capBegin = true;}
						if (i == 2) {capEnd = true;}
					}
					
					indiceData = indiceData.concat(FillIndices(i * 4,4,null,smooth,capBegin,capEnd));
				} else if (close) { // 如果是闭合的框
					var arr:Vector.<uint> = new Vector.<uint>();
					arr.push(12,13,14,15,0,1,2,3);
					
					indiceData = indiceData.concat(FillIndices(-1,null,arr,smooth));
				}
			}
			
			// 返回: 数组 0:点集 1:索引集
			return smooth ? [ verticeData,indiceData ] : CalculateRealData(verticeData,indiceData);
		}
		
		/**
		 * 通过得到的面的索引数组.得到真正需要的点的大小,因为我们制作的框是有棱角的,所以不能两个点共用顶点
		 * 那样会生成圆滑的曲面儿,而不是我们需要的折边儿.所以需要重新生成顶点的数组
		 */
		public static function CalculateRealData(verticeData:Vector.<Number>,indiceData:Vector.<uint>):Array {
			var realVeticeCount:uint = indiceData.length / 6 * 4;
			var realVerticeData:Vector.<Number> = new Vector.<Number>();
			var realIndiceData:Vector.<uint> = new Vector.<uint>();
			
			var vCount:uint = 0;
			
			for (var j:int = 0; j < indiceData.length; j += 6) 
			{
				vCount = realVerticeData.length / 3;
				for (var k:int = 0; k < 6; k++) 
				{
					if (k < 4) {
						realVerticeData.push(
							verticeData[indiceData[j + k] * 3],
							verticeData[indiceData[j + k] * 3 + 1],
							verticeData[indiceData[j + k] * 3 + 2]
						);
						
						realIndiceData.push(vCount + k);
					} else if (k == 4) 
						realIndiceData.push(vCount);
					else if (k == 5) 
						realIndiceData.push(vCount + 2);
				}
			}
			
			return [ realVerticeData, realIndiceData ];
		}
		
		/**
		 * Fill Indices Array,下4,上4
		 * 返回: index Vector
		 */
		public static function FillIndices(startIndex:int,
										   step:uint = 4,
										   indiceArr:Vector.<uint> = null,
										   smooth:Boolean = false,
										   closeBegin:Boolean = false,
										   closeEnd:Boolean = false):Vector.<uint> {
			// 通过 StartIndex 与 Step 构建数组
			var indices:Vector.<uint>;
			if (startIndex >= 0) {
				indices = new Vector.<uint>();
				for (var j:int = 0; j < 2; j++) 
				{
					for (var k:int = 0; k < step; k++) 
					{
						indices.push(startIndex + j * step + k);					
					}
				}
			} else {
				if(indiceArr != null) 
					indices = indiceArr;
				else return null;
			}
			
			// 计算Indice
			var res:Vector.<uint> = new Vector.<uint>();
			
			for(var i:int = 0; i < 4;i++) {
				if (i < 3) {
					res.push(indices[i + 1],indices[i],indices[i + 4]);
					res.push(indices[i + 5],indices[i + 1],indices[i + 4]);
				} else {
					res.push(indices[i - 3],indices[i],indices[i + 4]);
					res.push(indices[i + 1],indices[i - 3],indices[i + 4]);
				}
			}
			
			// 封开始口
			if(closeBegin) {
				if (smooth) {
					res.push(indices[1],indices[2],indices[0]);
					res.push(indices[2],indices[3],indices[0]);
				} else {
					res.push(indices[0],indices[1],indices[2]);
					res.push(indices[3],indices[2],indices[1]);
				}
			}
			
			// 封结束口 
			if (closeEnd) {
				res.push(indices[6],indices[5],indices[4]);
				res.push(indices[7],indices[6],indices[4]);
			}
			
			return res;
		}
		
		/**
		 * 通过给定的两个点的坐标及长度与宽度值,来创建一个棍型Box
		 */
		public static function StickBuilder(startPoint:Vector3D,
											endPoint:Vector3D,
											width:Number = 10,
											height:Number = 10,
											smooth:Boolean = false,
											closeBegin:Boolean = false,
											closeEnd:Boolean = false):Array {
			// 点集
			var vs:Vector.<Number> = new Vector.<Number>();
			var w:Number = width / 2;
			var h:Number = height / 2;
			
			// start 4 points
			vs.push(startPoint.x - w,startPoint.y,startPoint.z - h);
			vs.push(startPoint.x + w,startPoint.y,startPoint.z - h);
			vs.push(startPoint.x + w,startPoint.y,startPoint.z + h);
			vs.push(startPoint.x - w,startPoint.y,startPoint.z + h);
			
			// end 4 points
			vs.push(endPoint.x - w,endPoint.y,endPoint.z - h);
			vs.push(endPoint.x + w,endPoint.y,endPoint.z - h);
			vs.push(endPoint.x + w,endPoint.y,endPoint.z + h);
			vs.push(endPoint.x - w,endPoint.y,endPoint.z + h);
			
			// 得到Index集
			var indices:Vector.<uint> = FillIndices(0,4,null,smooth,closeBegin,closeEnd);
			
			return smooth ? [ vs,indices ] : CalculateRealData(vs,indices);
		}
		
		/**
		 * 能过[verticeArry,indiceArry],得到SubGeometry
		 */
		public static function getSubGeometry(dataArray:Array):SubGeometry {
			var sg:SubGeometry = new SubGeometry();
			sg.updateVertexData(dataArray[0]);
			sg.updateIndexData(dataArray[1]);
			
			return sg;
		}
		
		public function update():void {
		}
		
		/**
		 * 为Material设置LightPicker
		 */
		public function setLightPicker(lp:StaticLightPicker):void {
		}
	}
}