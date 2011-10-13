package org.kanoha.video
{
	public class VideoInfo
	{
		private var _$url:String
		private var _$length:uint
		private var _$id:uint
		public function VideoInfo(url:String,length:uint,id:uint = 0)
		{
			_$url = url;
			_$length = length;
			_$id = id;
		}
		public function get url():String
		{
			return _$url
		}
		public function get length():uint
		{
			return _$length
		}
	    public function get id():uint
		{
			return _$id
		}
	}
}