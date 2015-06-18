package rightaway3d.utils
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class MyTextField extends TextField
	{
		private var _textFormat:TextFormat;

		//protected var _label:String = "Label";

		private var _textSize:uint = 14;

		private var _bold:Boolean = false;
		
		private var _italic:Boolean = false;
		
		private var _underline:Boolean = false;
		
		private var _input:Boolean = false;

		//当对象被移出显示列表时，是否自动销毁自己
		//private var _autoDestroyWhenRemove:Boolean = true;

		//-----------------------------------------------------------------------------------
		public function MyTextField()
		{
			super();
			init();

			this.addEventListener(Event.CHANGE, setText);
		}
		
		public function dispose():void
		{
			_textFormat = null;
			this.removeEventListener(Event.CHANGE, setText);
		}

		//-----------------------------------------------------------------------------------

		private function init():void
		{
			//设置文本默认格式
			_textFormat = new TextFormat();
			//this.defaultTextFormat = _textFormat;

			//_textFormat.size = _textSize;

			this.input = false;

			//自动左对齐
			this.autoSize = TextFieldAutoSize.NONE;

			//不可选择
			this.selectable = false;

			//不自动换行
			this.wordWrap = false;

			//this.text = _label;
			//this.setTextFormat(_textFormat);
		}

		//-----------------------------------------------------------------------------------
		public function get input():Boolean
		{
			return _input;
		}

		public function set input(value:Boolean):void
		{
			_input = value;
			this.selectable = value;

			if (value)
			{
				//可输入文本
				this.type = TextFieldType.INPUT;
			}
			else
			{
				//静态文本
				this.type = TextFieldType.DYNAMIC;
			}
		}

		//-----------------------------------------------------------------------------------
		//设置文本字体大小
		public function set textSize(size:uint):void
		{
			if (_textSize == size)
				return;

			_textSize = size;
			_textFormat.size = size;

			this.setTextFormat(_textFormat);
			//trace("setTextFormat:" + size);

			//发布尺寸改变事件
			//this.dispatchEvent(new Event("sizeChanged"));
		}

		//返回文本字体大小
		public function get textSize():uint
		{
			return _textSize;
		}

		//-----------------------------------------------------------------------------------
		//指示文本是否粗体
		public function get bold():Boolean
		{
			return _bold;
		}
		
		public function set bold(value:Boolean):void
		{
			_bold = value;
			_textFormat.bold = value;
			
			this.setTextFormat(_textFormat);
		}
		
		//-----------------------------------------------------------------------------------
		//指示文本是否斜体
		public function get italic():Boolean
		{
			return _italic;
		}
		
		public function set italic(value:Boolean):void
		{
			_italic = value;
			_textFormat.italic = value;
			
			this.setTextFormat(_textFormat);
		}
		//-----------------------------------------------------------------------------------
		//指示文本是否带下划线
		public function set underline(value:Boolean):void
		{
			_underline = value;
			_textFormat.underline = value;

			this.setTextFormat(_textFormat);
		}

		//返回文本是否带下划线
		public function get underline():Boolean
		{
			return _underline;
		}

		//-----------------------------------------------------------------------------------
		//指示文本对齐方式
		public function set align(value:String):void
		{
			_textFormat.align = value;

			this.setTextFormat(_textFormat);
		}

		//返回文本是否带下划线
		public function get align():String
		{
			return _textFormat.align;
		}

		//-----------------------------------------------------------------------------------
		private function setText(event:Event):void
		{
			this.setTextFormat(_textFormat);
		}

		//-----------------------------------------------------------------------------------
		//设置文本内容，并应用格式
		override public function set text(value:String):void
		{
			// TextField's text property can't be set to null.
			if (!value)
				value = "";

			// Performance optimization: if the text hasn't changed,
			// don't let the player think that we're dirty.
			//if (super.text == value)
			//return;

			super.text = value;
			//this.textSize = _textSize;
			this.setTextFormat(_textFormat);
			//trace("set text");
		}

		//-------------------------------------------------------------------
		override public function appendText(newText:String):void
		{
			super.appendText(newText);
			this.setTextFormat(_textFormat);
		}
		//-------------------------------------------------------------------
	}
}

