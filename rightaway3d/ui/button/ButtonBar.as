package rightaway3d.ui.button
{
	import com.greensock.TweenMax;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ztc.ui.AlignMode;
	import ztc.ui.AnimateType;
	import ztc.ui.ShowButton;
	
	[Event(name="button_click", type="flash.events.Event")]
	
	public class ButtonBar extends Sprite
	{
		public var type:String;
		public var distance:int = 0;
		public var align:AlignMode;
		public var border:int;
		public var cornersRound:int;
		/**
		 * ButtonBar的使用区域与可用区域的比例
		 */
		public var useArea:Number = 0.5;
		
		private var btns:Array = [];
		
		public var currBtn:ShowButton;
		
		private var container:Sprite;
		
		private var masker:Shape;
		
		private var leftBtn:ShowButton;
		private var rightBtn:ShowButton;
		private var upBtn:ShowButton;
		private var downBtn:ShowButton;
		
		public function ButtonBar()
		{
			super();
			
			container = new Sprite();
			this.addChild(container);
		}
		
		private function updateMasker(w:int,h:int):void
		{
			if(!masker)masker = new Shape();
			if(!masker.stage)
			{
				this.addChild(masker);
				container.mask = masker;
			}
			var g:Graphics = masker.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0);
			g.drawRect(0,0,w,h);
			g.endFill();
		}
		
		private var _viewWidth:Number = 0;
		private var _viewHeight:Number = 0;
		
		static public var leftArrowIcon:String = "assets/icon/left.png";
		static public var rightArrowIcon:String = "assets/icon/right.png";
		static public var upArrowIcon:String = "assets/icon/up.png";
		static public var downArrowIcon:String = "assets/icon/down.png";
		
		public function setMaxViewSize(width:Number,height:Number):void
		{
			if(align==AlignMode.BOTTOM || align==AlignMode.TOP)
			{
				if(width<barWidth)
				{
					width = ajustViewWidth(width);
					var w:Number = _viewHeight*0.5;
					
					leftBtn ||= creatArrowButton("left",w,_viewHeight,leftArrowIcon,w*0.8);
					if(!leftBtn.stage)this.addChild(leftBtn);
					
					rightBtn ||= creatArrowButton("right",w,_viewHeight,rightArrowIcon,w*0.8);
					if(!rightBtn.stage)this.addChild(rightBtn);
					
					var mw:Number = width-_viewHeight-distance*2;
					updateMasker(mw,_viewHeight);
					masker.x = w + distance;
					if(container.x==0)container.x = masker.x;
					if(container.x + container.width < masker.x + mw)container.x = masker.x + mw - container.width;
					
					rightBtn.x = masker.x + mw + distance;
					updateArrowBtn();
				}
				else
				{
					_viewWidth = barWidth;
					_viewHeight = barHeight;
					
					if(leftBtn && leftBtn.stage)this.removeChild(leftBtn);
					if(rightBtn && rightBtn.stage)this.removeChild(rightBtn);
					
					container.x = 0;
					container.mask = null;
					
					if(masker && masker.stage)this.removeChild(masker);
				}
			}
			else if(align==AlignMode.LEFT || align==AlignMode.RIGHT)
			{
				if(height<barHeight)
				{
					height = ajustViewHeight(height);
					var h:Number = _viewWidth*0.5;
					
					upBtn ||= creatArrowButton("up",_viewWidth,h,upArrowIcon,h*0.8);
					if(!upBtn.stage)this.addChild(upBtn);
					
					downBtn ||= creatArrowButton("down",_viewWidth,h,downArrowIcon,h*0.8);
					if(!downBtn.stage)this.addChild(downBtn);
					
					var mh:Number = height-_viewWidth-distance*2;
					updateMasker(_viewWidth,mh);
					masker.y = h + distance;
					if(container.y==0)container.y = masker.y;
					if(container.y + container.height < masker.y + mh)container.y = masker.y + mh - container.height;
					downBtn.y = masker.y + mh + distance;
					updateArrowBtn();
				}
				else
				{
					_viewWidth = barWidth;
					_viewHeight = barHeight;
					
					if(upBtn && upBtn.stage)this.removeChild(upBtn);
					if(downBtn && downBtn.stage)this.removeChild(downBtn);
					
					container.y = 0;
					container.mask = null;
					
					if(masker && masker.stage)this.removeChild(masker);
				}
			}
			
			updateBtnsCorner();
		}
		
		protected function onArrowClick(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			if(isTween)return;
			
			var btn:ShowButton = event.currentTarget as ShowButton;
			var w:int = button.btnWidth*0.5;
			var h:int = button.btnHeight*0.5;
			switch(btn.name)
			{
				case "left":
					if(container.x+w<masker.x)tweenBtns(container.x+button.btnWidth+distance,container.y);
					break;
				case "right":
					if(container.x+container.width-w>masker.x+masker.width)tweenBtns(container.x-button.btnWidth-distance,container.y);
					break;
				case "up":
					if(container.y+h<masker.y)tweenBtns(container.x,container.y+button.btnHeight+distance);
					break;
				case "down":
					if(container.y+container.height-h>masker.y+masker.height)tweenBtns(container.x,container.y-button.btnHeight-distance);
					break;
			}
		}
		
		private var isTween:Boolean=false;
		
		private function tweenBtns(x:Number,y:Number,times:Number=0.3):void
		{
			TweenMax.to(container,times,{x:x,y:y,onComplete:onTweenComplete});
			isTween = true;
		}
		
		private function onTweenComplete():void
		{
			isTween = false;
			updateArrowBtn();
		}
		
		private function updateArrowBtn():void
		{
			if(leftBtn)
			{
				var w:int = button.btnWidth*0.5;
				leftBtn.enable = (container.x+w<masker.x)?true:false;
				rightBtn.enable = (container.x+container.width-w>masker.x+masker.width)?true:false;
			}
			else
			{
				var h:int = button.btnHeight*0.5;
				upBtn.enable = (container.y+h<masker.y)?true:false;
				downBtn.enable = (container.y+container.height-h>masker.y+masker.height)?true:false;
			}
		}
		
		private function ajustViewWidth(w:Number):Number
		{
			_viewHeight = button.btnHeight;
			var t:Number = _viewHeight + distance;//留出左右箭头按钮的位置，左右箭头的宽度取其高度的一半
			
			var n:int = (w-t)/(button.btnWidth+distance);
			_viewWidth = n * (button.btnWidth+distance)+t;
			return _viewWidth;
		}
		
		private function ajustViewHeight(h:Number):Number
		{
			_viewWidth = button.btnWidth;
			var t:Number = _viewWidth + distance;//留出上下箭头按钮的位置，上下箭头的高度取其宽度的一半
			var n:int = (h-t)/(button.btnHeight+distance);
			_viewHeight = n * (button.btnHeight+distance)+t;
			return _viewHeight;
		}
		
		private function creatArrowButton(name:String,w:int,h:int,icon:String,iconSize:Number):ShowButton
		{
			var btn:ShowButton = new ShowButton(w,h,"",icon);
			btn.backgroundAlpha = button.backgroundAlpha;
			btn.normalColor = button.normalColor;
			btn.hoverColor = button.hoverColor;
			btn.selectedColor = button.selectedColor;
			btn.animateType = AnimateType.BACKGROUND_ALPHA;
			btn.iconSize = iconSize;
			btn.addEventListener(MouseEvent.MOUSE_DOWN,onArrowClick);
			btn.name = name;
			return btn;
		}
		
		public function addButton(btn:ShowButton):void
		{
			container.addChild(btn);
			btn.addEventListener(MouseEvent.CLICK,onBtnClick);
			
			var n:int = btns.length;
			if(align==AlignMode.BOTTOM || align==AlignMode.TOP)
			{
				btn.x = getBtnsWidth();
				btn.y = 0;
			}
			else if(align==AlignMode.LEFT || align==AlignMode.RIGHT)
			{
				btn.x = 0;
				btn.y = getBtnsHeight();
			}
			
			btns.push(btn);
			
			updateBtnsCorner();
		}
		
		protected function onBtnClick(event:MouseEvent):void
		{
			var btn:ShowButton = event.currentTarget as ShowButton;
			if(type=="group")
			{
				if(btn==currBtn)return;
				
				btn.selected = true;
				if(currBtn)currBtn.selected = false;
			}
			currBtn = btn;
			//trace("onButtonClick:"+btn.data);
			this.dispatchEvent(new Event("button_click"));
		}
		
		private function updateArrowBtnCorner():void
		{
			if(leftBtn)
			{
				var r:Number = leftBtn.btnWidth*0.5;
				leftBtn.setRoundAngle(r,0,r,0);
				rightBtn.setRoundAngle(0,r,0,r);
			}
		}
		
		private function updateBtnsCorner():void
		{
			var btns:Array = this.btns.concat();
			if(leftBtn && leftBtn.stage)
			{
				btns.unshift(leftBtn);
				btns.push(rightBtn);
			}
			else if(upBtn && upBtn.stage)
			{
				btns.unshift(upBtn);
				btns.push(downBtn);
			}
			
			var len:int = btns.length;
			var r:int = cornersRound;
			if(len==1)
			{
				var btn:ShowButton = btns[0];
				btn.setRoundAngle(r,r,r,r);
			}
			else
			{
				for(var i:int=0;i<len;i++)
				{
					btn = btns[i];
					if(i==0)
					{
						if(align==AlignMode.BOTTOM || align==AlignMode.TOP)
						{
							btn.setRoundAngle(r,0,r,0);
						}
						else if(align==AlignMode.LEFT || align==AlignMode.RIGHT)
						{
							btn.setRoundAngle(r,r,0,0);
						}
					}
					else if(i==len-1)
					{
						if(align==AlignMode.BOTTOM || align==AlignMode.TOP)
						{
							btn.setRoundAngle(0,r,0,r);
						}
						else if(align==AlignMode.LEFT || align==AlignMode.RIGHT)
						{
							btn.setRoundAngle(0,0,r,r);
						}
					}
					else
					{
						btn.setRoundAngle(0,0,0,0);
					}
				}
			}
		}
		
		public function get viewWidth():Number
		{
			return _viewWidth;
		}
		
		public function get viewHeight():Number
		{
			return _viewHeight;
		}
		
		public function get barWidth():Number
		{
			var len:int = btns.length;
			if(len>0)
			{
				var btn:ShowButton = btns[len-1];
				return btn.x + btn.btnWidth;
			}
			return 0;
		}
		
		public function get barHeight():Number
		{
			var len:int = btns.length;
			if(len>0)
			{
				var btn:ShowButton = btns[len-1];
				return btn.y + btn.btnHeight;
			}
			return 0;
		}
		
		private function getBtnsHeight():int
		{
			var n:int = 0;
			var len:int = btns.length;
			if(len>0)
			{
				var btn:ShowButton = btns[len-1];
				n += btn.y + btn.btnHeight + distance;
			}
			return n;
		}
		
		private function getBtnsWidth():int
		{
			var n:int = 0;
			var len:int = btns.length;
			if(len>0)
			{
				var btn:ShowButton = btns[len-1];
				n += btn.x + btn.btnWidth + distance;
			}
			return n;
		}
		
		private function get button():ShowButton
		{
			return btns[0];
		}
	}
}