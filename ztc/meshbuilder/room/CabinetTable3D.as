package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.math.Vector3DUtils;
	import away3d.entities.Mesh;
	
	import org.poly2tri.Point;
	import org.poly2tri.Sweep;
	import org.poly2tri.SweepContext;
	import org.poly2tri.Triangle;
	
	/**
	 * 橱柜台面Mesh物体: CabinetTabel3D(外圈点,洞圈点,半径,圆角段数,高,挡水点集,挡水高,挡水宽)
	 * 注: 点以逆时针方向排列
	 */
	public class CabinetTable3D extends Mesh
	{
		public var sweepContext:SweepContext;
		// 为计算面积(忽略中间的水盆的面积),只计算整个面板的面积
		private var _sweepContext:SweepContext;
		private var _sweep:Sweep;
		
		public var sweep:Sweep;
		public var triangulated:Boolean = false;
		
		public var verticeData:Vector.<Point>;
		public var indiceData:Vector.<uint>;
		
		public var height:Number;
		public var radius:Number;
		public var segment:uint;
		
		private var border:Vector.<Point>;
		private var hole:Vector.<Point>;
		
		// 保存原始的point序列
		private var originalPointsArr:Vector.<Point>;
		private var borderCnt:uint;
		private var innerCnt:uint;
		private var allCnt:uint;
		
		private var dang:Vector.<Point>;
		private var dangWidth:Number;
		private var dangHeight:Number;
		
		//private var _mat:TextureMaterial;
		
		//private var _textureURL:String="";
		//private var _normalURL:String="";
		
		public function CabinetTable3D(border:Vector.<Point>,hole:Vector.<Point>=null,
									   radius:Number=30,segment:uint=8,height:Number=40,
									   dangshui:Vector.<Point> = null,
		                               dangHeight:Number = 50,dangWidth = 10)
									   /*,textureURL:String="",normalURL:String="",
									   color:uint=0xDDDDDD,ambient:Number=0.8,
									   specular:Number=0.3,gloss:Number=50)*/
		{
			// default material
			/*if (material == null) {
				material = new ColorMaterial(0xAAAADD);
				(material as ColorMaterial).specular = 0.2;
			}*/
			
			this.height = height;
			
			this.dang = dangshui;
			this.dangWidth = dangWidth;
			this.dangHeight = dangHeight;
			
			super(geometry, material);
			//setMaterial(textureURL,normalURL,color,ambient,specular,gloss);
			update(border,hole,radius,segment,height);
			/*this.radius = radius;
			this.segment = segment;
			this.height = height;
			
			// 初始化
			init(border,hole);*/
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		public function toJsonString():String
		{
			var s:String = "{";
			s += "\"dangshui\":" + getPointsData(dang) + ",";
			s += "\"border\":" + getPointsData(border) + ",";
			if(hole)s += "\"hole\":" + getPointsData(hole) + ",";
			s += "\"radius\":" + radius + ",";
			s += "\"segment\":" + segment + ",";
			s += "\"height\":" + height + ",";
			s += "\"tableY\":" + y + ",";//2015.10.29 new add by jell
			s += "\"materialName\":\"" + materialName + "\"";
			s += "}";
			return s;
		}
		
		private function getPointsData(pts:Vector.<Point>):String
		{
			var s:String = "[";
			var len:int = pts.length;
			for(var i:int=0;i<len;i++)
			{
				var p:Point = pts[i];
				s += "{";
				s += "\"x\":" + p.x + ",";
				s += "\"y\":" + p.y;
				s += "}" + (i<len-1?",":"");
			}
			s += "]";
			return s;
		}
		
		private var materialName:String;
		public function setMaterial(matName:String):void
		{
			if(materialName==matName)return;
			
			materialName = matName;
			
			RenderUtils.setMaterial(this,matName);
		}
		
		/*public function setMaterial(textureURL:String="",normalURL:String="",color:uint=0xAAAADD,ambient:Number=0.8,specular:Number=0.3,gloss:Number=50):void
		{
			if(!_mat)
			{
				_mat = new TextureMaterial();
				this.material = _mat;
			}
			_mat.color = color;
			_mat.ambientColor = color;
			_mat.ambient = ambient;
			_mat.specular = specular;
			_mat.gloss = gloss;
			
			if(textureURL && _textureURL!=textureURL)
			{
				_textureURL = textureURL;
//				loadTexture(textureURL);
				RenderUtils.loadTexture(textureURL,function(tex:BitmapTexture):void {
					_mat.texture = tex;
				});
			}
			
			if(normalURL && _normalURL!=normalURL)
			{
				_normalURL = normalURL;
//				loadNormal(normalURL);
				RenderUtils.loadTexture(normalURL,function(tex:BitmapTexture):void {
					_mat.normalMap = tex;
				});
			}
		}*/
		
//		private function loadTexture(url:String):void
//		{
//			
//		}
//		
//		private function loadNormal(url:String):void
//		{
//			
//		}
		
		public function update(border:Vector.<Point>,hole:Vector.<Point>,radius:Number=30,segment:uint=8,height:Number=40):void
		{
			this.border = border;
			this.hole = hole;
			
			this.radius = radius;
			this.segment = segment;
			this.height = height;
			
			// 初始化
			init(border,hole);	
		}
		
		public function init(border:Vector.<Point>,hole:Vector.<Point>):void {
			// reset
			reset();
			
			// add points
			sweepContext.addPolyline(border);
			_sweepContext.addPolyline(border);
			
			// 外圈点的数量
			this.borderCnt = border.length;
			
			// 圆角
			roundCorner(hole);
			
			// 因为传入的points会在计算的过程中重新的排序,所以需要保存原始的序列,用于生成Mesh
			originalPointsArr = sweepContext.points.slice();
			
			// 三角剖分
			triangulate();
			
			//创建Mesh
			buildMesh();
			
			// 创建挡水
			createDangShui();
		}
		
		/**
		 * 根据洞的四个角点坐标及半径值填补洞口点集
		 */
		public function roundCorner(hole:Vector.<Point>):void {
			// 如果不是4个点则路出
			if (!hole || hole.length != 4) {
				this.allCnt = this.borderCnt;
				this.innerCnt = 0;
				return;
			}
			
			var vs:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each (var item:Point in hole) {
				vs.push(getV(item));
			}
			
			var res:Vector.<Point> = new Vector.<Point>();
			
			for (var i:int = 0; i < vs.length; i ++) {
				var t:int = i + 1;
				if (t == vs.length) t = 0;
				
				var h:int = i - 1;
				if (h < 0) h = vs.length - 1;
				
				var v1:Vector3D = vs[t].subtract(vs[i]);
				v1.normalize();
				var v2:Vector3D = vs[h].subtract(vs[i]);
				v2.normalize();
				
				// 得到两边的夹角
				var angle:Number = Math.acos(v1.dotProduct(v2));
				
				// 得到反回的长度
				var l:Number = this.radius / Math.tan(angle / 2);
				
				var v11:Vector3D = v1;
				v11.scaleBy(l);
				var p1:Vector3D = vs[i].add(v11);
				
				var v22:Vector3D = v2;
				v22.scaleBy(l);
				var p2:Vector3D = vs[i].add(v22);
				
				var ll:Number = this.radius / Math.sin(angle / 2);
				
				var v3:Vector3D = v1.add(v2);
				v3.normalize();
				var v33:Vector3D = v3;
				v33.scaleBy(ll);
				var p:Vector3D = vs[i].add(v33);
				
				// 补角
				var angle2:Number = Math.PI - angle;
				var step:Number = angle2 / this.segment;
				
				var p22:Vector3D = p2.subtract(p);
				
				// 加入前面的点
				res.push(new Point(p2.x,p2.z));
				// 循环加入中间的点
				for (var f:int = 1;f < this.segment ; f++) {
					var pp:Vector3D = Vector3DUtils.rotatePoint(p22,new Vector3D(0,-step * 180 / Math.PI,0)).add(p);
					res.push(new Point(pp.x,pp.z));
				}
				// 加入后面的点
				res.push(new Point(p1.x,p1.z));
			}
			
			this.innerCnt = res.length;
			this.allCnt = this.borderCnt + innerCnt;
			
			sweepContext.addHole(res);
		}
		
		/**
		 * 得到生成后的三角型集合
		 */
		public function get triangles():Vector.<Triangle> {
			return sweepContext.triangles;
		}
		
		/**
		 * 得到所有的点
		 */
		public function get points():Vector.<Point> {
			return sweepContext.points;
		}
		
		public function reset():void {
			this.sweepContext = new SweepContext();
			this._sweepContext = new SweepContext();
			this.sweep = new Sweep(sweepContext);
			this._sweep = new Sweep(_sweepContext);
			this.triangulated = false;
		}
		
		protected function triangulate():void {
			if (!this.triangulated) {
				this.triangulated = true;
				this.sweep.triangulate();
				this._sweep.triangulate();
			}
		}
		
		/**
		 * 根据三角剖分后的数据,创建Mesh物体
		 */
		public function buildMesh():void {
			geometry = new Geometry();
			
			var sg:SubGeometry = new SubGeometry();
			
			var vs:Vector.<Number> = new Vector.<Number>();
			var ds:Vector.<uint> = new Vector.<uint>();
			
			var v:Vector3D;
			var p:Point;
			
			// vertex
			for each(p in originalPointsArr) {
				v = getV(p);
				vs.push(v.x,v.y,v.z);
			}
			// 顶面 vertex
			for each(p in originalPointsArr) {
				v = getV(p);
				vs.push(v.x,v.y + this.height,v.z);
			}
			
			// border vertex / up down points
			for (var j:uint = 0; j < allCnt; j ++) {
				vs.push(vs[j * 3],vs[j * 3 + 1],vs[j * 3 + 2]);
				vs.push(vs[(j + allCnt) * 3],vs[(j + allCnt) * 3 + 1],vs[(j + allCnt) * 3 + 2]);
				
				if (j == borderCnt - 1) {
					vs.push(vs[0],vs[1],vs[2]);
					vs.push(vs[allCnt * 3],vs[allCnt * 3 + 1],vs[allCnt * 3 + 2]);
				} else if (j < allCnt - 1) {
					vs.push(vs[j * 3 + 3],vs[j * 3 + 4],vs[j * 3 + 5]);
					vs.push(vs[(j + allCnt) * 3 + 3],vs[(j + allCnt) * 3 + 4],vs[(j + allCnt) * 3 + 5]);
				} else {
					vs.push(vs[borderCnt * 3],vs[borderCnt * 3 + 1],vs[ borderCnt * 3 + 2]);
					vs.push(vs[(allCnt + borderCnt) * 3],vs[(allCnt + borderCnt) * 3 + 1],vs[(allCnt + borderCnt) * 3 + 2]);
				}
			}
			
			sg.updateVertexData(vs);
			
			// triangle indice
			for each(var i:Triangle in sweepContext.triangles) {
				ds.push(i.points[0].index,i.points[1].index,i.points[2].index);
			}
			
			// 顶面 indice
			var cnt:uint = allCnt;//sweepContext.triangles.length;
			
			for each(i in sweepContext.triangles) {
				ds.push(i.points[0].index + cnt,i.points[2].index + cnt,i.points[1].index + cnt);
			}
			
			// border vertices && faces
			var all:uint = allCnt * 2;
			var d:uint = 0;
			
			for (d = 0; d < borderCnt; d++) {
				ds.push(all + d * 4,all + d * 4 + 1,all + d * 4 + 3);
				ds.push(all + d * 4,all + d * 4 + 3,all + d * 4 + 2);
			}
			
			// inner border
			if (innerCnt != 0) {
				all = allCnt * 2 + borderCnt * 4;
				for (d = 0; d < innerCnt; d++) {
					ds.push(all + d * 4,all + d * 4 + 3,all + d * 4 + 1);
					ds.push(all + d * 4,all + d * 4 + 2,all + d * 4 + 3);
				}
			}
			
			sg.updateIndexData(ds);
			
			// UV
			fillUV(sg);
			
			// add subGeometry to geometry
			geometry.addSubGeometry(sg);
		}
		
		/**
		 * 加入UV坐标信息
		 */
		private function fillUV(sg:SubGeometry,baseLen:Number = 1000):void {
			var uv:Vector.<Number> = new Vector.<Number>(sg.vertexData.length / 3 * 2);
			
			// 上下两个面儿一起定UV,先先上下两个面儿的首点UV设置为0,0
			uv[0] = uv[1] = uv[allCnt * 2] = uv[allCnt * 2 + 1] = 0;
			
			for (var i:int = 1;i < allCnt; i ++) {
				uv[i * 2] = uv[i * 2 + allCnt * 2] = (sg.vertexData[i * 3] - sg.vertexData[0]) / baseLen;
				uv[i * 2 + 1] = uv[i * 2 + allCnt * 2 + 1] = (sg.vertexData[i * 3 + 2] - sg.vertexData[2]) / baseLen;
			}
			
			// boder 的UV
			var base:int = allCnt * 4;
			var vbase:int = allCnt * 6;
			var w:Number = (sg.vertexData[vbase + 1] - sg.vertexData[vbase + 4]) / baseLen;
			
			var cnt:int = (sg.vertexData.length - vbase) / 3 * 4;
			
			var len:Number = 0;
			var last:Number = 0;
			
			for (var j:int = 0; j < allCnt * 4; j += 4) {
				var v1x:Number = sg.vertexData[vbase + j * 3];
				var v1z:Number = sg.vertexData[vbase + j * 3 + 2];
				var v2x:Number = sg.vertexData[vbase + (j+2) * 3];
				var v2z:Number = sg.vertexData[vbase + (j+2) * 3 + 2];
				
				var l:Number = Math.sqrt(Math.pow(v2x-v1x,2) + Math.pow(v2z - v1z,2)) / baseLen;
				
				len += l;
				
				uv[base + j * 2] = 0;
				uv[base + j * 2 + 1] = uv[base + j * 2 + 3] = last;
				uv[base + j * 2 + 2] = w;
				
				uv[base + j * 2 + 4] = 0;
				last = uv[base + j * 2 + 5] = uv[base + j * 2 + 7] = len;
				uv[base + j * 2 + 6] = w;
			}
			
			sg.updateUVData(uv);
		}
		
		/**
		 * 将平面点Point,转化为Vector3D
		 */
		private function getV(p:Point,y:Number = 0):Vector3D {
			return new Vector3D(p.x,y,p.y);
		}
		
		/**
		 * 将传入的SubGeometry反转法线
		 */
		private function inverseNormal(sg:SubGeometry):void {
			var t:Number;
			for (var i:int = 0; i < sg.indexData.length ; i += 3) {
				t = sg.indexData[1 + i];
				sg.indexData[1 + i] = sg.indexData[2 + i];
				sg.indexData[2 + i] = t;
			}
		}
		
		/**
		 * 得到台面的面积
		 */
		/*public function getArea():Number {
			var res:Number = 0;
			
			for each( var tri:Triangle in sweepContext.triangles) {
				res += getTriangleArea(tri);
			}
			
			return res;
		}*/
		
		/*private function getTriangleArea(tri:Triangle):Number {
			var p1:Vector3D = getV(tri.points[0]);
			var p2:Vector3D = getV(tri.points[1]);
			var p3:Vector3D = getV(tri.points[2]);
			
			var v1:Vector3D = p2.subtract(p1);
			var v2:Vector3D = p3.subtract(p1);
			
			return (v1.crossProduct(v2).length / 2 / 1000000);
		}*/
		
		/**
		 * 得到台面的面积
		 * withHole: 是否除去水盆的洞口面积
		 * 默认为Flash,即不去除水盆洞口面积
		 */
		public function getArea(withHole:Boolean = false):Number {
			var res:Number = 0;
			
			var tri:Triangle;
			
			if (withHole) {
				for each( tri in sweepContext.triangles) {
					res += getTriangleArea(tri);
				}
			} else {
				for each( tri in _sweepContext.triangles) {
					res += getTriangleArea(tri);
				}
			}
			
			return res;
		}
		
		private function getTriangleArea(tri:Triangle):Number {
			var p1:Vector3D = getV(tri.points[0]);
			var p2:Vector3D = getV(tri.points[1]);
			var p3:Vector3D = getV(tri.points[2]);
			
			var v1:Vector3D = p2.subtract(p1);
			var v2:Vector3D = p3.subtract(p1);
			
			return (v1.crossProduct(v2).length / 2 / 1000000);
		}
		
		/**
		 * 创建挡水
		 */
		private function createDangShui():void {
			if (dang == null || dang.length < 2) return;
			
			for (var i:int = 0; i < dang.length - 1; i ++) {
				var p1:Point = dang[i];
				var p2:Point = new Point(dang[i + 1].x ,dang[i + 1].y);
				
				p2.sub(p1);
				
				var x:Number = p2.x == 0 ? dangWidth * 2 : Math.abs(p2.x) + ((i == 0 || i == dang.length - 2 || i % 2 == 0) ? 0 : dangWidth * 2);
				var z:Number = p2.y == 0 ? dangWidth * 2 : Math.abs(p2.y) + ((i == 0 || i == dang.length - 2 || i % 2 == 0) ? 0 : dangWidth * 2);
				
				p2.mul(0.5);
				p2.add(p1);
				
				var cube:CubeMesh = new CubeMesh(x,dangHeight,z);
				cube.x = p2.x;
				cube.z = p2.y;
				cube.y = height + dangHeight * 0.5; 
				
				this.addChild(cube);
				this.subMeshes.push(cube.subMeshes[0]);
			}
		}
	}
}