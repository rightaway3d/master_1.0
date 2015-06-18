package rightaway3d.user
{
	//import com.adobe.crypto.MD5;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import rightaway3d.URLTool;

	[Event(name="error", type="flash.events.Event")]
	
	[Event(name="login", type="flash.events.Event")]
	
	[Event(name="logout", type="flash.events.Event")]
	
	public class User extends EventDispatcher
	{
		//static public var ServerURL:String = "";
		
		//=========================================================================================
		public var projectManager:ProjectManager;
		
		public var userID:String = "";
		public var userName:String = "";
		public var password:String = "";
		
		public var errorMsg:String;
		
		//=========================================================================================
		private var _isLogin:Boolean = false;
		
		//--------------------------------------------------------------------------
		public function get isLogin():Boolean
		{
			return _isLogin;
		}
		
		public function set isLogin(value:Boolean):void
		{
			if(_isLogin == value)return;
			_isLogin = value;
			
			if(value)
			{
				if(hasEventListener("login"))this.dispatchEvent(new Event("login"));
			}
			else
			{
				if(hasEventListener("logout"))this.dispatchEvent(new Event("logout"));
			}
		}
		
		//=========================================================================================
		public function login(userName:String,password:String):void
		{
			this.userName = userName;
			this.password = password;
			
			//password = MD5.hash(password);
			
			var o:Object = {username:userName,password:password};
			URLTool.CallRemote("logon",o,onLoginResult,onError);
		}
		//=========================================================================================
		private function onLoginResult(result:*):void
		{
			trace("onLoginResult:"+result);
			if(isNaN(Number(result)))
			{
				error("登陆失败："+result);
			}
			else
			{
				userID = result;
				isLogin = true;
			}
		}
		
		//=====================================================================
		
		private function onError(msg:String):void
		{
			error(msg);
		}
		
		private function error(msg:String=""):void
		{
			trace("error:"+msg);
			if(hasEventListener("error"))
			{
				//errorMsg = "remote call error";
				errorMsg = msg;
				this.dispatchEvent(new Event("error"));
			}
		}
		
		//=========================================================================================
		private static var _own:User;
		//--------------------------------------------------------------------------
		public static function get own():User
		{
			return _own ||= new User();
		}
		
		//--------------------------------------------------------------------------
		public function User()
		{
			projectManager = new ProjectManager(this);
		}
		//=========================================================================================
	}
}