package org.kanoha.net
{
	import flash.events.EventDispatcher;
	
	import org.kanoha.events.LoaderEvent;
	import org.kanoha.video.VideoInfo;
	public class VideoLoader extends EventDispatcher 
	{
		private var loader:XMLLoader = new XMLLoader();
		private var mode:String="file";
		public function VideoLoader()
		{
			loader.addEventListener(LoaderEvent.XML_COMPLETE,onComplete);
			loader.addEventListener(LoaderEvent.XML_LOAD_ERROR,onError);
			loader.addEventListener(LoaderEvent.XML_PARSE_ERROR,onError);
		}
		public function load(mode:String,s:String):void{
			this.mode = mode;
			if(mode=="sina"){
				loader.load("http://v.iask.com/v_play.php?vid=" + s);
			}else if(mode=="tudou"){
				loader.load("http://v2.tudou.com/v?it=" + s + "&hd=2&st=1%2C2%2C3%2C99");
			}else{
				//HAH-_-
			}
		}
		private function onComplete(event:LoaderEvent):void{
			var obj:Object = this.parse(XML(event.info),mode);
			dispatchEvent(new LoaderEvent(LoaderEvent.VIDEO_COMPLETE,obj));
		}
		private function parse(xmlObj:XML,mode:String):Object{
			if(mode=="sina"){
				var xl:XMLList = xmlObj.durl;
				var vArr:Array = new Array();
				var tt:uint = 0;
				for each(var vid:XML in xl){
					var vInfo:VideoInfo = new VideoInfo(String(vid.url),uint(vid.length),uint(vid.order));
					vArr.push(vInfo);
					tt+=int(vid.length);
				}
				return {video:vArr,duration:tt};
			}else if(mode=="tudou"){
				var q:int = 0;
				var v:String = "";
				var xl2:XMLList = xmlObj.a.f;
				for each(var video:XML in xl2){
					if(int(video.attribute("brt"))>q && int(video.attribute("brt"))<=4){
						q = int(video.attribute("brt"));//find highest quality
						v = video.toString();
					}
				}
				var tdInfo:VideoInfo = new VideoInfo(v,uint(xmlObj.attribute("time")),0);
				return {video:[tdInfo],duration:uint(xmlObj.attribute("time"))};
			}else{
				return {};
			}
		}
		private function onError():void{
			trace('An error occurred');
		}
	}
}