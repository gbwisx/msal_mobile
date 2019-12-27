package com.gbwisx.msal_mobile;

import android.app.Activity;

import com.microsoft.identity.client.AuthenticationCallback;
import com.microsoft.identity.client.IPublicClientApplication;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.CurrentAccountCallback;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.SignOutCallback;
import com.microsoft.identity.client.PublicClientApplication;
import com.microsoft.identity.client.SilentAuthenticationCallback;
import com.microsoft.identity.client.exception.MsalException;

import java.io.File;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

class Authenticator {
    private ISingleAccountPublicClientApplication mClient;
    private Activity mActivity;

    void init(@NonNull Activity activity, @NonNull final String configFilePath, @NonNull final AuthenticatorInitCallback callback) {
        mActivity = activity;
        final File configFile = new File(configFilePath);
        PublicClientApplication.createSingleAccountPublicClientApplication(activity.getApplicationContext(), configFile, new IPublicClientApplication.ISingleAccountApplicationCreatedListener() {
            @Override
            public void onCreated(ISingleAccountPublicClientApplication application) {
                mClient = application;
                callback.onSuccess();
            }

            @Override
            public void onError(MsalException exception) {
                callback.onError(exception);
            }
        });
    }

    void getAccount(@NonNull final CurrentAccountCallback callback) {
        mClient.getCurrentAccountAsync(callback);
    }

    void signIn(@NonNull final String[] scopes, @Nullable final String loginHint, @NonNull AuthenticationCallback callback) {
        mClient.signIn(mActivity, loginHint, scopes, callback);
    }

    void signOut(@NonNull SignOutCallback callback) {
        mClient.signOut(callback);
    }

    void acquireToken(@NonNull final String[] scopes, @NonNull final AuthenticationCallback callback) {
        mClient.acquireToken(mActivity, scopes, callback);
    }

    void acquireTokenSilent(@NonNull final String[] scopes, @NonNull final String authority, @NonNull final SilentAuthenticationCallback callback) {
        mClient.acquireTokenSilentAsync(scopes, authority, callback);
    }
}