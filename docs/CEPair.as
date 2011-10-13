package org.kanoha.comment
{
	import mx.effects.Effect;
	
	public class CEPair
	{
		private var _$comment:Comment;
		private var _$effect:Effect;
		public function CEPair(c:Comment,e:Effect)
		{
			this._$comment = c;
			this._$effect = e;
		}
		public function get comment():Comment{
			return this._$comment;
		}
		public function get effect():Effect{
			return this._$effect;
		}
	}
}