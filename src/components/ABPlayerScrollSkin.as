package components
{
	import mx.skins.halo.SliderTrackSkin;
	public class ABPlayerScrollSkin extends SliderTrackSkin
	{
		public function ABPlayerScrollSkin()
		{
			super();
			this.visible=false;
		}
		override public function get measuredHeight():Number{
			return 2;
		}
	}
}