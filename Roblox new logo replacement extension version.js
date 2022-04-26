// ==UserScript==
// @name          ROBLOX New Logo Replacement 2.0(for Windows chrome
// @namespace     http://userstyles.org
// @description	  A style that replaces the new ROBLOX logo with the old one. If the logo disappears please reload the website.ROBLOX New Logo Replacement 1.0  https://userstyles.org/styles/137531/roblox-new-logo-replacement
// @author        gustavo242
// @homepage      https://userstyles.org/styles/197300
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
// @version       0.20220420174623
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
		"    background-image: url(https://www.roblox.com/images/Logo/roblox_logo.svg) !important;",
		"}",
		".icon-logo-r {",
		"    /*Main site navbar small logo*/",
		"    background-image: url(https://raw.githubusercontent.com/anthony1x6000/ROBLOX2016stylus/e7e1749ce9770fc92c27226b20627243cd8291ad/images/logo_R2016.svg) !important;",
		"    background-size: 25px 135px !important;",
		"    background-position-x: 2px !important;",
		"    background-position-y: center !important;",
		"}",
		".big-logo {",
		"    /*Download page logo*/",
		"    background-image: url(https://www.roblox.com/images/Logo/roblox_logo.svg) !important;",
		"    height: 80px !important;",
		"}",
		".robloxLogo {",
		"    /*Landing page small logo*/",
		"    content: url(\"http://i.imgur.com/Hj502As.png\");",
		"    /*hides the new logo in the worst way possible idk*/",
		"    background-image: url(\"https://www.roblox.com/images/Logo/roblox_logo.svg\") !important;",
		"    background-size: 167px 167px !important;",
		"    background-position-x: left !important;",
		"    background-position-y: center !important;",
		"    width: 31px;",
		"}",
		"#MainLogoImage {",
		"    /*Landing page big logo*/",
		"    content: url(\"https://www.roblox.com/images/Logo/roblox_logo.svg\") !important;",
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
		"    background-image: url(https://vignette.wikia.nocookie.net/logopedia/images/1/19/ROBLOX_Logo_2015.svg/revision/latest?cb=20170907130237)",
		"}",
		".light-theme .icon-default-logo-r,",
		".light-theme .icon-logo-r,",
		".light-theme .icon-logo-r-95 {",
		"    background-image: url(https://vignette.wikia.nocookie.net/logopedia/images/1/19/ROBLOX_Logo_2015.svg/revision/latest?cb=20170907130237)",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://blog.roblox.com") == 0) || (document.location.href.indexOf("https://corp.roblox.com/") == 0) || (document.location.href.indexOf("http://corp.roblox.com") == 0) || (document.location.href.indexOf("http://blog.roblox.com") == 0))
	css += [
		"/*ROBLOX Blog*/",
		"footer .comp-logo a {",
		"    /*Blog footer logo*/",
		"    background-image: url(https://www.roblox.com/images/Logo/roblox_logo.svg) !important;",
		"    background-size: cover !important;",
		"    height: 30px !important;",
		"}",
		"header .site-title a {",
		"    /*Blog header logo*/",
		"    background-image: url(https://www.roblox.com/images/logo/roblox_logo.svg) !important;",
		"    background-size: 110px !important;",
		"    height: 42px !important;",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://www.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("https://web.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("https://www.roblox.com/") == 0) || (document.location.href.indexOf("https://web.roblox.com/") == 0) || (document.location.href.indexOf("https://de.roblox.com") == 0) || (document.location.href.indexOf("http://www.roblox.com") == 0) || (document.location.href.indexOf("http://web.roblox.com") == 0) || (document.location.href.indexOf("http://de.roblox.com") == 0) || (document.location.href.indexOf("https://de.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://www.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://web.roblox.com/account/signupredir?") == 0) || (document.location.href.indexOf("http://de.roblox.com/account/signupredir?") == 0))
	css += [
		"/* signup page */",
		"#signup-header .text-logo {",
		"    background-image: url(https://www.roblox.com/images/Logo/roblox_logo.svg);",
		"    width: 90%;",
		"    height: 65px;",
		"    max-width: 457px;",
		"}"
	].join("\n");
if (false || (document.domain == "roblox.com" || document.domain.substring(document.domain.indexOf(".roblox.com") + 1) == "roblox.com"))
	css += [
		"/*Events*/",
		".logo-link > img {",
		"    content: url(https://www.roblox.com/images/Logo/roblox_logo.svg) !important;",
		"    background-size: cover !important;",
		"    height: 125% !important;",
		"    margin-top: -15% !important;",
		"}"
	].join("\n");
if (false || (document.location.href.indexOf("https://web.roblox.com/giftcards") == 0) || (document.location.href.indexOf("https://www.roblox.com/giftcards") == 0) || (document.location.href.indexOf("https://de.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://web.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://www.roblox.com/giftcards") == 0) || (document.location.href.indexOf("http://de.roblox.com/giftcards") == 0))
	css += [
		"/*  giftcards */",
		".logo-link > img {",
		"    content: url(https://www.roblox.com/images/Logo/roblox_logo.svg) !important;",
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
		"    background-image: url(https://www.roblox.com/images/Logo/roblox_logo.svg);",
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
