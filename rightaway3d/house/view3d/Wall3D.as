package rightaway3d.house.view3d
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.view3d.base.WallGeometry;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Room;
	import rightaway3d.house.vo.Wall;
	import rightaway3d.house.vo.WallUtils;
	
	import ztc.meshbuilder.room.RenderUtils;
	

	public class Wall3D extends Mesh
	{
		public var wallGeom:WallGeometry;
		
		public var frontFace:SubMesh;
		public var backFace:SubMesh;
		
		private var holeFace:SubMesh;
		
		//public var lightPicker:LightPickerBase;
		
		private var _wall:Wall;
		
		public function Wall3D(wall:Wall)
		{
			_wall = wall;
			wallGeom = new WallGeometry(wall);
			
			var cm:TextureMaterial = new TextureMaterial();
			//var cm:ColorMaterial = new ColorMaterial(0x808080);
			//cm.color = 0x808080;
			cm.color = 0xeeeeee;
			cm.specular = 0.5;
			cm.ambient = 0.9;
			//cm.gloss = 100;
			cm.gloss = 50;
			//cm.normalMap = Common.getInstance().getNormalTexture();
			cm.alpha = 1;
			
			//super(wallGeom);
			super(wallGeom,cm);
			
			frontFace = getSubMesh(wallGeom.frontGeom);
			backFace = getSubMesh(wallGeom.backGeom);
			holeFace = getSubMesh(wallGeom.subGeometries[0]);
			
			//loadTexture("12003.png");
			//loadTexture2("assets/map/1528.png");//1528
			
			//RenderUtils.setMaterial(this,RenderUtils.getDefaultMaterial('wall'));
			//RenderUtils.setMaterial(frontFace,RenderUtils.getDefaultMaterial('wall'));
			
			//loadNormal2("assets/map/wallnormal.jpg");
			wall.frontCrossWall.addEventListener("material_change",onFrontMaterialChange);
			wall.backCrossWall.addEventListener("material_change",onBackMaterialChange);
			//wall.addEventListener("size_change",onSizeChange);
			//wall.addEventListener("changed",onSizeChange);
			wall.frontCrossWall.addEventListener("size_change",onSizeChange);
			
			onFrontMaterialChange();
			onBackMaterialChange();
			
			this.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
			
			this.mouseEnabled = this.mouseChildren = true;
			this.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			
			/*var text3d:Text3D = new Text3D("欢迎光临Wall3D墙");
			this.addChild(text3d);
			text3d.x = 200;
			text3d.y = 1000;
			text3d.z = -200;*/
		}
		
		private var showMark:Boolean = false;
		
		protected function onSizeChange(e:Event):void
		{
			//trace("-------onWallSizeChange");
			if(!showMark)return;
			
			var cw:CrossWall = _wall.frontCrossWall;
			if(mark1 || cw.groundObjects.length>0)
				markGrounCabinet(cw);
			if(mark2 || cw.wallObjects.length>0)
				markWallCabinet(cw);
		}
		
		public function get vo():Wall
		{
			return _wall;
		}
		
		/**
		 * 设置标注是否显示
		 * @param value
		 * 
		 */
		public function setMark(visible:Boolean):void
		{
			showMark = visible;
			if(mark1)mark1.visible = visible;
			if(mark2)mark2.visible = visible;
		}
		
		private var mark1:SizeMarking3D;
		private var mark2:SizeMarking3D;
		
		//标注地柜
		private function markGrounCabinet(cw:CrossWall):void
		{
			if(!mark1)
			{
				mark1 = new SizeMarking3D();
				mark1.ypos = 1000;
				mark1.zpos = -(_wall.width*0.5 + 5);
				this.addChild(mark1);
			}
			
			var a:Array = WallUtils.sortWallObject(cw.localHead.x,cw.localEnd.x,cw.groundObjects);
			if(a.length>2)
			{
				mark1.update(a);
				mark1.visible = true;
			}
			else
			{
				mark1.visible = false;
			}
		}
		
		//标注吊柜
		private function markWallCabinet(cw:CrossWall):void
		{
			if(!mark2)
			{
				mark2 = new SizeMarking3D();
				mark2.ypos = 1250;
				mark2.zpos = -(_wall.width*0.5 + 5);
				this.addChild(mark2);
			}
			
			var a:Array = WallUtils.sortWallObject(cw.localHead.x,cw.localEnd.x,cw.wallObjects);
			if(a.length>2)
			{
				mark2.update(a);
				mark2.visible = true;
			}
			else
			{
				mark2.visible = false;
			}
		}
		/*private function markWallCabinet(cw:CrossWall):void
		{
			if(!mark2)
			{
				mark2 = new DimensionLineManager();
				mark2.wallY = 1250;
				mark2.wallZ = -(_wall.width*0.5 + 30);
				this.addChild(mark2.parent);
			}
			
			var a:Array = WallUtils.sortWallObject(cw.localHead.x,cw.localEnd.x,cw.wallObjects);
			mark2.update(a);
		}*/
		
		private function onBackMaterialChange(e:Event=null):void
		{
			//setFrontWallMaterial(_wall.frontCrossWall.materialName);
		}
		
		private function onFrontMaterialChange(e:Event=null):void
		{
			setFrontWallMaterial(_wall.frontCrossWall.materialName);
		}
		
		private function setFrontWallMaterial(materialName:String):void
		{
			RenderUtils.setMaterial(frontFace,materialName);//当前是墙体的正面和背面都设置为同一种材质了
			//TextureMaterial(frontFace.material).shadowMethod = Engine3D.instance.shadowMethod;
			
			//RenderUtils.setMaterial(holeFace,materialName);//当前是墙体的正面和背面都设置为同一种材质了
			TextureMaterial(holeFace.material).alpha = 1;
			//TextureMaterial(backFace.material).alpha = 0.01;
		}
		
		override public function dispose():void
		{
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			this.removeEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
			if(mark1)
			{
				mark1.dispose();
				mark1 = null;
			}
			if(mark2)
			{
				mark2.dispose();
				mark2 = null;
			}
			if(_wall)
			{
				_wall.frontCrossWall.removeEventListener("material_change",onFrontMaterialChange);
				_wall.backCrossWall.removeEventListener("material_change",onBackMaterialChange);
				_wall = null;
			}
			wallGeom = null;
			frontFace = null;
			backFace = null;
			
			super.dispose();
		}
		
		private var isMouseDown:Boolean;
		private var isMouseMove:Boolean;
		private var lastTime:int;
		
		private function onMouseDown(e:MouseEvent3D):void
		{
			trace("onWall3DMouseDown");
			isMouseDown = true;
			isMouseMove = false;
			CabinetController.getInstance().scene.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			var sm:SubMesh = subMeshes[e.subGeometryIndex];
			if(sm==frontFace || sm==backFace)
			{
				var cw:CrossWall = sm==frontFace?_wall.frontCrossWall:_wall.backCrossWall;
				GlobalEvent.event.dispatchCrossWallMouseDownEvent(cw);
			}
			else
			{
				GlobalEvent.event.dispatchWallMouseDownEvent(_wall);
			}
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			isMouseMove = true;
		}
		
		private function onMouseUp(e:MouseEvent3D):void
		{
			CabinetController.getInstance().scene.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			if(!isMouseDown || isMouseMove)return;//如果鼠标不在此模型上按下，或者发生了移动，则不执行此后动作
			isMouseDown = false;
			
			var n:int = getTimer();
			//trace(n-lastTime);
			if(n-lastTime<1000)
			{
				trace("----wal3d onMouseUp");
				dispatchMouseUpEvent(e.subGeometryIndex);
				lastTime = 0;
			}
			else
			{
				lastTime = n;
			}
			
		}
		
		public function dispatchMouseUpEvent(subGeometryIndex:uint):void
		{
			var sm:SubMesh = subMeshes[subGeometryIndex];
			if(sm==frontFace || sm==backFace)
			{
				var cw:CrossWall = sm==frontFace?_wall.frontCrossWall:_wall.backCrossWall;
				GlobalEvent.event.dispatchCrossWallMouseUpEvent(cw);
			}
			else
			{
				GlobalEvent.event.dispatchWallMouseUpEvent(_wall);
			}
		}
		
		private function getSubMesh(geom:ISubGeometry):SubMesh
		{
			return subMeshes[_geometry.subGeometries.indexOf(geom)];
		}
		
		public function updateView():void
		{
			wallGeom.updateGeometry();
			//wallGeom.updateUVs();
			//wallGeom.frontGeom.scaleUV(2,2);
			//trace("wall bounds max:"+this.m+" min:"+this.bounds.min);
		}
		
		//========================================================================================================
		public function loadTexture2(url:String):void
		{
			trace("loadBackground:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onBGLoaded);
			loader.load(new URLRequest(url));			
		}
		
		private function onBGLoaded(event:Event):void
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
			
			mat.lightPicker = this.material.lightPicker;
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
		private function loadNormal2(url:String):void
		{
			trace("loadNormal:"+url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onNormalLoaded);
			loader.load(new URLRequest(url));			
		}
		
		private function onNormalLoaded(event:Event):void
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
			
			mat.lightPicker = this.material.lightPicker;
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
/*package rightaway3d.house.view3d
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
}*/

