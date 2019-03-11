<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("pageExpiredTitle")}
    <#elseif section = "form">
     <div class="ui raised shadow container segment fullpage-background-image">
        <div class="ui three column grid stackable">
            <div class="ui column tablet only computer only"></div>
            <div class="ui column mt-127 height-fix">
			<p id="instruction1" class="instruction">
				${msg("pageExpiredMsg1")} <a id="loginRestartLink" href="${url.loginRestartFlowUrl}">${msg("doClickHere")}</a>.
				${msg("pageExpiredMsg2")} <a id="loginContinueLink" href="${url.loginAction}">${msg("doClickHere")}</a>.
			</p>
			</div>
			<div class="ui column tablet only computer only"></div>
		</div>
    </#if>
</@layout.registrationLayout>
