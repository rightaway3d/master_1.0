package ztc.meshbuilder.room
{
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Object3D;
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	/**
	 * 创建一个Cube的Mesh物体，会自动的按物体的实际大小调整UV
	 */
	public class CubeMesh extends Mesh
	{
		private var cube:CubeGeometry;
		
		//private var _width:Number;

		public function get width():Number
		{
			return cube.width;
		}

		//private var _height:Number;

		public function get height():Number
		{
			return cube.height;
		}

		//private var _depth:Number;

		public function get depth():Number
		{
			return cube.depth;
		}

		public function resize(width:Number,height:Number,depth:Number):void
		{
			cube.width = width;
			cube.height = height;
			cube.depth = depth;
			
			updateUV();
		}
		
		// 场景中的一个单位代表的实际长度,如1000 = 1米
		// 此值用来设置UV坐标
		//public var tileWidth:int;
		//public var tileHeight:int;
		
		public function CubeMesh(width:Number = 100, height:Number = 100, depth:Number = 100, tileWidth_ = 0, tileHeight_ = 0)
		{
			//trace("---CubeMesh width,height,depth:"+width,height,depth);
			//this._width = width;
			//this._height = height;
			//this._depth = depth;
			//this.tileWidth = tileWidth_;
			//this.tileHeight = tileHeight_;
			
			cube = new CubeGeometry(width,height,depth,1,1,1,false);
			
			material = new ColorMaterial(0xdddddd);
			
			super(cube, material);
			
			geometry = cube;
			
			// 更新UV
			//updateUV(tileWidth_, tileHeight_);
			//trace("subMeshes:",subMeshes.length,subMeshes);
		}
		
		/*override public function clone():Object3D
		{
			var clone:Mesh = new Mesh(_geometry, material);
			clone.transform = transform;
			clone.pivotPoint = pivotPoint;
			clone.partition = partition;
			clone.bounds = _bounds.clone();
			clone.name = name;
			clone.castsShadows = castsShadows;
			clone.shareAnimationGeometry = shareAnimationGeometry;
			clone.mouseEnabled = this.mouseEnabled;
			clone.mouseChildren = this.mouseChildren;
			//this is of course no proper cloning
			//maybe use this instead?: http://blog.another-d-mention.ro/programming/how-to-clone-duplicate-an-object-in-actionscript-3/
			clone.extra = this.extra;
			var csubMeshs:Vector.<SubMesh> = clone.subMeshes;
			
			var _subMeshes:Vector.<SubMesh> = subMeshes;
			var len:int = _subMeshes.length;
			for (var i:int = 0; i < len; ++i)
				csubMeshs[i]._material = _subMeshes[i]._material;
			
			len = numChildren;
			for (i = 0; i < len; ++i)
				clone.addChild(ObjectContainer3D(getChildAt(i).clone()));
			
			if (animator)
				clone.animator = animator.clone();
			
			return clone;
		}*/
		
		/**
		 * 根据实际大小更新UV坐标
		 */
		public function updateUV(tileWidth = 0, tileHeight = 0):void
		{
			//if(tileWidth_ != 0)
				//tileWidth = tileWidth_;
			//if(tileHeight_ != 0 )
				//tileHeight = tileHeight_;
			
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
							sg.vertexData[_tmp + sg.UVOffset] 		=  tileWidth==0 ? sg.scaleU : (v.z - base.z) / tileWidth;
							sg.vertexData[_tmp + sg.UVOffset + 1] 	= tileHeight==0 ? sg.scaleV : (v.y - base.y) / tileHeight;
						} else if (n.y != 0) {   // y轴上的面
							sg.vertexData[_tmp + sg.UVOffset] 		=  tileWidth==0 ? sg.scaleU : (v.x - base.x) / tileWidth;
							sg.vertexData[_tmp + sg.UVOffset + 1] 	= tileHeight==0 ? sg.scaleV : (v.z - base.z) / tileHeight;
						} else if (n.z != 0) {   // z轴上的面
							sg.vertexData[_tmp + sg.UVOffset] 		=  tileWidth==0 ? sg.scaleU : (v.x - base.x) / tileWidth;
							sg.vertexData[_tmp + sg.UVOffset + 1] 	= tileHeight==0 ? sg.scaleV : (v.y - base.y) / tileHeight;
						}
					}	
				}
			}
			sg.updateData(sg.vertexData);
		}
	}
}