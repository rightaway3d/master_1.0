package rightaway3d.heter.core
{
	/**
	   角度转换为弧度.
	   @param degrees: 角度.
	   @return 弧度.
	 */
	public function degreesToRadians(degrees:Number):Number
	{
		return degrees * (Math.PI / 180);
	}
}