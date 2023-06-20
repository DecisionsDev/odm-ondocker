/*
* Copyright IBM Corp. 1987, 2023
* 
* Licensed to the Apache Software Foundation (ASF) under one
* or more contributor license agreements.  See the NOTICE file
* distributed with this work for additional information
* regarding copyright ownership.  The ASF licenses this file
* to you under the Apache License, Version 2.0 (the
* "License"); you may not use this file except in compliance
* with the License.  You may obtain a copy of the License at
* 
* http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied.  See the License for the
* specific language governing permissions and limitations
* under the License.
* 
**/
package loan;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.NoSuchElementException;



/**
 * DateUtil
 */
public class DateUtil {

   public static Date now() {
   	  return Calendar.getInstance().getTime();
   }

   public static Date makeDate(int year, int month, int day) {
   	  Calendar cal = Calendar.getInstance();
   	  cal.set(Calendar.MILLISECOND,0);
 	  cal.set(Calendar.SECOND,0);
 	  cal.set(Calendar.MINUTE,0);
 	  cal.set(Calendar.HOUR_OF_DAY,0);
 	  cal.set(Calendar.YEAR,year);
 	  cal.set(Calendar.MONTH,month);
 	  cal.set(Calendar.DAY_OF_MONTH,day);
 	  return cal.getTime();
   }

   public static Date dateAsDay(Date date) {
   	  Calendar cal = Calendar.getInstance();
   	  cal.setTime(date);
   	  cal.set(Calendar.MILLISECOND,0);
   	  cal.set(Calendar.SECOND,0);
   	  cal.set(Calendar.MINUTE,0);
   	  cal.set(Calendar.HOUR_OF_DAY,0);
   	  return cal.getTime();
   }

   public static Date addDays(Date date, int days) {
   	  Calendar cal = Calendar.getInstance();
 	  cal.setTime(date);
 	  cal.add(Calendar.DATE,days);
 	  return cal.getTime();
   }


   /**
    * Compute the number of days between 2 dates.
    * This method is simply done for the purpose of this sample.
    * It is more accurate (but less efficent) than the following :
    *    	  long startTime = startDate.getTime();
   	*         long endTime = endDate.getTime();
   	*         return (int)((endTime - startTime) / (24*3600*1000));
   	*         For example the above should fail if the beginning of Daylight Saving Time
   	*         is between startDate and endDate
   	* For accurate algorithm use dedicated date library.
    * @param startDate
    * @param endDate
    * @return The duration in days
    */
   public static int getDuration(Date startDate, Date endDate) {
       int tempDifference = 0;
       Calendar earlier = Calendar.getInstance();
       Calendar later = Calendar.getInstance();
        if (startDate.compareTo(endDate) < 0) {
           earlier.setTime(startDate);
           later.setTime(endDate);
        } else {
           earlier.setTime(endDate);
           later.setTime(startDate);
        }

        earlier.set(Calendar.HOUR_OF_DAY, 0);
        earlier.set(Calendar.MINUTE, 0);
        earlier.set(Calendar.SECOND, 0);
        earlier.set(Calendar.MILLISECOND, 0);

        later.set(Calendar.HOUR_OF_DAY, 0);
        later.set(Calendar.MINUTE, 0);
        later.set(Calendar.SECOND, 0);
        later.set(Calendar.MILLISECOND, 0);

        while (true) {
         // Did we reach the endDate ?
            if (earlier.equals(later)) return tempDifference;
         // Date incrementation
            earlier.add(Calendar.DAY_OF_MONTH,2);
      	 // Add 2 days
            tempDifference=tempDifference+2;
         // Guard
            if (earlier.getTime().after(later.getTime())) {
           	   return tempDifference-1;
            }
        }
   }

   public static Iterator<Object> iterator(final Date startDate, final Date endDate) {
   	  return new Iterator<Object>() {
   	  	Date currentDate = startDate;
   	  	public boolean hasNext() {
   	  		if (currentDate.after(endDate))
   	  			return false;
   	  		return true;
   	  	}
   	  	public Object next() {
   	  	   	Date returnDate = currentDate;
   	  	   	if (hasNext()) {
   	  	   		currentDate = addDays(currentDate, 1);
   	  	   		return returnDate;
   	  	   	}
   	  	   	else
   	  	   	{
   	  	   		throw new NoSuchElementException(currentDate + " is after " + endDate);
   	  	   	}
   	  	}
   	  	public void remove() {
   	  		throw new UnsupportedOperationException("Date iterator is read only") ;
   	  	}
   	  };
   }

   public static String format(Date date) {
   	  DateFormat formatter = DateFormat.getDateInstance();
   	  return formatter.format(date);
   }

   public static int getAge(Date birthDate, Date nowDate) {

    Calendar birth = Calendar.getInstance();
    birth.setTime(birthDate);

    // Create a calendar object with today's date
    Calendar now = Calendar.getInstance();
    now.setTime(nowDate);

    // Get age based on year
    int age = now.get(Calendar.YEAR) - birth.get(Calendar.YEAR);

    // Add the tentative age to the date of birth to get this year's birthday
    birth.add(Calendar.YEAR, age);

    // If this year's birthday has not happened yet, subtract one from age
    if (now.before(birth)) {
        age--;
    }

    return age;
   }

}
