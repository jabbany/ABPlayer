package org.kanoha.comment
{
	public class UsedPosition
	{
		private var _$top:int;
		private var _$bottom:int;
		private var _$width:int;
		private var _$joinTime:int;
		private var _$type:uint;
		private var _$duration:uint;
		
		public function UsedPosition(top:int,bottom:int,width:int,joinTime:int,type:uint,dr:uint)
		{
			this._$top = top;
			this._$bottom = bottom;
			this._$width = width;
			this._$joinTime = joinTime;
			this._$type = type;
			this._$duration = dr;
	    }
	    
	    public function get top():int
	    {
	    	return this._$top;
	    }
	    public function get bottom():int
	    {
	    	return this._$bottom;
	    }
	    public function get width():int
	    {
	    	return this._$width;
	    }
	    public function get joinTime():int
	    {
	    	return this._$joinTime;
	    }
	    public function get type():uint
	    {
	       return this._$type;
	    }
	    public function get duration():uint
	    {
	       return this._$duration;
	    }
	}
}