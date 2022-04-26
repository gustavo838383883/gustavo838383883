// ==UserScript==
// @name          Roblox New logo Replacement 2012for windows chrome
// @namespace     http://userstyles.org
// @description	  A Style that replaces the new logo with the old one.
// @author        gustavo242
// @homepage      https://userstyles.org/styles/237516
// @include       http://www.roblox.com*
// @include       https://www.roblox.com*
// @include       http://de.roblox.com*
// @include       https://de.roblox.com*
// @include       https://forums.roblox.com*
// @include       http://web.roblox.com*
// @include       https://web.roblox.com*
// @include       http://forums.roblox.com*
// @include       http://roblox.com/*
// @include       https://roblox.com/*
// @include       http://*.roblox.com/*
// @include       https://*.roblox.com/*
// @include       https://blog.roblox.com*
// @include       https://corp.roblox.com/*
// @include       http://corp.roblox.com*
// @include       http://blog.roblox.com*
// @include       https://www.roblox.com/account/signupredir?*
// @include       https://web.roblox.com/account/signupredir?*
// @include       https://www.roblox.com/*
// @include       https://web.roblox.com/*
// @include       https://de.roblox.com*
// @include       http://www.roblox.com*
// @include       http://web.roblox.com*
// @include       http://de.roblox.com*
// @include       https://de.roblox.com/account/signupredir?*
// @include       http://www.roblox.com/account/signupredir?*
// @include       http://web.roblox.com/account/signupredir?*
// @include       http://de.roblox.com/account/signupredir?*
// @include       http://roblox.com/*
// @include       https://roblox.com/*
// @include       http://*.roblox.com/*
// @include       https://*.roblox.com/*
// @include       https://web.roblox.com/giftcards*
// @include       https://www.roblox.com/giftcards*
// @include       https://de.roblox.com/giftcards*
// @include       http://web.roblox.com/giftcards*
// @include       http://www.roblox.com/giftcards*
// @include       http://de.roblox.com/giftcards*
// @include       https://en.help.roblox.com/*
// @include       http://en.help.roblox.com/*
// @include       http://careers.roblox.com/*
// @include       http://careers.roblox.com/*
// @run-at        document-start
// @version       0.20220426013651
// ==/UserScript==
(function() {var css = "";
if (false || (document.location.href.indexOf("http://www.roblox.com") == 0) || (document.location.href.indexOf("https://www.roblox.com") == 0) || (document.location.href.indexOf("http://de.roblox.com") == 0) || (document.location.href.indexOf("https://de.roblox.com") == 0) || (document.location.href.indexOf("https://forums.roblox.com") == 0) || (document.location.href.indexOf("http://web.roblox.com") == 0) || (document.location.href.indexOf("https://web.roblox.com") == 0) || (document.location.href.indexOf("http://forums.roblox.com") == 0) || (document.domain == "roblox.com" || document.domain.substring(document.domain.indexOf(".roblox.com") + 1) == "roblox.com"))
	css += [
		"/*ROBLOX New Logo Replacement 2.0 by Gustavo- https://www.roblox.com/users/1878060599/profile",
		"",
		"/*Should replace the new logo on the website with the old one*/",
		"/*NOTE: Roblox deleted the \"R\" logo (https://www.roblox.com/images/Logo/roblox_logo.svg)..*/",
		".icon-logo {",
		"    /*Main site navbar full logo*/",
		"    background-image: url(\"https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg\") !important;",
		"}",
		".icon-logo-r {",
		"    /*Main site navbar small logo*/",
		"    background-image: url(\"https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/oie_transparent.svg\") !important;",
		"    background-size: 27px 135px !important;",
		"    background-position-x: 2px !important;",
		"    background-position-y: center !important;",
		"}",
		".big-logo {",
		"    /*Download page logo*/",
		"    background-image: url(\"https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg\") !important;",
		"    height: 80px !important;",
		"}",
		".robloxLogo {",
		"    /*Landing page small logo*/",
		"    content: url(\"https://lh3.googleusercontent.com/2F-yjl82adcRgtSRpX3bP_Xmj2dWgSP1ZRbE9S1UMKmQtQsGgos-M-x_9KpdWe8cT491hL6K8fLTiT-sphew7Z8MbuWf9L9yaL0HiegE4jjAM8zMhj_csKpqZ-uEfs-UXnOXxDUTu0hLT2m6xLUdxYV3vl1eQ9KmOJgSxeLubGXtHT5cQX3ZBphhUcMGnQzlK9Hc7cuADXtgVSvUg__RwSFNnK6TclE-_QoMlpqZ2UZ9yD3GIEsH2Xg-IPM7nS3AB2hbbbzxHa_x0x0lttehjVyWLHHt_SS2JUDZAaOeLdllWg6Isi2OIrtJHtK2RDAMaBU0Gp4paxlqoPQQzaaDUj7MZ_l5mfNrt7i63I2sK1KIzFCx5ZnSy5U_XIa_dEM0hL2-UOzd_lpcwa7QkdlLGiI7VGJ66wgIJTW3RNXPLrkqurOUdAQP3OBnuWWs34Y3hWqERYs0NT8Y1DfQQJqyiV3tGjD-yqSGp3vzStwtsmcz_iCwNxPRFz60iCQ6hJLPkHQ7Pyb2Zn2PCi3Ry02XVW6xsJFVYOgZSoZO8FmArXWinti09rMYeDkEJkspyDxMv7BWF8c98ki43ECltgfuRqTZQA5WsIie5HJ2nKq8iwj7Wd2GFuho1hzK4mHee-D0Bl5jMEZQuKobRUP56DZTSjUYryuyWUK0WmvwQZ1cDsJNi4-9xMsgHNAG4laqbrPfwQI5sB70QXIqFklcxGWlA1Y7apc6bEgoihhK9s_F_KtUPMOHZLfYhntcosI=s225-no?authuser=0\");",
		"    /*hides the new logo in the worst way possible idk*/",
		"    background-image: url(\"https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg\") !important;",
		"    background-size: 167px 167px !important;",
		"    background-position-x: left !important;",
		"    background-position-y: center !important;",
		"    width: 31px;",
		"}",
		"#MainLogoImage {",
		"    /*Landing page big logo*/",
		"    content: url(\"https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg\") !important;",
		"    margin-left: 20px !important;",
		"}",
		"#LogoAndSlogan .clearfix::after {",
		"    /*Landing page slogan under the logo*/",
		"    content: \"Powering Imagination\" !important;",
		"    color: white !important;",
		"    font-size: 35px !important;",
		"    background-color: rgba(0, 0, 0, 0.7) !important;",
		"    padding: 10px 25px !important;",
		"    text-align: center !important;",
		"    margin-top: -20px !important;",
		"    display: inline-block !important;",
		"}",
		"#LogoAndSlogan .clearfix::before {",
		"    /*Slogan trademark thing, needed here so the font can be smaller*/",
		"    content: \"™\" !important;",
		"    color: white !important;",
		"    position: absolute !important;",
		"    font-size: 15px !important;",
		"    top: 100px !important;",
		"    margin-left: 413px !important;",
		"}",
		".dark-theme .icon-default-logo-r,",
		".dark-theme .icon-logo-r,",
		".dark-theme .icon-logo-r-95 {",
		"    background-image: url(https://lh3.googleusercontent.com/2F-yjl82adcRgtSRpX3bP_Xmj2dWgSP1ZRbE9S1UMKmQtQsGgos-M-x_9KpdWe8cT491hL6K8fLTiT-sphew7Z8MbuWf9L9yaL0HiegE4jjAM8zMhj_csKpqZ-uEfs-UXnOXxDUTu0hLT2m6xLUdxYV3vl1eQ9KmOJgSxeLubGXtHT5cQX3ZBphhUcMGnQzlK9Hc7cuADXtgVSvUg__RwSFNnK6TclE-_QoMlpqZ2UZ9yD3GIEsH2Xg-IPM7nS3AB2hbbbzxHa_x0x0lttehjVyWLHHt_SS2JUDZAaOeLdllWg6Isi2OIrtJHtK2RDAMaBU0Gp4paxlqoPQQzaaDUj7MZ_l5mfNrt7i63I2sK1KIzFCx5ZnSy5U_XIa_dEM0hL2-UOzd_lpcwa7QkdlLGiI7VGJ66wgIJTW3RNXPLrkqurOUdAQP3OBnuWWs34Y3hWqERYs0NT8Y1DfQQJqyiV3tGjD-yqSGp3vzStwtsmcz_iCwNxPRFz60iCQ6hJLPkHQ7Pyb2Zn2PCi3Ry02XVW6xsJFVYOgZSoZO8FmArXWinti09rMYeDkEJkspyDxMv7BWF8c98ki43ECltgfuRqTZQA5WsIie5HJ2nKq8iwj7Wd2GFuho1hzK4mHee-D0Bl5jMEZQuKobRUP56DZTSjUYryuyWUK0WmvwQZ1cDsJNi4-9xMsgHNAG4laqbrPfwQI5sB70QXIqFklcxGWlA1Y7apc6bEgoihhK9s_F_KtUPMOHZLfYhntcosI=s225-no?authuser=0)",
		"}",
		".light-theme .icon-default-logo-r,",
		".light-theme .icon-logo-r,",
		".light-theme .icon-logo-r-95 {",
		"    background-image: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/oie_transparent.svg)",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://blog.roblox.com") == 0) || (document.location.href.indexOf("https://corp.roblox.com/") == 0) || (document.location.href.indexOf("http://corp.roblox.com") == 0) || (document.location.href.indexOf("http://blog.roblox.com") == 0))
	css += [
		"/*ROBLOX Blog*/",
		"footer .comp-logo a {",
		"    /*Blog footer logo*/",
		"    background-image: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg) !important;",
		"    background-size: cover !important;",
		"    height: 30px !important;",
		"}",
		"header .site-title a {",
		"    /*Blog header logo*/",
		"    background-image: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg) !important;",
		"    background-size: 110px !important;",
		"    height: 42px !important;",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://www.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("https://web.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("https://www.roblox.com/") == 0) || (document.location.href.indexOf("https://web.roblox.com/") == 0) || (document.location.href.indexOf("https://de.roblox.com") == 0) || (document.location.href.indexOf("http://www.roblox.com") == 0) || (document.location.href.indexOf("http://web.roblox.com") == 0) || (document.location.href.indexOf("http://de.roblox.com") == 0) || (document.location.href.indexOf("https://de.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://www.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://web.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://de.roblox.com/account/signupredir?") == 0))
	css += [
		"/* signup page */",
		"#signup-header .text-logo {",
		"    background-image: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg);",
		"    width: 90%;",
		"    height: 65px;",
		"    max-width: 457px;",
		"}"
	].join("\n");
if (false || (document.domain == "roblox.com" || document.domain.substring(document.domain.indexOf(".roblox.com") + 1) == "roblox.com"))
	css += [
		"/*Events*/",
		".logo-link > img {",
		"    content: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg) !important;",
		"    background-size: cover !important;",
		"    height: 125% !important;",
		"    margin-top: -15% !important;",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://web.roblox.com/giftcards") == 0) || (document.location.href.indexOf("https://www.roblox.com/giftcards") == 0) || (document.location.href.indexOf("https://de.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://web.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://www.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://de.roblox.com/giftcards") == 0))
	css += [
		"/*  giftcards */",
		".logo-link > img {",
		"    content: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg) !important;",
		"    background-size: cover !important;",
		"    height: 125% !important;",
		"    margin-top: -15% !important;",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://en.help.roblox.com/") == 0) || (document.location.href.indexOf("http://en.help.roblox.com/") == 0) || (document.location.href.indexOf("http://careers.roblox.com/") == 0) || (document.location.href.indexOf("http://careers.roblox.com/") == 0))
	css += [
		"/* ROBLOX Support */",
		"#header {",
		"    background-color: #0074bd;",
		"    height: 40px;",
		"}",
		"/* Logo */",
		".logo img {",
		"    width: 0;",
		"    max-height: 30px;",
		"}",
		".logo a::after {",
		"    display: inline-block;",
		"    background-image: url(https://raw.githubusercontent.com/gustavo838383883/gustavo838383883/main/ROBLOX-2012.svg);",
		"    background-size: 100%;",
		"    background-repeat: no-repeat;",
		"    content: \'invisible\';",
		"    font-size: 0;",
		"    width: 120px;",
		"    height: 30px;",
		"    position: absolute;",
		"    left: 6px;",
		"    top: 6px;",
		"}"
	].join("\n");
if (typeof GM_addStyle != "undefined") {
	GM_addStyle(css);
} else if (typeof PRO_addStyle != "undefined") {
	PRO_addStyle(css);
} else if (typeof addStyle != "undefined") {
	addStyle(css);
} else {
	var node = document.createElement("style");
	node.type = "text/css";
	node.appendChild(document.createTextNode(css));
	var heads = document.getElementsByTagName("head");
	if (heads.length > 0) {
		heads[0].appendChild(node);
	} else {
		// no head yet, stick it whereever
		document.documentElement.appendChild(node);
	}
}
})();
