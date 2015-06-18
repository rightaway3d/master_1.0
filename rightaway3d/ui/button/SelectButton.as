package rightaway3d.ui.button
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	[Event(name="button_down", type="flash.events.Event")]
	
	public final class SelectButton extends Sprite
	{
		//---------------------------------------------------------
		/**
		 * 用于保存一些附加信息
		 */
		public var data:*;
		
		//---------------------------------------------------------
		private var _normalImageURL:String;
		private var _rollOverImageURL:String;
		private var _mouseDownImageURL:String;
		
		//---------------------------------------------------------
		//private var _normalImage:DisplayObject;
		//private var _rollOverImage:DisplayObject;
		//private var _selectImage:DisplayObject;
		private var _currentImage:DisplayObject;
		
		//---------------------------------------------------------
		private var _normalLoader:Loader;
		private var _rollOverLoader:Loader;
		private var _mouseDownLoader:Loader;
		
		//---------------------------------------------------------
		private var _selected:Boolean = false;
		
		//---------------------------------------------------------
		static public const BUTTON_DOWN:String = "button_down";
		
		public var autoRepeat:Boolean = false;
		public var repeatDelay:int = 400;
	
		private var repeatTimer:Timer;
		
		//==============================================================================================

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if(_selected == value)
			{
				return;
			}
			
			_selected = value;
			
			if(value == true)
			{
				setMouseDown();//选中状态与鼠标按下状态一致
			}
			else
			{
				setNormal();
			}
		}

		//==============================================================================================
		public function init2(width,height,color,alpha,caption,normalImage:String,rollOverImage:String,mouseDownImage:String,tips):void
		{
			
		}
		public function init(normalImage:String,rollOverImage:String,mouseDownImage:String):void
		{
			_normalImageURL = normalImage;
			_rollOverImageURL = rollOverImage;
			_mouseDownImageURL = mouseDownImage;
			
			_normalLoader = new Loader();
			_normalLoader.load(new URLRequest(normalImage));
			
			_rollOverLoader = new Loader();
			_rollOverLoader.load(new URLRequest(rollOverImage));
			
			_mouseDownLoader = new Loader();
			_mouseDownLoader.load(new URLRequest(mouseDownImage));
			
			setNormal();
		}
		
		//==============================================================================================
		public function setNormal():void
		{
			if(_selected == true)
			{
				setMouseDown();
				return;
			}
			
			setCurrentLoader(_normalLoader);
		}
		
		//---------------------------------------------------------
		public function setRollOver():void
		{
			setCurrentLoader(_rollOverLoader);
		}
		
		//---------------------------------------------------------
		public function setMouseDown():void
		{
			setCurrentLoader(_mouseDownLoader);
		}
		
		//==============================================================================================
		private function setCurrentLoader(loader:Loader):void
		{
			if(_currentImage != loader)
			{
				if(_currentImage != null)
				{
					this.removeChild(_currentImage);
				}
				
				this.addChild(loader);
				_currentImage = loader;
			}
		}
		
		//==============================================================================================
		private function onRollOver(e:MouseEvent):void
		{
			setRollOver();
		}
		
		private function onRollOut(e:MouseEvent):void
		{
			setNormal();
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			setMouseDown();
			
			if(this.hasEventListener(BUTTON_DOWN))
			{
				this.dispatchEvent(new Event(BUTTON_DOWN));
				if(this.autoRepeat==true)
				{
					if(this.repeatTimer==null)
					{
						this.repeatTimer = new Timer(this.repeatDelay);
						this.repeatTimer.addEventListener(TimerEvent.TIMER,onRepeatTimer);
					}
					this.repeatTimer.delay = this.repeatDelay;
					this.repeatTimer.start();
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			setRollOver();
			
			if(this.repeatTimer!=null)
			{
				this.repeatTimer.stop();
				this.repeatTimer.reset();
			}
		}
		
		private function onRepeatTimer(e:TimerEvent):void
		{
			this.dispatchEvent(new Event(BUTTON_DOWN));
		}
		
		//==============================================================================================
		public function SelectButton()
		{
			super();
			
			this.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT,onRollOut); 
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.useHandCursor = true;
		}

	}
}