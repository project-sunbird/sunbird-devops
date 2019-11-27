function getQueryStringValue (key) {
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
}

window.onload = function(){
	var mergeaccountprocess = (new URLSearchParams(window.location.search)).get('mergeaccountprocess');
	var version = (new URLSearchParams(window.location.search)).get('version');
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

	if (mergeaccountprocess === '1') {
		hideElement("kc-registration");
		hideElement("stateButton");
		hideElement("fgtKeycloakFlow");
		hideElement("fgtPortalFlow");
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

	var response_type = (new URLSearchParams(window.location.search)).get('response_type');
	if ((new URLSearchParams(window.location.search)).get('automerge') !== '1' && response_type === 'code') {
		localStorage.clear();
	}
	var autoMerge = getValue('automerge');
	if (autoMerge === '1') {
		decoratePage('autoMerge');
		storeValueForMigration();
	}
};

var storeValueForMigration = function () {
	// storing values in localstorage for future references
	localStorage.setItem('automerge', getValue('automerge'));
	localStorage.setItem('goBackUrl', getValue('goBackUrl'));
	localStorage.setItem('identifierValue', getValue('identifierValue'));
	localStorage.setItem('identifierType', getValue('identifierType'));
	localStorage.setItem('userId', getValue('userId'));
};

var getValue = function (valueId) {
	var value = (new URLSearchParams(window.location.search)).get(valueId);
	if (value) {
		localStorage.setItem('renderingType', 'queryParams');
		return value
	} else {
		value = localStorage.getItem(valueId);
		if (value) {
			localStorage.setItem('renderingType', 'localStorage');
		}
		return value
	}
};


var decoratePage = function (pageType) {
	if (pageType === 'autoMerge') {
		var identifierValue = getValue('identifierValue');
		var goBackUrl = getValue('goBackUrl');
		var signIn = document.getElementById("signIn");
		if (signIn) {
			signIn.innerText = 'Merge Account';
			signIn.classList.add('fs-22');
		}
		setElementValue('username', identifierValue);

		var elementsToHide = ['kc-registration', 'stateButton', 'fgtKeycloakFlow', 'fgtPortalFlow',
			'usernameLabel', 'usernameLabelPlaceholder', 'username'];

		unHideElement('migrateAccountMessage');
		unHideElement('goBack');
		var goBackElement = document.getElementById("goBack");
		if (goBackElement) {
			goBackElement.href = goBackUrl;
		}
		if (localStorage.getItem('renderingType') === 'localStorage') {
			unHideElement('selfSingUp');
			var errorElement = document.getElementById('error-summary');
			if (errorElement) {
				if (errorElement.innerText === 'Invalid email ID/Mobile number or password. Please try again with valid credentials') {
					unHideElement('inCorrectPasswordError');
					handlePasswordFailure();
				}
				elementsToHide.push('error-summary');
			}
		}
		for (var i = 0; i < elementsToHide.length; i++) {
			hideElement(elementsToHide[i]);
		}
	}
};

var handlePasswordFailure = function () {
	var passwordFailCount = Number(localStorage.getItem('passwordFailCount') || 0);
	passwordFailCount = passwordFailCount + 1;
	localStorage.setItem('passwordFailCount', passwordFailCount);
	if (passwordFailCount >= 2) {
		const url = '/sign-in/sso/auth?status=error' + '&identifierType=' + getValue('identifierType');
		const query = '&userId=' + getValue('userId') + '&identifierValue=' + getValue('identifierValue');
		window.location.href = window.location.protocol + '//' + window.location.host + url + query;
	}
};

var unHideElement = function (elementId) {
	var elementToUnHide = document.getElementById(elementId);
	if (elementToUnHide) {
		elementToUnHide.className = elementToUnHide.className.replace("hide", "");
	}
};
var setElementValue = function (elementId, elementValue) {
	var element = document.getElementById(elementId);
	if (element) {
		element.value = elementValue;
	}
};

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
	var autoMerge = getValue('automerge');
	if (autoMerge === '1') {
		return;
	}
	if(currentElement.id !== 'totp'){
		var placeholderElement = document.querySelector("label[id='"+currentElement.id+"LabelPlaceholder']");
		var labelElement = document.querySelector("label[id='"+currentElement.id+"Label']");
		placeholderElement.className = placeholderElement.className.replace("hide", "");
		addClass(labelElement,"hide");
	}
};
var inputBoxFocusOut = function (currentElement) {
	var autoMerge = getValue('automerge');
	if (autoMerge === '1') {
		return;
	}
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
