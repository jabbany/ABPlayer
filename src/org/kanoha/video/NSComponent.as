/*******************
 * Based on Tamaki Video Component
 * Modified by CQZ
 * 2011-9-3 Initial
********************/
package org.kanoha.video
{
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.media.Video;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import org.kanoha.events.*;
	public class NSComponent extends UIComponent
	{
		private var nss:Array; //netstreams
		private var ifs:Array; //videoinfo
		private var ofs:Array; //offset:uint
		private var bi:int; //buffer index
		private var pi:int;//play index
		private var _$volume:Number;
		private var _$video:Video;
		private var _$total:uint;
		private var _$state:String = NSComponent.UNLOAD;
		private var _$smoothing:Boolean;
		private var _$metaReader:NS;
		private var _$url:String;
		private var _$allowScreencap:Boolean = true;
		public static const UNLOAD:String = "unLoad";
		public static const PLAY:String = "play";
		public static const STOP:String = "stop";
	    public static const PAUSE:String = "pause";
	    public var p_x:int = 0;
	    public var p_y:int = 0;
	    public var nsBuf:Boolean=false;
		public function NSComponent() 
		{
			super(); 
	 	    this._$video = new Video();
		    this.addChild(this._$video);
		    this._$video.height = this.height;
		    this._$video.width = this.width;
		    this.addEventListener(ResizeEvent.RESIZE,resize);
		    this.addEventListener(NMEvent.COMPLETE,onComplete);
		}
		public function resize(eve:Event):void
		{
			if(this._$video==null)
				return;//dont resize if video not inited
			if(this.p_x<=0 || this.p_y<=0){
				this._$video.width = this.width;
				this._$video.height = this.height;
			}else{
				if((this.width / this.height) >= (this.p_x / this.p_y)){
					this._$video.height = this.height;
					this._$video.width = (this.height * this.p_x )/this.p_y;
				}else{
					this._$video.width = this.width;
					this._$video.height = (this.width * this.p_y)/ this.p_x;
				}
				//Position Center
				this._$video.x = (this.width - this._$video.width)/2;
				this._$video.y = (this.height - this._$video.height)/2; 
			}
		}
		public function init(ifv:Array,tv:uint):void
		{   
		    this.close();
		    this.resetAll(); 
		    this.ifs = ifv;
		    this._$total = tv;
		    initOffset();
			createBuffer();
		}
		public function initBySingleUrl(url:String):void
		{
			this.close();
			this.resetAll();
			this._$url = url;
			this._$metaReader = new NS();
			this._$metaReader.addEventListener(NSEvent.META_DATA,onMetaData);
			this._$metaReader.loadV(url);
			this.addEventListener(NMEvent.META_LOADED,onMetaLoaded);
		}
		private function onMetaLoaded(eve:NMEvent):void
		{
			initOffset();
			trace('loaded meta!');
			createBuffer();
			this.dispatchEvent(new NMEvent(NMEvent.URL_COMPLETE));
		}
		private function initOffset():void
		{
			var co:uint = 0;
			for(var i:uint = 0;i < ifs.length;i++)
			{
				ofs[i] = co += VideoInfo(ifs[i]).length;
			}
		}
		private function createBuffer():void
		{   
			if(ifs[++bi])
			{
				var ns:NS = new NS();
				var info:VideoInfo = VideoInfo(ifs[bi]);
				if(this._$allowScreencap){
					ns.checkPolicyFile = true;
				}
				ns.id = info.id;
			    ns.loadV(info.url);
			    ns.addEventListener(NSEvent.META_DATA,onSingleMetaData);
	            ns.addEventListener(NSEvent.STOP, onStop);
	            ns.addEventListener(NSEvent.CHECK_FULL, onFull);
	            ns.addEventListener(NSEvent.BUFFERING,onBuff);
	            ns.addEventListener(NSEvent.PLAYING,onPlaying);
	            ns.addEventListener(NSEvent.FILE_EMPTY,onNotFound);
	            ns.volume = this._$volume;
	            nss.push(ns);
            }
		}
		private function changeNS():void
		{  
			if(pi >= 0)
			{
				if(!nss[pi])
					return;
				NS(nss[pi]).stopV();
			} 
			if(nss[pi+1])
			{
				NS(nss[++pi]).playV();
				NS(nss[pi]).stopV();
				NS(nss[pi]).playV();
				this.attachVideo(_$video);
			}
		}
		private function onFull(eve:NSEvent):void
		{
			if(this.state != NSComponent.UNLOAD)
			{
				if(nss[bi]!=null){
					NS(nss[bi]).removeEventListener(NSEvent.BUFFERING,onBuff);
					NS(nss[bi]).removeEventListener(NSEvent.CHECK_FULL,onFull);
				}
				createBuffer();
			}
		}
		private function onStop(eve:NSEvent):void
		{
			if(pi != ifs.length-1)
				changeNS();
			else
			{
				this.dispatchEvent(new NMEvent(NMEvent.COMPLETE));
			}
		}
		private function onBuff(eve:NSEvent):void
		{
			var current:Number;
			var next:Number
			if(bi == 0)
			{
				next = ofs[bi]/_$total;
				current = Number(eve.info) * next;
				this.dispatchEvent(new NMEvent(NMEvent.PROGRESS,current));
			}
			else
			{
				var pre:Number = ofs[bi-1]/_$total;
				next = ofs[bi]/_$total;
				current = pre + Number(eve.info) * (next - pre);
				this.dispatchEvent(new NMEvent(NMEvent.PROGRESS,current));
			}
		}
		private function onPlaying(eve:NSEvent):void
		{
			if(pi == 0)
				this.dispatchEvent(new NMEvent(NMEvent.PLAY_HEAD_UPDATE,uint(eve.info)));
			else
			{
				this.dispatchEvent(new NMEvent(NMEvent.PLAY_HEAD_UPDATE,uint(ofs[pi-1]+uint(eve.info))));
			}
		}
        private function onNotFound(eve:NSEvent):void
		{
			this.dispatchEvent(new NMEvent(NMEvent.VIDEO_NOT_FOUND))
		}
		private function getPIByTime(time:uint):uint
		{
			var i:uint = 0;
			var pre:uint = 0;
			for(;i<nss.length;)
			{
				if(time > pre && time <=  ofs[i])
					break;
				pre = ofs[i++];
			}
			return i;
		}
		private function seekInPart(time:uint,si:uint):void
		{
			var ptime:uint;
			if (si == 0)
				ptime = time;
			else
				ptime = time - ofs[si-1];
			NS(nss[pi]).seekV(ptime);
			this.play();
		}
		private function attachVideo(v:Video):void
		{   
			//v.clear();
			v.attachNetStream(NS(nss[pi]).ns);
		}
		private function onSingleMetaData(eve:NSEvent):void{
			if(!nsBuf){
				nsBuf = true;
			}else{
				return;
			}
			if(eve.info.width!=null && eve.info.height!=null){
				this.p_x = eve.info.width;
				this.p_y = eve.info.height;
				this.resize(null);
			}
			if(nss != null && nss[bi]!=null )
				NS(this.nss[bi]).removeEventListener(NMEvent.META_LOADED,onSingleMetaData);
			this.dispatchEvent(new NMEvent(NMEvent.META_LOADED,eve.info));
		}
		private function onMetaData(eve:NSEvent):void
		{
			if(eve.info.width!=null && eve.info.height!=null){
				this.p_x = eve.info.width;
				this.p_y = eve.info.height;
				this.resize(null);
			}
			this._$total = eve.info.duration  * 1000;
			this.ifs = new Array;
			this.ifs.push(new VideoInfo(this._$url,eve.info.duration *1000));
			this._$metaReader.removeEventListener(NSEvent.META_DATA,onMetaData);
			this._$metaReader.closeV();
			this._$metaReader = null;
			this.dispatchEvent(new NMEvent(NMEvent.META_LOADED,eve.info));
		}
		private function resetAll():void
		{
			if(nss&&nss[bi])
			{
				NS(nss[bi]).removeEventListener(NSEvent.BUFFERING,onBuff);
				NS(nss[bi]).removeEventListener(NSEvent.CHECK_FULL,onFull);
			}
			this.bi = -1;
			this.pi = -1;
			this._$volume = 0.7;
			this.nss = new Array();
			this.ofs = new Array();
			this._$state = NSComponent.UNLOAD;
		}
		private function onComplete(eve:NMEvent):void
		{
			this.stop();
            this.play();
			this.stop();
			this.dispatchEvent(new NMEvent(NMEvent.REFRESH));
		}
		/*** Handlers ***/
		public function seek(time:uint):Boolean
		{
			if(this._$state == NSComponent.STOP||this._$state == NSComponent.UNLOAD)
				return false;
			var si:uint = this.getPIByTime(time);
			if(si >= nss.length)
				si = nss.length-1;
			if(si == pi)
			{
				this.seekInPart(time,si);
			}
			else
			{
				this.stop();
			    pi = si;
				this.attachVideo(this._$video);
                this.seekInPart(time,si);
			}
			return true;
		}
		public function play():Boolean
		{ 
			if(this._$state == NSComponent.PLAY)
					return false;
	 	 	if(pi == -1)
				changeNS();
		 	else
		    	NS(nss[pi]).playV(); 
			this.dispatchEvent(new NMEvent(NMEvent.STATE_CHANGE,"play"));
			this._$state = NSComponent.PLAY;
			return true;
		}
		public function pause():Boolean
		{
			if(this._$state != NSComponent.PLAY)
				return false;
			if(nss==null || nss[pi]==null){
				//not prepared
				return false;
			}
			NS(nss[pi]).pauseV();
			this.dispatchEvent(new NMEvent(NMEvent.STATE_CHANGE,"pause"));
			this._$state = NSComponent.PAUSE;
			return true;
		}
		public function stop():Boolean
		{
		 	if(this._$state == NSComponent.STOP||this._$state==NSComponent.UNLOAD)
				return false
			for(var i:uint = 0;i<nss.length;)
		  	{
	        	NS(nss[i++]).stopV();
	        }
			this.dispatchEvent(new NMEvent(NMEvent.STATE_CHANGE,"stop"));
			this._$state = NSComponent.STOP;
			this._$video.clear();
			pi = -1;
			return true;
		}
		public function close():Boolean
		{
			if(this._$state==NSComponent.UNLOAD)
				return false
			for(var i:uint = 0;i<nss.length;)
			{         
				NS(nss[i]).removeEventListener(NSEvent.PLAYING,onPlaying);
				NS(nss[i]).removeEventListener(NSEvent.STOP, onStop);
				NS(nss[i]).removeEventListener(NSEvent.FILE_EMPTY,onNotFound);
				NS(nss[i++]).closeV();
			}
			this._$video.clear();
			this.resetAll();
			this._$state = NSComponent.UNLOAD;
			return true;
		}
		public function set filterMode(mode:String):void{
			var matrix:Array = new Array();
			switch(mode){
				case 'blackwhite':{matrix=[0.3,0.6,0.1,0,0,0.3,0.6,0.1,0,0,0.3,0.6,0.1,0,0,0,0,0,1,0];}break;
				case 'contrastup':{matrix=[1.5,0,0,0,-40,0,1.5,0,0,-40,0,0,1.5,0,-40,0,0,0,1,0];}break;
				case 'redchannel':{matrix=[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];}break;
				case 'greenchannel':{matrix=[0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0];}break;
				case 'bluechannel':{matrix=[0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0];}break;
				case 'brighter':{matrix=[1,0,0,0,30,0,1,0,0,30,0,0,1,0,30,0,0,0,1,0];}break;
				case 'default':{matrix=[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];}break;
				default:return;//HAH?
			}
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var filters:Array = new Array();
			filters.push(filter);
			this._$video.filters = filters;
		}
		public function get video():Video
		{
			return _$video;
		}
		public function getState():String{
			return _$state;
		}
		public function get state():String
		{
			return _$state;
		}
		public function get smoothing():Boolean
		{
			return this._$smoothing;
		}
		public function set smoothing(smoothing:Boolean):void
		{
			this._$video.smoothing = smoothing;
			this._$smoothing = smoothing;
		}
		public function get volume():Number
		{
			return this._$volume;
		}
		public function set volume(vol:Number):void
		{
			for(var i:uint=0;i<nss.length;)
		  	{
	            NS(nss[i++]).volume = vol;
		  	}
		  	this._$volume = vol;
		}
		public function get total():uint
		{
			return this._$total;
		}
		public function set allowCapture(allow:Boolean):void{
			this._$allowScreencap = allow;
		}
		public function get allowCapture():Boolean{
			return this._$allowScreencap;
		}
		public function get time():uint
		{
			if(this.state == NSComponent.STOP||this.state == NSComponent.UNLOAD)
			  return 0;
			var t:uint =  NS(nss[pi]).time;
			for(var i:int = 0;i<pi;i++)
			{
			  t += ofs[i];
			}
			return t;
		}
	}
}
