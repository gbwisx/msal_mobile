package com.gbwisx.msal_mobile;

class MsalMobileException extends Exception {
    private String mErrorCode;

    String getErrorCode() {
        return mErrorCode;
    }

    MsalMobileException(String errorCode, String message) {
        super(message);
        mErrorCode = errorCode;
    }
}
