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
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;



@XmlAccessorType(XmlAccessType.FIELD)
public class Borrower implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 888265255939699136L;

	@XmlElement	
	private String   firstName;
	@XmlElement
	private String   lastName;
	@XmlElement
	private Calendar birth;
	@XmlElement
	private SSN      SSN;

	@XmlElement
	private int      yearlyIncome;
	@XmlElement
	private String   zipCode ;
	@XmlElement
	private int      creditScore;
	@XmlElement
	private Borrower spouse;
	@XmlElement
	private Bankruptcy latestBankruptcy;
	
	
	@SuppressWarnings("unused")
	private Borrower() {
		birth = new GregorianCalendar();
		SSN= new SSN();
		latestBankruptcy = new Bankruptcy();
	}
	
	public Calendar getBirth() {
		return birth;
	}

	public void setBirth(Calendar birth) {
		this.birth = birth;
	}

	public Bankruptcy getLatestBankruptcy() {
		return latestBankruptcy;
	}

	public void setLatestBankruptcy(Bankruptcy latestBankruptcy) {
		this.latestBankruptcy = latestBankruptcy;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public void setSSN(SSN sSN) {
		SSN = sSN;
	}

	
	/**
	 * @return Returns the creditScore.
	 */
	public int getCreditScore() {
		return creditScore;
	}
	/**
	 * @param creditScore The creditScore to set.
	 */
	public void setCreditScore(int creditScore) {
		this.creditScore = creditScore;
	}
	


	public Borrower(String firstName, String lastName, 
			Date birthDate,	String SSNCode) {
		this.firstName = firstName;
		this.lastName = lastName;
		Calendar cal = Calendar.getInstance();
		birthDate = DateUtil.dateAsDay(birthDate);
		cal.setTime(birthDate);
		this.birth = cal;
		this.SSN = new SSN(SSNCode);
	}
	
	public String toString() {
		String msg = Messages.getMessage("borrower");
		Object[] arguments = { firstName, lastName,
				DateUtil.format(getBirthDate()), getSSN() };
		String result = MessageFormat.format(msg, arguments);
	     
	     if (zipCode != null) {
			Object[] zipCodeObj = { getZipCode() };
			String zipCodeStr = MessageFormat.format(Messages
					.getMessage("zipCode"), zipCodeObj);
			result = result + "\n" + "   - " + zipCodeStr;
	     }
	     
	     if (yearlyIncome != 0) {
			Object[] incomeObj = { getYearlyIncome() };
			String incomeStr = MessageFormat.format(Messages
					.getMessage("yearlyIncome"), incomeObj);
			result = result + "\n" + "   - " + incomeStr;
	     }
	     
	     if (creditScore>0) {
			Object[] creditScoreObj = { getCreditScore() };
			String creditScoreStr = MessageFormat.format(Messages
					.getMessage("creditScore"), creditScoreObj);
			result = result + "\n" + "   - " + creditScoreStr;
	     }
	     
	     if (hasLatestBankrupcy()) {
			Object[] bankruptcyObj = {
					DateUtil.format(getLatestBankruptcyDate()),
					getLatestBankruptcyReason(), getLatestBankruptcyChapter() };
			String bankruptcyStr = MessageFormat.format(Messages
					.getMessage("bankruptcy"), bankruptcyObj);
			result = result + "\n" + "   - " + bankruptcyStr;
	     }
	     
		return result;
	}

	public String getFirstName() {
		return this.firstName;
	}

	public String getLastName() {
		return this.lastName;
	}

	public Date getBirthDate() {
		return birth.getTime();
	}

	public String getZipCode() {
		return zipCode;
	}

	public void setZipCode(String zipCode) {
		this.zipCode = zipCode;
	}

	public SSN getSSN() {
		return SSN;
	}

	public String getSSNCode() {
		return SSN.toString();
	}

	public int getYearlyIncome() {
		return yearlyIncome;
	}

	public void setYearlyIncome(int income) {
		this.yearlyIncome = income;
	}

	public boolean hasLatestBankrupcy() {
		return latestBankruptcy != null;
	}

	public Date getLatestBankruptcyDate() {
		if(hasLatestBankrupcy())
		return latestBankruptcy.getDate();
		return null;
	}

	public String getLatestBankruptcyReason() {
		if(hasLatestBankrupcy())
		return latestBankruptcy.getReason();
		return null;
	}
	// Among Unemployment; Large medical expenses; Seriously overextended credit; Marital problems, and Other large unexpected expenses

	public int getLatestBankruptcyChapter() {
		if(hasLatestBankrupcy())
		return latestBankruptcy.getChapter();
		return -1;
	}
	
	public void setLatestBankruptcy(Date date, int chapter, String reason) {
		this.latestBankruptcy = new Bankruptcy(date, chapter, reason);
	}
	
	public void setSpouse(Borrower spouse) {
	    this.spouse = spouse;
	}
	
	public Borrower getSpouse() {
	    return spouse;
	}

	@XmlAccessorType(XmlAccessType.FIELD)
	public static class Bankruptcy implements java.io.Serializable {
		/**
		 * 
		 */
		private static final long serialVersionUID = 3107842066700686170L;
		@XmlElement
		private Date date;
		@XmlElement
		private int chapter;
		@XmlElement
		private String reason;
	
		@SuppressWarnings("unused")
		private Bankruptcy() {
		}
	
		public Bankruptcy(Date date, int chapter, String reason) {
			this.date = date;
			this.chapter = chapter;
			this.reason = reason;
		}
	
		public void setDate(Date date) {
			this.date = date;
		}

		public void setChapter(int chapter) {
			this.chapter = chapter;
		}

		public void setReason(String reason) {
			this.reason = reason;
		}

		public Date getDate() {
			return date;
		}
	
		public String getReason() {
			return reason;
		}
		
		public int getChapter() {
			return this.chapter;
		}
	}

	
	@XmlAccessorType(XmlAccessType.FIELD)
	public static class SSN implements java.io.Serializable {
		/**
		 * 
		 */
		private static final long serialVersionUID = -2186494815176523547L;
		@XmlElement
		private String areaNumber;
		@XmlElement
		private String groupCode;
		@XmlElement
		private String serialNumber;

		private SSN() {
			areaNumber = "";
			groupCode = "";
			serialNumber = "";
		}		
		
		private void parseSSN(String number) {
			int firstDash = number.indexOf('-');
			if (firstDash >= 1) {
				areaNumber = number.substring(0, firstDash);
				int secondDash = number.indexOf('-', firstDash+1);
				if (secondDash >= firstDash+2) {
					groupCode = number.substring(firstDash+1, secondDash);
					serialNumber = number.substring(secondDash+1);
				} 
				else {
					groupCode = number.substring(firstDash+1, Math.min(number.length(), firstDash+3));
					serialNumber = number.substring(Math.min(number.length(), firstDash+3), number.length());
				}
			}
			else {
				areaNumber = number.substring(0, Math.min(number.length(), 3));
				groupCode = number.substring(Math.min(number.length(), 3), Math.min(number.length(), 5));
				serialNumber = number.substring(Math.min(number.length(), 5), number.length());
			}
		}
	
	
		public void setAreaNumber(String areaNumber) {
			this.areaNumber = areaNumber;
		}

		public void setGroupCode(String groupCode) {
			this.groupCode = groupCode;
		}

		public void setSerialNumber(String serialNumber) {
			this.serialNumber = serialNumber;
		}

		public SSN(String number) {
			parseSSN(number);
		}
		
		public SSN(String areaNumber, String groupCode, String serialNumber) {
			this.areaNumber = areaNumber;
			this.groupCode = groupCode;
			this.serialNumber = serialNumber;
		}
		
		public int getDigits() {
			return areaNumber.length() + groupCode.length() + serialNumber.length();
		}
	
		public String getAreaNumber() {
			return areaNumber;
		}
		
		public String getGroupCode() {
			return groupCode;
		}
		
		public String getSerialNumber() {
			return serialNumber;
		}
		
		
		public String getFullNumber() {
			return getAreaNumber() + "-" + getGroupCode() + "-" + getSerialNumber();
		}
		
		public String toString() {
			return this.getFullNumber();
		}
	}

};
