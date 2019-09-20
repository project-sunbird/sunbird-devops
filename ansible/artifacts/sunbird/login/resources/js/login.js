function getQueryStringValue (key) {
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}
var getValueFromSession = function (valueId) {
    var value = (new URLSearchParams(window.location.search)).get(valueId);
    if (value) {
        sessionStorage.setItem(valueId, value);
        sessionStorage.setItem('renderingType', 'queryParams');
        return value
    } else {
        value = sessionStorage.getItem(valueId);
        if (value) {
            sessionStorage.setItem('renderingType', 'sessionStorage');
        }
        return value
    }
};
window.onload = function(){
	var mergeaccountprocess = (new URLSearchParams(window.location.search)).get('mergeaccountprocess');
	var version = (new URLSearchParams(window.location.search)).get('version');
	var showForgotPortal = getValueFromSession(version);
	var renderingType = 'queryParams';
	if (!mergeaccountprocess) {
		mergeaccountprocess = localStorage.getItem('mergeaccountprocess');
		if (mergeaccountprocess === '1') {
			if (!version) {
				version = localStorage.getItem('version');
			}
			hideElement("mergeAccountMessage");
			renderingType = 'local-storage';
			var error_summary = document.getElementById('error-summary');
			if (error_summary) {
				var errorMessage = error_summary.innerHTML.valueOf();
				error_summary.innerHTML = errorMessage + 'to merge';
			}
		}
	} else {
		localStorage.clear()
	}
	addVersionToURL(version);
	var error_message = (new URLSearchParams(window.location.search)).get('error_message');
	var success_message = (new URLSearchParams(window.location.search)).get('success_message');
	var version = (new URLSearchParams(window.location.search)).get('version');
	if(error_message){
		var error_msg = document.getElementById('error-msg');
		error_msg.className = error_msg.className.replace("hide","");
		error_msg.innerHTML = error_message;
	}else if(success_message){
		var success_msg = document.getElementById("success-msg");
		success_msg.className = success_msg.className.replace("hide","");
		success_msg.innerHTML = success_message;
	}
	if (version >= 4) {
		var forgotElement = document.getElementById("fgtPortalFlow");
		forgotElement.className = forgotElement.className.replace("hide","");
	} else {
		var forgotElement = document.getElementById("fgtKeycloakFlow");
		forgotElement.className = forgotElement.className.replace("hide","");
		forgotElement.href = forgotElement.href + '&version=' + version ;
	}
	if(!version && showForgotPortal >= 4){
		var forgotElement = document.getElementById("fgtPortalFlow");
		forgotElement.className = forgotElement.className.replace("hide","");
	}

	if (mergeaccountprocess === '1') {
		hideElement("kc-registration");
		hideElement("stateButton");
		hideElement("fgtKeycloakFlow");
		// change sign in label with merge label
		var signIn = document.getElementById("signIn");
		if (signIn) {
			signIn.innerText = 'Merge Account';
			signIn.classList.add('fs-22');
		}
		// adding link to go back url
		var goBackElement = document.getElementById("goBack");
		if (goBackElement) {
			goBackElement.className = goBackElement.className.replace("hide", "");
		}
		// if rendering type is local-storage get redirect url from localstorage else from query param
		if (renderingType === 'local-storage') {
			goBackElement.href = localStorage.getItem('redirectUrl');
		} else {
			goBackElement.href = (new URLSearchParams(window.location.search)).get('goBackUrl');
			localStorage.setItem('mergeaccountprocess', mergeaccountprocess);
			localStorage.setItem('version', version);
			localStorage.setItem('redirectUrl', (new URLSearchParams(window.location.search)).get('goBackUrl'));
		}
		var mergeAccountMessage = document.getElementById("mergeAccountMessage");
		if (mergeAccountMessage && renderingType === 'queryParams') {
			mergeAccountMessage.className = mergeAccountMessage.className.replace("hide", "");
		}
	}
}
var storeLocation = function(){
	sessionStorage.setItem('url', window.location.href);
}
var addVersionToURL = function (version){

	if (version >= 1){
		var selfSingUp = document.getElementById("selfSingUp");

		if(selfSingUp) {
			selfSingUp.className = selfSingUp.className.replace(/\bhide\b/g, "");
		}

		var stateButton = document.getElementById("stateButton");

		if ((version >= 2) && stateButton) {
			stateButton.className = stateButton.className.replace(/\bhide\b/g, "");
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

function hideElement(elementId) {
	var elementToHide = document.getElementById(elementId);
	if (elementToHide) {
		addClass(elementToHide, "hide");
	}
}

function addClass(element,classname)
{
	var arr;
  	arr = element.className.split(" ");
  	if (arr.indexOf(classname) == -1) {
    	element.className += " " + classname;
	}
}

var redirectToLib = () => {
	window.location.href = window.location.protocol + '//' + window.location.host + '/resource';
};

var viewPassword = function(previewButton){
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
var urlMap = {
	google: '/google/auth',
	state: '/sign-in/sso/select-org',
	self: '/signup'
}
var navigate = function(type) {
	var version = getQueryStringValue("version");
	if(version == '1' || version == '2') {
		if(type == 'google' || type == 'self'){
			redirect(urlMap[type]);
		} else if(type == 'state') {
			handleSsoEvent()
		}
	} else if (version >= '3') {
		if(type == 'google') {
			handleGoogleAuthEvent()
		} else if(type == 'state' || type == 'self') {
			redirectToPortal(urlMap[type])
		}
	}
}
var redirect  = (redirectUrlPath) => {
	console.log('redirect', redirectUrlPath)
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
var handleSsoEvent  = () => {
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
var handleGoogleAuthEvent = () => {
  const googleAuthUrl = '/google/auth';
  const curUrlObj = window.location;
  let redirect_uri = (new URLSearchParams(curUrlObj.search)).get('redirect_uri');
  let client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
  const updatedQuery = curUrlObj.search + '&error_callback=' + curUrlObj.href.split('?')[0];
  const sessionUrl = sessionStorage.getItem('url');
  if (redirect_uri) {
    const redirect_uriLocation = new URL(redirect_uri);
    sessionStorage.setItem('url', window.location.href);
    if (client_id === 'android') {
      const googleRedirectUrl = curUrlObj.protocol + '//' + curUrlObj.host + googleAuthUrl;
      window.location.href = redirect_uri + '?googleRedirectUrl=' + googleRedirectUrl  + updatedQuery;
    } else {
      window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + googleAuthUrl + updatedQuery;
    }
  } else if (sessionUrl) {
    const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
    const sessionUrlObj = new URL(sessionUrl);
    redirect_uri = (new URLSearchParams(sessionUrlObj.search)).get('redirect_uri');
    client_id = (new URLSearchParams(sessionUrlObj.search)).get('client_id');
    if (redirect_uri) {
      const redirect_uriLocation = new URL(redirect_uri);
      if (client_id === 'android') {
        const googleRedirectUrl = sessionUrlObj.protocol + '//' + sessionUrlObj.host + googleAuthUrl;
        window.location.href = redirect_uri + '?googleRedirectUrl=' + googleRedirectUrl + updatedQuery;
      } else {
        window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + googleAuthUrl + updatedQuery;
      }
    } else {
      redirectToLib();
    }
  } else {
    redirectToLib();
  }
};
var redirectToPortal = (redirectUrlPath) => { // redirectUrlPath for sso and self signUp
  const curUrlObj = window.location;
  var redirect_uri = (new URLSearchParams(curUrlObj.search)).get('redirect_uri');
  var client_id = (new URLSearchParams(curUrlObj.search)).get('client_id');
  const sessionUrl = sessionStorage.getItem('url');
  if (redirect_uri) {
    const updatedQuery = curUrlObj.search + '&error_callback=' + curUrlObj.href.split('?')[0];
    const redirect_uriLocation = new URL(redirect_uri);
    sessionStorage.setItem('url', window.location.href);

    if (client_id === 'android') {
      window.location.href = curUrlObj.protocol + '//' + curUrlObj.host + redirectUrlPath + updatedQuery;
    } else {
      window.location.href = redirect_uriLocation.protocol + '//' + redirect_uriLocation.host + redirectUrlPath + updatedQuery;
    }
  } else if (sessionUrl) {
    const sessionUrlObj = new URL(sessionUrl);
    const updatedQuery = sessionUrlObj.search + '&error_callback=' + sessionUrlObj.href.split('?')[0];
    redirect_uri = (new URLSearchParams(sessionUrlObj.search)).get('redirect_uri');
    client_id = (new URLSearchParams(sessionUrlObj.search)).get('client_id');

    if (redirect_uri) {
      const redirect_uriLocation = new URL(redirect_uri);
      if (client_id === 'android') {
        window.location.href = sessionUrlObj.protocol + '//' + sessionUrlObj.host + redirectUrlPath + updatedQuery;
      }
      else {
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
