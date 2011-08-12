/*jslint vars: true, unparam: true, browser: true */
/*global jQuery */

jQuery(document).ready(function($) {
	"use strict";

	var root = $("#new_document");
	if(root.length === 0) {
		return;
	}

	var fieldsets = $("fieldset", root);
	fieldsets.mouseenter(function(ev) {
		fieldsets.not(this).animate({ opacity: 0.2 })
			.find("input, textarea").prop("disabled", true);
		$(this).animate({ opacity: 1 })
			.find(":disabled").prop("disabled", false);
	});
});
