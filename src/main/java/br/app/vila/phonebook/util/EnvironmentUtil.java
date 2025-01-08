package br.app.vila.phonebook.util;

import java.util.Map;

public interface EnvironmentUtil {
    static String replaceAll(String input) {
        if(input != null && !input.isEmpty()) {
            // Retrieve all environment variables
            Map<String, String> env = System.getenv();

            // Replace each placeholder with its corresponding value
            for (Map.Entry<String, String> entry : env.entrySet()) {
                String placeholder = "${" + entry.getKey() + "}";

                input = input.replace(placeholder, entry.getValue());
            }
        }

        return input;
    }
}
