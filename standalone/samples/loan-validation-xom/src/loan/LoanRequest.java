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

import java.text.MessageFormat;
import java.util.Date;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;

@XmlAccessorType(XmlAccessType.FIELD)
public class LoanRequest extends LoanUtil implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 7356529391378635986L;

	//Fields
	@XmlElement	
	private int numberOfMonthlyPayments;
	@XmlElement	
	private Date startDate;
	@XmlElement	
	private int amount;
	@XmlElement	
	private double loanToValue;

	@SuppressWarnings("unused")
	private LoanRequest() {
		
	}

	public void setNumberOfMonthlyPayments(int numberOfMonthlyPayments) {
		this.numberOfMonthlyPayments = numberOfMonthlyPayments;
	}


	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}


	public void setAmount(int amount) {
		this.amount = amount;
	}


	public LoanRequest(Date startDate, int numberOfMonthlyPayments, int amount,
			double loanToValue) {
		this.startDate = startDate;
		this.numberOfMonthlyPayments = numberOfMonthlyPayments;
		this.amount = amount;
		this.loanToValue = loanToValue;
	}


	/**
	 * @return Returns the loanToValue.
	 */
	public double getLoanToValue() {
		return loanToValue;
	}

	/**
	 * @param loanToValue
	 *            The loanToValue to set.
	 */
	public void setLoanToValue(double loanToValue) {
		this.loanToValue = loanToValue;
	}
	

	/**
	 * @return Returns the amount.
	 */
	public int getAmount() {
		return amount;
	}

	/**
	 * @return Returns the numberOfMonthlyPayments.
	 */
	public int getNumberOfMonthlyPayments() {
		return numberOfMonthlyPayments;
	}
	
	/**
	 * Get the loan duration (rounded to the upper int)
	 * @return a number of years 
	 */
	public int getDuration() {
		return (numberOfMonthlyPayments+11)/12;
	}

	/**
	 * @return Returns the startDate.
	 */
	public Date getStartDate() {
		return startDate;
	}
	
	public String toString() {
		String msg = Messages.getMessage("loan");
		Object[] arguments = { amount, DateUtil.format(startDate),
				numberOfMonthlyPayments, formattedPercentage(loanToValue) };
		String result = MessageFormat.format(msg, arguments);

		
		return result;
	}
};
