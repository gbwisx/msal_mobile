package com.gbwisx.msal_mobile;

import com.google.gson.Gson;
import com.microsoft.identity.client.exception.MsalException;

import androidx.annotation.NonNull;

public class Results {
    static class MsalMobileResult {
        private boolean isSuccess;
        private ExceptionDetail exception;
        private ExceptionDetail innerException;
        private Object payload;
        private boolean isUiRequired;

        private MsalMobileResult(@NonNull Exception ex) {
            isSuccess = false;
            exception = new ExceptionDetail(ex);
            if (ex.getCause() != null) {
                innerException = new ExceptionDetail(ex.getCause());
            }
        }

        private MsalMobileResult(@NonNull Object successPayload) {
            isSuccess = true;
            payload = successPayload;
        }

        static String success(@NonNull final Object successPayload) {
            MsalMobileResult result = new MsalMobileResult(successPayload);
            return result.toJson();
        }

        static String error(@NonNull final Exception ex) {
            MsalMobileResult result = new MsalMobileResult(ex);
            return result.toJson();
        }

        static String uiRequiredError(@NonNull final Exception ex) {
            MsalMobileResult result = new MsalMobileResult(ex);
            result.isUiRequired = true;
            return result.toJson();
        }

        private String toJson() {
            Gson gson = new Gson();
            return gson.toJson(this);
        }
    }

    static class ExceptionDetail {
        private String message;
        private String errorCode;

        ExceptionDetail(@NonNull final Throwable throwable) {
            init(throwable);
        }

        ExceptionDetail(@NonNull final Exception exception) {
            init(exception);
        }

        private void init(@NonNull final Throwable throwable) {
            message = throwable.getMessage();

            if (throwable instanceof MsalException) {
                final MsalException ex = (MsalException) throwable;
                errorCode = ex.getErrorCode();
            } else if (throwable instanceof MsalMobileException) {
                final MsalMobileException ex = (MsalMobileException) throwable;
                errorCode = ex.getErrorCode();
            }
        }
    }
}
