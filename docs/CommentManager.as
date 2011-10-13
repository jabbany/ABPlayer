package org.kanoha.comment
{
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.effects.Move;
	import mx.effects.easing.*;
	import mx.events.EffectEvent;
	
	import org.kanoha.collections.*;
	public class CommentManager
	{
		private var _$scrollDuration:int;//duration (no support for velocity!)
		private var _$nowScroll:SortedLinkedList;//scrolling
		private var _$nowTop:SortedLinkedList;//top
		private var _$nowBottom:SortedLinkedList;//bottom
		private var _$CEList:LinkedList;//a list of comments/effects pairs
		private var _$commentList:CommentDataList;//place to store comments
		private var _$cPool:CommentPool;//pool for recollection of comments
		private var _$paused:Boolean;//is playback paused?
		private var _$container:UIComponent;//container layer for comments
		private var _$alpha:Number = 1;//default alpha for comments
		private var ct:uint=0;//current time
		public function CommentManager(parent:UIComponent,dur:int,alpha:int)
		{
			this._$container = parent;
			this._$alpha = alpha;
			this._$scrollDuration = dur;
		}
		public function init(cDataArr:Array):void{
			this.clearAll();
			this._$commentList = new CommentDataList(cDataArr);
			this._$paused = false; 
			this._$cPool = new CommentPool(30);
		}
		public function clearAll():void{
			if(_$CEList){
				_$CEList.visit(clear);
			}
			_$nowScroll = new SortedLinkedList(PositionAllocator.allocateByTop);
			_$nowTop = new SortedLinkedList(PositionAllocator.allocateByTop);
			_$nowBottom = new SortedLinkedList(PositionAllocator.allocateByBottom);
			_$CEList = new LinkedList();
		}
		private function clear(pair:CEPair):void{
			pair.comment.setVisible(false);
		}
		public function displayComments(time:uint):void{
			if(time == ct)
				return;
			ct = time;
			var tmp:Array = _$commentList.loadTime(time);
			for(var t:int=0;t<tmp.length;t++){
				if(tmp[t]!=null){
					this.display(tmp[t]);
				}
			}
		}
		/**** PAUSE AND RESUME HANDLERS ****/
		public function pause():void{
			_$CEList.visit(pauseEffects);
			this._$paused = true;
		}
		public function resume():void{
			_$CEList.visit(resumeEffects);
			this._$paused = false;
		}
		private function pauseEffects(cep:CEPair):void{
			cep.effect.pause();
		}
		private function resumeEffects(cep:CEPair):void{
			cep.effect.resume();
		}
		public function resetTime(time:uint):void{
			if(_$commentList){
				this.clearAll();
				this._$commentList.resetIndex(time);
				//Process Committed List
			}
		}
		public function get parent():UIComponent{
			return this._$container;
		}
		public function addComment(cd:CommentData):void{
			//Hold Here
		}
		private function display(cd:CommentData):void{
			if(cd.text.length > 200)
				return; //OOPS, too long!
			var cmt:Comment = this._$cPool.getInstance();
			cmt.setComment(cd);
			if(cd.mode<4){
				displayScroll(cmt);
			}else if(cd.mode==4){
				displayTop(cmt);
			}else if(cd.mode==5){
				displayBottom(cmt);
			}
		}
		private function displayScroll(cmt:Comment):void{
			var eff:Move = new Move(cmt);
			var tce:CEPair = new CEPair(cmt,eff);
			this._$CEList.push(tce);
			eff.easingFunction = Linear.easeNone;
			parent.addChild(cmt);
			//cmt.validateEX();
			this.setTrace(tce);
			eff.duration = this._$scrollDuration;
			var cpos:UsedPosition = new UsedPosition(eff.yFrom,eff.yFrom + cmt.textHeight,cmt.textWidth,ct,cmt.mode,eff.duration)
			_$nowScroll.pushReverse(cpos);
            cmt.setVisible(true);
            eff.addEventListener(EffectEvent.EFFECT_END,eventUp(release,tce));
            eff.play();
		}
		private function displayTop(cmt:Comment):void{
			var tfd:Fade = new Fade(cmt);
			tfd.duration = this._$scrollDuration;
			tfd.alphaFrom = 1;
			tfd.alphaTo = 1;
			var tce:CEPair = new CEPair(cmt,tfd);
			this._$CEList.push(tce);
			parent.addChild(cmt);
			//cmt.validateEX();
			this.setTPos(cmt);
			tfd.addEventListener(EffectEvent.EFFECT_END,eventUp(release,tce));
			tfd.play();
		}
		private function displayBottom(cmt:Comment):void{
			var tfd:Fade = new Fade(cmt);
			tfd.duration = this._$scrollDuration;
			tfd.alphaFrom = 1;
			tfd.alphaTo = 1;
			var tce:CEPair = new CEPair(cmt,tfd);
			this._$CEList.push(tce);
			parent.addChild(cmt);
			//cmt.validateEX();
			this.setBPos(cmt);
			tfd.addEventListener(EffectEvent.EFFECT_END,eventUp(release,tce));
			tfd.play();
		}
		private function setTrace(cp:CEPair):void
		{
			var y:Number = this.getY(_$nowScroll,cp.comment.textHeight);
			Move(cp.effect).xFrom = parent.width;
			Move(cp.effect).xTo = 0 - cp.comment.textWidth;
			Move(cp.effect).yFrom = y;
			Move(cp.effect).yTo = y;
		}
		private function setTPos(cmt:Comment):void
		{
		 	var y:Number = this.getY(_$nowTop,cmt.textHeight);
		 	var x:Number = this.getX(cmt.textWidth);
		 	cmt.x = x;
		 	cmt.y = y;
		 	var cpos:UsedPosition = new UsedPosition(y,y + cmt.textHeight,cmt.textWidth,ct,cmt.mode,this._$scrollDuration);
		 	_$nowTop.pushReverse(cpos);
		}
		private function setBPos(cmt:Comment):void
		{
			var y:Number = this.getRY(_$nowBottom,cmt.textHeight);
			var x:Number = this.getX(cmt.textWidth);
			cmt.x = x;
			cmt.y = y;
			var cpos:UsedPosition = new UsedPosition(y,y + cmt.textHeight,cmt.textWidth,ct,cmt.mode,this._$scrollDuration);
			_$nowBottom.pushReverse(cpos);
		}
		private function eventUp(f:Function,ce:CEPair):Function{
			return function(e:EffectEvent):void{f.call(this,ce);}
		}
		private function release(ce:CEPair):void{
			trace('released comment ' + ce.comment.text); 
			if(ce.comment.parent == this._$container){
				this._$container.removeChild(ce.comment);
			}
			ce.comment.setVisible(false);
			_$CEList.remove(ce);
			ce.effect.stop();
			this._$cPool.dumpComment(ce.comment);//recycle the comment onj
		}
		private function getY(positions:SortedLinkedList,height:int):Number{
			if(height > _$container.height){
				return this._$container.height - height;
			}
			positions.filter(this.isUsedPosValid,this);
			positions.reset();
			var rs:Number = 10;
			if(positions.size ==0){
				return rs;
			}
			if(positions.peek().top - 10 >= height){
				return rs;
			}
			if(positions.size==1){
				var tup:UsedPosition = positions.peek();
				if(tup.top<_$container.height/2){
					if(tup.bottom + height > _$container.height){
						return this._$container.height - height;
					}
					return tup.bottom;
				}else{
					if(tup.top - height < 0){
						return 0;
					}
					return tup.top - height;
				}
			}
			//now for heavy work
			for(var j:int=0;j<positions.size;j++){
				var current:UsedPosition = positions.forward();
				var next:UsedPosition = positions.current();
				if(next.top - current.bottom >= height){
					rs = current.bottom;
					break;
				}
				if(j==positions.size-2){
					if(_$container.height - next.bottom >= height){
						rs = next.bottom;
					}
					else{
						var rtop:Number = Math.random() * (_$container.height - height);
						rs = rtop;
					}
				}
			}
			return rs;
		}
		private function getRY(poses:SortedLinkedList,height:int):Number{
			if(height > _$container.height)
				return _$container.height - height;
			poses.filter(this.isUsedPosValid,this);
			poses.reset();
			var bottom:Number = _$container.height - 10;
			if(poses.size == 0)
				return bottom - height;
			if( bottom - poses.peek().bottom >= height)
			{
				return bottom - height; 
			}
			if(poses.size == 1)
			{
				var tup:UsedPosition = poses.peek();
				if(tup.bottom > _$container.height/2)
				{
					if(tup.top - height <0)
						return 0	
					return tup.top - height;
				} 
				else
				{
					if(tup.bottom + height > _$container.height)	
						return _$container.height - height;
					return tup.bottom;
				}
			}
			for(var j:int = 0;j < poses.size-1;j++)
			{  
				var current:UsedPosition =  poses.forward();
				var next:UsedPosition = poses.peek();
				if(current.top - next.bottom >= height)
				{
					bottom = current.top;
					break;
				}
				if(j == poses.size-2)
				{
					if(next.top - height >= 0)
					{
						bottom = next.top;
					} 
					else
					{
						var top:Number = Math.random() * (_$container.height - height);
						return top;
					}
				} 
			} 
			return bottom - height;
		}
		private function getX(width:Number):Number{
			return _$container.width - width >= 0 ? (_$container.width - width)/2 : 0;
		}
		private function isUsedPosValid(uP:UsedPosition):Boolean{
			var dr:uint = Math.ceil(uP.duration); 
			var pw:Number = this._$container.width / dr;
			var fd:uint = dr;
			if(this._$alpha<0.2){
				fd--;
			}
			if(uP.type > 3){
				//NOT SCROLLING
				if(uP.joinTime + fd > ct){
					if(uP.width>0)
						return true;
				}
			}else{
				for(var i:int = 0;i<dr;i++){
					if(ct == uP.joinTime + i){
						if(uP.width > pw * i){
							return true;
						}
					}
				}
			}
			return false;
		}
	}
}