package rightaway3d.utils
{
	//import app.utils.AppCommand;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.system.Security;
	
	public class RemotingConnection extends NetConnection
	{
		//public var configInfo:ConfigInfo = new ConfigInfo();//系统配置
		/**
		 * NetConnection 类在客户端和服务器之间创建双向连接。
		 * 客户端可以是 Flash Player 或 AIR 应用程序。
		 * 服务器可以是 Web 服务器、Flash Media Server、
		 * 运行 Flash Remoting 的应用程序服务器或 Adobe 状态服务。
		 * 调用 NetConnection.connect() 以建立连接。
		 * 使用 NetStream 通过该连接发送媒体流和数据。
		 * 在air环境中使用时，要将allowDomain参数值设为false
		 * @param gatewayURL
		 * @param allowDomain
		 * 
		 */
		public function RemotingConnection(gatewayURL:String,allowDomain:Boolean=true) {
			//this.addEventListener(NetStatusEvent.NET_STATUS, netStatusAction);
			//configInfo = Controller.getInstance().configInfo;
			/*if (null == gatewayURL)
			{
				gatewayURL = configInfo.ServerURL;
			}*/
			if(allowDomain)Security.allowDomain(gatewayURL);
			
			this.objectEncoding=ObjectEncoding.AMF3;
			this.connect(gatewayURL);
		}
		/*private function netStatusAction(e:NetStatusEvent):void
		{
			//Controller.getInstance().addBox(AppCommand.SHOW_ERROR_BOX,"NetConnection error!");
			trace("netStatusAction");
			var o:Object = e.info;
			for(var s:* in o)
			{
				trace(s+":"+o[s]);
			}
			switch(e.type) {  
                case AsyncErrorEvent.ASYNC_ERROR:  
                    break;  
                case "NetConnection.Call.Failed":  
					//Controller.getInstance().addBox(AppCommand.SHOW_SYSTEM_TIPS_BOX,"NetConnection.Call.Failed!");
                    break; 					
                default:  
                    //dispatchEvent(e);  
					break;
            }    
		}	*/	
	}
}