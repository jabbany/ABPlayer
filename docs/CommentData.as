package org.kanoha.comment
{
	public class CommentData
	{
		private var _$txt:String;
		public var mode:uint;
		public var time:int;
		public var color:uint;
		private var _$fontSize:uint;
		private var _$date:String;
		private var _$border:Boolean;
		public function CommentData(mode:uint,time:int,color:uint,fsize:uint,txt:String,date:String = null,border:Boolean=false)
		{
			this.mode = mode;
			this.time = time;
			this.color = color;
			this._$fontSize = fsize;
			this._$txt = txt;
			this._$date = date;
			this._$border = border;
		}
		public function set fontSize(fs:uint):void{
			this._$fontSize = fs;
		}
		public function get fontSize():uint{
			return this._$fontSize;
		}
		public function set text(txt:String):void{
			this._$txt = txt;
		}
		public function get text():String{
			return this._$txt;
		}
		public function get date():String{
			return this._$date;
		}
		public function get border():Boolean{
			return this._$border;
		}
		public function get borderColor():uint{
			return 6750207;
		}
		public function get alpha():int{
			return 1;
		}
		public function clone():CommentData{
			return new CommentData(this.mode,this.time,this.color,this.fontSize,this.text,this.date,this.border);
		}
	}
}