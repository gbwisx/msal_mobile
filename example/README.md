# msal_mobile_example

Be sure to check out the README one level up for a comprehensive overview of the MSAL Mobile plugin and how to install it.

## Example project configuration
To run the example project, do the following:

1. Open **lib > main.dart**. Update the `SCOPE` constant to be the name of the scope you are requesting from Azure AD.
2. Update the `TENANT_ID` to be `Organizations` for multiple tenants or a specific tenant id to allow login only from users of a specific tenant.
3. Open **android > app > src > main > AndroidManifest.xml** and make the following changes to the BrowserTabActivity **\<activity\>** section:
    * Change the value of `android:host` to be the name of your Android package.
    * Change the value of `android:path` to be your Android signature hash used during Azure app registration setup. Note: this value should be prefixed with a `/`
4. Open **assets > auth_config.json** and make the following changes:
    * Update `client_id` to be the client id/application id of your Azure app registration.
    * Update the `redirect_uri` to be redirect uri listed on the Android platform in the **Authentication** section of your Azure app registration.
    * Update the `ios_redirect_uri` to be the redirect uri listed on the iOS/macOS platform in the **Authentication** section of your Azure app registration.
    * In the authority section, update `tenant_id` to be the same tenant id that you set in main.dart.
    * In the authority section, update `type` to an MSAL authority type that suits your use case.
    * More on MSAL configuration file customization can be found at https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-configuration
    ```json
    {
        "client_id" : "<app-registration-client-id>",
        "authorization_user_agent" : "DEFAULT",
        "redirect_uri" : "msauth://<your-package-name>/<url-encoded-package-signature-hash>",
        "ios_redirect_uri": "msauth.<your-ios-bundle-identifier>://auth",
        "account_mode": "SINGLE",
        "authorities" : [
            {
                "type": "AAD",
                "audience": {
                "type": "AzureADMyOrg",
                "tenant_id": "organizations"
                }
            }
        ],
            "logging": {
            "pii_enabled": false
        }
    }
    ```