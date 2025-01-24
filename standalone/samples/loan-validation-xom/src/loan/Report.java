/*
* Copyright IBM Corp. 1987, 2025
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
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Result
 */
public class Report extends LoanUtil implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2376025988992249999L;

	private Report() {
		this.insuranceRate = 0.0d;
		this.insuranceRequired = false;
		this.messages = new ArrayList<String>();
		this.validData = true;
		this.approved = false;
	}

	/**
	 * Build a Result report
	 * 
	 * @param borrower
	 *            the borrower
	 * @param loan
	 *            the loan
	 */
	public Report(Borrower borrower, LoanRequest loan) {
		this();
		this.borrower = borrower;
		this.loan = loan;
	}

	private Borrower borrower;

	/**
	 * @return the borrower under validation
	 */
	public Borrower getBorrower() {
		return borrower;
	}

	private LoanRequest loan;

	/**
	 * @return the loan under validation
	 */
	public LoanRequest getLoan() {
		return loan;
	}
	
	private boolean validData;
	
	/**
	 * Returns true when data is valid
	 * @return a boolean (default=true).
	 */
	public boolean isValidData() {
		return validData;
	}
	/**
	 * Sets the data validity flag
	 * @param validData a boolean
	 */
	public void setValidData(boolean validData) {
		this.validData = validData;
	}	
	
	private boolean insuranceRequired;

	/**
	 * @return Returns whether insurance is required or not.
	 */
	public boolean isInsuranceRequired() {
		return insuranceRequired;
	}

	/**
	 * @param required
	 *            Sets whether insurance is required or not.
	 */
	public void setInsuranceRequired(boolean required) {
		this.insuranceRequired = required;
	}

	public String getInsurance() {
		return (!insuranceRequired) ? "none" : formattedPercentage(insuranceRate);
	}

	private double insuranceRate;

	/**
	 * @return Returns the rate.
	 */
	public double getInsuranceRate() {
		return insuranceRate;
	}

	/**
	 * @param rate
	 *            The rate to set.
	 */
	public void setInsuranceRate(double rate) {
		this.insuranceRate = rate;
	}

	private boolean approved;

	/**
	 * Gets the approval value of this loan
	 * 
	 * @return a boolean value
	 */
	public boolean isApproved() {
		return approved;
	}

	/**
	 * Sets the the approval value of this loan
	 * 
	 * @param approved
	 *            a boolean value
	 */
	public void setApproved(boolean approved) {
		this.approved = approved;
	}

	private ArrayList<String> messages;

	/**
	 * Gets the message list
	 * 
	 * @return a List of messages
	 */
	public List<String> getMessages() {
		return messages;
	}

	/**
	 * Adds a message to the list
	 * 
	 * @param message
	 *            a String message
	 */
	public void addMessage(String message) {
		this.messages.add(message);
	}

	/**
	 * Gets a concatenation of all messages
	 * 
	 * @return a String
	 */
	public String getMessage() {
		Iterator<String> it = messages.iterator();
		StringBuffer buf = new StringBuffer();
		while (it.hasNext()) {
			buf.append(it.next());
			if (it.hasNext()) {
				buf.append('\n');
			}
		}
		return buf.toString();
	}
	
	private double yearlyInterestRate;
	private double monthlyRepayment;


	/**
	 * @return Returns the yearlyRepayment.
	 */
	public double getYearlyRepayment() {
		return 12*monthlyRepayment;
	}

	/**
	 * @return Returns the monthlyRepayment.
	 */
	public double getMonthlyRepayment() {
		return monthlyRepayment;
	}
	/**
	 * @param monthlyRepayment
	 *            The monthlyRepayment to set.
	 */
	public void setMonthlyRepayment(double monthlyRepayment) {
		this.monthlyRepayment = monthlyRepayment;
	}

	/**
	 * @return Returns the rate.
	 */
	public double getYearlyInterestRate() {
		return yearlyInterestRate;
	}

	/**
	 * @param rate
	 *            The rate to set.
	 */
	public void setYearlyInterestRate(double rate) {
		this.yearlyInterestRate = rate;
	}


	public String toString() {
		String msg = Messages.getMessage("report");
		Object[] arguments = { isValidData(), isApproved() };
		String result = MessageFormat.format(msg, arguments);

		if (yearlyInterestRate > 0) {
			Object[] rateObj = { yearlyInterestRate };
			String rateStr = MessageFormat.format(Messages.getMessage("rate"),
					rateObj);
			result = result + "\n" + "   - " + rateStr;
		}
		if (monthlyRepayment > 0) {
			Object[] monthlyRepaymentObj = { formattedAmount(monthlyRepayment) };
			String monthlyRepaymentStr = MessageFormat.format(Messages
					.getMessage("monthlyRepayment"), monthlyRepaymentObj);
			result = result + "\n" + "   - " + monthlyRepaymentStr;
		
		}
		
		if (insuranceRequired) {
			Object[] insuranceObj = { isInsuranceRequired(),
					formattedPercentage(insuranceRate) };
			String insuranceStr = MessageFormat.format(Messages
					.getMessage("insurance"), insuranceObj);
			result = result + "\n" + "   - " + insuranceStr;
		}
		if (getMessage() != null && ! (getMessage().trim().length() == 0)) {
			Object[] messageObj = { getMessage() };
			String messageStr = MessageFormat.format(Messages
					.getMessage("message"), messageObj);
			result = result + "\n" + "   - " + messageStr;
		}
		return result;
	}

};
