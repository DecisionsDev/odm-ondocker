package com.ibm.odm.ondocker;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
            String url = generateUrl(request, redirect_url);
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
