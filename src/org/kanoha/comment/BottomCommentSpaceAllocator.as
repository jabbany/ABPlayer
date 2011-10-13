package org.kanoha.comment
{
	public class BottomCommentSpaceAllocator extends CommentSpaceAllocator
	{
		public function BottomCommentSpaceAllocator()
		{
		}
		override protected function transformY(y:int,cmt:Comment):int
        {
            return this.Height - y - cmt.height;
        }
		override protected function vCheck(y:int, cmt:Comment, index:int):Boolean
        {
            var bottom:int = y + cmt.height;
            for each(var c:Comment in this.pools[index])
            {
                var _y:int = transformY(c.y,c);
                if(_y > bottom || c.bottom < y)
                {
                    continue;
                }
                else 
                {
                    return false;
                }
            }
            return true;
        }
	}
}