//Register right-clicked menu
var NODE_CUT_ID = null;
var NODE_CUT_NAME = null;
$(function(){
    var isAdmin =  $("#my_tree :first-child").attr('id');
    if (isAdmin == "isAdmin") {
      $.contextMenu({
          selector: '.root_node', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var node_name = opt.$trigger.text();
              switch (key) 
              {
                case "new child":
                  $('#addNewNode').modal();
                  $(".modal-body #parent").val(node_id);
                  break;
                case "new resource":
                  $('#addNewResource').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "import json":
                  $('#importJSON').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "paste":
                  if (NODE_CUT_ID == null) {
                    alert("There is nothing to paste");
                  }
                  else {
                    $('#pasteNode').modal();
                    $(".modal-body #node_id").val(node_id);
                    $(".modal-body .node_name").text(node_name);
                    $(".modal-body #source_id").val(NODE_CUT_ID);
                    $(".modal-body .source_name").text(NODE_CUT_NAME); 
                  }
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" },
              "paste" : {name: "Paste"},
              "import json": {name: "Import JSON"}
          }
      });

      $.contextMenu({
          selector: '.tree_nodes', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var node_name = opt.$trigger.text();
              switch (key) 
              {
                case "new child":
                  $('#addNewNode').modal();
                  $(".modal-body #parent").val(node_id);
                  break;
                case "new resource":
                  $('#addNewResource').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "delete":
                  $('#deleteNode').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body .node_name").text(node_name);
                  break;
                case "deleteAll":
                  $('#deleteAll').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body .node_name").text(node_name);
                  break;
                case "edit":
                  var description = opt.$trigger.attr("data-original-title");
                  $('#editNode').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body #name").val(node_name);
                  $(".modal-body #description").val(description);
                  break;
                case "import json":
                  $('#importJSON').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "cut":
                  NODE_CUT_ID = node_id;
                  NODE_CUT_NAME = node_name;
                  break;
                case "paste":
                  if (NODE_CUT_ID == null) {
                    alert("There is nothing to paste");
                  }
                  else {
                    $('#pasteNode').modal();
                    $(".modal-body #node_id").val(node_id);
                    $(".modal-body .node_name").text(node_name);
                    $(".modal-body #source_id").val(NODE_CUT_ID);
                    $(".modal-body .source_name").text(NODE_CUT_NAME); 
                  }
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" },
              "edit": {name: "Edit node"},
              "cut" : {name: "Cut"},
              "paste" : {name: "Paste"},
              "import json": {name: "Import JSON"},
              "delete": {name: "Remove node"},
              "deleteAll" : {name: "Remove all"}
          }
      });

      $.contextMenu({
          selector: '.resources', 
          callback: function(key, opt) {
              var resource_id = opt.$trigger.attr("id").split("_")[1];
              var resource_name = opt.$trigger.text();
              var url = opt.$trigger.attr("href");
              var $tabs = $('#body').tabs();
              switch (key) 
              {
                case "delete":
                  $('#deleteResource').modal();
                  $(".modal-body #resource_id").val(resource_id);
                  $(".modal-body .resource_name").text(resource_name);
                  break;
                case "edit":
                  $('#editResource').modal();
                  $(".modal-body #resource_id").val(resource_id);
                  $(".modal-body #name").val(resource_name);
                  $(".modal-body #url").val(url);
                  break;
                case "resource_tab_1":
                  loadTabFrame("#tabs-2", url);
                  $tabs.tabs("option", "active", 1);
                  break;
                case "resource_tab_2":
                  loadTabFrame("#tabs-3", url);
                  $tabs.tabs("option", "active", 2);
                  break;
              }
          },
          items: {
              "edit": {name: "Edit resource" },
              "delete": {name: "Remove resource" },
              "resource_tab_1": {name: "Open in Resource 1 tab" },
              "resource_tab_2": {name: "Open in Resource 2 tab" }
          }
      });
    }
    function loadTabFrame(tab, url) {
      $(tab).html("");
      if ($(tab).find("iframe").length == 0) {
          var html = [];
          html.push('<div class="tabIframeWrapper">');
          html.push('<div class="openout"><a href="' + url + '"><img src="/assets/world.png" border="0" alt="Open" title="Remove iFrame" /></a></div><iframe class="iframetab" src="' + url + '">Load Failed?</iframe>');
          html.push('</div>');
          $(tab).append(html.join(""));
          $(tab).find("iframe").height($(window).height()-80);
          $(tab).find("iframe").width($(window).width()-210);
      }
      return false;
    }
});

