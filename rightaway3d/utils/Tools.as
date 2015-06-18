package rightaway3d.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import away3d.controllers.HoverController;

	public final class Tools extends EventDispatcher
	{
		// Singlaton
		private static var _instance:Tools = null;
		
		public function Tools()
		{
			
		}
		
		public static function get Instance():Tools {
			if(!_instance) {
				_instance = new Tools();
			}
			return _instance;
		}
		
		// deltaTime
		public static var deltaTime:Number = 0;
		
		// 得到当前SWF文件所在的路径.
		public function getCurrentPath(stage:Stage):String {
			var selfURL: String = stage.loaderInfo.url;
			var idx: int = selfURL.lastIndexOf("\\") + 1;
			var path: String = selfURL.slice(0, idx);
			return(path);
		}
		
		// 得到XML后,执行的数据
		private var loaderXMLCompleteFunc:Function;
		
		/**
		 * 得到XML数据,返回一个 XML 类的实例
		 */
		public function getXML(url:String,completeFun:Function = null):void {
			loaderXMLCompleteFunc = completeFun;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,onXMLLoaded);
			loader.load(new URLRequest(url));
		}
		
		private function onXMLLoaded(event:Event):void {
			var xml:XML = XML(event.target.data);
			if(loaderXMLCompleteFunc != null) {
				loaderXMLCompleteFunc(xml);
			}
		}
		
		/**
		 * Vector3D X Number
		 */ 
		public function VectorMulNum(v:Vector3D,num:Number):Vector3D {
			return new Vector3D(v.x * num,v.y * num,v.z * num);
		}
		
		/**
		 * 通过给定的相机的坐标及目标点的坐标,计算  panAngle,tiltAngle及distance.
		 * @param hc: HoverController
		 * @param camPos: 相机的坐标
		 * @param tarPos: 目标点的坐标
		 * @return Object {panAngle:pa,tiltAngle:ta,distance:dis}
		*/ 
		public function calculateAngles(hc:HoverController,camPos:Vector3D,tarPos:Vector3D):Object {
			// 通过  yFoctor 得到真正的相机位置
			var realCamPos:Vector3D = new Vector3D(camPos.x,camPos.y / hc.yFactor,camPos.z);
			// 得到相机与目标点的距离
			var dis:Number = Vector3D.distance(realCamPos,tarPos);
			// 通过给定的相机及目标点的距离得到相机的向量
			var v:Vector3D = tarPos.subtract(realCamPos);
			v.normalize();
			
			// 得到相机向量的平面向量,用来计算 panAngle
			var _v:Vector3D = new Vector3D(v.x,0,v.z);
			_v.normalize();
			
			// 计算 panAngle 的基准向量
			var vx:Vector3D = new Vector3D(0,0,-1);
			// 计算 tiltAngle 的基准微量
			var vy:Vector3D = new Vector3D(v.x,0,v.z);
			vy.normalize();
			
			// 通过 panAngle 基准向量及相机的平面向量的 差积,通过左手定则,判断角度 (大于180度的角的正负)
			var prefix:int = _v.crossProduct(vx).y < 0 ? 1 : -1;
			// 得到 panAngle
			var pa:Number = Vector3D.angleBetween(_v,vx) * 180 / Math.PI * prefix;
			// 得到 tiltAngle
			var ta:Number = Vector3D.angleBetween(v,vy) * 180 / Math.PI * (realCamPos.y - tarPos.y > 0 ? 1 : -1);
			
			// 返回包含 panAngle , tiltAngle 及 distance 的 Object
			return {panAngle:pa,tiltAngle:ta,distance:dis};
		}
		
		// Get delta Time
		private var lastTime:Number = 0 ,currentTime:Number = 0;
		private static var added:Boolean = false;
		
		/**
		 * 运行此方法,是为了让Stage计算deltaTime.
		 * 运行之后.即可使用 Tools.deltaTime.得到 deltaTime 值 
		 */
		public function calculateDeltaTime(stage:Stage):void {
			if(added) return;
			stage.addEventListener(Event.ENTER_FRAME,getDelta);
			added = true;
		}
		
		protected function getDelta(event:Event):void {
			if(lastTime == 0) {
				currentTime = lastTime = flash.utils.getTimer();
				return;
			}
			currentTime = flash.utils.getTimer();
			deltaTime = (currentTime - lastTime) / 1000;
			lastTime = currentTime;
		}
		
		/**
		 * 计算当前角度与指定角度之间的最进角度, 比如: 733度 与 20 度 之间的
		 * 最小角度是:733 +- (它们在园周上的差值).
		 */
		public function getNearestDegree(from:Number,to:Number):Number {
			// regular 得到相应 0 - 360 之间的角度
			var f:Number = from % 360;
			var t:Number = to % 360;
			// 得到都为正数的角度值
			f = f < 0 ? 360 + f : f;
			t = t < 0 ? 360 + t : t;
			// 计算之间的差值
			var delta:Number = t - f;
			
			// 如果差值大于 180度,需要进行转换
			if(Math.abs(delta) > 180) {
				// 如果差值大于0,说明to值在from的前方,并且之间的角度大于180度,
				// 比如: from:20 to:340  delta=320 需要使用差值减去360
				return from + (delta > 0 ? delta - 360 : 360 + delta);
			}
			return from + delta;
		}
	}
}