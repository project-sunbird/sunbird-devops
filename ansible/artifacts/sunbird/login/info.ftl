<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        <#if messageHeader??>
        <#-- ${messageHeader} -->
        <#else>
        <#-- ${message.summary} -->
        </#if>
    <#elseif section = "form">
        <div class="fullpage-background-image">
          <div class="container-wrapper">
            <div id="kc-info-message">
<!--           <p class="instruction">${message.summary}<#if requiredActions??><#list requiredActions>: <b><#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#items></b></#list><#else></#if></p> -->
             <#if skipLink??>
             <#else>
               <#if pageRedirectUri??>
                 <p><a href="${pageRedirectUri}" class="sb-btn sb-btn-normal sb-btn-outline-primary mt-16 line-height-normal">${kcSanitize(msg("backToApplication"))?no_esc}</a></p>
               <#elseif actionUri??>
                 <div class="ui text active centered inline large loader">Loading.. Please wait..</div>
                 <div id="kc-info-message-hide" style="display:none">
                   <p><a id="click-here-to-proceed" href="${actionUri}">${kcSanitize(msg("proceedWithAction"))?no_esc}</a></p>
                   <script type="text/javascript">
                     window.onload = function(){
                       function autoClick() {
                         document.getElementById("click-here-to-proceed").click();
                       }
                     setInterval(autoClick, 500);
                     }
                   </script>
                 </div>
               <#elseif client.baseUrl??>
                 <p><a href="${client.baseUrl}" class="sb-btn sb-btn-normal sb-btn-outline-primary mt-16 line-height-normal">${kcSanitize(msg("backToApplication"))?no_esc}</a></p>
               </#if>
             </#if>
          </div>
        </div>
      </div>
    </#if>
</@layout.registrationLayout>
