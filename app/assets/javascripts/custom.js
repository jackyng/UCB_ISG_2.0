function displayTicket(id) {
	window.location.replace('complaint/ticket?cid=' + id)
}

$(document).ready( function() {
	$("#my_tree").treeview({control: "#treecontrol"});
	$(".iframe").colorbox({iframe:true, width:"80%", height:"80%"});
});