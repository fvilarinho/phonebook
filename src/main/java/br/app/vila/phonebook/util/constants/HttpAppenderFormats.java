package br.app.vila.phonebook.util.constants;

public enum HttpAppenderFormats {
    JSON("application/json"),
    CSV("text/csv");

    private String value;

    public String getValue() {
        return this.value;
    }

    private void setValue(String value) {
        this.value = value;
    }

    HttpAppenderFormats(String value) {
        setValue(value);
    }

    public static HttpAppenderFormats fromString(String value) {
        if (value != null && !value.isEmpty()) {
            if (value.equalsIgnoreCase(JSON.name()))
                return JSON;

            if (value.equalsIgnoreCase(CSV.name()))
                return CSV;
        }

        return null;
    }
}
