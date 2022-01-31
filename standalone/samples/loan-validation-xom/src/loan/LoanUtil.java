/*
* Copyright IBM Corp. 1987, 2022
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

import java.io.Serializable;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * LoanUtil
 */
public class LoanUtil implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 7764736178720624835L;

	/**
	 * Computes the monthly repayment from the loan amount, the number of monthly payments and the yearly interest rate
	 * @param amount the loan amount (double)
	 * @param numberOfMonth the number of monthly payments (int)
	 * @param yearlyRate the yearly interest rate (double)
	 * @return the monthly repayment
	 */
	public static double getMonthlyRepayment(double amount, int numberOfMonth,
			double yearlyRate) {
		double i = yearlyRate / 12;
		double p = i * amount / (1 - Math.pow(1 + i, -numberOfMonth));

		return p;
	}
	
	public static String formattedAmount(double amount) {
		NumberFormat formatter = NumberFormat.getInstance(Locale.US);
		formatter.setMinimumFractionDigits(2);
		formatter.setMaximumFractionDigits(2);
		return formatter.format(amount);
	}
	
	public static String formattedPercentage(double percent) {
		NumberFormat formatter = NumberFormat.getInstance(Locale.US);
		formatter.setMaximumFractionDigits(2);
		return formatter.format(percent*100) + "%";
	}
	
	public static boolean containsOnlyDigits(String string) {
		if (string == null) return false;

		char[] array = string.toCharArray();
		for (int i=0 ; i<array.length; i++) {
			if (!Character.isDigit(array[i]))
				return false;
		}
		return true;
	}
}
