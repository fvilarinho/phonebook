package br.app.vila.phonebook.util;

import br.app.vila.phonebook.util.constants.HttpAppenderFormats;
import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.spi.ILoggingEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class HttpAppenderTest {
    private HttpAppender httpAppender;

    @Mock
    private HttpURLConnection mockConnection;

    @Mock
    private ILoggingEvent mockLoggingEvent;

    @BeforeEach
    void setUp() throws Exception {
        MockitoAnnotations.openMocks(this);

        when(this.mockConnection.getOutputStream()).thenReturn(mock(OutputStream.class));

        when(this.mockLoggingEvent.getTimeStamp()).thenReturn(System.currentTimeMillis());
        when(this.mockLoggingEvent.getThreadName()).thenReturn("main");
        when(this.mockLoggingEvent.getLevel()).thenReturn(Level.INFO);
        when(this.mockLoggingEvent.getLoggerName()).thenReturn(null);
        when(this.mockLoggingEvent.getFormattedMessage()).thenReturn("Test log message");
    }

    @Test
    void testAppendWithValidAuthentication() throws IOException {
        when(this.mockConnection.getResponseCode()).thenReturn(HttpURLConnection.HTTP_OK);

        // Set up the HttpAppender
        this.httpAppender = new HttpAppender(this.mockConnection);
        this.httpAppender.setUrl("http://example.com/log");
        this.httpAppender.setFormat(HttpAppenderFormats.JSON.name());
        this.httpAppender.setUser("testUser");
        this.httpAppender.setPassword("testPassword");

        when(this.mockConnection.getResponseCode()).thenReturn(HttpURLConnection.HTTP_OK);

        this.httpAppender.append(this.mockLoggingEvent);

        assertTrue(this.httpAppender.isProcessed());
    }

    @Test
    void testAppendWithInvalidAuthentication() throws IOException {
        when(this.mockConnection.getResponseCode()).thenReturn(HttpURLConnection.HTTP_UNAUTHORIZED);

        // Set up the HttpAppender
        this.httpAppender = new HttpAppender(this.mockConnection);
        this.httpAppender.setUrl("http://example.com/log");
        this.httpAppender.setFormat(HttpAppenderFormats.JSON.name());
        this.httpAppender.setUser(null);
        this.httpAppender.setPassword(null);

        this.httpAppender.append(this.mockLoggingEvent);

        assertFalse(this.httpAppender.isProcessed());

        this.httpAppender.setUser("");
        this.httpAppender.setPassword("");

        this.httpAppender.append(this.mockLoggingEvent);

        assertFalse(this.httpAppender.isProcessed());
    }

    @Test
    void testAppendWithInvalidFormat() {
        // Set up the HttpAppender
        this.httpAppender = new HttpAppender(this.mockConnection);
        this.httpAppender.setUrl("http://example.com/log");
        this.httpAppender.setFormat("INVALID_FORMAT");

        this.httpAppender.append(mockLoggingEvent);

        this.httpAppender.setFormat(null);

        this.httpAppender.append(mockLoggingEvent);

        this.httpAppender.setFormat("");

        this.httpAppender.append(mockLoggingEvent);

        assertFalse(this.httpAppender.isProcessed());
    }

    @Test
    void testAppendWithValidFormat() {
        // Set up the HttpAppender
        this.httpAppender = new HttpAppender(this.mockConnection);
        this.httpAppender.setUrl("http://example.com/log");
        this.httpAppender.setFormat("CSV");
        this.httpAppender.setDelimiter(",");

        this.httpAppender.append(mockLoggingEvent);

        assertFalse(this.httpAppender.isProcessed());
    }
}
