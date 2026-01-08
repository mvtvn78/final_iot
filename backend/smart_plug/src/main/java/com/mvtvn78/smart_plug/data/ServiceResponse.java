package com.mvtvn78.smart_plug.data;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.google.gson.Gson;
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ServiceResponse {
    private int statusCode;
    private Object data;

    @Override
    public String toString() {
        return new Gson().toJson(this);
    }
}

