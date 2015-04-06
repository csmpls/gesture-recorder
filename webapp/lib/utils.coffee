
exports.nonEmpty = (v) -> v.length > 0 

exports.setEnabled = (element, enabled) -> element.attr("disabled", !enabled) 
