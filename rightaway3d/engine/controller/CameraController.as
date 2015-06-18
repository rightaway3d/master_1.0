package rightaway3d.engine.controller
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import away3d.cameras.Camera3D;
	import away3d.controllers.HoverController;
	
	import ztc.utils.Tools;
	
	[Event(name="distanceChange", type="flash.events.Event")]
	
	public final class CameraController extends EventDispatcher
	{
		public var cc:HoverController;
		
		private var stage2d:DisplayObjectContainer;
		
		private var isMove:Boolean = false;
		
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		private var tiltSpeed:Number = 2;
		private var panSpeed:Number = 2;
		private var distanceSpeed:Number = 2;
		private var tiltIncrement:Number = 0;
		private var panIncrement:Number = 0;
		private var distanceIncrement:Number = 0;
		
		private var _stage:Stage;
		
		public function CameraController(stage2d:DisplayObjectContainer,camera:Camera3D)
		{
			trace("CameraController");
			this.stage2d = stage2d;
			
			cc = new HoverController();
			cc.targetObject = camera;
			cc.yFactor = 1;
			
			enable();
		}
		
		public function enable():void
		{
			stage2d.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
			stage2d.addEventListener(MouseEvent.MOUSE_WHEEL,onStageMouseWheel);
			stage2d.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,onMiddleDown);
		}
		
		protected function onMiddleDown(event:MouseEvent):void
		{
			_stage = stage2d.stage;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
			_stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,onMiddleUp);
			
			updateLast();
		}		
		
		protected function onStageMouseMove(event:MouseEvent):void
		{
			cc.lookAtPosition = cc.lookAtPosition.add(Tools.Instance.VectorMulNum(cc.targetObject.rightVector, (_stage.mouseX - lastMouseX) * -panSpeed).add( 
				Tools.Instance.VectorMulNum(cc.targetObject.upVector, (_stage.mouseY - lastMouseY) * panSpeed)));
			
			updateLast();
		}
		
		protected function onMiddleUp(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMove);
			_stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP,onMiddleUp);
		}
		
		public function disable():void
		{
			stage2d.removeEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
			stage2d.removeEventListener(MouseEvent.MOUSE_WHEEL,onStageMouseWheel);
			
			stage2d.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage2d.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
			
			isMove = false;
		}
		
		public function disableWheel():void
		{
			stage2d.removeEventListener(MouseEvent.MOUSE_WHEEL,onStageMouseWheel);
		}
		
		private var distanceChangeEvent:Event;
		
		public var maxWhellDistance:int = 2000;
		
		protected function onStageMouseWheel(event:MouseEvent):void
		{
			//trace("distance:"+cc.distance);
			//cc.distance -= event.delta;
			var n:int = event.delta>0?1:-1;
			var d:Number = cc.distance - cc.distance*n*0.05;
			if(d>maxWhellDistance)
			{
				d = maxWhellDistance;
			}
			cc.distance = d;
			
			if(this.hasEventListener("distanceChange"))
			{
				distanceChangeEvent ||= new Event("distanceChange");
				this.dispatchEvent(distanceChangeEvent);
			}
		}
		
		protected function onStageMouseDown(event:MouseEvent):void
		{
			isMove = true;
			
			updateLast();
			
			stage2d.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage2d.stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
			
			//testTween();
		}
		
		private function updateLast():void
		{
			lastPanAngle = cc.panAngle;
			lastTiltAngle = cc.tiltAngle;
			
			lastMouseX = stage2d.stage.mouseX;
			lastMouseY = stage2d.stage.mouseY;
		}
		
		public function testTween():void
		{
			tweenTo(cc.panAngle+15,cc.tiltAngle,cc.distance,null,0.3,testTween);
		}
		
		private var autoRotationTimer:Timer;
		
		private function onMouseUp(event:Event):void
		{
			isMove = false;
			//planeDisturb = false;
			stage2d.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage2d.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
			
			if(autoRotation || (autoRotationTimer && autoRotationTimer.running))
			{
				autoRotation = false;
				if(!autoRotationTimer)
				{
					autoRotationTimer = new Timer(2000);
					autoRotationTimer.addEventListener(TimerEvent.TIMER,onAutoRotationTimer);
				}
				else if(autoRotationTimer.running)
				{
					autoRotationTimer.reset();
				}
				autoRotationTimer.start();
			}
		}
		
		protected function onAutoRotationTimer(event:TimerEvent):void
		{
			autoRotationTimer.stop();
			autoRotation = true;
		}
		
		public var autoRotationStep:Number = 0.1;
		
		public var autoRotation:Boolean = false;
		
		public function update():void
		{
			if (isMove)
			{
				cc.panAngle = 0.3*(stage2d.stage.mouseX - lastMouseX) + lastPanAngle;
				cc.tiltAngle = 0.3*(stage2d.stage.mouseY - lastMouseY) + lastTiltAngle;
				//trace("Camera panAngle:"+cc.panAngle.toFixed(1)+" tiltAngle:"+cc.tiltAngle.toFixed(1)+" distance:"+cc.distance.toFixed(1)+" center:"+cc.lookAtPosition);
			}
			else if(autoRotation)
			{
				cc.panAngle += autoRotationStep;
			}
			
			//cc.panAngle += panIncrement;
			//cc.tiltAngle += tiltIncrement;
			//cc.distance += distanceIncrement;
			cc.update();
		}
		
		private var callbackByMoveTo:Function;
		public function tweenTo(panAngle:Number,tiltAngle:Number,distance:Number,centerPoint:Vector3D=null,times:Number=0.4,callback:Function=null):void
		{
			//trace("tweenCamera:"+panAngle,tiltAngle,distance,centerPoint);
			callbackByMoveTo = callback;
			var pan:Number = getNearestDegree(cc.panAngle,panAngle);
			var tilt:Number = getNearestDegree(cc.tiltAngle,tiltAngle);
			TweenMax.to(cc,times,{panAngle:pan,tiltAngle:tilt,distance:distance,onComplete:onMoveComplete});
			if(centerPoint)
			{
				TweenMax.to(cc.lookAtPosition,times,{x:centerPoint.x,y:centerPoint.y,z:centerPoint.z});
			}
		}
		
		private function onMoveComplete():void
		{
			//trace("onMoveComplete");
			if(callbackByMoveTo!=null)
			{
				callbackByMoveTo();
				//callbackByMoveTo = null;
			}
		}
		
		public static function getNearestDegree(start:Number,end:Number):Number
		{
			if(Math.abs(end - start)>180)
			{
				var n:Number = end%360 - start%360;
				n %= 360;
				var n2:Number = Math.abs(n);
				var n3:Number = (n2>180)?(n>0?n2-360:360-n2):n;
				end = start + n3;
			}
			return end;
		}
		
		public function reset():void
		{
			//cc.distance = 1000;
			cc.panAngle = 0;//-45;
			cc.tiltAngle = 0;//25;
		}
	}
}