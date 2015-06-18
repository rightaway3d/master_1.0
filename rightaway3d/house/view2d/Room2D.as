package rightaway3d.house.view2d
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.house.editor2d.Scene2D;
	import rightaway3d.house.utils.Point3D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Room;

	public final class Room2D extends Base2D
	{
		/**
		 * 以当前房间的所有墙体2D对象为键，墙体数据对象为值的字典
		 */
		public var walls:Dictionary = new Dictionary();
		
		public var vo:Room;
		
		private var matrix:Matrix;// = new Matrix(0.2,0,0,0.2);
		//private var matrix:Matrix = new Matrix(.1,0,0,.1);
		
		public function Room2D(room:Room)
		{
			vo = room;
			
			var n:Number = Room.textureScale/Base2D.scaleRuler;
			matrix = new Matrix(n,0,0,n);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			GlobalEvent.event.dispatchGroundMouseDownEvent(vo);
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			//屏蔽事件20150121
			//GlobalEvent.event.dispatchGroundMouseUpEvent(vo);
		}
		
		override public function dispose():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			walls = null;
			matrix = null;
			bmd = null;
			vo = null;
		}
		
		/*public function loadGroundImage(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onGroundLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onGroundLoadError);
			loader.load(new URLRequest(url));
			//vo.groundTextureURL = url;
		}*/
		
		protected function onGroundLoadError(event:IOErrorEvent):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			
			loaderInfo.removeEventListener(Event.COMPLETE,onGroundLoaded);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onGroundLoadError);
			
			trace("onGroundLoadError");
		}
		
		protected function onGroundLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			
			loaderInfo.removeEventListener(Event.COMPLETE,onGroundLoaded);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onGroundLoadError);
			
			bmd = Bitmap(loaderInfo.content).bitmapData;
			
			loaderInfo.loader.unload();
			
			updateView();
			
			vo.isChanged = false;
		}
		
		private var bmd:BitmapData;
		
		public function updateView():void
		{
			var gra:Graphics = this.graphics;
			gra.clear();
			
			if(bmd)
			{
				gra.beginBitmapFill(bmd,matrix,true,true);
			}
			else
			{
				gra.beginFill(0xEEEEEE,0.5);
			}
			
			var cws:Vector.<CrossWall> = vo.walls;
			var len:int = cws.length;
			
			var p0:Point = getDrawPoint(cws[0]);
			gra.moveTo(p0.x,p0.y);
			var p:Point = new Point();
			for(var i:int=1;i<len;i++)
			{
				getDrawPoint(cws[i],p);
				gra.lineTo(p.x,p.y);
			}
			gra.lineTo(p0.x,p0.y);
			gra.endFill();
		}
		
		private function getDrawPoint(cw:CrossWall,p:Point=null):Point
		{
			var p0:Point3D = cw.isHead ? cw.wall.groundFrontHeadPoint : cw.wall.groundBackEndPoint;
			
			p ||= new Point();
			p.x = Base2D.sizeToScreen(p0.x);//左手系坐标值转换为屏幕坐标值
			p.y = Scene2D.sceneHeight - Base2D.sizeToScreen(p0.z);//左手系坐标值转换为屏幕坐标值
			
			return p;
		}
	}
}