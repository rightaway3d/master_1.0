package jell3d.utils
{

	/**
	 *
	 * @author a
	 */
	public class DateTime
	{
		private var _year:uint = 1900;

		private var _month:uint = 1;

		private var _date:uint = 1;

		private var _hour:uint = 0;

		private var _minute:uint = 0;

		private var _second:uint = 0;

		/**
		 *
		 * @param year
		 * @param month
		 * @param date
		 * @param hour
		 * @param minute
		 * @param second
		 */
		public function DateTime(year:uint, month:uint, date:uint, hour:uint = 0, minute:uint = 0, second:uint = 0)
		{
			this.year = year;
			this.month = month;
			this.date = date;
			this.hour = hour;
			this.minute = minute;
			this.second = second;
		}

		//-------------------------------------
		//年
		/**
		 *
		 * @param year
		 */
		public function set year(year:uint):void
		{
			_year = year;
		}

		//
		/**
		 *
		 * @return
		 */
		public function get year():uint
		{
			return _year;
		}

		//-------------------------------------
		//月份：1-12
		/**
		 *
		 * @param month
		 */
		public function set month(month:uint):void
		{
			_month = 1;
			this.addMonth(month - 1);
		}

		//
		/**
		 *
		 * @return
		 */
		public function get month():uint
		{
			return _month;
		}

		//-------------------------------------
		//日
		/**
		 *
		 * @param date
		 */
		public function set date(date:uint):void
		{
			_date = 1;
			this.addDate(date - 1);
		}

		//
		/**
		 *
		 * @return
		 */
		public function get date():uint
		{
			return _date;
		}

		//-------------------------------------
		//星期
		/**
		 *
		 * @return
		 */
		public function get day():uint
		{
			var d:Date = new Date(_year, _month - 1, _date);
			return d.getDay();
		}

		//-------------------------------------
		//时
		/**
		 *
		 * @param hour
		 */
		public function set hour(hour:uint):void
		{
			_hour = 0;
			this.addHour(hour);
		}

		//
		/**
		 *
		 * @return
		 */
		public function get hour():uint
		{
			return _hour;
		}

		//-------------------------------------
		//分
		/**
		 *
		 * @param minute
		 */
		public function set minute(minute:uint):void
		{
			_minute = 0;
			this.addMinute(minute);
		}

		//
		/**
		 *
		 * @return
		 */
		public function get minute():uint
		{
			return _minute;
		}

		//-------------------------------------
		//秒
		/**
		 *
		 * @param second
		 */
		public function set second(second:uint):void
		{
			_second = 0;
			this.addSecond(second);
		}

		//
		/**
		 *
		 * @return
		 */
		public function get second():uint
		{
			return _second;
		}

		//-------------------------------------
		/**
		 *
		 * @param second
		 */
		public function addSecond(second:int):void
		{
			var s:int = _second + second;
			var m:int = Math.floor(s / 60);
			addMinute(m);

			if(s >= 0)
			{
				_second = s % 60;
			}
			else
			{
				_second += second - s * 60;
			}
		}

		//2011年9月23日T10时20分0秒
		/**
		 *
		 * @param minute
		 */
		public function addMinute(minute:int):void
		{
			var m:int = _minute + minute;
			var h:int = Math.floor(m / 60);
			addHour(h);

			if(m >= 0)
			{
				_minute = m % 60;
			}
			else
			{
				_minute += minute - m * 60;
			}
		}

		/**
		 *
		 * @param hour
		 */
		public function addHour(hour:int):void
		{
			var h:int = _hour + hour;
			var d:int = Math.floor(h / 24);
			addDate(d);

			if(h >= 0)
			{
				_hour = h % 24;
			}
			else
			{
				_hour += hour - d * 24;
			}
		}

		/**
		 *
		 * @param date
		 */
		public function addDate(date:int):void
		{
			var d:int = _date + date;
			var days:uint;
			var i:uint;
			var j:uint;

			if(d > 0)
			{
				for(i = _month; ; i++)
				{
					j = (i - 1) % 12 + 1;

					days = getMonthDays(_year, j);

					if(d > days) //计算后的日期大于本月份的天数
					{
						d -= days; //则从中减去本月份的天数
						addMonth(1); //月份加1后继续循环
					}
					else
					{
						_date = d; //设置日期
						break; //终止循环
					}
				}
			}
			else
			{
				addMonth(-1); //月份减1
				days = getMonthDays(_year, _month);
				addDate(date + days);
			}
		}

		/**
		 *
		 * @param month
		 */
		public function addMonth(month:int):void
		{
			var m:int = _month + month;
			var y:int = Math.floor((m - 1) / 12); //计算要增加的年数
			_year += y;

			if(m > 0)
			{
				_month = (m - 1) % 12 + 1;
			}
			else
			{
				_month += month - y * 12;
			}
		}

		//-------------------------------------
		//计算某年某个月份的天数，月份参数为1-12；
		/**
		 *
		 * @param year
		 * @param month
		 * @return
		 */
		static public function getMonthDays(year:uint, month:uint):uint
		{
			if(month > 12)
			{
				return 0;
			}

			var monthDays:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

			if(month != 2)
			{
				return monthDays[month - 1];
			}

			if(isLeapYear(year))
			{
				return 29;
			}

			return 28;
		}

		//-------------------------------------
		//判断某年是否闰年，四年一润，百年不润，四百年再润
		/**
		 *
		 * @param year
		 * @return
		 */
		static public function isLeapYear(year:uint):Boolean
		{
			if((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
			{
				return true;
			}
			return false;
		}

		//-------------------------------------
		/**
		 *
		 * @return
		 */
		public function clone():DateTime
		{
			return new DateTime(_year, _month, _date, _hour, _minute, _second);
		}

		//-------------------------------------
		//计算本日期与给定日期之差，返回秒数
		/**
		 *
		 * @param dtime
		 * @return
		 */
		public function subtraction(dtime:DateTime):Number
		{
			var date1:Date = new Date(this.year, this.month - 1, this.date, this.hour, this.minute, this.second, 0);
			var date2:Date = new Date(dtime.year, dtime.month - 1, dtime.date, dtime.hour, dtime.minute, dtime.second, 0);

			return (date1.valueOf() - date2.valueOf()) / 1000;
		}

		//-------------------------------------
		//判断本日期是否比 dtime 日期大，也就是在 dtime 日期的后面
		/**
		 *
		 * @param dtime
		 * @return
		 */
		public function isMaxThan(dtime:DateTime):Boolean
		{
			if(_year > dtime.year)
			{
				return true;
			}
			else if(_year < dtime.year)
			{
				return false;
			}

			//年份相等时            
			if(_month > dtime.month)
			{
				return true;
			}
			else if(_month < dtime.month)
			{
				return false;
			}

			//月份也相等时            
			if(_date > dtime.date)
			{
				return true;
			}
			else if(_date < dtime.date)
			{
				return false;
			}

			//日子也相等时            
			if(_hour > dtime.hour)
			{
				return true;
			}
			else if(_hour < dtime.hour)
			{
				return false;
			}

			//时也相等时            
			if(_minute > dtime.minute)
			{
				return true;
			}
			else if(_minute < dtime.minute)
			{
				return false;
			}

			//分也相等时            
			if(_second > dtime.second)
			{
				return true;
			}
			else
			{
				//两个日期相等时也返回false
				return false;
			}
		}

		//-------------------------------------

		//public function toString(style:String = "cn"):String

		/**
		 *
		 * @param format
		 * @param content
		 * @return
		 */
		public function toString(format:String = "cn", content:String = ""):String

		{
			var date:String;
			var time:String;
			
			if(format == "cn")
			{
				date = _year + "年" + _month + "月" + _date + "日";
				time = _hour + "时" + _minute + "分" + _second + "秒";
			}
			else if(format == "en")
			{
				date = _year + "-" + _month + "-" + _date;
				time = _hour + ":" + _minute + ":" + _second;
			}
			else
			{
				date = _year + format + _month + format + _date;
				time = _hour + format + _minute + format + _second;
			}
			
			if(content == "date")
			{
				return date;
			}
			else if(content == "time")
			{
				return time;
			}
			
			if(format == "cn")
			{
				return date + time;
			}
			else if(format == "en")
			{
				return date + " " + time;
			}
			
			return date + " " + time;
		}
		
		static public function getCurrDateString(format:String = "cn", content:String = ""):String
		{
			var date:Date = new Date();
			var dt:DateTime = new DateTime(date.fullYear,date.month+1,date.date,date.hours,date.minutes,date.seconds);
			return dt.toString(format,content);
		}
		
		/**
		 * 获取一个以当前时间为基准的DateTime实例
		 * @param offset 对当前时间的偏移量，单位秒
		 * @return 新的DateTime实例
		 * 
		 */
		static public function getDateTime(offset:int=0):DateTime
		{
			var date:Date = new Date();
			var dt:DateTime = new DateTime(date.fullYear,date.month+1,date.date,date.hours,date.minutes,date.seconds);
			dt.addSecond(offset);
			return dt;
		}
	}
}