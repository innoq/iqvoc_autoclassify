/*jslint vars: true, unparam: true, browser: true */
/*global jQuery */

jQuery(document).ready(function($) {
	"use strict";

	// activate trace tooltips on Show Document page
	$(".trace .hint, .trace li a").each(function(i, node) {
		var el = $(this);
		var html = el.next(".details").remove().html();
		el.mintip({ content: html, allowHTML: true });
	});
});
