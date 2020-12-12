## 0.0.1

* Allow for single client authentication via MSAL
* Android and iOS platform implementations
* APIs include: sign in, sign out, acquire token interactive and silent, get active account

## 0.0.2

* code formatting updates

## 0.1.0

* beta release

## 0.1.1

* bug fixes

## 0.1.2

* bug fixes

## 0.1.3

* update dependencies

## 0.1.4

* New documentation on setting up Azure delegated permissions

## 1.0.0

* Add ability to specify a login hint to MSAL when acquiring a token
> **_NOTE:_** Version 1.0.0 contains a breaking change to the MSAL Mobile ready callback. MSAL Mobile's create function no longer returns a future.  Instead it returns an authentication interface that exposes an isReady future property.\
\
The following:\
`MsalMobile.create('assets/auth_config.json', authority).then((client) { ... });`
\
\
Now becomes:\
`IAuthenticator authenticator = MsalMobile.create('assets/auth_config.json', authority);
authenticator.isReady.then((client) { ... });
`