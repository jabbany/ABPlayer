package org.kanoha.events
{
	import flash.events.Event;
	public class LoaderEvent extends Event
	{
		private var _$info:*;
        private var _$type:String;
		public static const XML_COMPLETE:String = "xmlComplete";// load xml
		public static const XML_PARSE_ERROR:String = "xmlParseError";//parse xml error
		public static const XML_LOAD_ERROR:String = "xmlLoadError";//load xml error
		public static const VIDEO_COMPLETE:String = "videoComplete";//load video
		public static const VIDEO_ERROR:String = "videoError";//load video
		public static const COMMENT_COMPLETE:String = "commentComplete";//load comment
		public static const NO_COMMENT:String = "noComment";//comment error
		public static const COMMENT_ERROR:String = "commentError";//comment error
		public static const REGEX_COMPLETE:String = "regexComplete";//search by regex and url
		public static const REGEX_SEARCH_ERROR:String = "regexSearchError";//io error or not found
		public static const MULTI_VIDEO_COMPLETE:String = "multiVideoComplete";//load multi part video 
        public static const MULTI_VIDEO_ERROR:String = "multiVideoError";//load multi part comment error
        public static const MULTI_COMMENT_COMPLETE:String = "multiCommentComplete";//load multi part comment
        public static const MULTI_COMMENT_ERROR:String = "multiCommentError";//load multi part comment error
        public static const MULTI_PART_COMPLETE:String = "multiPartComplete";//load multi part
        public static const MULTI_PART_ERROR:String = "multiPartError";//load multi part
        public static const LOACL_LOAD_COMPLETE:String = "loaclLoadComplete";//load local file
        public static const DOWN_ERROR:String = "downError";
        public static const DOWN_COMPLETE:String = "downComplete";//download complete
        public static const CONFIG_COMPLETE:String="configComplete";
        public static const CONFIG_ERROR:String="configError";
		public function LoaderEvent(param1:String, param2:* = 0)
		{
			super(param1);
            _$type = param1;
            _$info = param2;
            return;
		}
		override public function clone():Event
		{
		    return new LoaderEvent(_$type, _$info);
		}
		public function get info():*{
			return this._$info;
		}
	}
}