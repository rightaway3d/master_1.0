package rightaway3d.ui.panel
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	public class TextPanel extends Sprite
	{
		private var textFormat:TextFormat;
		private var textField:TextField;
		
		public function TextPanel(color:uint,size:int,align:String,useFilter:Boolean=true)
		{
			super();
			initText(color,size,align,useFilter);
		}
		
		private function initText(color:uint,size:int,align:String,useFilter:Boolean):void
		{
			// Format
			textFormat = new TextFormat();
			textFormat.font = "微软雅黑";
			textFormat.size = size;
			textFormat.color = color;
			textFormat.align = align;
			
			textField = new TextField();
			this.addChild(textField);
			
			textField.width = 400;
			textField.wordWrap = true;
			textField.alpha = 1;
			textField.antiAliasType = AntiAliasType.NORMAL;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.selectable = false;
			textField.mouseEnabled = false;
			//textField.textColor = 0xffffff;
			if(useFilter)
			{
				var f:GlowFilter = new GlowFilter(0x707070);
				this.filters = [f];
			}
		}
		
		public function setText(str:String,autoHide:Boolean=true):void
		{
			var a:Array = str.split("\\n");
			str = a.join("\n");
			textField.text = str;
			
			textField.setTextFormat(textFormat);
			
			if(autoHide)
			{
				TweenMax.to(this,0.3,{autoAlpha:1});
				hideTextPanel(str.length * 2000);
			}
		}
		
		private var timer:Timer;
		private function hideTextPanel(time:int):void
		{
			if(!timer)
			{
				timer = new Timer(time);
				timer.addEventListener(TimerEvent.TIMER,onTimer)
			}
			else
			{
				timer.delay = time;
				timer.reset();
			}
			timer.start();
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			timer.stop();
			TweenMax.to(this,0.3,{autoAlpha:0});
		}
	}
}