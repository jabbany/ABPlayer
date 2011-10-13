package org.kanoha.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	
	import mx.rpc.http.HTTPService;
	public class CommentSender extends EventDispatcher
	{
		private var loader:HTTPService = new HTTPService();
		private var _$url:String;
		private var _$vid:String;
		public function CommentSender(url:String)
		{
			this._$url = url;
			//loader.addEventListener(ResultEvent.RESULT,onComplete);
			//loader.addEventListener(FaultEvent.FAULT,onError);
		}
		public function set vid(u:String):void{
			this._$vid = u;
		}
		public function set url(u:String):void{
			this._$url = u;
		}
		public function get url():String{
			return this._$url;
		}
		public function send(data:Object):void{
			trace('Sending for ' + _$url);
			var d:URLVariables = new URLVariables();
			for (var key:String in data){
				if(key!="border")
					d[key] = String(data[key]);
			}
			d['action']="send_comment";
			d['vid']=this._$vid;
			loader.method="POST";
			loader.request = d;
			loader.url = this._$url;
			loader.send();
		}

	}
}