package main.java;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class Index extends HttpServlet {

    private static final String DASHBOARD_KEY="dashboard";
    private static final String REDIRECT_URI_KEY="redirect_url";

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        InputStream is = getClass().getClassLoader().getResourceAsStream("app.properties");
        if (null == is)
            throw new ServletException("Could not read the app.properties file.");

        Properties prop = new Properties();
        prop.load(is);
        String is_dashboard = prop.getProperty(DASHBOARD_KEY);

        if ("true".equals(is_dashboard)) {
            this.getServletContext().getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
        } else {
            String redirect_uri = generateUrl(request, prop.getProperty(REDIRECT_URI_KEY));
            response.sendRedirect(redirect_uri);
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
