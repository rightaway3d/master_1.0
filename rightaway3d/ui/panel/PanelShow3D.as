package rightaway3d.ui.panel
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextFormatAlign;
	
	import rightaway3d.Urls;
	import rightaway3d.engine.animation.AnimationAction;
	import rightaway3d.engine.core.EngineController;
	import rightaway3d.engine.model.ModelManager;
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.engine.parser.ModelParser;
	import rightaway3d.ui.button.ButtonBar;
	
	import ztc.ui.AlignMode;
	import ztc.ui.ShowButton;
	
	public class PanelShow3D extends Sprite
	{
		public var animationPanelTextColor:uint = 0xffffff;
		
		private var engineController:EngineController;
		private var returnButton:ShowButton;
		private var returnButtonBorder:int;
		private var aniCtrlPanel:AnimationControlPanel;
		
		private var textPanel:TextPanel;
		private var copyRight:TextPanel;
		
		private var btnBars:Array = [];
		
		public function PanelShow3D(engineController:EngineController)
		{
			super();
			this.engineController = engineController;
			
			moviePanel = new MoviePanel();
			this.addChild(moviePanel);
			
			textPanel = new TextPanel(0xffffff,16,TextFormatAlign.LEFT);
			this.addChild(textPanel);
			
			copyRight = new TextPanel(0xDDDDDD,12,TextFormatAlign.CENTER);
			this.addChild(copyRight);
			copyRight.setText("Copyright (C) 1999-2014 @inno studio,All Rights Reserved",false);
			
			ModelParser.own.addEventListener("all_model_parsed",onAllModelParsed);
		}
		
		protected function onAllModelParsed(event:Event):void
		{
			//trace("onAllModelParsed");
			//ModelParser.own.removeEventListener("all_model_parsed",onAllModelParsed);
			
			this.addEventListener(Event.ENTER_FRAME,createAniCtrlPanel);
		}
		
		private function createAniCtrlPanel(e:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME,createAniCtrlPanel);
			
			var objs:Array = ModelManager.own.getAllObjects();
			//trace("onAllModelParsed:"+a);
			var aas:Array = [];
			for each(var obj:ModelObject in objs)
			{
				if(obj.animationActions && obj.animationActions.length>0)
				{
					for each(var aa:AnimationAction in obj.animationActions)
					{
						trace("animationActions:"+aa.tips+" "+aa.name);
						aas.push(aa);
					}
				}
			}
			if(aas.length>0)
			{
				aniCtrlPanel = new AnimationControlPanel();
				this.addChild(aniCtrlPanel);
				aniCtrlPanel.addEventListener("button_click",onAnimationPanleClick);
				aniCtrlPanel.addActions(aas,animationPanelTextColor);
				
				aniCtrlPanel.x = (stage.stageWidth - aniCtrlPanel.width)/2;
				aniCtrlPanel.y = 30;
			}
		}
		
		protected function onAnimationPanleClick(event:Event):void
		{
			var s:String = aniCtrlPanel.currBtn.data.dscp;
			if(s)showTextInfo(s);
		}
		
		public function setReturnButton(btn:ShowButton,border:int,align:AlignMode):void
		{
			this.addChild(btn);
			this.returnButton = btn;
			btn.addEventListener(MouseEvent.CLICK,onReturnClick);
			btn.visible = false;
			
			returnButtonBorder = border;
		}
		
		protected function onReturnClick(event:MouseEvent):void
		{
//			trace("onReturnClick:"+this.returnButton.data);
			returnButton.visible = false;
			moviePanel.close();
			
			engineController.showScene();
			
			for each(var b:ButtonBar in btnBars)
			{
				b.visible = true;
			}
			
			if(aniCtrlPanel)aniCtrlPanel.visible = true;
			if(guideObj)guideObj.visible = true;
		}
		
		public function addButtonBar(bar:ButtonBar):void
		{
			this.addChild(bar);
			btnBars.push(bar);
			bar.addEventListener("button_click",onButtonBarClick);
		}
		
		private var textureLoader:TextureLoader;
		
		protected function onButtonBarClick(event:Event):void
		{
			var bar:ButtonBar = event.currentTarget as ButtonBar;
//			trace("onButtonBarClick:"+bar.currBtn.data);
			var xml:XML = bar.currBtn.data;
			
			var dscp:String = xml.dscp?xml.dscp:null;
			if(dscp)showTextInfo(dscp);
			
			var actionType:String = xml.type;
			
			switch(actionType)
			{
				case "color":
					var color:uint = xml.value;
					var target:String = xml.target;
					var targetType:String = xml.target.@type;
					var ary:Array = target.split("|");
					var objID:String = ary[0];
					var targetName:String = ary[1];
					
					if(targetType=="material")
						engineController.setMaterialColor(color,targetName,objID)
					else
						engineController.setMeshColor(color,targetName,objID);
					break;
				
				case "material":
					var url:String = xml.value;
					url = Urls.materialBaseURL + url;
					trace(url);
					
					target = xml.target;
					targetType = xml.target.@type;
					ary = target.split("|");
					objID = ary[0];
					targetName = ary[1];
					
					textureLoader ||= new TextureLoader(this.engineController);
					textureLoader.load(url,targetName,targetType,objID);
					break;
				
				case "view":
					var s:String = xml.value;
					var a:Array = s.split(",");
					var pan:Number = a[0];
					var tilt:Number = a[1];
					var distance:Number = a[2];
					s = a[3];
					a = s.split("|");
					var lookAt:Vector3D = new Vector3D(a[0],a[1],a[2]);
					engineController.setCamera(pan,tilt,distance,lookAt);
					break;
				
				case "point":
					hideScene(bar);
					
					url = xml.movie;
					url = Urls.movieBaseURL + url;
					moviePanel.loadMovie(url);
					moviePanel.show();
					break;
				
				case "video":
					hideScene(bar);
					
					url = xml.movie;
					url = Urls.videoBaseURL + url;
					var w:int = xml.width;
					var h:int = xml.height;
					moviePanel.loadVideo(url,w,h);
					moviePanel.show();
					break;
				
				default:
					trace("不可识别的ActionType:"+actionType);
			}
		}
		
		private function hideScene(bar:ButtonBar):void
		{
			for each(var b:ButtonBar in btnBars)
			{
				if(b!=bar)
				{
					b.visible = false;
				}
			}
			
			if(aniCtrlPanel)aniCtrlPanel.visible = false;
			
			engineController.hideScene();
			
			returnButton.visible = true;
			if(guideObj)guideObj.visible = false;
		}
		
		private function showTextInfo(s:String):void
		{
			textPanel.setText(s);
			updateView(stage.stageWidth,stage.stageHeight);
		}
		
		private var background:DisplayObject;
		
		private var companyLogo:DisplayObject;
		private var companyBorder:int;
		
		private var productLogo:DisplayObject;
		private var productBorder:int;
		
		private var moviePanel:MoviePanel;
		
		public function setBackground(bg:DisplayObject):void
		{
			this.addChildAt(bg,0);
			background = bg;
		}
		
		public function setCompanyLogo(o:DisplayObject,border:int=20):void
		{
			this.addChild(o);
			companyLogo = o;
			companyBorder = border;
			o.x = border;
			o.y = border;
		}
		
		public function setProductLogo(o:DisplayObject,border:int=20):void
		{
			this.addChild(o);
			productLogo = o;
			productBorder = border;
			
			updateView(stage.stageWidth,stage.stageHeight);
		}
		
		private var guideObj:DisplayObject;
		
		public var guideAlign:String = "right";
		public var guideHorizontal:int = 20;
		public var guideVertical:int = 100;
		
		public function setGuide(o:DisplayObject):void
		{
			guideObj = o;
			this.addChild(o);
			
			updateView(stage.stageWidth,stage.stageHeight);
		}
		
		public function updateView(w:int,h:int):void
		{
			if(returnButton)
			{
				returnButton.x = w - returnButton.btnWidth - returnButtonBorder;
				returnButton.y = returnButtonBorder;
			}
			
			if(aniCtrlPanel)
			{
				aniCtrlPanel.x = (w - aniCtrlPanel.width)/2;
				aniCtrlPanel.y = 30;
			}

			var len:int = btnBars.length;
			var bottomBar:ButtonBar;
			
			for(var i:int=0;i<len;i++)
			{
				var bar:ButtonBar = btnBars[i];
				if(bar.align==AlignMode.LEFT)
				{
					var maxBarHeight:Number = h*bar.useArea;
					bar.setMaxViewSize(0,maxBarHeight);
					bar.x = bar.border;
					bar.y = (h-bar.viewHeight)/2;
				}
				else if(bar.align==AlignMode.RIGHT)
				{
					maxBarHeight = h*bar.useArea;
					bar.setMaxViewSize(0,maxBarHeight);
					bar.x = w - bar.viewWidth - bar.border;
					bar.y = (h-bar.viewHeight)/2;
				}
				else if(bar.align==AlignMode.BOTTOM)
				{
					var maxBarWidth:Number = w*bar.useArea;
					bar.setMaxViewSize(maxBarWidth,0);
					bar.x = (w-bar.viewWidth)/2;
					bar.y = h - bar.viewHeight - bar.border;
					bottomBar = bar;
				}
			}
			
			textPanel.x = (w-textPanel.width)/2;
			
			var hh:Number = bottomBar?bottomBar.y:h;
			textPanel.y = hh - textPanel.height - 50;
			
			copyRight.x = (w-copyRight.width)/2;
			copyRight.y = h - copyRight.height - 5;
			
			moviePanel.setViewSize(w,h);
			
			if(productLogo)
			{
				productLogo.x = w - productLogo.width - productBorder;
				productLogo.y = h - productLogo.height - productBorder;
			}
			
			if(background)
			{
				background.width = w;
				background.height = h;
			}
			
			if(guideObj)
			{
				if(guideAlign=="right")
				{
					guideObj.x = w - guideObj.width - guideHorizontal;
					guideObj.y = h - guideObj.height - guideVertical;
				}
				else
				{
					guideObj.x = guideHorizontal;
					guideObj.y = guideVertical;
				}
			}
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import rightaway3d.engine.core.EngineController;
import rightaway3d.engine.utils.BMP;

class TextureLoader
{
	private var loader:Loader;
	private var targetName:String;
	private var targetType:String;
	private var modelID:String;
	
	public function TextureLoader(engineController:EngineController)
	{
		this.engineController = engineController;
	}
	
	public function load(url:String,targetName:String,targetType:String,modelID:String):void
	{
		this.targetName = targetName;
		this.targetType = targetType;
		this.modelID = modelID;
		_load(url);
	}
	
	private var isLoading:Boolean = false;
	private var engineController:EngineController;
	
	private function _load(url:String):void
	{
		if(!loader)
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
		}
		else
		{
			if(isLoading)loader.close();
			loader.unload();
		}
		
		loader.load(new URLRequest(url));
		
		isLoading = true;
	}
	
	protected function onLoadError(event:IOErrorEvent):void
	{
		isLoading = false;
	}
	
	protected function onLoaded(event:Event):void
	{
		var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
		
		var bmp:Bitmap= loaderInfo.content as Bitmap;
		var data:BitmapData = BMP.scaleBmpData(bmp.bitmapData);
		
		if(targetType=="material")engineController.setMaterialBitmapTexture(modelID,targetName,data);
		else
			engineController.setMeshBitmapTexture(modelID,targetName,data);
		
		loaderInfo.loader.unload();
		isLoading = false;
	}
}













