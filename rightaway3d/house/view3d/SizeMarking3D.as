package rightaway3d.house.view3d
{
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	
	import rightaway3d.engine.object.Text3D;
	
	public class SizeMarking3D extends ObjectContainer3D
	{
		public var lineColor:uint = 0x0000ff;
		public var arrowHeight:uint = 150;
		
		public var textColor:uint = 0xff0000;
		public var textHeight:uint = 100;
		
		public var ypos:Number = 1000;
		public var zpos:Number = 100;
		
		private var lineSegment:LineSegment;
		private var setmentSet:SegmentSet;
		
		private var arrows:Array = [];
		private var texts:Array = [];
		
		static private var arrowPool:Array = [];
		static private var textPool:Array = [];
		
		public function SizeMarking3D()
		{
		}
		
		private function addArrow3D():Mesh
		{
			var arrow:Mesh = arrowPool.length>0?arrowPool.pop():new Mesh(new CylinderGeometry(3,3,arrowHeight),new ColorMaterial(lineColor));
			this.addChild(arrow);
			arrow.y = ypos;
			arrow.z = zpos;
			
			return arrow;
		}
		
		private function addText3D():Text3D
		{
			var text3d:Text3D = textPool.length>0?textPool.pop():new Text3D(null,textColor,textHeight);
			this.addChild(text3d);
			text3d.y = ypos;// + arrowHeight*0.5;
			text3d.z = zpos;
			return text3d;
		}
		
		public function update(xposs:Array):void
		{
			var xlen:int = xposs.length;
			
			while(arrows.length>xlen)//移除多出的箭头到缓存池中
			{
				var arrow:Mesh = arrows.pop();
				this.removeChild(arrow);
				arrowPool.push(arrow);
			}
			
			while(arrows.length<xlen)//当前箭头数量不够时，优先从缓存池中取出箭头
			{
				arrows.push(addArrow3D());
			}
			
			var textLen:int = xlen-1;
			while(texts.length>textLen)//移除多出的文字到缓存池中
			{
				var text3d:Text3D = texts.pop();
				this.removeChild(text3d);
				textPool.push(text3d);
			}
			
			while(texts.length<textLen)//当文字数量不够时，优先从缓存池中取出
			{
				texts.push(addText3D());
			}
			
			var tx:int;
			
			for(var i:int=0;i<xlen;i++)
			{
				var xpos:int = xposs[i];
				
				arrow = arrows[i];
				arrow.x = xpos;
				arrow.y = ypos;
				arrow.z = zpos;
				
				if(i>0)
				{
					var dist:int = xpos-tx;
					text3d = texts[i-1];
					text3d.text = String(dist);
					
					var dx:Number = tx + dist*0.5 - text3d.width*0.5 + 10;
					//trace("i,dx,text3d.width,xpos:",i,dx,text3d.width,xpos);
					
					if(i==1 && dx<tx)
					{
						dx = tx;
						//trace("---1");
					}
					else if(i==textLen && dx+text3d.width-10>xpos)
					{
						dx = xpos - text3d.width + 10;
						//trace("---2",dx,xpos-text3d.width);
					}
					//trace(dx,text3d.width,xpos,xpos-text3d.width);
					
					text3d.x = dx;
					text3d.y = dist<110?ypos+60:ypos;
				}
				tx = xpos;
			}
			
			
			var startPoint:Vector3D = arrows[0].position;
			//startPoint.y += arrowHeight*0.5;
			
			var endPoint:Vector3D = arrows[xlen-1].position;
			//endPoint.y = startPoint.y;
			
			if(!lineSegment)
			{
				setmentSet = new SegmentSet();
				lineSegment = new LineSegment(startPoint,endPoint,lineColor,lineColor,1);
				setmentSet.addSegment(lineSegment);
				addChild(setmentSet);
			}
			else
			{
				lineSegment.start = startPoint;
				lineSegment.end = endPoint;
			}
		}
		
		override public function dispose():void
		{
			if(arrows)
			{
				while(arrows.length>0)//移除多出的箭头到缓存池中
				{
					var arrow:Mesh = arrows.pop();
					this.removeChild(arrow);
					arrowPool.push(arrow);
				}
				arrows = null;
			}
			
			if(texts)
			{
				while(texts.length>0)//移除多出的文字到缓存池中
				{
					var text3d:Text3D = texts.pop();
					this.removeChild(text3d);
					textPool.push(text3d);
				}
				texts = null;
			}
			
			if(setmentSet)
			{
				setmentSet.dispose();
				setmentSet = null;
			}
			if(lineSegment)
			{
				lineSegment.dispose();
				lineSegment = null;
			}
			
			super.dispose();
		}
	}
}