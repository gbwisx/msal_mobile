package com.gbwisx.msal_mobile;

import com.microsoft.identity.client.exception.MsalException;

public interface AuthenticatorInitCallback {
    void onSuccess();
    void onError(MsalException exception);
}