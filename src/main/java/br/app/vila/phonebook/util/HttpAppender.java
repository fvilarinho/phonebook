package br.app.vila.phonebook.util;

import br.app.vila.phonebook.util.constants.HttpAppenderFormats;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.ObjectMapper;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class HttpAppender extends AppenderBase<ILoggingEvent> {
    private final ObjectMapper objectMapper = new ObjectMapper();

    private HttpURLConnection connection;
    private String url;
    private String user;
    private String password;
    private boolean authenticated = false;
    private boolean processed = false;
    private String errorMessage;

    public HttpAppender() {
        super();
    }

    public HttpAppender(HttpURLConnection connection) {
        this();

        this.connection = connection;
    }

    public String getErrorMessage() {
        return this.errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public boolean isProcessed() {
        return processed;
    }

    public void setProcessed(boolean processed) {
        this.processed = processed;
    }

    public String getUser() {
        return this.user;
    }

    public void setUser(String user) {
        this.user = EnvironmentUtil.replaceAll(user);

        this.authenticated = (user != null && !user.isEmpty());
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = EnvironmentUtil.replaceAll(password);

        this.authenticated = (password != null && !password.isEmpty());
    }

    public String getUrl() {
        return this.url;
    }

    public void setUrl(String url) {
        this.url = EnvironmentUtil.replaceAll(url);
    }

    protected void append(ILoggingEvent eventObject) {
        setErrorMessage(null);
        setProcessed(false);

        try {
            HttpAppenderFormats formatObject = HttpAppenderFormats.JSON;
            URL urlObject = new URL(getUrl());
            HttpURLConnection connectionObject;

            if (this.connection == null)
                connectionObject = (HttpURLConnection) urlObject.openConnection();
            else
                connectionObject = this.connection;

            connectionObject.setDoOutput(true);
            connectionObject.setRequestMethod(HttpMethod.POST.name());

            if (this.authenticated) {
                String auth = getUser() + ":" + getPassword();
                String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes());
                String authHeaderValue = "Basic " + encodedAuth;

                connectionObject.setRequestProperty("Authorization", authHeaderValue);
            }

            connectionObject.setRequestProperty("Accept", formatObject.getValue());
            connectionObject.setRequestProperty("Content-Type", formatObject.getValue());

            Map<String, Object> logObject = new HashMap<>();

            logObject.put("timestamp", eventObject.getTimeStamp());
            logObject.put("thread", eventObject.getThreadName());
            logObject.put("level", eventObject.getLevel().toString());
            logObject.put("logger", eventObject.getLoggerName());
            logObject.put("message", eventObject.getFormattedMessage());

            String logLine = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(logObject);

            try (OutputStream os = connectionObject.getOutputStream()) {
                os.write(logLine.getBytes());
                os.flush();
            }

            // Handle the response
            int responseCode = connectionObject.getResponseCode();
            String responseMessage = connectionObject.getResponseMessage();

            if (responseCode != HttpURLConnection.HTTP_OK)
                setErrorMessage(String.format("Failed to send log: %s - %s%n", responseCode, responseMessage));
        } catch (Exception e) {
            setErrorMessage(String.format("Internal server error - %s", e.getMessage()));
        }

        setProcessed(getErrorMessage() == null);
    }
}
