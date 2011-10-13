package org.kanoha.comment
{
	public class PositionAllocator
	{
		public function PositionAllocator()
		{
		}
		public static function allocateByTop(src:UsedPosition,des:UsedPosition):int{
			if(src.top > des.top)
				return 1;
			else if(src.top == des.top)
				return 0;
			else
				return -1;
		}
		public static function allocateByBottom(src:UsedPosition,des:UsedPosition):int{
			if(src.bottom > des.bottom)
				return -1;
			else if(src.bottom == des.bottom)
				return 0;
			else
				return 1;
		}
	}
}