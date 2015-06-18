package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	/**
	 * 创建一个Cube的Mesh物体，会自动的按物体的实际大小调整UV
	 */
	public class CubeMesh extends Mesh
	{
		private var _width:Number;
		public var _height:Number;
		public var _depth:Number;
		
		// 场景中的一个单位代表的实际长度,如1000 = 1米
		// 此值用来设置UV坐标
		public var _baseLength:Number;
		
		public function CubeMesh(width:Number = 100, height:Number = 100, depth:Number = 100, baseLength = 1000)
		{
			this._width = width;
			this._height = height;
			this._depth = depth;
			this._baseLength = baseLength;
			
			var geo:Geometry = new CubeGeometry(width,height,depth,1,1,1,false);
			
			material = new ColorMaterial(0xdddddd);
			
			super(geo, material);
			
			geometry = geo;
			
			// 更新UV
			updateUV();
		}
		
		/**
		 * 根据实际大小更新UV坐标
		 */
		public function updateUV():void {
			var sg:CompactSubGeometry = CompactSubGeometry(geometry.subGeometries[0]);
			
			var vs:Vector.<Number> = sg.vertexData;
			var index:Vector.<uint> = sg.indexData;
			var normal:Vector.<Number> = sg.faceNormals;
			
			for ( var i:int = 0; i < 6; i++) {
				var n:Vector3D = new Vector3D();
				n.x = normal[i * 6];
				n.y = normal[i * 6 + 1];
				n.z = normal[i * 6 + 2];
				
				var base:Vector3D = new Vector3D();
				var v:Vector3D = new Vector3D();
				var num:int = i * 6;
				var _tmp:int;
				
				for ( var j:int = 0; j < 4; j++) {
								
					if (j == 0) {
						_tmp = index[num] * 13;
						base.x = vs[_tmp];
						base.y = vs[_tmp + 1];
						base.z = vs[_tmp + 2];
						
						sg.vertexData[_tmp + sg.UVOffset] = sg.vertexData[_tmp + sg.UVOffset + 1] = 0;
					} else {
						if (j == 3) {
							_tmp = index[num + 5] * 13;
						} else {
							_tmp = index[num + j] * 13
						}
						
						v.x = vs[_tmp];
						v.y = vs[_tmp + 1];
						v.z = vs[_tmp + 2];
						
						if (n.x != 0) {          // x轴上的面
							sg.vertexData[_tmp + sg.UVOffset] = (v.z - base.z) / _baseLength;
							sg.vertexData[_tmp + sg.UVOffset + 1] = (v.y - base.y) / _baseLength;
						} else if (n.y != 0) {   // y轴上的面
							sg.vertexData[_tmp + sg.UVOffset] = (v.x - base.x) / _baseLength;
							sg.vertexData[_tmp + sg.UVOffset + 1] = (v.z - base.z) / _baseLength;
						} else if (n.z != 0) {   // z轴上的面
							sg.vertexData[_tmp + sg.UVOffset] = (v.x - base.x) / _baseLength;
							sg.vertexData[_tmp + sg.UVOffset + 1] = (v.y - base.y) / _baseLength;
						}
					}	
				}
			}
		}
	}
}