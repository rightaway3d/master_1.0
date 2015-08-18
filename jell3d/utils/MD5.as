/*

The contents of this file are subject to the Mozilla Public License Version
1.1 (the "License"); you may not use this file except in compliance with
the License. You may obtain a copy of the License at 

http://www.mozilla.org/MPL/ 

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
for the specific language governing rights and limitations under the License. 

The Original Code is CalistA Framework.

The Initial Developer of the Original Code is
ALCARAZ Marc (aka eKameleon)  <ekameleon@gmail.com>.
Portions created by the Initial Developer are Copyright (C) 2004-2010
the Initial Developer. All Rights Reserved.

Contributor(s) :

Alternatively, the contents of this file may be used under the terms of
either the GNU General Public License Version 2 or later (the "GPL"), or
the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
in which case the provisions of the GPL or the LGPL are applicable instead
of those above. If you wish to allow use of your version of this file only
under the terms of either the GPL or the LGPL, and not to allow others to
use your version of this file under the terms of the MPL, indicate your
decision by deleting the provisions above and replace them with the notice
and other provisions required by the LGPL or the GPL. If you do not delete
the provisions above, a recipient may use your version of this file under
the terms of any one of the MPL, the GPL or the LGPL.

*/

package jell3d.utils
{
	
	/**
	 * Encrypt a string with the MD5 algorithm.
	 * <pMD5 Message Digest Algorithm, as defined in RFC 1321.</p>
	 * <p><b>Example :</b></p>
	 * <pre class="prettyprint">
	 * import calista.hash.MD5 ;
	 * 
	 * var hash:String   = MD5.encrypt("calista") ;
	 * var equal:Boolean = hash == '93fc1e28bc17af6420552b746af10f4f' ;
	 * 
	 * trace("'calista' MD5 result : " + hash + " : " + equal ) ;
	 * 
	 * // 'calista' MD5 result : 93fc1e28bc17af6420552b746af10f4f : true
	 * </pre>
	 */
	public class MD5 
	{
		
		/**
		 * Encrypt the specified text with the MD5 algorithm.
		 * <p><b>Example :</b></p>
		 * <pre class="prettyprint">
		 * import calista.hash.MD5 ;
		 * 
		 * var hash:String   = MD5.encrypt("calista") ;
		 * var equal:Boolean = hash == '93fc1e28bc17af6420552b746af10f4f' ;
		 * 
		 * trace("'calista' MD5 result : " + hash + " : " + equal ) ;
		 * </pre>
		 */
		public static function encrypt( source:String ):String
		{
			return binl2hex( hash( str2binl(source) , source.length*8 ) ) ;
		}
		
		/**
		 * @private
		 */
		private static function bit_rol( num:int , cnt:int ):Number 
		{
			return (num << cnt) | (num >>> (32-cnt));
		}
		
		/**
		 * @private
		 */
		private static function cmn(q:int, a:int, b:int, x:int, s:int, t:int):Number 
		{
			return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b);
		}
		
		/**
		 * @private
		 */    
		private static function hash(x:Array, len:int):Array 
		{
			x[len >> 5] |= 0x80 << ((len)%32) ;
			x[(((len+64) >>> 9) << 4)+14] = len ;
			var olda:int ;
			var oldb:int ;
			var oldc:int ;
			var oldd:int ;
			var a:int = 1732584193  ;
			var b:int = -271733879  ;
			var c:int = -1732584194 ;
			var d:int = 271733878   ;
			for (var i:int = 0; i < x.length ; i += 16) 
			{
				olda = a ;
				oldb = b ;
				oldc = c ;
				oldd = d ;
				a = ff(a, b, c, d, x[i+0], 7, -680876936);
				d = ff(d, a, b, c, x[i+1], 12, -389564586);
				c = ff(c, d, a, b, x[i+2], 17, 606105819);
				b = ff(b, c, d, a, x[i+3], 22, -1044525330);
				a = ff(a, b, c, d, x[i+4], 7, -176418897);
				d = ff(d, a, b, c, x[i+5], 12, 1200080426);
				c = ff(c, d, a, b, x[i+6], 17, -1473231341);
				b = ff(b, c, d, a, x[i+7], 22, -45705983);
				a = ff(a, b, c, d, x[i+8], 7, 1770035416);
				d = ff(d, a, b, c, x[i+9], 12, -1958414417);
				c = ff(c, d, a, b, x[i+10], 17, -42063);
				b = ff(b, c, d, a, x[i+11], 22, -1990404162);
				a = ff(a, b, c, d, x[i+12], 7, 1804603682);
				d = ff(d, a, b, c, x[i+13], 12, -40341101);
				c = ff(c, d, a, b, x[i+14], 17, -1502002290);
				b = ff(b, c, d, a, x[i+15], 22, 1236535329);
				a = gg(a, b, c, d, x[i+1], 5, -165796510);
				d = gg(d, a, b, c, x[i+6], 9, -1069501632);
				c = gg(c, d, a, b, x[i+11], 14, 643717713);
				b = gg(b, c, d, a, x[i+0], 20, -373897302);
				a = gg(a, b, c, d, x[i+5], 5, -701558691);
				d = gg(d, a, b, c, x[i+10], 9, 38016083);
				c = gg(c, d, a, b, x[i+15], 14, -660478335);
				b = gg(b, c, d, a, x[i+4], 20, -405537848);
				a = gg(a, b, c, d, x[i+9], 5, 568446438);
				d = gg(d, a, b, c, x[i+14], 9, -1019803690);
				c = gg(c, d, a, b, x[i+3], 14, -187363961);
				b = gg(b, c, d, a, x[i+8], 20, 1163531501);
				a = gg(a, b, c, d, x[i+13], 5, -1444681467);
				d = gg(d, a, b, c, x[i+2], 9, -51403784);
				c = gg(c, d, a, b, x[i+7], 14, 1735328473);
				b = gg(b, c, d, a, x[i+12], 20, -1926607734);
				a = hh(a, b, c, d, x[i+5], 4, -378558);
				d = hh(d, a, b, c, x[i+8], 11, -2022574463);
				c = hh(c, d, a, b, x[i+11], 16, 1839030562);
				b = hh(b, c, d, a, x[i+14], 23, -35309556);
				a = hh(a, b, c, d, x[i+1], 4, -1530992060);
				d = hh(d, a, b, c, x[i+4], 11, 1272893353);
				c = hh(c, d, a, b, x[i+7], 16, -155497632);
				b = hh(b, c, d, a, x[i+10], 23, -1094730640);
				a = hh(a, b, c, d, x[i+13], 4, 681279174);
				d = hh(d, a, b, c, x[i+0], 11, -358537222);
				c = hh(c, d, a, b, x[i+3], 16, -722521979);
				b = hh(b, c, d, a, x[i+6], 23, 76029189);
				a = hh(a, b, c, d, x[i+9], 4, -640364487);
				d = hh(d, a, b, c, x[i+12], 11, -421815835);
				c = hh(c, d, a, b, x[i+15], 16, 530742520);
				b = hh(b, c, d, a, x[i+2], 23, -995338651);
				a = ii(a, b, c, d, x[i+0], 6, -198630844);
				d = ii(d, a, b, c, x[i+7], 10, 1126891415);
				c = ii(c, d, a, b, x[i+14], 15, -1416354905);
				b = ii(b, c, d, a, x[i+5], 21, -57434055);
				a = ii(a, b, c, d, x[i+12], 6, 1700485571);
				d = ii(d, a, b, c, x[i+3], 10, -1894986606);
				c = ii(c, d, a, b, x[i+10], 15, -1051523);
				b = ii(b, c, d, a, x[i+1], 21, -2054922799);
				a = ii(a, b, c, d, x[i+8], 6, 1873313359);
				d = ii(d, a, b, c, x[i+15], 10, -30611744);
				c = ii(c, d, a, b, x[i+6], 15, -1560198380);
				b = ii(b, c, d, a, x[i+13], 21, 1309151649);
				a = ii(a, b, c, d, x[i+4], 6, -145523070);
				d = ii(d, a, b, c, x[i+11], 10, -1120210379);
				c = ii(c, d, a, b, x[i+2], 15, 718787259);
				b = ii(b, c, d, a, x[i+9], 21, -343485551);
				a = safe_add(a, olda); b = safe_add(b, oldb);
				c = safe_add(c, oldc); d = safe_add(d, oldd);
			}
			return [ a, b, c, d ] ;
		}
		
		/**
		 * @private
		 */
		private static function ff(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number 
		{
			return cmn((b & c) | ((~b) & d), a, b, x, s, t);
		}
		
		/**
		 * @private
		 */
		private static function gg(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number 
		{
			return cmn((b & d) | (c & (~d)), a, b, x, s, t);
		}
		
		/**
		 * @private
		 */
		private static function hh(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number 
		{
			return cmn(b ^ c ^ d, a, b, x, s, t);
		}
		
		/**
		 * @private
		 */
		private static function ii(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number 
		{
			return cmn(c ^ (b | (~d)), a, b, x, s, t);
		}
		
		/**
		 * @private
		 */
		private static function safe_add(x:Number, y:Number):Number 
		{
			var lsw:int = (x & 0xFFFF)+(y & 0xFFFF);
			var msw:int = (x >> 16)+(y >> 16)+(lsw >> 16);
			return (msw << 16) | (lsw & 0xFFFF);
		}
		
		/**
		 * @private
		 */
		private static function str2binl(str:String):Array 
		{
			str = new String(str) ;
			var bin:Array = new Array();
			var mask:int = (1 << 8)-1;
			var size:int = str.length * 8 ;
			for (var i:int = 0 ; i<size ; i += 8 ) 
			{
				bin[i >> 5] |= (str.charCodeAt(i/8) & mask) << (i%32);
			}
			return bin;
		}
		
		/**
		 * @private
		 */
		private static function binl2hex(binarray:Array):String 
		{
			var str:String = "" ;
			var tab:String = new String("0123456789abcdef");
			var size:int = binarray.length * 4 ;
			for (var i:int = 0; i<size; i++) 
			{
				str += tab.charAt((binarray[i >> 2] >> ((i%4)*8+4)) & 0xF) + tab.charAt((binarray[i >> 2] >> ((i%4)*8)) & 0xF);
			}
			return str;
		}
	}
}
