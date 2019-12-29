package com.gbwisx.msal_mobile;

import com.microsoft.identity.client.IAccount;
import com.microsoft.identity.client.IAuthenticationResult;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

public class Payloads {
    static interface MsalMobileResultPayload {}

    static class GetAccountResultPayload implements MsalMobileResultPayload {
        private Payloads.Account currentAccount;
        private boolean accountLoaded;

        GetAccountResultPayload(IAccount currentMsalAccount) {
            accountLoaded = true;
            if (currentMsalAccount != null) {
                currentAccount = new Payloads.Account(currentMsalAccount.getTenantId(), currentMsalAccount.getClaims(), currentMsalAccount.getAuthority(), currentMsalAccount.getId(), currentMsalAccount.getUsername());
            }
        }
    }

    static class Account {
        private String tenantId;
        private Map<String, ?> claims;
        private String authority;
        private String id;
        private String username;

        Account(String accountTenantId, Map<String, ?> accountClaims, String accountAuthority, String accountId, String accountUsername) {
            tenantId = accountTenantId;
            claims = accountClaims;
            authority = accountAuthority;
            id = accountId;
            username = accountUsername;
        }
    }

    static class AuthenticationResultPayload implements MsalMobileResultPayload {
        private boolean cancelled;
        private boolean success;
        private String accessToken;
        private String tenantId;
        private String[] scope;
        private String expiresOn;

        private AuthenticationResultPayload(final boolean authSuccessful, final boolean authCancelled, final String authAccessToken) {
            success = authSuccessful;
            cancelled = authCancelled;
            accessToken = authAccessToken;
        }

        private AuthenticationResultPayload(IAuthenticationResult result) {
            success = true;
            cancelled = false;
            accessToken = result.getAccessToken();
            tenantId = result.getTenantId();
            scope = result.getScope();

            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            expiresOn = formatter.format(result.getExpiresOn());
        }

        static AuthenticationResultPayload success(IAuthenticationResult result) {
            return new AuthenticationResultPayload(result);
        }

        static AuthenticationResultPayload cancelled() {
            return new AuthenticationResultPayload(false, true, null);
        }
    }
}
