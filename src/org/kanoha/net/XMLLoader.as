package org.kanoha.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import org.kanoha.events.LoaderEvent;
	public class XMLLoader extends EventDispatcher
	{
		private var loader:URLLoader = new URLLoader();
		public function XMLLoader()
		{
			this.hookListeners();
		}
		public function load(url:String):void{
			var req:URLRequest = new URLRequest(url);
			loader.load(req);
		}
		private function hookListeners():void{
			loader.addEventListener(Event.COMPLETE,onComplete);	
			loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		private function onComplete(e:Event):void{
			try{
				var xml:XML = new XML(loader.data);
				this.dispatchEvent(new LoaderEvent(LoaderEvent.XML_COMPLETE,xml));
			}catch(e:Error){
				this.dispatchEvent(new LoaderEvent(LoaderEvent.XML_PARSE_ERROR));
			}
		}
		private function onError():void{
			this.dispatchEvent(new LoaderEvent(LoaderEvent.XML_LOAD_ERROR));
		}
	}
}