/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ibm.odm.ondocker;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class RedirectServlet extends HttpServlet {

    public static final String PROPERTIES_FILE="app.properties";
    public static final String DASHBOARD_KEY="dashboard";
    public static final String REDIRECT_URL_KEY="redirect_url";

    private boolean use_dashboard = false;
    private String redirect_url = null;

    @Override
    public void init() throws ServletException {
          InputStream is = getClass().getClassLoader().getResourceAsStream(PROPERTIES_FILE);
        if (null == is)
            throw new ServletException("Could not read the " + PROPERTIES_FILE + " file.");

        try {
            Properties prop = new Properties();
            prop.load(is);
            use_dashboard = Boolean.parseBoolean(prop.getProperty(DASHBOARD_KEY));
            redirect_url = prop.getProperty(REDIRECT_URL_KEY);
        } catch (IOException e) {
            e.printStackTrace();
            throw new ServletException("Could not read the " + PROPERTIES_FILE + " file.");
        }
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (use_dashboard) {
              this.getServletContext().getRequestDispatcher("/index.jsp").forward(request, response);
        }
        else if (redirect_url != null) {
	    String contextRoot = System.getenv("ODM_CONTEXT_ROOT");
	    String url;
            if ( contextRoot != null){
	    	url = generateUrl(request, contextRoot + redirect_url);
	    } else {
		url = generateUrl(request, redirect_url);
	    }
            response.sendRedirect(url);
        }
    }

    /**
     * Generate an URL with the right hostname and port.
     * @param request The HttpServletRequest request.
     * @param context the url after the hostname and port (e.g.: /some/url).
     * @return An URL.
     */
    private String generateUrl(HttpServletRequest request, String context) {
        return request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + context;
    }
}
