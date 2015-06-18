package rightaway3d.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	public class MySocket extends Socket
	{
		private var _host:String;
		private var _port:int;
		private var _autoReconnect:Boolean;
		private var _numReconnect:int;
		private var _reconnectDelay:int;
		private var timer:Timer;
		
		public function MySocket()
		{
			
		}
		
		/**
		 * 开始远程日志输出
		 * @param host 远程服务地址
		 * @param port 远程服务端口
		 * @param autoReconnect 连接失败或连接被断开后，是否自动重连
		 * @param numReconnect 自动重连的尝试次数,为0时次数无限
		 * @param reconnectTime 自动重连的间隔时间，单位为秒
		 * 
		 */
		public function start(host:String,port:int,autoReconnect:Boolean=false,numReconnect:int=10,reconnectDelay:int=5):void
		{
			_host = host;
			_port = port;
			_autoReconnect = autoReconnect;
			_numReconnect = numReconnect;
			_reconnectDelay = reconnectDelay;
			
			this.addEventListener(Event.CLOSE,onSocketClosed);
			this.addEventListener(Event.CONNECT,onSockConnect);
			this.addEventListener(IOErrorEvent.IO_ERROR,onSocketError);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketError);
			this.connect(host,port);
		}
		
		public function dispose():void
		{
			this.removeEventListener(Event.CLOSE,onSocketClosed);
			this.removeEventListener(Event.CONNECT,onSockConnect);
			this.removeEventListener(IOErrorEvent.IO_ERROR,onSocketError);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketError);
			this.close();
			clearTimer();
		}
		
		private function onSockConnect(e:Event):void
		{
			trace("LogSocketConnect:"+e);
			clearTimer();
		}
		
		private function onSocketClosed(e:Event):void
		{
			trace("LogSocketClose:"+e);
			reConnect();
		}
		
		private function onSocketError(e:Event):void
		{
			trace("LogSocketError:"+e);
			reConnect();
		}
		
		private function reConnect():void
		{
			if(timer==null && _autoReconnect)
			{
				timer = new Timer(_reconnectDelay * 1000);
				timer.addEventListener(TimerEvent.TIMER,onConnectTimer);
				timer.start();
			}
		}
		
		private function onConnectTimer(e:TimerEvent):void
		{
			if(_numReconnect==0 || timer.currentCount<_numReconnect)
			{
				this.connect(_host,_port);
			}
			else
			{
				trace("连接失败 host："+_host+" port："+_port);
				clearTimer();
				_autoReconnect = false;
			}
		}
		
		private function clearTimer():void
		{
			if(timer!=null)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,onConnectTimer);
				timer = null;
			}
		}
		
		public function send(s:String):void
		{
			if(this.connected)
			{
				s += "\x00";
				this.writeUTFBytes(s);
				this.flush();
			}
		}
		
	}
}