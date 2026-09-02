import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class App {
    public static void main(String[] args) throws IOException {
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0);

        server.createContext("/", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) throws IOException {
                String response = "<!DOCTYPE html>\n" +
                        "<html lang=\"en\">\n" +
                        "<head>\n" +
                        "    <meta charset=\"UTF-8\">\n" +
                        "    <title>Java - Hello World</title>\n" +
                        "    <style>\n" +
                        "        body {\n" +
                        "            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n" +
                        "            background: linear-gradient(135deg, #18181b, #27272a);\n" +
                        "            color: #fff;\n" +
                        "            display: flex;\n" +
                        "            align-items: center;\n" +
                        "            justify-content: center;\n" +
                        "            height: 100vh;\n" +
                        "            margin: 0;\n" +
                        "        }\n" +
                        "        .card {\n" +
                        "            background: rgba(255, 255, 255, 0.08);\n" +
                        "            padding: 2.5rem 3.5rem;\n" +
                        "            border-radius: 16px;\n" +
                        "            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);\n" +
                        "            backdrop-filter: blur(8px);\n" +
                        "            text-align: center;\n" +
                        "            border: 1px solid rgba(255, 255, 255, 0.18);\n" +
                        "        }\n" +
                        "        h1 { color: #f97316; margin-bottom: 0.5rem; }\n" +
                        "        p { color: #cbd5e1; font-size: 1.1rem; }\n" +
                        "        .badge { background: #3f3f46; padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; }\n" +
                        "    </style>\n" +
                        "</head>\n" +
                        "<body>\n" +
                        "    <div class=\"card\">\n" +
                        "        <h1>Hello World from Java Web Application! ☕</h1>\n" +
                        "        <p>DevOps Containerization Lab - Section B</p>\n" +
                        "        <span class=\"badge\">Running on OpenJDK 17 inside Docker</span>\n" +
                        "    </div>\n" +
                        "</body>\n" +
                        "</html>";

                exchange.getResponseHeaders().set("Content-Type", "text/html; charset=UTF-8");
                byte[] bytes = response.getBytes("UTF-8");
                exchange.sendResponseHeaders(200, bytes.length);
                OutputStream os = exchange.getResponseBody();
                os.write(bytes);
                os.close();
            }
        });

        server.setExecutor(null);
        System.out.println("Java HTTP Server started on port " + port);
        server.start();
    }
}
