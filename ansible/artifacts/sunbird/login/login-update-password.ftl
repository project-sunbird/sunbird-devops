<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("updatePasswordTitle")}
    <#elseif section = "form">
    <div class="fullpage-background-image">
        <div class="container-wrapper">
                <div class="ui header centered mb-18">
                    <img onerror="" alt="">
                    <div class="signInHead mt-27">${msg("newPasswordTitle")}</div>
                </div>
                <div class="ui content center justfy textCenter mb-24 loginupdate">
                    <#if message?has_content>
                        <div class="ui text ${message.type}">
                            ${message.summary}
                        </div>
                    </#if>
                </div>
                <form id="kc-passwd-update-form" class="ui form" action="${url.loginAction}" method="post">
                    <div class="field">
                        <label id="password-newLabel" for="password-new" class="">
                            ${msg("passwordNew")}
                        </label>
                        <label id="password-newLabelPlaceholder" for="password-new" class="activeLabelColor hide">
                            ${msg("passwordNew")}
                        </label>
                        <div class="ui search">
                            <div class="ui mt-8 icon input">
                                <input class="" type="password" id="password-new" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" name="password-new" autocomplete="new-password" onkeydown="javascript:validatePassword()"/>    
                                <i class="eye icon link" onclick="viewPassword(this)"></i>
                                <!--i id="preview-hide" class="eye slash icon hide link"></i-->
                            </div>
                            <div id="passwd-error-msg" class="ui text passwdchk">Your password must contain a minimum of 8 characters. It must include numerals, lower and upper case alphabets and special characters, without any spaces</div>
                        </div>
                    </div>
                    <div class="field">
                        <label id="password-confirmLabel" class="" for="password-confirm">
                            ${msg("passwordConfirm")}
                        </label>
                        <label id="password-confirmLabelPlaceholder" class="activeLabelColor hide" for="password-confirm">
                            ${msg("passwordConfirm")}
                        </label>
                        <input type="password" class="mt-8" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" id="password-confirm" name="password-confirm" autocomplete="new-password" onkeydown="javascript:matchPassword()"/>
                        <div id="passwd-match-error-msg" class="ui text confpasswderr hide">Passwords do not match</div>
                    </div>
                    <div class="field">
                        <button id="login" class="sb-btn sb-btn-normal sb-btn-primary width-100 mt-36" onclick="javascript:makeDivUnclickable()">
                            ${msg("doReset")}
                        </button>
                    </div>
                </form>
                <!--div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-45 textCenter">
                    <span>
                        <a class="backToLogin" onclick="javascript:makeDivUnclickable()" href="${url.loginUrl}">
                            <span class="fs-14"><< </span> ${msg("backToLogin")}
                        </a>
                    </span>
                 </div-->
        </div>
    </div>
    </#if>
</@layout.registrationLayout>
