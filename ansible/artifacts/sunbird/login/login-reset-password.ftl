<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <div class="fullpage-background-image">
        <div class="container-wrapper">
                <div class="ui header centered mb-8">
                    <img onerror="" alt="">
                    <div class="signInHead">${msg("emailForgotTitle")}</div>
                </div>
                <div class="ui content center justfy textCenter mt-24">
                    ${msg("enterEmailPhonenumberToGetCode")}
                </div>
                <div class="ui content center justfy textCenter mt-8 mb-16">
                    <#if message?has_content>
                        <div class="ui text ${message.type}">
                            ${message.summary}
                        </div>
                    </#if>
                </div>
                <form id="kc-reset-password-form" class="ui form" method="POST" action="${url.loginAction}">
                    <div class="field mb-24">
                        <label id="usernameLabel" for="username" class="">
                            <#if !realm.loginWithEmailAllowed>
                                ${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>
                                ${msg("emailOrPhone")}
                            <#else>${msg("email")}
                            </#if>
                        </label>
                        <label id="usernameLabelPlaceholder" for="username" class="activeLabelColor hide">
                            <#if !realm.loginWithEmailAllowed>${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>${msg("placeholderForEmailOrPhone")}
                            <#else>${msg("email")}
                            </#if>
                        </label>
                        <input type="text" id="username" class="mt-8" name="username" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" autofocus/>
                    </div>
                    <div class="field">
                        <button id="login" onclick="javascript:makeDivUnclickable()" class="sb-btn sb-btn-normal sb-btn-primary width-100">
                        ${msg("doReset")}
                        </button>
                    </div>
                </form>
                <div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-24 textCenter">
                   <a id="versionLink" class="sb-btn sb-btn-normal sb-btn-outline-primary" onclick="javascript:makeDivUnclickable()" href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
        </div>
    </div>
    <#elseif section = "info" >
    </#if>
</@layout.registrationLayout>
