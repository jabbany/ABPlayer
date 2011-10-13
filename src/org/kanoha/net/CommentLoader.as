package org.kanoha.net
{
	import flash.events.EventDispatcher;
	
	import org.kanoha.events.LoaderEvent;
	import org.kanoha.util.CommentListParser;
	
	public class CommentLoader extends EventDispatcher
	{
		private var loader:XMLLoader = new XMLLoader();
		private var _$addr:String="";
		public function CommentLoader(address:String)
		{
			this._$addr = address;
			loader.addEventListener(LoaderEvent.XML_COMPLETE,onLoad);
			loader.addEventListener(LoaderEvent.XML_LOAD_ERROR,onLoadError);
			loader.addEventListener(LoaderEvent.XML_PARSE_ERROR,onParseError);
		}
		public function load(s:String):void{
			this._$addr = s;
			loader.load(s);
		}
		public function reload():void{
			this.load(this._$addr);
		}
		private function onLoad(e:LoaderEvent):void{
			var cArr:Array = CommentListParser.parse(XML(e.info),0);
			this.dispatchEvent(new LoaderEvent(LoaderEvent.COMMENT_COMPLETE,cArr));
		}
		private function onLoadError(e:LoaderEvent):void{
			this.dispatchEvent(new LoaderEvent(LoaderEvent.NO_COMMENT));
		}
		private function onParseError(e:LoaderEvent):void{
			this.dispatchEvent(new LoaderEvent(LoaderEvent.COMMENT_ERROR));
		}
	}
}