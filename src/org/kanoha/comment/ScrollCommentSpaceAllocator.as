package org.kanoha.comment
{
	public class ScrollCommentSpaceAllocator extends CommentSpaceAllocator
	{
		private var dur:int = 4;
		public function ScrollCommentSpaceAllocator()
		{
		}
		override public function add(cmt:Comment):void
        {
            cmt.x = this.Width;
            cmt.duration = (this.Width + cmt.width) / this.getSpeed(cmt);
            if(cmt.height >= this.Height)
            {
                cmt.setY(0,-1,transformY);
            }
            else 
            {
                this.setY(cmt);
            }
        }
        override protected function vCheck(y:int, cmt:Comment, index:int):Boolean 
        {
            var bottom:int = y + cmt.height;
            var right:int = cmt.x + cmt.width;
            for each(var c:Comment in this.pools[index])
            {
                if(c.y > bottom || c.bottom < y)
                {
                    continue;
                }
                else if(c.right < cmt.x || c.x > right) 
                {
                    if(this.getEnd(c) <= this.getMiddle(cmt))
                    {
                        continue;
                    }
                    else 
                    {
                        return false;
                    }
                }
                else 
                {
                    return false;
                }
            }
            return true;
        }
        private function getSpeed(cmt:Comment):Number
        {
            return 1 * 0.5 * (this.Width + cmt.width) / this.dur;
        }
        private function getEnd(cmt:Comment):Number
        {
            return cmt.stime + (this.Width + cmt.width) / this.getSpeed(cmt);
        }
        private function getMiddle(cmt:Comment):Number
        {
            return cmt.stime + this.Width / this.getSpeed(cmt);
        }
	}
}