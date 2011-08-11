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
		fieldsets.not(this).find("input, textarea")
			.prop("disabled", true).animate({ opacity: 0.2 });
		$(":disabled", this).prop("disabled", false).animate({ opacity: 1 });
	});
});
