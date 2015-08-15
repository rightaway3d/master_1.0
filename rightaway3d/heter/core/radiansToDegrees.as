package rightaway3d.heter.core 
{
	/**
	 弧度转换为角度
	 @param radians: 弧度.
	 @return 角度.
	 */
	public function radiansToDegrees(radians:Number):Number
	{
		return radians * (180 / Math.PI);
	}
}