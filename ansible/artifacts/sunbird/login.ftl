<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))}
    <#elseif section = "form">
        <#if realm.password>
            <div class="page-login">
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
              <div class="ui centered grid container">
                <div class="ten wide column signInGridAlign">
                  <div class="ui fluid card">
                    <div class="ui centered medium image signInLogo margin-top3em">
                        <img src="${url.resourcesPath}/img/logo.png">
                    </div>
                    <div class="ui basic segment">
                        <h2 class="ui header">${msg("loginTitle",(realm.displayName!''))}</h2>
                    </div>
                    <div class="content signin-contentPadding">
                        <form id="kc-form-login" class="ui form pre-signin" method="POST" action="${url.loginAction}">
                            <div class="field">
                                <label for="username"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmailOrPhone")}<#else>${msg("email")}</#if></label>
                                <#if usernameEditDisabled??>
                                    <input id="username" name="username" value="${(login.username!'')?html}" type="text" disabled />
                                <#else>
                                    <input id="username" name="username" value="${(login.username!'')?html}" type="text" autofocus autocomplete="off" />
                                </#if>
                            </div>
                            <div class="field">
                                <label for="password">${msg("password")}</label>
                                <input id="password" name="password" type="password" autocomplete="off" />
                            </div>
                            <div class="ui grid margin-top2em">
                                <div class="six wide column">
                                    <div class="forgot-passwordText">
                                        <#if realm.resetPasswordAllowed>
                                        <span><a onclick="javascript:makeDivUnclickable()" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                                        </#if>
                                    </div>
                                </div>
                                <div class="six wide column">
                                    <button class="ui primary right floated button buttonResizeClass" name="login" id="kc-login" onclick="javascript:makeDivUnclickable()" type="submit">${msg("doLogIn")}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
        </#if>
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
            <div id="kc-registration">
                <span>${msg("noAccount")} <a href="${url.registrationUrl}">${msg("doRegister")}</a></span>
            </div>
        </#if>

        <#if realm.password && social.providers??>
            <div id="kc-social-providers">
                <ul>
                    <#list social.providers as p>
                        <li><a href="${p.loginUrl}" id="zocial-${p.alias}" class="zocial ${p.providerId}"> <span class="text">${p.displayName}</span></a></li>
                    </#list>
                </ul>
            </div>
        </#if>
    </#if>
</@layout.registrationLayout>
