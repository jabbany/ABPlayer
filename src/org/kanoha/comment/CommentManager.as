package org.kanoha.comment
{
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	import mx.events.ResizeEvent;
	
	import org.kanoha.comment.effects.TimelineEffect;
	
	import spark.effects.Fade;
	import spark.effects.Move;
	import spark.effects.easing.*;
	import spark.effects.easing.Linear;

	/**
	* CommentManager 弹幕时间轴管理器
	* 负责管理弹幕的播放与暂停
	* 实现参考 @aristotle9 org.lala.comments.CommentManager
	* Mod .C
	* Version 2 - "Sparked"
	**/
	public class CommentManager
	{
		protected var timeline:Array = new Array();
		protected var position:int = 0;
		protected var lastPos:Number = 0;
		protected var _$container:UIComponent;
		protected var _$list:Array = new Array();
		protected var _$handleAdv:Boolean = false;
		protected var _$cpuF:Boolean = false;
		protected var _$filter:CommentFilter;
		protected var salloc_top:CommentSpaceAllocator;
		protected var salloc_scroll:CommentSpaceAllocator;
		protected var salloc_bottom:CommentSpaceAllocator;
		protected var cmSettings:CommentConfig;
		protected var prepare_stack:Array = new Array();
		protected var isPlaying:Boolean = false;
		public function CommentManager(parent:UIComponent,cs:CommentConfig,commentFilter:CommentFilter,handleAdvCmnt:Boolean = false)
		{
			this._$container = parent;
			this._$handleAdv = handleAdvCmnt;
			this._$filter = commentFilter;
			this.cmSettings = cs;
			this.init();
		}
		private function init():void{
			this.salloc_top = new CommentSpaceAllocator();
			this.salloc_scroll = new ScrollCommentSpaceAllocator();
			this.salloc_bottom = new BottomCommentSpaceAllocator();
			//var self:CommentManager = CommentManager(this);
			this._$container.addEventListener(ResizeEvent.RESIZE,function():void{
				salloc_top.setBounds(_$container.width,_$container.height);
				salloc_scroll.setBounds(_$container.width,_$container.height);
				salloc_bottom.setBounds(_$container.width,_$container.height);
			});
			this.salloc_top.setBounds(_$container.width,_$container.height);
			this.salloc_scroll.setBounds(_$container.width,_$container.height);
			this.salloc_bottom.setBounds(_$container.width,_$container.height);
			this.isPlaying = true;
		}
		public function set provider(data:Array):void{
			this._$list = data;
			this._$list.sortOn("timestamp",2|16);
			this._$list.sortOn("stime",16);
			this.timeline = this._$list;
		}
		public function set cpufriendly(b:Boolean):void{
			this._$cpuF = b;
		}
		public function reset():void{
			this.timeline = new Array();
			this.position = 0;
			this.lastPos = 0;
		}
		public function clear():void{
			//clears current running
			while(prepare_stack.length!=0){
				for(var i:int=0;i<prepare_stack.length;i++){
					if(prepare_stack[i]!=null && Comment(prepare_stack[i]).effect!=null){
						//call each comment and end its life
						Comment(prepare_stack[i]).effect.end();
						if(Comment(prepare_stack[i])!=null){
							//huh?
							Comment(prepare_stack[i]).endEffectsStarted();
						}
					}else{
						trace('Not processed: ' + Comment(prepare_stack[i]).text);
					}
				}
			}
			//this.clearContainer();
		}
		public function clearContainer():void{
			while(this._$container.numChildren>0){
				this._$container.removeChildAt(0);
			}
		}
		public function pause():void{
			this.isPlaying=false;
			for(var i:int = 0;i<_$container.numChildren;i++){
				var c:Comment = Comment(_$container.getChildAt(i));
				if(c!=null && c.effect!=null){
					c.effect.pause();
				}
			}
		}
		public function resume():void{
			for(var i:int = 0;i<_$container.numChildren;i++){
				var c:Comment = Comment(_$container.getChildAt(i));
				if(c!=null && c.effect!=null){
					c.effect.resume();
				}
			}
			this.isPlaying=true;
		}
		public function insert(commentData:Object):void{
			var obj:Object = {on:false};
			for (var key:String in commentData){
				obj[key] = commentData[key];
			}
			if(obj.border){
				this.start(obj);//only run if it is playing
			}
			if(obj.preview){
				return;//Don't really add for future plays
			}
			var p:int = binsert(this.timeline,obj,function(a:*,b:*):int{
				if(a.time < b.time)
					return -1;
				else
				{
					if(a.time > b.time){
						return 1;
					}else{
						if(a.date < b.date){
							return -1;
						}else if(a.date > b.date){
							return 1;
						}else{
							return 0;
						}
						
					}
				}
			});
			if(p <= this.position){
				this.position++;//inserted before so bump position up
			}
		}
		protected function start(data:Object):void{
			if(data.mode >= 6 && !this._$handleAdv){
				return;//Skip this
			}
			if(this._$cpuF && prepare_stack.length > 20){
				return;//skip it
			}
			data['on'] = false;
			//data['border']=true;
			var cmt:Comment = new Comment(data);
			cmt.defaults = this.cmSettings;
			//new comment
			var self:CommentManager = CommentManager(this);
			_$container.addChild(cmt);//add to container
			cmt.init();
			this.allocSpace(cmt);
			if(!this._$handleAdv){
				if(data.mode<4){
					var eff:Move = new Move(cmt);
					eff.easer = new Linear(0,0);
					eff.duration = 4000;
					eff.xFrom = _$container.width;
					eff.xTo = 0 - cmt.width;
					cmt.effect = eff;
					cmt.effect.play();
				}else if(data.mode==4 || data.mode==5){
					var eff2:Fade = new Fade(cmt);
					eff2.alphaTo = 1;
					eff2.alphaFrom = 1;
					eff2.duration = 4000;
					cmt.effect=eff2;
					cmt.effect.play();
				}else{
					trace('unknown mode!');
				}
			}else{
				if(data.mode==7 && this._$handleAdv){
					if(data.movable == false){
						var advFade:Fade = new Fade(cmt);
						advFade.alphaTo = data.outAlpha;
						advFade.alphaFrom = data.inAlpha;
						advFade.duration = data.duration * 1000;
						cmt.effect = advFade;
						cmt.effect.play();
					}else{
						trace("New Movable type Effect: " + data.toX + " " + data.toY + " DUR:" + data.moveDuration + " Delay:" + data.moveDelay);
						var advEvt:TimelineEffect = new TimelineEffect();
						var advFade2:Fade = new Fade(cmt);
						advFade2.alphaTo = data.outAlpha;
						advFade2.alphaFrom = data.inAlpha;
						advFade2.duration = data.duration * 1000;
						var advMove:Move = new Move(cmt);
						advMove.xTo = data.toX;
						advMove.yTo = data.toY;
						advMove.startDelay = data.moveDelay;
						advMove.duration = data.moveDuration;
						advEvt.addEffect(advFade2);
						advEvt.addEffect(advMove);
						cmt.effect = advEvt;
						cmt.effect.play();
					}
				}else if(data.mode==6 && this._$handleAdv){
					var effc:Move = new Move(cmt);
					effc.easer = new Linear(0,0);
					effc.duration = 4000;
					effc.xFrom = 0 - cmt.width;
					effc.xTo = _$container.width;
					cmt.effect = effc;
					cmt.effect.play();
				}
			}
			if(cmt.effect!=null){
				cmt.effect.addEventListener(EffectEvent.EFFECT_END,function ():void{
					self.complete(cmt);
					self.deallocSpace(cmt);
					self._$container.removeChild(cmt);
					cmt = null;
				});
			}else{
				this.complete(cmt);
				this.deallocSpace(cmt);
				this._$container.removeChild(cmt);
				cmt = null;//Free up space for comment
				return;//unhandled comments need not be pushed into run stack!
				//unhandled comment!;
			}
			this.prepare_stack.push(cmt);
		}
		protected function allocSpace(cm:Comment):void{
			if(cm.dataObject.mode<4){
				this.salloc_scroll.add(cm);
			}else if(cm.dataObject.mode==5){
				this.salloc_top.add(cm);
			}else if(cm.dataObject.mode==4){
				this.salloc_bottom.add(cm);
			}
		}
		protected function deallocSpace(cm:Comment):void{
			if(cm.dataObject.mode<4){
				this.salloc_scroll.remove(cm);
			}else if(cm.dataObject.mode==5){
				this.salloc_top.remove(cm);
			}else if(cm.dataObject.mode==4){
				this.salloc_bottom.remove(cm);
			}
		}
		protected function getComment(data:Object):Comment{
			return new Comment(data);
		}
		protected function complete(cmt:Comment):void{
			var i:int = this.prepare_stack.indexOf(cmt);
			this.prepare_stack.splice(i,1);//remove from current running
		}
		public function time(t:Number):void{
			if(!this.isPlaying){
				return;//not playing
			}
			t = t - 1;
			if(this.position >= this.timeline.length || Math.abs(this.lastPos - t) >= 2000){
				this.seek(t);
				this.clear();
				this.lastPos = t;
				if(this.timeline.length <= this.position){
					return;
				}
			}else{
				this.lastPos = t;
			}
			for(;this.position < this.timeline.length;this.position++){
				if(this.getData(this.position)['stime'] <= t){
					if(this.validate(this.getData(this.position))){
						this.start(this.getData(this.position));
					}
				}else{
					break;
				}
			}
		}
		protected function getData(id:int):Object{
			//safety wrapper
			if(id>=0 && id < this.timeline.length){
				return this.timeline[id];
			}
			return null;//npe
		}
		protected function seek(time:Number):void{
			this.position = bsearch(this._$list,time,function(pos:*,data:*):int{
				if(pos < data.stime){
					return -1;
				}else if(pos > data.stime){
					return 1;
				}else{
					return 0;
				}
			});
		}
		protected function validate(data:Object):Boolean{
			if(data['on']){
				return false;//dont send again
			}
			return _$filter.validate(data);//no filter caps yet!
			return true;
		}
		/**
		 * BSearch
		 **/
		public static function bsearch(arr:Array,a:*,f:Function):int{
			if(arr.length==0)
				return 0;//Nothing to search
			if(f(a,arr[0])<0)
				return 0;//Smaller than smallest
			if(f(a, arr[arr.length-1])>=0)
				return arr.length;//Bigger than biggest
			var low:int = 0;
			var i:int;
			var count:int = 0;
			var high:int = arr.length - 1;
			while(low<=high){
				i = Math.floor((high + low + 1)/2);//find middle
				count++;
				if(f(a,arr[i-1])>=0 && f(a,arr[i])<0){
					return i;
				}else if(f(a, arr[i-1]) < 0){
					high = i-1;
				}else if(f(a, arr[i]) >=0){
					low = i;
				}else{
					throw new Error("BSearch Unexpected Error");
				}
				if(count > 1500){
					throw new Error("BSearch Execute Limit Exceed");
					break;
				}
			}
			return -1;//Wha?
		}
		public static function binsert(arr:Array,elem:*,f:Function):Number{
			var i:int = bsearch(arr,elem,f);
			arr.splice(i,0,elem);
			return i;
		}
	}
}