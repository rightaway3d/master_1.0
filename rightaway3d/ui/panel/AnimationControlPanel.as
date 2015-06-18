package rightaway3d.ui.panel
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import rightaway3d.engine.animation.AnimationAction;
	import rightaway3d.engine.animation.AnimationController;
	
	import ztc.ui.AlignMode;
	import ztc.ui.AnimateType;
	import ztc.ui.ShowButton;
	
	[Event(name="button_click", type="flash.events.Event")]
	
	public class AnimationControlPanel extends Sprite
	{
		[Embed(source="../../../../assets/rectangle.png")]
		public static var BG_BITMAP:Class;
		
		private var aniCtrl:AnimationController = new AnimationController();
		
		public function AnimationControlPanel()
		{
			super();
		}
		
		public function addActions(actions:Array,textColor:uint):void
		{
			var dist:Number = 100;
			var len:int = actions.length;
			if(len>1)
			{
				if(len>6)dist = 500/(len-1);
				
				var bmp:Bitmap = new BG_BITMAP();
				bmp.smoothing = true;
				bmp.width = (len-1) * dist;
				bmp.x = 40;
				bmp.y = 25;
				this.addChild(bmp);
			}
			
			for(var i:int=0;i<len;i++)
			{
				var action:AnimationAction = actions[i];
				var btn:ShowButton = createBtn(action.name,action.tips,textColor);
				btn.data = action;
				btn.x = i * dist;
				this.addChild(btn);
				btn.addEventListener(MouseEvent.CLICK,onClick);
				
				if(i==0)
				{
					btn.addEventListener("select_icon_loaded",onSelectIconLoaded);
				}
			}
		}
		
		private var btn:ShowButton;
		protected function onSelectIconLoaded(event:Event):void
		{
			this.addEventListener(Event.ENTER_FRAME,doMouseEvent);
			btn = event.currentTarget as ShowButton;
		}
		
		protected function doMouseEvent(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME,doMouseEvent);
			btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));

		}
		
		public var currBtn:ShowButton;
		
		protected function onClick(event:MouseEvent):void
		{
			var btn:ShowButton = event.currentTarget as ShowButton;
			if(btn==currBtn)return;
			
			if(currBtn)currBtn.selected = false;
			
			currBtn = btn;
			currBtn.selected = true;
			
			var action:AnimationAction = currBtn.data;
			aniCtrl.setCurrObject(action.modelObject);
			aniCtrl.play(action.startFrame,action.endFrame,action.loop);
			
			this.dispatchEvent(new Event("button_click"));
		}
		
		private function createBtn(cap:String,tips:String,textColor:uint):ShowButton
		{
			var normalIcon:String = "assets/icon/circle1.png";
			var selectIcon:String = "assets/icon/circle2.png";
			
			//var btn:ShowButton = new ShowButton(50,30,cap,"color:0x909090","");
			var btn:ShowButton = new ShowButton(80,80,cap,normalIcon,"");
			
			btn.textAlign = AlignMode.BOTTOM;
			btn.roundAngleWidth = 10;
			btn.backgroundAlpha = 0;
			btn.fontSize = 14;
			btn.fontColor = textColor;
			
//			btn.normalMapFileName = normalIcon;
//			btn.hoverMapFileName = normalIcon;
//			btn.selectedMapFileName = selectIcon;
			btn.selectIcon = selectIcon;
			
//			btn.normalColor = 0x101010;
//			btn.hoverColor = 0;
//			btn.selectedColor = 0;
			btn.animateType = AnimateType.BACKGROUND_ALPHA;
			btn.tooltipAlign = AlignMode.BOTTOM;
			btn.tooltipDelay = 100;
			
			btn.iconSize = 22;
			return btn;
		}
	}
}