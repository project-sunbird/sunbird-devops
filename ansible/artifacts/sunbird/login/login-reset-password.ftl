<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <div class="ui raised shadow container segment fullpage-background-image">
        <div class="ui three column grid stackable">
            <div class="ui column tablet only computer only"></div>
            <div class="ui column height-fix">
                <div class="ui header centered">
                    <img onerror="" alt="">
                    <div class="signInHead mt-27">${msg("emailForgotTitle")}</div>
                </div>
                <div class="ui content center justfy textCenter">
                    ${msg("enterEmailPhonenumberToGetCode")}
                </div>
                <div class="ui content center justfy textCenter mt-8 mb-28">
                    <#if message?has_content>
                        <div class="ui text ${message.type}">
                            ${message.summary}
                        </div>
                    </#if>
                </div>
                <form id="kc-reset-password-form" class="ui form" method="POST" action="${url.loginAction}">
                    <div class="field mb-36">
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
                        <button id="login" class="ui fluid submit button">
                        ${msg("doReset")}
                        </button>
                    </div>
                </form>
                <div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-45 textCenter">
                    <span><a id="versionLink" class="backToLogin" onclick="javascript:makeDivUnclickable()" href="${url.loginUrl}"><span class="fs-14"><< </span> ${msg("backToLogin")}</a></span>
                </div>
            </div>
            <div class="ui column tablet only computer only"></div>
        </div>
    </div>
    <#elseif section = "info" >
    </#if>
</@layout.registrationLayout>
