<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "title">
    ${message.summary}
    <#elseif section = "form">
    <div class="fullpage-background-image">
        <div class="container-wrapper">
            <div>
                <div id="kc-info-message">
                    <p class="instruction">${message.summary}</p>
                    <#if skipLink??>
                    <#else>
                    <p><a onclick="javascript:backToApplication()" class="sb-btn sb-btn-normal sb-btn-outline-primary mt-16 line-height-normal">${msg("backToApplication")}</a></p>
                    </#if>
                </div>
            </div>
        </div>
    </div>
    </#if>
</@layout.registrationLayout>