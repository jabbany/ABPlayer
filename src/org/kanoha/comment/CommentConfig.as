package org.kanoha.comment
{
	public class CommentConfig
	{
		import flash.filters.GlowFilter;
		private var _$settings:Object = {
				bold:true,
				alpha:1,
				filter:[new GlowFilter(0, 0.7, 3,3)],
				whiteFilter:[new GlowFilter(0xffffff, 0.7, 3,3)],
				relsize:1,
				font:"宋体"
			};
		public function CommentConfig(init:Object = null)
		{
			if(init!=null)
				this._$settings = init;
		}
		public static function getDefaults():Object{
			var obj:Object = {
				bold:true,
				alpha:1,
				filter:[new GlowFilter(0, 0.7, 3,3)],
				whiteFilter:[new GlowFilter(0xffffff, 0.7, 3,3)],
				relsize:1,
				font:"宋体"
			};
			return obj;
		}
		public function get bold():Boolean{
			return this._$settings.bold;
		}
		public function get alpha():Number{
			return this._$settings.alpha;
		}
		public function get filter():Array{
			return this._$settings.filter;
		}
		public function get whiteFilter():Array{
			return this._$settings.whiteFilter;
		}
		public function get relsize():Number{
			return this._$settings.relsize;
		}
		public function get font():String{
			return this._$settings.font;
		}
		public function setStyle(styleKey:String,styleValue:*):void{
			this._$settings[styleKey] = styleValue;
		}
		public function setGlow(glowMode:String):void{
			if(glowMode=='none'){
				this._$settings['filter']=[];
				this._$settings['whiteFilter']=[];
			}else if(glowMode=='border'){
				this._$settings['filter']=[new GlowFilter(0, 0.7, 3,3)];
				this._$settings['whiteFilter']=[new GlowFilter(0xffffff, 0.7, 3,3)];
			}else if(glowMode=="highlight"){
				this._$settings['filter']=[new GlowFilter(0x34251e, 0.7, 6,6)];
				this._$settings['whiteFilter']=[new GlowFilter(0x34251e, 0.7, 6,6)];
			}
		}
	}
}