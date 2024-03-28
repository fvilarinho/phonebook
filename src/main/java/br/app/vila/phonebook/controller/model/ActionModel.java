package br.app.vila.phonebook.controller.model;

public class ActionModel {
    private boolean success = false;
    private String message = "";

    public ActionModel(){
        super();
    }

    public ActionModel(boolean success, String message){
        this();

        setSuccess(success);
        setMessage(message);
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
