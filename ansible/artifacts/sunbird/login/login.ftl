<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
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
                    <div class="signInHead mt-27">${msg("doSignIn")}</div>
                </div>
                <div class="formMsg mb-28 textCenter">
                <#if message?has_content>
                    <div class="ui text ${message.type}">
                        ${message.summary}
                    </div>
                    </#if>
                    <div id="success-msg" class="ui text success hide">suceess</div>
                    <div id="error-msg" class="ui text error hide">error</div>
                </div>
                <form id="kc-form-login" class="ui form" method="POST" action="${url.loginAction}">
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
                        <input class="mt-8" id="username" name="username" value="${(login.username!'')?html}" type="text" disabled />
                        <#else>
                        <input class="mt-8" id="username" name="username" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" value="${(login.username!'')?html}" type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>
                    <div class="field">
                        <div>
                            <label id="passwordLabel" for="password" class="">
                                ${msg("password")}
                            </label>
                            <label id="passwordLabelPlaceholder" for="password" class="activeLabelColor hide">
                                ${msg("placeholderForPassword")}
                            </label>
                        </div>
                        <input class=" mt-8" id="password" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" name="password" type="password" autocomplete="off" />
                    </div>
                    <div class="field">
                        <button id="login" class="mt-36 ui fluid button">${msg("doSignIn")}</button>
                    </div>
                    <#if realm.resetPasswordAllowed>
                        <a id="versionLink" class="ui right floated forgetPasswordLink" onclick="javascript:storeLocation(); javascript:makeDivUnclickable()" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                    </#if>
                    <div id="selfSingUp" class="hide">
                        <p class="or mb-30 mt-30 textCenter">OR</p>
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
                            <button type="button" class="ui fluid blue basic button googleButton" onclick="redirect('/google/auth')">
                            <img class="signInWithGoogle" src="${url.resourcesPath}/img/google.png">
                            ${msg("doSignIn")} ${msg("doSignWithGoogle")}
                            </button>
							<button type="button" id="stateButton" class="ui fluid blue basic button googleButton stateButton hide" onclick="handleSsoEvent()">
								${msg("doSignWithState")}
							</button>
                        </div>
                        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                            <div id="kc-registration" class="field">
                                <div class="ui content signUpMsg">
                                    ${msg("noAccount")} <span id="signup" tabindex="0" class="registerLink" onclick="redirect('/signup')">${msg("doRegister")}</span> to access relevant learning material and enroll for courses.
                                </div>
                            </div>
                        </#if>
                    </div>
                </form>
            </div>
            <div class="ui column tablet only computer only"></div>
        </div>
    </div>
    </#if>
</#if>
</@layout.registrationLayout>
