<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
<#if section = "title">
    ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
    <#elseif section = "form">
    <#if realm.password>
    <div class="fullpage-background-image">
    <div class="container-wrapper">
                <div class="ui header centered mb-8">
                    <img onerror="" alt="">
                    <div id="signIn" class="signInHead mt-8 mb-8">${msg("loginDiksha")}</div>
                    <p class="subtitle">Login</p>
                </div>
                <p id="mergeAccountMessage" class="hide mb-0 textCenter">${msg("mergeAccountMessage")}</p>
                <p id="migrateAccountMessage" class="hide mb-0 textCenter">${msg("migrateAccountMessage")}</p>
                <div class="formMsg textCenter mt-8">
                <#if message?has_content>
                    <div id="error-summary" class="ui text ${message.type}">
                        ${message.summary}
                    </div>
                    </#if>
                    <div id="success-msg" class="ui text success hide">suceess</div>
                    <div id="error-msg" class="ui text error hide">error</div>
                </div>
                <form id="kc-form-login"  onsubmit="login.disabled = true; return true;" class="ui form mt-16" method="POST" action="${url.loginAction}">
                    <div class="field">
                        <label id="usernameLabel" for="username" class="">
                            <#if !realm.loginWithEmailAllowed>${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>${msg("emailOrPhone")}
                            <#else>${msg("email")}
                            </#if>
                        </label>
                        <label id="usernameLabelPlaceholder" for="username" class="activeLabelColor hide">
                            <#if !realm.loginWithEmailAllowed>${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>${msg("placeholderForEmailOrPhone")}
                            <#else>${msg("email")}
                            </#if>
                        </label>
                         <#if usernameEditDisabled??>
                         <#-- TODO: need to find alternative for prepopulating username -->
                        <input class="mt-8" id="username" name="username" placeholder="Enter your email / mobile number" type="text" disabled />
                        <#else>
                        <input class="mt-8" id="username" name="username" placeholder="Enter your email / mobile number" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>
                    <div class="field mb-8">
                        <div>
                            <label id="passwordLabel" for="password" class="">
                                ${msg("password")}
                            </label>

                            <label id="passwordLabelPlaceholder" for="password" class="activeLabelColor hide">
                                ${msg("placeholderForPassword")}
                            </label>
                        </div>
                        <input placeholder="${msg('passwordPlaceholder')}" class=" mt-8" id="password" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" name="password" type="password" autocomplete="off" />
                    <span class="ui text error hide" id="inCorrectPasswordError">${msg("inCorrectPasswordError")}</span>
                    </div>
                    <div class="remember-forgot-row">
                    <div class="sb-checkbox sb-checkbox-secondary hide">
                        <input type="checkbox" id="rememberme" name="rememberme">
                        <label for="rememberme">Remember Me</label>
                    </div>
                    <div class="forgot-password">
                      <#if realm.resetPasswordAllowed>
                        <a id="fgtKeycloakFlow" class="ui right floated forgetPasswordLink hide" tabindex="1" onclick="javascript:storeLocation(); javascript:makeDivUnclickable(); javascript:storeForgotPasswordLocation(event);" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                        <div id="fgtPortalFlow" class="ui right floated forgetPasswordLink hide" tabindex="1" onclick="javascript:makeDivUnclickable(); javascript:createTelemetryEvent(event); javascript:forgetPassword('/recover/identify/account');">${msg("doForgotPassword")}</div>
                      </#if>
                    </div>
                    </div>

                    <div class="field mb-8">
                        <button id="login" onclick="doLogin(event)" class="mt-24 sb-btn sb-btn-normal sb-btn-primary width-100">${msg("login")}</button>
                    </div>
                  <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                    <div id="kc-registration" class="field">
                                <div class="ui content signUpMsg">
                                    ${msg("noAccount")} <span id="signup" tabindex="0" class="registerLink" onclick=navigate('self')>${msg("registerHere")}</span>
                                </div>
                    </div>
                  </#if>
                    <div id="selfSingUp" class="hide">
                        <p class="or my-16 textCenter">OR</p>
                        <div class="field">
                            <#if realm.password && social.providers??>
                                <!--div id="kc-social-providers">
                                    <#list social.providers as p>
                                    <a href="${p.loginUrl}" id="zocial-${p.alias}" class="zocial ${p.providerId} ui fluid blue basic button textCenter">
                                    <i class="icon signInWithGoogle"></i>${msg("doSignIn")} ${msg("doSignWithGoogle")}
                                    </a>
                                    </#list>
                                </div-->
                            </#if>
                            <button type="button" class="sb-btn sb-btn-normal sb-btn-primary width-100 mb-16 btn-signInWithGoogle" onclick="navigate('google')">
                            <img class="signInWithGoogle" src="${url.resourcesPath}/img/google.svg">
                            ${msg("signIn")} ${msg("doSignWithGoogle")}
                            </button>
                            <button type="button" id="stateButton" class="sb-btn sb-btn-outline-gray sb-btn-normal width-100" onclick="navigate('state')">
                                ${msg("doSignWithState")}
                            </button>
                        </div>
                    </div>
                </form>
                <a id="goBack" class="textCenter mt-16 hide cursor-pointer">${msg("goBack")}</a>
            <!-- <button id="goBack" class="sb-btn sb-btn-normal sb-btn-link sb-btn-link-primary back-btn hide" type="button">
            <img src="${url.resourcesPath}/img/arrow_back.png" width="12" /> <span class="ml-4">${msg("goBack")}</span>
                </button> -->
    </div>
    </div>
    </#if>
</#if>
</@layout.registrationLayout>