import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/track")
public class TrackIPServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(TrackIPServlet.class.getName());

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get IP address, considering proxy servers
        String ipAddress = request.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = request.getRemoteAddr();
        }

        // Get timestamp and User-Agent
        LocalDateTime timestamp = LocalDateTime.now();
        String userAgent = request.getHeader("User-Agent");

        // Log visitor information
        logger.info("Visitor IP: " + ipAddress + " | Time: " + timestamp + " | User-Agent: " + userAgent);

        // Response to the user
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        out.println("Your IP Address: " + ipAddress);
        out.println("Timestamp: " + timestamp);
        out.println("User-Agent: " + userAgent);

        // Optionally, store this information in a database
        saveToDatabase(ipAddress, timestamp, userAgent);
    }

    // Optional: Store tracking data in a database
    private void saveToDatabase(String ipAddress, LocalDateTime timestamp, String userAgent) {
        try {
            // Replace with your database connection details
            String url = "jdbc:mysql://localhost:3306/tracking";
            String user = "your_db_user";
            String password = "your_db_password";
            java.sql.Connection conn = java.sql.DriverManager.getConnection(url, user, password);
            
            String sql = "INSERT INTO visits (ip, timestamp, user_agent) VALUES (?, ?, ?)";
            java.sql.PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, ipAddress);
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(timestamp));
            stmt.setString(3, userAgent);
            stmt.executeUpdate();
            
            stmt.close();
            conn.close();
        } catch (Exception e) {
            logger.severe("Database error: " + e.getMessage());
        }
    }
}
