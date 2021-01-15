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

	// new ClipboardJS('.btn-clipboard');

	// new ClipboardJS('.btn-clipboard-multiple', {
	// 	text: function (trigger) {
	// 		var targetSelector = $(trigger).data('clipboard-targets');
	// 		var joinSeparator = $(trigger).data('clipboard-targets-join-separator');
	// 		var targets = $(targetSelector);

	// 		return targets.toArray().map(function(element) {
	// 			return element.innerText.trim()
	// 		}).join(joinSeparator);
	// 	}
	// });
});
