import 'clipboard/dist/clipboard'

jQuery(function($) {
  "use strict";

  new ClipboardJS('.btn-clipboard');
  new ClipboardJS('.btn-clipboard-multiple', {
    text: function (trigger) {
      var targetSelector = $(trigger).data('clipboard-targets');
      var joinSeparator = $(trigger).data('clipboard-targets-join-separator');
      var targets = $(targetSelector);

      return targets.toArray().map(function(element) {
        return element.innerText.trim()
      }).join(joinSeparator);
    }
  });
});