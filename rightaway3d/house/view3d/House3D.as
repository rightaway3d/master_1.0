package rightaway3d.house.view3d
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import away3d.containers.ObjectContainer3D;
	
	import rightaway3d.engine.core.Engine3D;
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.vo.BaseVO;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallHole;
	
	import ztc.meshbuilder.room.Door;
	import ztc.meshbuilder.room.MeshObject;
	import ztc.meshbuilder.room.Window;

	public class House3D extends ObjectContainer3D
	{
		public var engine3d:Engine3D;
		public var engineManager:EngineManager;
		
		public function House3D()
		{
			//trace("---------------House3D");
		}
		
		private var wallDict:Dictionary = new Dictionary();
		private var roomDict:Dictionary = new Dictionary();
		private var dict:Dictionary = new Dictionary();
		
		public function update(house:House):void
		{
			var walls:Vector.<Wall> = house.currFloor.walls;
			var len:int = walls.length;
			for(var i:int=0;i<len;i++)
			{
				var w:Wall = walls[i];
				if(wallDict[w])
				{
					var j:int = i+1;
					var wall3d:Wall3D = wallDict[w];
					wall3d.updateView();
					//wall3d.wallGeom.frontGeom.scaleUV(j,j);
					//wall3d.wallGeom.backGeom.scaleUV(j*2,j*2);
				}
				else
				{
					wall3d = new Wall3D(w);
					this.addChild(wall3d);
					
					wall3d.material.lightPicker = engine3d.lightPicker;
					wallDict[w] = wall3d;
					
					w.addEventListener("will_dispose",onWallDispose);
					
					//engineManager.addCollisionObject(wall3d);
				}
				
				var p:Point3D = w.groundHeadPoint.point;
				wall3d.x = p.x-house.x;
				wall3d.y = p.y;
				wall3d.z = p.z-house.z;
				wall3d.rotationY = 360 - w.angles;
				
				updateWindoor(w,house);
			}
			
			var rooms:Vector.<Room> = house.currFloor.rooms;
			len = rooms.length;
			for(i=0;i<len;i++)
			{
				var r:Room = rooms[i];
				if(roomDict[r])
				{
					var room3d:Room3D = roomDict[r];
					room3d.updateView();
				}
				else
				{
					room3d = new Room3D(r);
					this.addChild(room3d);
					room3d.material.lightPicker = engine3d.lightPicker;
					roomDict[r] = room3d;
					
					r.addEventListener("will_dispose",onRoomDispose);
				}
				
				room3d.x = -house.x;
				room3d.z = -house.z;
			}
		}
		
		private function onWallDispose(e:Event):void
		{
			var wall:Wall  = e.currentTarget as Wall;
			wall.removeEventListener("will_dispose",onWallDispose);
			
			var wall3d:Wall3D = wallDict[wall];
			delete wallDict[wall];
			
			this.removeChild(wall3d);
			//engineManager.removeCollisionObject(wall3d);
			
			wall3d.disposeWithAnimatorAndChildren();
		}
		
		private function onRoomDispose(e:Event):void
		{
			var room:Room = e.currentTarget as Room;
			room.removeEventListener("will_dispose",onRoomDispose);
			
			var room3d:Room3D = roomDict[room];
			delete roomDict[room];
			
			this.removeChild(room3d);
			room3d.disposeWithAnimatorAndChildren();
		}
		
		/*public function setGroundMaterial(matName:String):void
		{
			trace("setGroundMaterial");
			for each(var room3d:Room3D in roomDict)
			{
				trace("setGroundMaterial");
				//room3d.setGroundMaterial(matName);
				room3d
			}
		}*/
		
		/*public function setCeilingMaterial(matName:String):void
		{
			trace("setCeilingMaterial");
			for each(var room3d:Room3D in roomDict)
			{
				trace("setCeilingMaterial");
				room3d.setCeilingMaterial(matName);
			}
		}*/
		
		/*public function updateRoomGroundTexture(url:String):void
		{
			for each(var room3d:Room3D in roomDict)
			{
				room3d.loadGroundTexture2(url);
			}
		}*/
		
		/*public function setWallMaterial(matName:String):void
		{
			trace("setWallMaterial");
			for each(var wall3d:Wall3D in wallDict)
			{
				trace("setWallMaterial");
				wall3d.setFrontWallMaterial(matName);
			}
		}*/
		
		/*public function updateWallTexture(url:String):void
		{
			for each(var wall3d:Wall3D in wallDict)
			{
				wall3d.loadTexture2(url);
			}
		}*/
		
		private function resetMax(max:Vector3D,min:Vector3D):void
		{
			if(min.x>max.x)
			{
				var t:Number = min.x;
				min.x = max.x;
				max.x = t;
			}
			if(min.y>max.y)
			{
				t = min.y;
				min.y = max.y;
				max.y = t;
			}
			if(min.z>max.z)
			{
				t = min.z;
				min.z = max.z;
				max.z = t;
			}
		}
		
		private var holesDict:Dictionary = new Dictionary();
		
		private function updateWindoor(wall:Wall,house:House):void
		{
			var holes:Vector.<WallHole> = wall.holes;
			for each(var hole:WallHole in holes)
			{
				if(holesDict[hole])
				{
					var mo:MeshObject = holesDict[hole];
					//trace("MeshObject1:"+mo);
				}
				else
				{
					if(hole.modelType>0)
					{
						hole.addEventListener("dispose",onWindoorDispose);
						hole.addEventListener(BaseVO.CHANGED,onHoleChange);
						mo = createWindoor(hole);
					}
					else
					{
						mo = null;
					}
				}
				if(mo)_updateWindoor(hole,mo,wall);
				
				/*mo.mesh.rotationY = 360 - wall.angles;
				
				var p:Point3D = new Point3D(hole.x);
				wall.localToGlobal(p,p);
				
				mo.mesh.x = p.x-house.x;
				mo.mesh.y = hole.y+hole.height;
				mo.mesh.z = p.z-house.z;*/
			}
		}
		
		private function createWindoor(hole:WallHole):MeshObject
		{
			var mo:MeshObject;
			if(hole.modelType==101)
			{
				mo = new Door(hole.width,hole.height,hole.modelThickness,hole.modelThickness*0.6);
			}
			else if(hole.modelType==201)
			{
				mo = new Window(hole.width,hole.height,hole.modelThickness,hole.modelThickness*0.6);
			}
			holesDict[hole] = mo;
			mo.setLightPicker(engine3d.lightPicker);
			this.addChild(mo.mesh);
			
			return mo;
		}
		
		private function _updateWindoor(hole:WallHole,mo:MeshObject,wall:Wall):void
		{
			var p:Point3D = new Point3D(hole.x);
			wall.localToGlobal(p,p);
			
			var house:House = House.getInstance();
			mo.mesh.x = p.x-house.x;
			mo.mesh.y = hole.y+hole.height;
			mo.mesh.z = p.z-house.z;
			mo.mesh.rotationY = 360 - wall.angles;
		}
		
		private function onWindoorDispose(e:Event):void
		{
			var hole:WallHole = e.currentTarget as WallHole;
			hole.removeEventListener("dispose",onWindoorDispose);
			hole.removeEventListener(BaseVO.CHANGED,onHoleChange);
			disposeWindoor(hole);
		}
		
		private function disposeWindoor(hole:WallHole):void
		{			
			var mo:MeshObject = holesDict[hole];
			delete holesDict[hole];
			
			this.removeChild(mo.mesh);
			mo.mesh.disposeWithAnimatorAndChildren();
		}
		
		private function onHoleChange(e:Event):void
		{
			//trace("house3d onHoleChange");
			var hole:WallHole = e.currentTarget as WallHole;
			disposeWindoor(hole);
			var mo:MeshObject = createWindoor(hole);
			_updateWindoor(hole,mo,hole.wall);
		}
	}
}

/**
 * 
package rightaway3d.house.view3d
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.house.view3d.base.WallGeometry;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	

	public class Wall3D extends ObjectContainer3D
	{
		public var wallGeom:WallGeometry;
		
		public var frontFace:SubMesh;
		public var backFace:SubMesh;
		
		private var mesh:Mesh;
		
		//public var lightPicker:LightPickerBase;
		
		public function Wall3D(wall:Wall)
		{
			wallGeom = new WallGeometry(wall);
			
			var cm:ColorMaterial = new ColorMaterial(0x808080);
			//var cm:ColorMaterial = new ColorMaterial(0x808080);
			cm.specular = 0.5;
			cm.ambient = 0.9;
			//cm.gloss = 100;
			cm.gloss = 50;
			//cm.normalMap = Common.getInstance().getNormalTexture();
			
			//super(wallGeom,cm);
			mesh = new Mesh(wallGeom,cm);
			this.addChild(mesh);
			
			frontFace = getSubMesh(wallGeom.frontGeom);
			backFace = getSubMesh(wallGeom.backGeom);
			
			//loadTexture("12003.png");
			loadTexture("1528.png");//1528
			loadNormal("wallnormal.jpg");
		}
		
		private function getSubMesh(geom:CompactSubGeometry):SubMesh
		{
			return mesh.subMeshes[mesh.geometry.subGeometries.indexOf(geom)];
		}
		
		public function updateView():void
		{
			wallGeom.updateGeometry();
			//wallGeom.updateUVs();
			//wallGeom.frontGeom.scaleUV(2,2);
			//this.updateBounds();
		}
		
		public function get material():MaterialBase
		{
			return mesh.material;
		}
		
		//========================================================================================================
		private function loadTexture(url:String):void
		{
			trace("loadBackground:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onBGLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onBGLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onBGLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			var ow:int = bmp.bitmapData.width*Room.textureScale;
			var oh:int = bmp.bitmapData.height*Room.textureScale;
			
			wallGeom.frontTextureWidth = ow;
			wallGeom.frontTextureHeight = oh;
			
			//var bmd:BitmapData = BMP.scaleBmpData(bmp.bitmapData);
			var mat:TextureMaterial = new TextureMaterial(new BitmapTexture(BMP.scaleBmpData(bmp.bitmapData)));
			mat.color = 0x808080;
			mat.ambientColor = 0x808080;
			mat.alphaThreshold = 0.5;
			mat.specular = 0.5;
			mat.ambient = 0.6;
			mat.gloss = 100;
			
			mat.lightPicker = mesh.material.lightPicker;
			mat.repeat = true;
			//mat.normalMap = Common.getInstance().getNormalTexture();
			
			frontFace.material = mat;
			//frontFace.scaleU = 2;
			//frontFace.scaleV = 2;
			//wallGeom.frontGeom.scaleUV(2,2);
			
			//backFace.material = mat;
			
			loaderInfo.loader.unload();
			
			this.updateView();
		}
		
		
		//========================================================================================================
		private function loadNormal(url:String):void
		{
			trace("loadNormal:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onNormalLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onNormalLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onNormalLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			var ow:int = bmp.bitmapData.width*Room.textureScale;
			var oh:int = bmp.bitmapData.height*Room.textureScale;
			
			wallGeom.backTextureWidth = ow;
			wallGeom.backTextureHeight = oh;
			
			//var bmd:BitmapData = BMP.scaleBmpData(bmp.bitmapData);
			var mat:TextureMaterial = new TextureMaterial();
			mat.color = 0xAAAAAA;
			mat.ambientColor = 0xFFFFFF;
			mat.alphaThreshold = 0.5;
			mat.specular = 0.5;
			mat.ambient = 1;
			mat.gloss = 100;
			
			mat.lightPicker = mesh.material.lightPicker;
			mat.repeat = true;
			mat.normalMap = new BitmapTexture(BMP.scaleBmpData(bmp.bitmapData));
			//mat.normalMap = Common.getInstance().getNormalTexture();
			
			//frontFace.material = mat;
			//frontFace.scaleU = 2;
			//frontFace.scaleV = 2;
			//wallGeom.frontGeom.scaleUV(2,2);
			
			backFace.material = mat;
			
			loaderInfo.loader.unload();
			
			this.updateView();
		}
		
		//========================================================================================================
	}
}
 *  */
















