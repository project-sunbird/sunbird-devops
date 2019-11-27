<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
<#ftl autoesc=false>
<#if section = "title">
    ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
    <#elseif section = "form">
    <#if realm.password>
    <div class="ui raised shadow container segment fullpage-background-image">
        <div class="ui three column grid stackable">
            <div class="ui column tablet only computer only"></div>
            <div class="ui column height-fix">
                <div class="ui header centered">
                    <img onerror="" alt="">
                    <div id="signIn" class="signInHead mt-27">${msg("loginDiksha")}</div>
                </div>
                <p id="mergeAccountMessage" class="hide mb-0 textCenter">${msg("mergeAccountMessage")}</p>
                <p id="migrateAccountMessage" class="hide mb-0 textCenter">${msg("migrateAccountMessage")}</p>
                <div class="formMsg mb-28 textCenter">
                <#if message?has_content>
                    <div id="error-summary" class="ui text ${message.type}">
                        ${message.summary}
                    </div>
                    </#if>
                    <div id="success-msg" class="ui text success hide">suceess</div>
                    <div id="error-msg" class="ui text error hide">error</div>
                </div>
                <form id="kc-form-login" onsubmit="login.disabled = true; return true;" class="ui form" method="POST" action="${url.loginAction}">
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
                        <#ftl autoesc=false>
                        <#if usernameEditDisabled??>
                        <input placeholder="${msg('usernamePlaceholder')}" class="mt-8" id="username" name="username" value="${(login.username!'')?html}" type="text" disabled />
                        <#else>
                        <input placeholder="${msg('usernamePlaceholder')}" class="mt-8" id="username" name="username" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" value="${(login.username!'')?html}" type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>
                    <div class="field">
                        <div>
                            <label id="passwordLabel" for="password" class="">
                                ${msg("password")}
                            </label>
                            <#if realm.resetPasswordAllowed>
                                <a id="fgtKeycloakFlow" class="ui right floated forgetPasswordLink hide" tabindex="1" onclick="javascript:storeLocation(); javascript:makeDivUnclickable()" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                                <div id="fgtPortalFlow" class="ui right floated forgetPasswordLink hide" tabindex="1" onclick="javascript:redirect('/recover/identify/account');javascript:makeDivUnclickable()">${msg("doForgotPassword")}</div>
                            </#if>
                            <label id="passwordLabelPlaceholder" for="password" class="activeLabelColor hide">
                                ${msg("placeholderForPassword")}
                            </label>
                        </div>
                        <input placeholder="${msg('passwordPlaceholder')}" class=" mt-8" id="password" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" name="password" type="password" autocomplete="off" />
                    <span class="ui text error hide" id="inCorrectPasswordError">${msg("inCorrectPasswordError")}</span>
                    </div>
                    <div class="field">
                        <button id="login" class="mt-16 sb-btn sb-btn-normal sb-btn-primary width-100">${msg("doLogIn")}</button>
                    </div>

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
							<button type="button" id="stateButton" class="sb-btn sb-btn-normal sb-btn-success width-100 mb-16" onclick="navigate('state')">
								${msg("doSignWithState")}
							</button>
                            <button type="button" class="sb-btn sb-btn-normal sb-btn-outline-primary width-100 d-flex flex-ai-center flex-jc-center" onclick="navigate('google')">
                            <img class="signInWithGoogle" src="${url.resourcesPath}/img/google.png">
                            ${msg("doLogIn")} ${msg("doSignWithGoogle")}
                            </button>
                        </div>
                        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                            <div id="kc-registration" class="field">
                                <div class="ui content signUpMsg">
                                    ${msg("noAccount")} <span id="signup" tabindex="0" class="registerLink" onclick=navigate('self')>${msg("registerHere")}</span>
                                </div>
                            </div>
                        </#if>
                    </div>
                </form>
                 <a id="goBack" class="textCenter mt-16 hide cursor-pointer">${msg("goBack")}</a>
            </div>
            <div class="ui column tablet only computer only"></div>
        </div>
    </div>
    </#if>
</#if>
</@layout.registrationLayout>
