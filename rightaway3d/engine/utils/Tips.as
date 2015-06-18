package rightaway3d.engine.utils
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import rightaway3d.utils.MyTextField;
	import rightaway3d.utils.Tween;

	public class Tips extends Sprite
	{
		static public var stage:Stage;
		
		static private var index:uint = 0;
		static private var queue:Array = [];
		static private var dict:Dictionary = new Dictionary();
		
		static public function show(msg:String,mouseX:Number,mouseY:Number,duration:int=2000,size:int=12):uint
		{
			var tips:Tips;
			//trace(queue.length);
			if(queue.length>0)
			{
				tips = queue.pop();
			}
			else
			{
				tips = new Tips();
				dict[tips.id] = tips;
			}
			tips.init(msg,duration,size);
			stage.addChild(tips);
			
			var tw:int = tips.width;
			var th:int = tips.height;
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			//var sh:int = stage.stageHeight*0.3;
			
			var mx:Number = mouseX + 20;
			var my:Number = mouseY + 20;
			
			if(mx+tw>sw)
			{
				mx=mouseX-tw;
				my=mouseY-th;
				if(my<0)my=0;
			}
			
			//mouseX -= tw*0.5;
			//mouseX += 20;
			
			//if(mouseX<0)mouseX = 0;
			//else if(mouseX+tw>sw)mouseX = sw - tw;
			
			//mouseY += mouseY>sh?-20:20;
			//mouseY += 20;
			//if(mouseY+th>sh)mouseY = sh - th;
			
			tips.x = mx;
			tips.y = my;
			
			tips.alpha = 0;
			Tween.to(tips,100,{alpha:1},autoHideTips);
			
			return tips.id;
		}
		
		static private function autoHideTips(tips:Tips):void
		{
			if(tips.autoHide)
			{
				_hideTips(tips);
			}
		}
		
		static public function hide(id:uint):void
		{
			var tips:Tips = dict[id];
			hideTips(tips);
		}
		
		static private function hideTips(tips:Tips):void
		{
			//trace("hideTips:"+tips.id,tips.alpha,tips.stage);
			tips.autoHide = true;
			if(!tips || tips.alpha<1 || !tips.stage)return;//alpha小于1时，已经在隐藏中了
			_hideTips(tips);
		}
		
		static private function _hideTips(tips:Tips):void
		{
			if(tips.timeoutID>-1)
			{
				flash.utils.clearTimeout(tips.timeoutID);
				tips.timeoutID = -1;
			}
			Tween.to(tips,300,{alpha:0},onHided);
		}
		
		static private function onHided(tips:Tips):void
		{
			if(tips.stage)
			{
				stage.removeChild(tips);
				queue.push(tips);
			}
		}
		
		//=================================================================================================
		private var txt:MyTextField;
		
		public var autoHide:Boolean = false;
		public var timeoutID:int = -1;
		
		public function Tips()
		{
			_id = index++;
			txt = new MyTextField();
			this.addChild(txt);
			txt.textSize = 16;
			txt.align = TextFormatAlign.CENTER;
			
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		public function init(msg:String,duration:int=3000,size:int=28):void
		{
			autoHide = false;
			
			timeoutID = setTimeout(hide,duration);
			
			if(txt.text==msg)return;
			
			txt.text = msg;
			//txt.textSize = size;
			txt.textColor = 0x505050;
			
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			var w:int = txt.width = txt.textWidth + 20;
			var h:int = txt.height = txt.textHeight + 5;
			txt.align = TextFormatAlign.CENTER;
			
			drawBack(w,h);
		}
		
		private function hide():void
		{
			hideTips(this);
		}
		
		private function drawBack(w:int,h:int):void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle(0,0x707070);
			g.beginFill(0xEEEEEE,0.8);
			g.drawRoundRect(0,0,w,h,8);
		}
		
		private var _id:uint;
		public function get id():uint
		{
			return _id;
		}
	}
}