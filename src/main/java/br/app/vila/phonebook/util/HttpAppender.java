package br.app.vila.phonebook.util;

import br.app.vila.phonebook.util.constants.HttpAppenderFormats;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpMethod;

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
    private String format = HttpAppenderFormats.JSON.name();
    private String delimiter = ";";
    private String user;
    private String password;
    private boolean authenticated = false;
    private boolean processed = false;
    private String errorMessage;

    public HttpAppender(){
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

    public String getDelimiter() {
        return this.delimiter;
    }

    public void setDelimiter(String delimiter) {
        this.delimiter = delimiter;
    }

    public String getFormat() {
        return this.format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getUser() {
        return this.user;
    }

    public void setUser(String user) {
        this.user = user;

        this.authenticated = (user != null && !user.isEmpty());
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = password;

        this.authenticated = (password != null && !password.isEmpty());
    }

    public String getUrl() {
        return this.url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    protected void append(ILoggingEvent eventObject) {
        setErrorMessage(null);

        try {
            HttpAppenderFormats formatObject= HttpAppenderFormats.fromString(getFormat());

            if(formatObject != null) {
                URL urlObject = new URL(getUrl());
                HttpURLConnection connectionObject;

                if(this.connection == null)
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

                String logLine;

                if(formatObject == HttpAppenderFormats.JSON)
                    logLine = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(logObject);
                else {
                    String[] values = new String[logObject.size()];
                    int i = 0;

                    for (Object value : logObject.values()) {
                        values[i] = (value != null ? value.toString() : "");

                        i++;
                    }

                    logLine = String.join(getDelimiter(), values);
                }

                try (OutputStream os = connectionObject.getOutputStream()) {
                    os.write(logLine.getBytes());
                    os.flush();
                }

                // Handle the response
                int responseCode = connectionObject.getResponseCode();
                String responseMessage = connectionObject.getResponseMessage();

                if (responseCode != HttpURLConnection.HTTP_OK)
                    setErrorMessage(String.format("Failed to send log: %s - %s%n", responseCode, responseMessage));
            }
            else
                setErrorMessage("Log format not supported!");
        }
        catch (Exception e) {
            setErrorMessage(String.format("Internal server error - %s", e.getMessage()));
        }

        setProcessed(getErrorMessage() == null);
    }
}
