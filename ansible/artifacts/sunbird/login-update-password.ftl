<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("updatePasswordTitle")}
    <#elseif section = "header">
        ${msg("updatePasswordTitle")}
    <#elseif section = "form">
        <div class="page-login">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
            <div class="ui centered grid container">
                <div class="ten wide column signInGridAlign">
                    <div class="ui fluid card">
                        <div class="ui centered medium image signInLogo margin-top3em">
                            <img src="${url.resourcesPath}/img/logo.png">
                        </div>
                        <div class="ui basic segment">
                            <h2 class="ui header">${msg("updatePasswordTitle")}</h2>
                        </div>
                        <div class="content signin-contentPadding">
                            <form id="kc-passwd-update-form" class="ui form pre-signin" action="${url.loginAction}" method="post">
                            <input type="text" readonly value="this is not a login form" style="display: none;">
                            <input type="password" readonly value="this is not a login form" style="display: none;">

                            <div class="field">
                                <label for="password-new">${msg("passwordNew")}</label>
                                <input type="password" id="password-new" name="password-new" autofocus autocomplete="off" />
                            </div>

                            <div class="field">
                                <label for="password-confirm" >${msg("passwordConfirm")}</label>
                                <input type="password" id="password-confirm" name="password-confirm" autocomplete="off" />
                            </div>

                            <div class="ui grid margin-top2em">
                                <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                                    <div class="${properties.kcFormOptionsWrapperClass!}">
                                    </div>
                                </div>

                                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                                    <button class="ui primary right floated button buttonResizeClass" type="submit">${msg("doSubmit")}</button>
                                </div>
                            </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
