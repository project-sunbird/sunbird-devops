<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("pageExpiredTitle")}
    <#elseif section = "form">
     <div class="fullpage-background-image">
        <div class="container-wrapper">
			<div id="instruction1" class="instruction textCenter">
            <p>${msg("pageExpiredMsg1")} <br>
                <a id="loginRestartLink" class="sb-btn sb-btn-normal sb-btn-outline-primary mt-16 line-height-normal" href="${url.loginRestartFlowUrl}">${msg("doClickHere")}</a></p>
				<p class="mt-16">
                ${msg("pageExpiredMsg2")} <br>
                <a id="loginContinueLink" class="sb-btn sb-btn-normal sb-btn-outline-primary mt-16 line-height-normal" href="${url.loginAction}">${msg("doClickHere")}</a>
                </p>
			</div>
		</div>
    </#if>
</@layout.registrationLayout>
