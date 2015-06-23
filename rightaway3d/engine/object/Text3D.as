package rightaway3d.engine.object
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.utils.MyTextField;

	public class Text3D extends ObjectContainer3D
	{
		public function Text3D(text:String=null,textColor:uint=0xff0000,textHeight:uint=150)
		{
			super();
			
			initText();
			
			this.textColor = textColor;
			this.textHeight = textHeight;
			this.text = text;
		}
		
		private var mesh:Mesh;
		
		private var _material:TextureMaterial;
		
		private var plane:PlaneGeometry;
		
		private var texture:BitmapTexture;
		
		private var txt:MyTextField;
		
		private function initText():void
		{
			txt = new MyTextField();
			txt.textSize = 32;
			txt.align = TextFormatAlign.LEFT;
			txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function update():void
		{
			txt.text = text;
			txt.textColor = textColor;
			
			var tmp:Number = txt.textWidth;
			tmp = txt.textHeight;
			tmp = txt.width;
			tmp = txt.height;
			
			var tw:Number = txt.textWidth + 20;
			var th:Number = txt.textHeight + 2;
			
			txt.width = tw;
			txt.height = th;
			
			var w1:int = BMP.getMaxPower(tw);
			var h1:int = BMP.getMaxPower(th);
			
			var m:Matrix = new Matrix();
			m.scale(w1/tw,h1/th);
			
			var bmd:BitmapData = new BitmapData(w1,h1,true,0);
			bmd.draw(txt,m,null,null,null,true);
			
			if(!texture)texture = new BitmapTexture(bmd);
			else
				texture.bitmapData = bmd;
			
			if(!_material)
			{
				_material = new TextureMaterial(texture);
				_material.alphaBlending = true;
				_material.bothSides = true;
			}
			
			if(!plane)
			{
				plane = new PlaneGeometry(300,150);
			}
			
			var s:Number = tw/th;//计算的文字的宽高比例
			plane.height = textHeight;//3D文字高度为指定高度
			plane.width = textHeight * s;//3D文字高度，与文本框等比缩放
			
			if(!mesh)
			{
				mesh = new Mesh(plane,_material);
				this.addChild(mesh);
				
				mesh.rotationX = -90;
			}
			
			mesh.x = plane.width * 0.5;
			mesh.y = plane.height * 0.5;
		}
		
		private var _text:String;

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
			
			if(value)update();
		}

		public var textHeight:uint;

		/*public function get textHeight():uint
		{
			return _textHeight;
		}

		public function set textHeight(value:uint):void
		{
			_textHeight = value;
		}*/
		
		public var textColor:uint;

		/*public function get textColor():uint
		{
			return _textColor;
		}

		public function set textColor(value:uint):void
		{
			_textColor = value;
		}*/
		
		public function get width():Number
		{
			return plane.width;
		}
		
		public function get height():Number
		{
			return plane.height;
		}

	}
}