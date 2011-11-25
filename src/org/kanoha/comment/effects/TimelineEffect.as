package org.kanoha.comment.effects
{
	import mx.effects.Effect;
	import mx.effects.IEffectInstance;
	import mx.events.EffectEvent;
	
	import spark.effects.Animate;

	/***
	 * Timelined Effect
	 * @Package ABPlayer
	 * A Special Effect for offsetting multiple effects together
	 * **/
	public class TimelineEffect extends Animate
	{
		protected var _$eff:Array = new Array();
		protected var _$ran:int = 0;
		public function TimelineEffect()
		{
		}
		public function addEffect(eff:Animate):void{
			this._$eff.push(eff);
		}
		public function removeEffect(eff:Animate):void{
			var rid:int = this._$eff.indexOf(eff);
			this._$eff.splice(rid,1);
		}
		private function onEffectEnd(e:EffectEvent):void{
			this._$ran++;
			trace(_$ran);
			if(_$ran==_$eff.length){
				this.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END));
				trace("Multiple Effect Finished");
			}
		}
		override public function end(inst:IEffectInstance = null):void{
			//End all effects
			for(var i:int = 0;i<_$eff.length;i++){
				if(_$eff[i]!=null && Effect(_$eff[i]).isPlaying)
					_$eff[i].end();
			}
			//The end dispatch event will be automatically dispatched
		}
		override public function resume():void{
			for(var i:int = 0;i<_$eff.length;i++){
				if(_$eff[i]!=null && Effect(_$eff[i]).isPlaying)
					_$eff[i].resume();
			}
		}
		override public function pause():void{
			for(var i:int = 0;i<_$eff.length;i++){
				if(_$eff[i]!=null && Effect(_$eff[i]).isPlaying)
					_$eff[i].pause();
			}
		}
		override public function play(targets:Array=null,reverse:Boolean=false):Array{
			//Get count
			if(this._$eff.length ==0){
				this.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END));//Nothing to do
				return null;
			}
			for(var i:int=0;i<this._$eff.length;i++){
				this._$eff[i].addEventListener(EffectEvent.EFFECT_END,onEffectEnd);
				this._$eff[i].play();
			}
			return null;
		}
		override public function get duration():Number{
			var dur:Number = 0;
			for(var i:int = 0; i< this._$eff.length;i++){
				dur+=this._$eff[i].duration;
			}
			return dur;
		}
	}
}