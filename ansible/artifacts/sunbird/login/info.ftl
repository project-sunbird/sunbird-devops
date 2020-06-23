<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "title">
    ${message.summary}
    <#elseif section = "form">
    <div class="ui raised shadow container segment fullpage-background-image">
        <div class="ui three column grid stackable">
            <div class="ui column tablet only computer only"></div>
            <div class="ui column height-fix">
                <div id="kc-info-message">
                    <p class="instruction">${message.summary}</p>
                    <#if skipLink??>
                    <#else>
                        <p><a onclick="javascript:backToApplication()">${msg("backToApplication")}</a></p>
                    </#if>
                </div>
            </div>
            <div class="ui column tablet only computer only"></div>
        </div>
    </div>
    </#if>
</@layout.registrationLayout>