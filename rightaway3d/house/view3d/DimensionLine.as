package rightaway3d.house.view3d
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import rightaway3d.engine.object.Text3D;
	
	public class DimensionLine extends ObjectContainer3D
	{
		public var line:SegmentSet ;
		public var lineSegment:LineSegment;
		public var startArrow:Mesh;
		public var endArrow:Mesh;
		public var linePlane_height :uint = 10;
		public var max:int;
		public var min:int;
		public function DimensionLine()
		{
			super();
		}
		public function createDimension(startPoint:Vector3D,endPoint:Vector3D):void
		{
			line = new SegmentSet();
			lineSegment = new LineSegment(startPoint,endPoint,0x0000FF,0x0000FF,1);
			line.addSegment(lineSegment);
			addChild(line);
			var startP2d:Point = new Point(startPoint.x,startPoint.y);
			var endp2d:Point = new Point(endPoint.x,endPoint.y);
			var centerP2d:Point = getLineCenter(startP2d,endp2d);
			var center:Vector3D = new Vector3D(centerP2d.x,centerP2d.y,startPoint.z);
			createDimensionPlane(center);
			startArrow = ceateArrows(startPoint);
			endArrow = ceateArrows(endPoint);
			update(startPoint,endPoint);
//			update(new Vector3D(-200,0,0),new Vector3D(500,0,0));
		}
		
		public var dimensionMaterial:TextureMaterial;
		private var dimentTitle:TextField ;
		private var dimentPlane:Mesh ;
		private function createDimensionPlane(_center:Vector3D):void
		{
			dimentTitle = new TextField();
			dimentTitle.width = 128;
			dimentTitle.height = 64;
			
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.size = 30;
			format.color = 0xff0000;
			dimentTitle.defaultTextFormat = format;
			dimentTitle.text = "20.89";
			
			var bitmapData:BitmapData = new BitmapData(256,64,true,0);
			bitmapData.draw(dimentTitle);
			
			dimensionMaterial = new TextureMaterial(Cast.bitmapTexture(bitmapData));
			dimensionMaterial.alphaBlending = true;
			
			dimentPlane = new Mesh(new PlaneGeometry(300,150),dimensionMaterial);
			//addChild(dimentPlane);
			dimentPlane.rotationX = -90;
			dimentPlane.x = _center.x;
			//			dimentPlane.y = linePlane_height;
		}
		
		private function ceateArrows(point:Vector3D,color:Number=0x0000FF):Mesh
		{
			var arrow:Mesh = new Mesh(new CylinderGeometry(3,3,150),new ColorMaterial(color));
			addChild(arrow);
			arrow.x = point.x;
			arrow.y = point.y;
			arrow.z = point.z;
			return arrow;
		}
		
		public function update(startPoint:Vector3D,endPoint:Vector3D):void
		{
			dimensionMaterial.texture.dispose();
			lineSegment.start = startPoint;
			lineSegment.end = endPoint;
			startArrow.position = startPoint;
			endArrow.position = endPoint;
			var distance:int = Vector3D.distance(startPoint,endPoint);
			dimentTitle.text = distance+"";
			//trace("------distance:"+distance);
			
			var bitmapData:BitmapData = new BitmapData(128,64,true,0xFFFFFF);
			bitmapData.draw(dimentTitle);
			var bitmapTexture:BitmapTexture = Cast.bitmapTexture(bitmapData);
			dimensionMaterial.texture = bitmapTexture;
			
			var startP2d:Point = new Point(startPoint.x,startPoint.y);
			var endp2d:Point = new Point(endPoint.x,endPoint.y);
			var centerP2d:Point = getLineCenter(startP2d,endp2d);
			
			dimentPlane.x = Math.max(min+35,Math.min(centerP2d.x,max-35));
			
			if(distance<=70)
			{
				dimentPlane.y = startPoint.y+linePlane_height+70;
			}else
			{
				dimentPlane.y = startPoint.y+linePlane_height;
			}
			dimentPlane.z = startPoint.z;
			
			trace("dimentPlane.x,min,max,centerP2d.x:"+dimentPlane.x,min,max,centerP2d.x);
			
			var text3d:Text3D = new Text3D();
			this.addChild(text3d);
			text3d.text = distance+"";
			text3d.position = dimentPlane.position;
			text3d.update();
		}
		
		public function getLineCenter(p1:Point,p2:Point):Point
		{
			return new Point((p1.x+p2.x)/2,(p1.y+p2.y)/2);
		}
	}
}