(function(){
	window.addEventListener("DOMContentLoaded", function() {
        var tenant = localStorage.getItem('tenant');
		document.body.classList.add(tenant);
		if(tenant==='space')
		{
			document.getElementById('kc-locale-dropdown').classList.add('hidedropdown');
			document.getElementById('selfSingUp').classList.add('hidegooglesignin');
			document.getElementById('login').classList.add('societalbtn');
			document.getElementById('loginbox').classList.add('societallogin');
		}
    }, false);
})(); 