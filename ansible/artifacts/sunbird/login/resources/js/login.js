function getQueryStringValue (key) {
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}

window.onload = function(){

	addVersionToURL();
	var error_message = (new URLSearchParams(window.location.search)).get('error_message');
	var success_message = (new URLSearchParams(window.location.search)).get('success_message');

	if(error_message){
		var error_msg = document.getElementById('error-msg');
		error_msg.className = error_msg.className.replace("hide","");
		error_msg.innerHTML = error_message;
	}else if(success_message){
		var success_msg = document.getElementById("success-msg");
		success_msg.className = success_msg.className.replace("hide","");
		success_msg.innerHTML = success_message;
	}
}

var storeLocation = function(){
	sessionStorage.setItem('url', window.location.href);
}

var addVersionToURL = function (){
	var version = getQueryStringValue("version");
	
	if (version == 1 || version == 2){
		
		var selfSingUp = document.getElementById("selfSingUp");
		
		if(selfSingUp) {
			selfSingUp.className = selfSingUp.className.replace(/\bhide\b/g, "");
		}
		
		var stateButton = document.getElementById("stateButton");

		if (version == 2 && stateButton) {
			stateButton.className = stateButton.className.replace(/\bhide\b/g, "");
		}

		var versionLink = document.getElementById("versionLink");
		
		if(versionLink){
			versionLink.href = versionLink.href + '&version=' + version ;
		}
	}
	
}
var makeDivUnclickable = function() {
	var containerElement = document.getElementById('kc-form');
	var overlayEle = document.getElementById('kc-form-wrapper');
	overlayEle.style.display = 'block';
	containerElement.setAttribute('class', 'unClickable');
};

var inputBoxFocusIn = function(currentElement){
	if(currentElement.id !== 'totp'){
		var placeholderElement = document.querySelector("label[id='"+currentElement.id+"LabelPlaceholder']");
		var labelElement = document.querySelector("label[id='"+currentElement.id+"Label']");
		placeholderElement.className = placeholderElement.className.replace("hide", "");
		addClass(labelElement,"hide");
	}
};
var inputBoxFocusOut = function(currentElement){
	if(currentElement.id !== 'totp'){
		var placeholderElement = document.querySelector("label[id='"+currentElement.id+"LabelPlaceholder']");
		var labelElement = document.querySelector("label[id='"+currentElement.id+"Label']");
		labelElement.className = labelElement.className.replace("hide", "");
		addClass(placeholderElement,"hide");
	}
};

function addClass(element,classname)
{
	var arr;
  	arr = element.className.split(" ");
  	if (arr.indexOf(classname) == -1) {
    	element.className += " " + classname;
	}
}
const redirect  = (redirectUrlPath) => {
	const curUrlObj = window.location;
	var redirect_uri = (new URLSearchParams(curUrlObj.search)).get('redirect_uri');
	var client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
	const sessionUrl = sessionStorage.getItem('url');
	if (redirect_uri) {
		const updatedQuery = curUrlObj.search + '&error_callback=' + curUrlObj.href.split('?')[0];
		const redirect_uriLocation = new URL(redirect_uri);
		sessionStorage.setItem('url', window.location.href);
		
		if(client_id === 'android'){
            window.location.href = curUrlObj.protocol + '//' + curUrlObj.host + redirectUrlPath + updatedQuery;
		}
		else
		{
			window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + redirectUrlPath + updatedQuery;
		}
	} else if (sessionUrl) {
		const sessionUrlObj = new URL(sessionUrl);
		const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
		redirect_uri = (new URLSearchParams(sessionUrlObj.search)).get('redirect_uri');
		client_id = (new URLSearchParams(sessionUrlObj.search)).get('client_id');

		if (redirect_uri) {
			const redirect_uriLocation = new URL(redirect_uri);
			if(client_id === 'android'){
				window.location.href = sessionUrlObj.protocol + '//' + sessionUrlObj.host + redirectUrlPath + updatedQuery;
			}
			else{
				window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host +
				redirectUrlPath + updatedQuery;
			}
		} else {
			redirectToLib();
		}
	} else {
		redirectToLib();
	}
};
const redirectToLib = () => {
	window.location.href = window.location.protocol + '//' + window.location.host + '/resource';
};

const viewPassword = function(previewButton){
	console.log('Show Password');

	var newPassword = document.getElementById("password-new");
  	if (newPassword.type === "password") {
		newPassword.type = "text";
		addClass(previewButton,"slash");
  	} else {
		newPassword.type = "password";
		previewButton.className = previewButton.className.replace("slash","");
  	}
}
const handleSsoEvent  = () => {
  const ssoPath = '/sign-in/sso/select-org';
  const curUrlObj = window.location;
  let redirect_uri = (new URLSearchParams(curUrlObj.search)).get('redirect_uri');
  let client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
  const sessionUrl = sessionStorage.getItem('url');
  if (redirect_uri) {
    const redirect_uriLocation = new URL(redirect_uri);
    sessionStorage.setItem('url', window.location.href);
    if (client_id === 'android') {
      const ssoUrl = curUrlObj.protocol + '//' + curUrlObj.host + ssoPath;
      window.location.href = redirect_uri + '?ssoUrl=' + ssoUrl;
    } else {
      window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + ssoPath;
    }
  } else if (sessionUrl) {
    const sessionUrlObj = new URL(sessionUrl);
    redirect_uri = (new URLSearchParams(sessionUrlObj.search)).get('redirect_uri');
    client_id = (new URLSearchParams(sessionUrlObj.search)).get('client_id');
    if (redirect_uri) {
      const redirect_uriLocation = new URL(redirect_uri);
      if (client_id === 'android') {
        const ssoUrl = sessionUrlObj.protocol + '//' + sessionUrlObj.host + ssoPath;
        window.location.href = redirect_uri + '?ssoUrl=' + ssoUrl;
      } else {
        window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + ssoPath;
      }
    } else {
      redirectToLib();
    }
  } else {
    redirectToLib();
  }
};
