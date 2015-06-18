package rightaway3d.house.view3d
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.editor2d.CabinetController;
	import rightaway3d.house.view3d.base.RoomGeometry;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Room;
	
	import ztc.meshbuilder.room.RenderUtils;

	public class Room3D extends Mesh
	{
		public var roomGeom:RoomGeometry;
		
		private var vo:Room;
		
		private var groundFace:SubMesh;
		
		private var ceilingFace:SubMesh;
		
		public function Room3D(room:Room)
		{
			vo = room;
			roomGeom = new RoomGeometry(room);
			
			//var m:ColorMaterial = new ColorMaterial(0x444444);
			var m:TextureMaterial = new TextureMaterial();
			m.color = 0x444444;
			m.ambientColor = 0x444444;
			m.specular = 0;
			m.ambient = 1;
			
			m.repeat = true;
			
			super(roomGeom);
			
			groundFace = getSubMesh(roomGeom.groundGeom);
			groundFace.material = m;
			
			var cm:TextureMaterial = new TextureMaterial();
			cm.ambientColor = cm.color = 0xCCCCCC;
			cm.specular = 0.1;
			cm.ambient = 0.9;
			cm.gloss = 50;
			cm.repeat = true;
			
			ceilingFace = getSubMesh(roomGeom.ceilingGeom);
			ceilingFace.material = cm;
			
//			loadGroundTexture("assets/map/12034.png");
//			loadCeilingTexture("assets/map/7837.png");
			
			//RenderUtils.setMaterial(ceilingFace,RenderUtils.getDefaultMaterial('ceiling'));
			//RenderUtils.setMaterial(groundFace,RenderUtils.getDefaultMaterial('ground'));
			room.addEventListener("ground_material_change",onGroundMaterialChange);
			room.addEventListener("ceiling_material_change",onCeilingMaterialChange);
			
			onGroundMaterialChange();
			onCeilingMaterialChange();
			
			this.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
			
			this.mouseEnabled = this.mouseChildren = true;
			this.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
		}
		
		private function onCeilingMaterialChange(e:Event=null):void
		{
			setCeilingMaterial(vo.ceilingMaterialName);
		}
		
		private function onGroundMaterialChange(e:Event=null):void
		{
			setGroundMaterial(vo.groundMaterialName);
		}
		
		private function setGroundMaterial(materialName:String):void
		{
			RenderUtils.setMaterial(groundFace,materialName);
		}
		
		private function setCeilingMaterial(materialName:String):void
		{
			RenderUtils.setMaterial(ceilingFace,materialName);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			this.removeEventListener(MouseEvent3D.MOUSE_UP,onMouseUp);
			
			if(vo)
			{
				vo.removeEventListener("ground_material_change",onGroundMaterialChange);
				vo.removeEventListener("ceiling_material_change",onCeilingMaterialChange);
				
				vo = null;
			}
			
			roomGeom = null;
			groundFace = null;
			ceilingFace = null;
		}
		
		private var isMouseDown:Boolean;
		private var isMouseMove:Boolean;
		
		private function onMouseDown(e:MouseEvent3D):void
		{
			isMouseDown = true;
			isMouseMove = false;
			CabinetController.getInstance().scene.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			var sm:SubMesh = subMeshes[e.subGeometryIndex];
			if(sm==groundFace)
			{
				GlobalEvent.event.dispatchGroundMouseDownEvent(vo);
			}
			else
			{
				GlobalEvent.event.dispatchCeilingMouseDownEvent(vo);
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
				trace("----room3d mouseUp");
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
			if(sm==groundFace)
			{
				GlobalEvent.event.dispatchGroundMouseUpEvent(vo);
			}
			else
			{
				GlobalEvent.event.dispatchCeilingMouseUpEvent(vo);
			}
		}
		
		public function updateView():void
		{
			roomGeom.updateGeometry();
		}
		
		private function getSubMesh(geom:CompactSubGeometry):SubMesh
		{
			return subMeshes[_geometry.subGeometries.indexOf(geom)];
		}
		
		//========================================================================================================
		private var groundURL:String;
		public function loadGroundTexture2(url:String):void
		{
			return;
			trace("loadGroundTexture:"+url);
			if(groundURL==url)return;
			groundURL = url;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onGroundLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onGroundLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onGroundLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			var ow:int = bmp.bitmapData.width*Room.textureScale;
			var oh:int = bmp.bitmapData.height*Room.textureScale;
			
			roomGeom.groundTextureWidth = ow;
			roomGeom.groundTextureHeight = oh;

			var m:TextureMaterial = groundFace.material as TextureMaterial;
			m.texture = new BitmapTexture(BMP.scaleBmpData(bmp.bitmapData));
			
			loaderInfo.loader.unload();
			
			roomGeom.updateGeometry();
		}
		
		
		//========================================================================================================
		private var ceilingURL:String;
		private var lastTime:int;
		public function loadCeilingTexture2(url:String):void
		{
			trace("loadCeilingTexture:"+url);
			if(ceilingURL==url)return;
			
			ceilingURL = url;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCeilingLoaded);
			loader.load(new URLRequest(url));			
		}
		
		protected function onCeilingLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE,onCeilingLoaded);
			
			var bmp:Bitmap= loaderInfo.content as Bitmap;
			var ow:int = bmp.bitmapData.width*Room.textureScale;
			var oh:int = bmp.bitmapData.height*Room.textureScale;
			
			roomGeom.ceilingTextureWidth = ow;
			roomGeom.ceilingTextureHeight = oh;
			
			var m:TextureMaterial = ceilingFace.material as TextureMaterial;
			m.texture = new BitmapTexture(BMP.scaleBmpData(bmp.bitmapData));
			
			loaderInfo.loader.unload();
			
			roomGeom.updateGeometry();
		}
		
		//========================================================================================================
	}
}