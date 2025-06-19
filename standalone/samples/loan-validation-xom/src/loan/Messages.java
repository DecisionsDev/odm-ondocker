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

import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class Messages {
	static private ResourceBundle m_bundle;

	static public String getMessage(String messageKey) {
		prepareMessages();
		String message;
		if (m_bundle == null) return messageKey;
		try {
			message = m_bundle.getString(messageKey);
		} catch (MissingResourceException e1) {
				message = messageKey;
		}
		return message;
	}

	static private void prepareMessages() {
		if (m_bundle == null)
			try {
				m_bundle = ResourceBundle.getBundle("loan.messages");
			} catch (MissingResourceException e) {
				m_bundle = null;
			}
	}

}
