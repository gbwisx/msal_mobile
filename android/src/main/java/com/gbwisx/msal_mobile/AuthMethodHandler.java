package com.gbwisx.msal_mobile;

import android.app.Activity;

import com.microsoft.identity.client.AuthenticationCallback;
import com.microsoft.identity.client.IAccount;
import com.microsoft.identity.client.IAuthenticationResult;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.SignOutCallback;
import com.microsoft.identity.client.SilentAuthenticationCallback;
import com.microsoft.identity.client.exception.MsalException;
import com.microsoft.identity.client.exception.MsalUiRequiredException;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class AuthMethodHandler implements MethodChannel.MethodCallHandler {
    private Activity mActivity;
    private Authenticator mAuth;

    void setActivity(@NonNull Activity activity) {
        mActivity = activity;
    }

    private void error(@NonNull Result result, @NonNull Exception exception) {
        // even though this is an error, success is returned because a success response allows for more detail to be sent back
        result.success(Results.MsalMobileResult.error(exception));
    }
    private void error(@NonNull Result result, @NonNull String errorCode, @NonNull String message) {
        final MsalMobileException exception = new MsalMobileException(errorCode, message);
        result.success(Results.MsalMobileResult.error(exception));
    }
    private void uiRequiredError(@NonNull Result result, @NonNull MsalUiRequiredException exception) {
        // even though this is an error, success is returned because a success response allows for more detail to be sent back
        result.success(Results.MsalMobileResult.uiRequiredError(exception));
    }
    private void success(@NonNull Result result, Payloads.MsalMobileResultPayload payload) {
        result.success(Results.MsalMobileResult.success(payload));
    }
    private void success(@NonNull Result result) {
        result.success(Results.MsalMobileResult.success(true));
    }

    private void handleInit(@NonNull final Result result, @Nullable final String configFilePath) {
        if (mActivity == null) {
            error(result, "no_activity", "No Android activity was found to bind MSAL to.");
            return;
        }
        mAuth = new Authenticator();
        mAuth.init(mActivity, configFilePath, new AuthenticatorInitCallback() {
            @Override
            public void onSuccess() {
                success(result);
            }

            @Override
            public void onError(MsalException exception) {
                error(result, exception);
            }
        });
    }

    private void handleGetAccount(@NonNull final Result result) {
        mAuth.getAccount(new ISingleAccountPublicClientApplication.CurrentAccountCallback() {
            @Override
            public void onAccountLoaded(@Nullable IAccount activeAccount) {
                success(result, new Payloads.GetAccountResultPayload(activeAccount));
            }

            @Override
            public void onAccountChanged(@Nullable IAccount priorAccount, @Nullable IAccount currentAccount) {
                success(result, new Payloads.GetAccountResultPayload(priorAccount, currentAccount));
            }

            @Override
            public void onError(@NonNull MsalException exception) {
                error(result, exception);
            }
        });
    }

    private void handleSignIn(@NonNull final Result result, @Nullable final String loginHint, @NonNull final String[] scopes) {
        mAuth.signIn(scopes, loginHint, new AuthenticationCallback() {
            @Override
            public void onCancel() {
                success(result, Payloads.AuthenticationResultPayload.cancelled());
            }

            @Override
            public void onSuccess(IAuthenticationResult authenticationResult) {
                success(result, Payloads.AuthenticationResultPayload.success(authenticationResult));
            }

            @Override
            public void onError(MsalException exception) {
                error(result, exception);
            }
        });
    }

    private void handleSignOut(@NonNull final Result result) {
        mAuth.signOut(new SignOutCallback() {
            @Override
            public void onSignOut() {
                success(result);
            }

            @Override
            public void onError(@NonNull MsalException exception) {
                error(result, exception);
            }
        });
    }

    private void handleAcquireToken(@NonNull final Result result, @NonNull String[] scopes) {
        mAuth.acquireToken(scopes, new AuthenticationCallback() {
            @Override
            public void onCancel() {
                success(result, Payloads.AuthenticationResultPayload.cancelled());
            }

            @Override
            public void onSuccess(IAuthenticationResult authenticationResult) {
                success(result, Payloads.AuthenticationResultPayload.success(authenticationResult));
            }

            @Override
            public void onError(MsalException exception) {
                error(result, exception);
            }
        });
    }

    private void handleAcquireTokenSilent(@NonNull final Result result, @NonNull String[] scopes, @Nullable final String authority) {
        mAuth.acquireTokenSilent(scopes, authority, new SilentAuthenticationCallback() {
            @Override
            public void onSuccess(IAuthenticationResult authenticationResult) {
                success(result, Payloads.AuthenticationResultPayload.success(authenticationResult));
            }

            @Override
            public void onError(MsalException exception) {
                if (exception instanceof MsalUiRequiredException) {
                    uiRequiredError(result, (MsalUiRequiredException) exception);
                } else {
                    error(result, exception);
                }
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            switch(call.method) {
                case "init": {
                    final String configFilePath = call.argument("configFilePath");
                    handleInit(result, configFilePath);
                    break;
                }
                case "getAccount": {
                    handleGetAccount(result);
                    break;
                }
                case "signIn": {
                    final String loginHint = call.argument("loginHint");
                    final ArrayList<String> scopesList = call.argument("scopes");
                    final String[] scopes = scopesList != null ? scopesList.toArray(new String[0]) : new String[0];
                    handleSignIn(result, loginHint, scopes);
                    break;
                }
                case "signOut": {
                    handleSignOut(result);
                    break;
                }
                case "acquireToken": {
                    final ArrayList<String> scopesList = call.argument("scopes");
                    final String[] scopes = scopesList != null ? scopesList.toArray(new String[0]) : new String[0];
                    handleAcquireToken(result, scopes);
                    break;
                }
                case "acquireTokenSilent": {
                    final ArrayList<String> scopesList = call.argument("scopes");
                    final String[] scopes = scopesList != null ? scopesList.toArray(new String[0]) : new String[0];
                    final String authority = call.argument("authority");
                    handleAcquireTokenSilent(result, scopes, authority);
                    break;
                }
                default: {
                    result.notImplemented();
                    break;
                }
            }
        } catch (Exception exception) {
            error(result, exception);
        }
    }
}
