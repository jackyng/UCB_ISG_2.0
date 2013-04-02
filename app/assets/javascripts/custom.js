function displayResource(url) {
	var content = $("#content");
	if (content.children().length > 0) {
		content.children().first().remove();
	}
	content.addClass('span8');
	$('<iframe />', {
		src: url,
		width: content.width(),
		height: 900,
		frameborder: 1
	}).appendTo(content);
}

function displayTicket(id) {
	window.location.replace('complaint/ticket?cid=' + id)
}

$(document).ready( function() {
	$("#my_tree").treeview({control: "#treecontrol"});
	$(". iframe").colorbox({iframe:true, width:"80%", height:"80%"});
});