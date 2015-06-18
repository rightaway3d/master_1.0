package rightaway3d.house.view3d.base
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PrimitiveBase;
	
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	
	public class WallGeometry extends PrimitiveBase
	{
		public var vo:Wall;
		
		public var frontGeom:CompactSubGeometry;
		public var backGeom:CompactSubGeometry;
		//public var frontGeom:SubGeometry;
		//public var backGeom:SubGeometry;
		
		/**
		 * 墙体正面贴图材质的宽度，用于计算贴图UV
		 */
		public var frontTextureWidth:Number = 1000;
		/**
		 * 墙体正面贴图材质的高度，用于计算贴图UV
		 */
		public var frontTextureHeight:Number = 1000;
		
		/**
		 * 墙体背面贴图材质的宽度，用于计算贴图UV
		 */
		public var backTextureWidth:Number = 1000;
		/**
		 * 墙体背面贴图材质的高度，用于计算贴图UV
		 */
		public var backTextureHeight:Number =  1000;
		
		public function WallGeometry(wall:Wall)
		{
			super();
			this.vo = wall;
			init();
		}
		
		private function init():void
		{
			frontGeom = getSubGeom();
			backGeom = getSubGeom();
		}
		
		private function getSubGeom():CompactSubGeometry
		{
			var subGeom:CompactSubGeometry = new CompactSubGeometry();
			subGeom.autoGenerateDummyUVs = false;
			addSubGeometry(subGeom);
			return subGeom;
		}
		
		public function updateGeometry():void
		{
			this.invalidateGeometry();
		}
		
		public function updateUVs():void
		{
			this.invalidateUVs();
		}
		
		//在墙体刨去墙洞区域后所划分的若干矩形区域
		private var surfaceRects:Vector.<Rectangle> = new Vector.<Rectangle>();
		
		private var numVertices:int;
		private var numIndices:int;
		
		//计算创建墙体除正面与背面区域后，所需要的顶点数量，及三角形顶点索引数（包括墙洞上下左右4个侧面）
		private function countNumVertices():void
		{
			numVertices = 12;//墙体的底面和顶面各有6个顶点
			numIndices = 24;//墙体的底面和顶面各有4个三角面，每个三角面3个顶点索引，计24个
			
			if(vo.groundHeadPoint.crossWalls.length==1)
			{
				numVertices += 4;//墙体头端没有相交墙体时，取头端上下前后4个角顶点绘制闭合面
				numIndices += 6;//墙头2个三角面，计6个顶点索引
			}
			
			if(vo.groundEndPoint.crossWalls.length==1)
			{
				numVertices += 4;//墙体尾端没有相交墙体时，取尾端上下前后4个角顶点绘制闭合面
				numIndices += 6;//墙尾2个三角面，计6个顶点索引
			}
			
			var len:int = vo.holes.length;
			for(var i:int=0;i<len;i++)
			{
				numVertices += 16;//洞口上下左右4个面各4个点，计16个点
				numIndices += 24;//洞口内侧的4个矩形区域，每个矩形区域有2个三角面，每个三角面3个顶点索引,计24个索引
			}
			
			/*surfaceRects.length = 0;
			
			numVertices += 8;//墙体的正面及背面的4个角，各4个顶点
			numIndices += 12;//没有墙洞时，墙体的正面及背面各2个三角面，计12个顶点索引
			
			var len:int = vo.holes.length;
			//trace("holes:"+len);
			if(len==0)
			{
				surfaceRects.push(new Rectangle(0,0,vo.length,vo.floor.ceilingHeight));//没有洞口时，整面墙体作为一个区域
			}
			else
			{
				sortHoles(vo.holes);
				
				var h0:WallHole = vo.holes[0];
				addSurfaceArea(h0,0);
				
				for(var i:int=1;i<len;i++)
				{
					var h:WallHole = vo.holes[i-1];
					h0 = vo.holes[i];
					addSurfaceArea(h0,h.x+h.width);
				}
				
				var rect:Rectangle = new Rectangle(h0.x+h0.width,0,vo.length-(h0.x+h0.width),vo.floor.ceilingHeight);//最右侧洞口的右侧区域
				surfaceRects.push(rect);
			}*/
		}
		
		private function countNumVertices2():void
		{
			/*numVertices = 12;//墙体的底面和顶面各有6个顶点
			numIndices = 24;//墙体的底面和顶面各有4个三角面，每个三角面3个顶点索引，计24个
			
			if(vo.groundHeadPoint.crossWalls.length==1)
			{
				numVertices += 4;//墙体头端没有相交墙体时，取头端上下前后4个角顶点绘制闭合面
				numIndices += 6;//墙头2个三角面，计6个顶点索引
			}
			
			if(vo.groundEndPoint.crossWalls.length==1)
			{
				numVertices += 4;//墙体尾端没有相交墙体时，取尾端上下前后4个角顶点绘制闭合面
				numIndices += 6;//墙尾2个三角面，计6个顶点索引
			}*/
			
			surfaceRects.length = 0;
			
			numVertices = 4;//墙体的单面4个角，计4个顶点
			numIndices = 6;//没有墙洞时，墙体的单面2个三角面，计6个顶点索引
			
			var len:int = vo.holes.length;
			//trace("holes:"+len);
			if(len==0)
			{
				surfaceRects.push(new Rectangle(0,0,vo.length,vo.floor.ceilingHeight));//没有洞口时，整面墙体作为一个区域
			}
			else
			{
				//sortHoles(vo.holes);
				
				var h0:WallHole = vo.holes[0];
				addSurfaceArea(h0,0);
				
				for(var i:int=1;i<len;i++)
				{
					var h:WallHole = vo.holes[i-1];
					h0 = vo.holes[i];
					addSurfaceArea(h0,h.x+h.width);
				}
				
				var rect:Rectangle = new Rectangle(h0.x+h0.width,0,vo.length-(h0.x+h0.width),vo.floor.ceilingHeight);//最右侧洞口的右侧区域
				surfaceRects.push(rect);
			}
		}
		
		private function addSurfaceArea(hole:WallHole,left:Number):void
		{
			numVertices += 12;//墙洞左侧及上下方3个矩形区域，每个矩形4个点，计12个点
			numIndices += 18;//洞口左侧及上下方3个矩形区域，每个矩形区域有2个三角面，每个三角面3个顶点索引，计18个顶点索引
			
			var rect:Rectangle = new Rectangle(left,0,hole.x-left,vo.floor.ceilingHeight);//洞口左侧区域
			surfaceRects.push(rect);
			
			rect = new Rectangle(hole.x,0,hole.width,hole.y);//洞口下方区域
			surfaceRects.push(rect);
			
			rect = new Rectangle(hole.x,hole.y+hole.height,hole.width,vo.floor.ceilingHeight-(hole.y+hole.height));//洞口上方区域
			surfaceRects.push(rect);
		}
		
		private var vertexIndex:int;
		private var strideSkip:int;
		private var stride:uint;
		
		private function addVertex(data:Vector.<Number>,x:Number,y:Number,z:Number,nx:Number,ny:Number,nz:Number,tx:Number,ty:Number,tz:Number):void
		{
			_addVertex(data,x,y,z,nx,ny,nz,tx,ty,tz);			
			vertexIndex += strideSkip;
		}
		
		private function addVertexUV(data:Vector.<Number>,x:Number,y:Number,z:Number,nx:Number,ny:Number,nz:Number,tx:Number,ty:Number,tz:Number,u:Number,v:Number):void
		{
			//trace("addVertexUV:"+u,v);
			_addVertex(data,x,y,z,nx,ny,nz,tx,ty,tz);			
			data[vertexIndex++] = u;
			data[vertexIndex++] = v;
			data[vertexIndex++] = u;
			data[vertexIndex++] = v;
		}
		
		private function _addVertex(data:Vector.<Number>,x:Number,y:Number,z:Number,nx:Number,ny:Number,nz:Number,tx:Number,ty:Number,tz:Number):void
		{
			//trace("addVertex vertexIndex:"+(getCurrVertexIndex()),vertexIndex+" xyz:"+x,y,z);
			//trace("data length:"+data.length+" vertexIndex:"+vertexIndex);
			data[vertexIndex++] = x;
			data[vertexIndex++] = y;
			data[vertexIndex++] = z;
			
			data[vertexIndex++] = nx;
			data[vertexIndex++] = ny;
			data[vertexIndex++] = nz;
			
			data[vertexIndex++] = tx;
			data[vertexIndex++] = ty;
			data[vertexIndex++] = tz;
		}
		
		//添加四边形顶点索引，将四边形拆分为两个三角形
		private function addQuadrilateralIndex(indices:Vector.<uint>,n1:int,n2:int,n3:int,n4:int):void
		{
			//trace("\n numIndices:"+numIndices+" n:"+n1,n2,n3,n4);
			indices[numIndices++] = n1;
			indices[numIndices++] = n2;
			indices[numIndices++] = n4;
			
			indices[numIndices++] = n2
			indices[numIndices++] = n3;
			indices[numIndices++] = n4;
		}
		
		//创建墙体的底面和顶面
		private function createFace1(data:Vector.<Number>,indices:Vector.<uint>):void
		{
			var p1:Point3D = vo.groundHead;
			var p2:Point3D = vo.groundFrontHead;
			var p3:Point3D = vo.groundFrontEnd;
			var p4:Point3D = vo.groundEnd;
			var p5:Point3D = vo.groundBackEnd;
			var p6:Point3D = vo.groundBackHead;
			
			//底面
			var y:Number = 0;
			var n:int = getCurrVertexIndex();
			var nx:Number=0,ny:Number=-1,nz:Number=0,tx:Number=1,ty:Number=0,tz:Number=0;
			
			addVertex(data,p1.x,y,p1.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p2.x,y,p2.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p3.x,y,p3.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p4.x,y,p4.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p5.x,y,p5.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p6.x,y,p6.z,nx,ny,nz,tx,ty,tz);
			
			addQuadrilateralIndex(indices,n,n+1,n+2,n+3);
			addQuadrilateralIndex(indices,n,n+3,n+4,n+5);
			
			//顶面
			n = getCurrVertexIndex();
			ny = 1;
			y = vo.floor.ceilingHeight;
			
			addVertex(data,p1.x,y,p1.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p2.x,y,p2.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p3.x,y,p3.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p4.x,y,p4.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p5.x,y,p5.z,nx,ny,nz,tx,ty,tz);
			addVertex(data,p6.x,y,p6.z,nx,ny,nz,tx,ty,tz);
			
			addQuadrilateralIndex(indices,n,n+5,n+4,n+3);
			addQuadrilateralIndex(indices,n,n+3,n+2,n+1);
		}
		
		//创建墙体的左右侧面
		private function createFace2(data:Vector.<Number>,indices:Vector.<uint>):void
		{
			if(vo.groundHeadPoint.crossWalls.length==1 || vo.groundEndPoint.crossWalls.length==1)
			{
				var p1:Point3D = vo.groundBackHead;
				var p2:Point3D = vo.groundFrontHead;
				var p3:Point3D = p2.clone();
				p3.y = vo.floor.ceilingHeight;
				var p4:Point3D = p1.clone();
				p4.y = p3.y;
				
				var nx:Number=-1,ny:Number=0,nz:Number=0,tx:Number=0,ty:Number=0,tz:Number=-1;
				
				//left
				if(vo.groundHeadPoint.crossWalls.length==1)
				{
					var x:Number = 0;
					var n:int = getCurrVertexIndex();
					
					addVertex(data,x,p1.y,p1.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p2.y,p2.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p3.y,p3.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p4.y,p4.z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+3,n+2,n+1);
				}
				
				//right
				if(vo.groundEndPoint.crossWalls.length==1)
				{
					x = vo.length;
					n = getCurrVertexIndex();
					nx = 1;
					tz = 1;
					
					addVertex(data,x,p1.y,p1.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p2.y,p2.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p3.y,p3.z,nx,ny,nz,tx,ty,tz);
					addVertex(data,x,p4.y,p4.z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+1,n+2,n+3);
				}
			}
		}
		
		//创建洞口内侧面
		private function createHoleFace(data:Vector.<Number>,indices:Vector.<uint>):void
		{
			var len:int = vo.holes.length;
			if(len>0)
			{
				var nx:Number=0,ny:Number=0,nz:Number=0,tx:Number=0,ty:Number=0,tz:Number=0;
				var p0:Point3D=new Point3D(),p1:Point3D=new Point3D(),p2:Point3D=new Point3D(),p3:Point3D=new Point3D();
				var z:Number = vo.width * 0.5;
				
				for(var i:int=0;i<len;i++)
				{
					var h:WallHole = vo.holes[i];
					p0.x = h.x;
					p0.y = h.y;
					p1.x = h.x+h.width;
					p1.y = h.y;
					p2.x = h.x+h.width;
					p2.y = h.y+h.height;
					p3.x = h.x;
					p3.y = h.y+h.height;
					
					//窗洞底面
					var n:int = getCurrVertexIndex();
					ny = 1;
					tx = 1;
					
					addVertex(data,p0.x,p0.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p1.x,p1.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p1.x,p1.y,z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p0.x,p0.y,z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+3,n+2,n+1);
					
					//窗洞顶面
					n = getCurrVertexIndex();
					
					addVertex(data,p3.x,p3.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p2.x,p2.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p2.x,p2.y,z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p3.x,p3.y,z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+1,n+2,n+3);
					
					//窗洞左面
					n = getCurrVertexIndex();
					ny = 0;
					tx = 0;
					nx = 1;
					tz = 1;
					
					addVertex(data,p3.x,p3.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p0.x,p0.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p0.x,p0.y,z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p3.x,p3.y,z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+3,n+2,n+1);
					
					//窗洞左面
					n = getCurrVertexIndex();
					nx = -1;
					tz = -1;
					
					addVertex(data,p2.x,p2.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p1.x,p1.y,-z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p1.x,p1.y,z,nx,ny,nz,tx,ty,tz);
					addVertex(data,p2.x,p2.y,z,nx,ny,nz,tx,ty,tz);
					
					addQuadrilateralIndex(indices,n,n+1,n+2,n+3);
				}
			}
		}
		
		//创建墙体的正面及背面
		private function createFrontFace(data:Vector.<Number>,indices:Vector.<uint>,target:CompactSubGeometry):void
		{
			var p1:Point = new Point();
			var p2:Point = new Point();
			var p3:Point = new Point();
			var p4:Point = new Point();
			
			var nx:Number=0,ny:Number=0,nz:Number=-1,tx:Number=1,ty:Number=0,tz:Number=0;//back data
			var z:Number = -vo.width * 0.5;
			
			var x0:Number = vo.groundFrontHead.x;
			
			var length:Number = vo.groundFrontEnd.x - x0;
			var height:Number = vo.floor.ceilingHeight;
			
			var su:Number = length/frontTextureWidth;
			var sv:Number = height/frontTextureHeight;
			//target.scaleUV(su,sv);
			
			var u:Number,v:Number;
			
			var len:int = surfaceRects.length;
			for(var i:int=0;i<len;i++)
			{
				var r:Rectangle = surfaceRects[i].clone();
				if(r.x==0)
				{
					var dx:Number = vo.groundFrontHead.x - r.x;
					r.x = vo.groundFrontHead.x;
					r.width -= dx;
				}
				if(r.x+r.width==vo.length)
				{
					dx = vo.groundFrontEnd.x - vo.length;
					r.width += dx;
				}
				p1.x = r.x;
				p1.y = r.y;
				p2.x = r.x+r.width;
				p2.y = r.y;
				p3.x = r.x+r.width;
				p3.y = r.y+r.height;
				p4.x = r.x;
				p4.y = r.y+r.height;
				
				//front
				var n:int = getCurrVertexIndex();
				
				u = (p1.x-x0)/length*su;
				v = (1-p1.y/height)*sv;;
				addVertexUV(data,p1.x,p1.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (p2.x-x0)/length*su;
				v = (1-p2.y/height)*sv;;
				addVertexUV(data,p2.x,p2.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (p3.x-x0)/length*su;
				v = (1-p3.y/height)*sv;;
				addVertexUV(data,p3.x,p3.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (p4.x-x0)/length*su;
				v = (1-p4.y/height)*sv;;
				addVertexUV(data,p4.x,p4.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				addQuadrilateralIndex(indices,n,n+3,n+2,n+1);
			}
		}
		
		//创建墙体的正面及背面
		private function createBackFace(data:Vector.<Number>,indices:Vector.<uint>,target:CompactSubGeometry):void
		{
			var p1:Point = new Point();
			var p2:Point = new Point();
			var p3:Point = new Point();
			var p4:Point = new Point();
			
			var nx:Number=0,ny:Number=0,nz:Number=1,tx:Number=-1,ty:Number=0,tz:Number=0;//back data
			var z:Number = vo.width * 0.5;
			
			var x0:Number = vo.groundBackHead.x;
			
			var length:Number = vo.groundBackEnd.x - x0;
			var height:Number = vo.floor.ceilingHeight;
			
			var su:Number = length/backTextureWidth;
			var sv:Number = height/backTextureHeight;
			
			var u:Number,v:Number;
			
			var len:int = surfaceRects.length;
			for(var i:int=0;i<len;i++)
			{
				var r:Rectangle = surfaceRects[i].clone();
				if(r.x==0)
				{
					var dx:Number = vo.groundBackHead.x - r.x;
					r.x = vo.groundBackHead.x;
					r.width -= dx;
				}
				if(r.x+r.width==vo.length)
				{
					dx = vo.groundBackEnd.x - vo.length;
					r.width += dx;
				}
				p1.x = r.x;
				p1.y = r.y;
				p2.x = r.x+r.width;
				p2.y = r.y;
				p3.x = r.x+r.width;
				p3.y = r.y+r.height;
				p4.x = r.x;
				p4.y = r.y+r.height;
				
				//back
				var n:int = getCurrVertexIndex();
				
				u = (1-(p1.x-x0)/length)*su;
				v = (1-p1.y/height)*sv;
				addVertexUV(data,p1.x,p1.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (1-(p2.x-x0)/length)*su;
				v = (1-p2.y/height)*sv;
				addVertexUV(data,p2.x,p2.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (1-(p3.x-x0)/length)*su;
				v = (1-p3.y/height)*sv;
				addVertexUV(data,p3.x,p3.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				u = (1-(p4.x-x0)/length)*su;
				v = (1-p4.y/height)*sv;
				addVertexUV(data,p4.x,p4.y,z,nx,ny,nz,tx,ty,tz,u,v);
				
				addQuadrilateralIndex(indices,n,n+1,n+2,n+3);
			}
		}
		
		private function getCurrVertexIndex():int
		{
			return vertexIndex/stride;
		}
		
		private function createFace(data:Vector.<Number>,indices:Vector.<uint>,target:CompactSubGeometry):void
		{
			createFace1(data,indices);
			createFace2(data,indices);
			createHoleFace(data,indices);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function buildGeometry(target:CompactSubGeometry):void
		{
			_buildGeom(target,countNumVertices,createFace);
			_buildGeom(frontGeom,countNumVertices2,createFrontFace);
			_buildGeom(backGeom,countNumVertices2,createBackFace);
		}
		
		private function _buildGeom(target:CompactSubGeometry,countVerticesFun:Function,createFaceFun:Function):void
		{
			var data:Vector.<Number>;//顶点数据集
			var indices:Vector.<uint>;//顶点索引集
			
			vertexIndex = target.vertexOffset;
			stride = target.vertexStride;
			strideSkip = stride - 9;
			
			//countNumVertices();
			countVerticesFun();
			//trace("numVertices:"+numVertices);
			
			if (numVertices == target.numVertices) {
				data = target.vertexData;
				indices = target.indexData || new Vector.<uint>(numIndices, true);
			} else {
				data = new Vector.<Number>(numVertices*stride, true);
				indices = new Vector.<uint>(numIndices, true);
				invalidateUVs();
			}
			//trace("numVertices:"+data.length);
			//trace("numIndices:"+indices.length);
			
			numIndices = 0;
			
			/*createFace1(data,indices);
			createFace2(data,indices);
			createFrontFace(data,indices);
			createBackFace(data,indices);
			createHoleFace(data,indices);*/
			createFaceFun(data,indices,target);
			
			target.updateData(data);
			target.updateIndexData(indices);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function buildUVs(target:CompactSubGeometry):void
		{
			/*var data:Vector.<Number>;
			var stride:uint = target.UVStride;
			var skip:uint = stride - 4;
			
			target.updateData(data);*/
		}
	}
}