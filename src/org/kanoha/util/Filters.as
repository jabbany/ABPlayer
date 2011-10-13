package org.kanoha.util
{
	import flash.filters.GlowFilter;
	public class Filters
	{
		private static var fs:Array = [new GlowFilter(0,1,6,6,5)];
		private static var fs2:Array = [new GlowFilter(0, 0.7, 3,3)];
		public function Filters()
		{
			
		}
		public static function getGlow():Array{
			return fs;
		}
		public static function getAdvancedGlow():Array{
			return fs2;
		}
	}
}