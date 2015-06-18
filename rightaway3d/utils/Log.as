package rightaway3d.utils
{
	import flash.text.TextField;

	public final class Log
	{
		static private var logTxt:TextField;	
		static private var logFun:Function;
		static private var clearFun:Function;
		
		/**
		 * 日志输出内容分隔符
		 */
		static private var delimiter:String = "\r\n";
		
		/**
		 * 是否输出日志
		 */
		static public var isLog:Boolean = true;
		
		/**
		 * 消息前缀，只在远程输出时会加上此前缀
		 */
		static public var msgPrefix:String = "";
		
		static public function log(... args):void
		{
			if(!isLog)return;
			
			var s:String = args.toString();
			
			if(socket && socket.connected)
			{
				s = msgPrefix + s;
				socket.send(s);
			}
			else if(logTxt)
			{
				logTxt.appendText(s + delimiter);
				logTxt.scrollV = logTxt.maxScrollV;
			}			
			else if(logFun != null)
			{
				logFun(s);
			}
			else
			{
				//trace(s);
			}
			trace(s);
		}
		
		static private var socket:MySocket;
		
		static public function startRemoteLog(host:String,port:int,autoReconnect:Boolean=false,numReConnect:int=10):void
		{
			if(socket==null)
			{
				socket = new MySocket();
			}
			socket.start(host,port,autoReconnect,numReConnect,10);
		}
		
		static public function endRemoteLog():void
		{
			if(socket!=null)
			{
				socket.dispose();
				socket = null;
			}
		}
				
		/**
		 * 设置输出日志的文本框及输出内容的分隔符
		 * @param txt
		 * @param delimiter
		 * 
		 */
		static public function setTextField(txt:TextField,delimiter:String="\r\n"):void
		{
			logTxt = txt;
			Log.delimiter = delimiter;
			logFun = null;
			clearFun=null;
		}
		
		/**
		 * 设置输出日志的外调方法及清除日志的外调方法
		 * @param logFunc
		 * @param clearLogFunc
		 * 
		 */
		static public function setLogFunc(logFunc:Function,clearLogFunc:Function=null):void
		{
			logFun = logFunc;
			clearFun = clearLogFunc;
			logTxt = null;
		}
		
		static public function clear():void
		{
			if(logTxt != null)logTxt.text = "";
			if(clearFun!=null)clearFun();
		}
	}
}






