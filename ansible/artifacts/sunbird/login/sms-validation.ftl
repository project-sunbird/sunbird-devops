<#import "template.ftl" as layout>
    <@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTitle",realm.displayName)}
    <#elseif section = "form">
    <div class="ui raised shadow container segment fullpage-background-image">
        <div class="ui three column grid stackable">
            <div class="ui column tablet only computer only"></div>
            <div class="ui column height-fix">
                <div class="ui header centered">
                    <img onerror="" alt="">
                    <div class="signInHead mt-27">${msg("emailForgotTitle")}</div>
                </div>
                <div class="ui content textCenter mb-28">
                    ${msg("enterCode")}
                </div>
                <div class="ui content textCenter mt-8 mb-28">
                    <#if message?has_content>
                    <div class="ui text ${message.type}">
                        ${message.summary}
                    </div>
                    </#if>
                </div>
                <form id="kc-totp-login-form" class="${properties.kcFormClass!} ui form pre-signin" action="${url.loginAction}" method="post">
                    <div class="field">
                        <input id="totp" name="smsCode" type="text" class="mb-28 smsinput" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)"/>
                    </div>
                    <div class="field">
                        <button onclick="javascript:makeDivUnclickable()" class="ui fluid submit button" name="login" id="login" type="submit" value="${msg("doLogIn")}">${msg("doSubmit")}</button>
                    </div>
                </form>
                <#if client?? && client.baseUrl?has_content>
                    <div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-45 textCenter">
                        <span>
                            <a id="backToApplication" onclick="javascript:makeDivUnclickable()" class="backToLogin" href="${client.baseUrl}">
                                <span class="fs-14"><< </span>${msg("backToApplication")}
                            </a>
                        </span>
                    </div>
                </#if>
            </div>
            <div class="ui column tablet only computer only"></div>
        </div>
    </div>
    </#if>
</@layout.registrationLayout>
