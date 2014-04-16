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

	// deactivate conflicting input fields on New Document page (by URL vs.
	// direct input)
	var fieldsets = $(".document-form");

	fieldsets.each(function(i, el) {
		$(el).css("opacity", 0.2);
	});

	fieldsets.mouseenter(function(ev) {
		fieldsets.not(this).animate({ opacity: 0.2 })
			.find("input, textarea").prop("disabled", true);
		$(this).animate({ opacity: 1 })
			.find(":disabled").prop("disabled", false);
	});
});
