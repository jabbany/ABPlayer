/**********************
 * Based on Tamaki Comment Object
 * Modified for ABPlayer
 * 2011-09-04 .C
 * ********************/
package org.kanoha.comment
{
	import mx.controls.Label;
	import org.kanoha.util.Filters;
	public class Comment extends Label
	{
		private var _$managed:Boolean;
		private var _$time:int;
		private var _$border:Boolean;
		private var _$mode:uint;
		private var _$borderColor:uint = 6750207;
		public function Comment(managed:Boolean = false)
		{
			super();
			this._$managed = managed;
			this.selectable = false;
			this.filters = Filters.getGlow();
			//this.setStyle("fontWeight","bold");
		}
		public function setComment(cData:CommentData):void{
			this.text = cData.text;
			this.setStyle("fontSize",cData.fontSize);
			this.setStyle("fontFamily","黑体");
			this.setStyle("color",cData.color);
			this._$time = cData.time;
			this._$mode = cData.mode;
			this._$border = cData.border;
			this._$borderColor = cData.borderColor;
			this.alpha = cData.alpha;
		}
		public function get managed():Boolean{
			return this._$managed;
		}
		public function validateEX():void{
			this.validateNow();
			this.height = this.textHeight*1.2;
			this.width = this.textWidth*1.2;
			if(this._$border)
				this.setBorder();
			else
				this.textField.border=false; 
		}
		public function setBorder():void{
			this.textField.border=true;
			this.textField.height = this.textField.height + 1;
			this.textField.width = this.textField.width + 3;
			this.textField.borderColor = this._$borderColor;
		}
		public function get time():int{
			return this._$time;
		}
		public function get mode():uint{
			return this._$mode;
		}
		public function get border():Boolean{
			return this._$border;
		}
		public function set borderColor(color:uint):void{
			this._$borderColor = color;
		}
	}
}