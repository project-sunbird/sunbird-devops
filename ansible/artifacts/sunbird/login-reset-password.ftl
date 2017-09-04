<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "header">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
        <div class="page-login">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
            <div class="ui centered grid container">
                <div class="ten wide column signInGridAlign">
                    <div class="ui fluid card">
                        <div class="ui">
                            <h2 class="ui header">${msg("emailForgotTitle")}</h2>
                        </div>
                        <div class="content signin-contentPadding">
                            <form id="kc-reset-password-form" class="ui form pre-signin" action="${url.loginAction}" method="post">
                            <div class="field">
                                <label for="username"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                                <input type="text" id="username" name="username" autofocus/>
                            </div>

                            <div class="ui grid margin-top2em">
                                <div id="kc-form-options">
                                    <div class="${properties.kcFormOptionsWrapperClass!}">
                                        <span><a href="${url.loginUrl}">${msg("backToLogin")}</a></span>
                                    </div>
                                </div>

                                <div id="kc-form-buttons">
                                    <button class="ui primary right floated button buttonResizeClass" type="submit">${msg("doSubmit")}</button>
                                </div>
                            </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    <#elseif section = "info" >
        ${msg("emailInstruction")}
    </#if>
</@layout.registrationLayout>