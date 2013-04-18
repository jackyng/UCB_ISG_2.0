$(document).ready(function() {
	$("#my_tree").treeview({control: "#treecontrol"});
	$(".iframe").colorbox({iframe:true, width:"80%", height:"80%"});
});

//Display complaint chart
function drawChart() {
  google.load('visualization', '1.0', {'packages':['corechart','controls']});
  google.setOnLoadCallback(apiLoaded);
  function apiLoaded() {
    drawChartRangeFilter();
  }
  
  function drawChartRangeFilter() {
    var dashboard = new google.visualization.Dashboard(
        document.getElementById('chartRangeFilter_dashboard_div'));

    // 1 day in milliseconds = 24 * 60 * 60 * 1000 = 86,400,000
    startDate = new Date(new Date() - 7*86400000);
    var control = new google.visualization.ControlWrapper({
      'controlType': 'ChartRangeFilter',
      'containerId': 'chartRangeFilter_control_div',
      'options': {
        // Filter by the date axis.
        'filterColumnIndex': 0,
        'ui': {
          'chartType': 'LineChart',
          'chartOptions': {
            'chartArea': {'width': '90%'},
            'hAxis': {'baselineColor': 'none'}
          },
          // Display a single series that shows the number of complaints.
          // Thus, this view has two columns: the date (axis) and the number of complaints (line series).
          'chartView': {
            'columns': [0, 1]
          },
          'minRangeSize': 86400000
        }
      },
      // Initial range: prev 7 days to today.
      'state': {'range': {'start': startDate, 'end': new Date()}}
    });

    var chart = new google.visualization.ChartWrapper({
      'chartType': 'ColumnChart',
      'containerId': 'chartRangeFilter_chart_div',
      'options': {
        // Use the same chart area width as the control for axis alignment.
        'chartArea': {'height': '80%', 'width': '90%'},
        'hAxis': {'slantedText': false},
        'vAxis': {'viewWindow': {'min': 0, 'max': 30}},
        'legend': {'position': 'none'}
      },
      // Convert the first column from 'date' to 'string'.
      'view': {
        'columns': [
          {
            'calc': function(dataTable, rowIndex) {
              return dataTable.getFormattedValue(rowIndex, 0);
            },
            'type': 'string'
          }, 1, 2, 3]
      }
    });

    var data = new google.visualization.DataTable();
    data.addColumn('date', 'Date');
    data.addColumn('number', 'Complaints');
    data.addColumn('number', 'Resolved');
    data.addColumn('number', 'Unresolved');

    //Request values
    $.ajax({
      url: "/complaint/getComplaintData",
      dataType: "json",
      }).success(function(complaintData) {
        totalComplaints = complaintData.totalComplaints;
        totalResolved = complaintData.totalResolved;
        totalUnresolved = complaintData.totalUnresolved;
        var date, numOfComplaints, numOfResolved, numOfUnresoleved;
        for (key in totalComplaints) {
          date = new Date(key);
          numOfComplaints = totalComplaints[key];
          numOfResolved = totalResolved[key];
          numOfUnresoleved = totalUnresolved[key];
          data.addRow([date, numOfComplaints, numOfUnresoleved, numOfResolved]);
        }
        dashboard.bind(control, chart);
        dashboard.draw(data);
    });
  }
}

//Show the ticket form
function displayTicketForm(id) {
  var url = "/complaint/create";
  $(location).attr('href', url);
}

//Show the ticket content
function displayTicket(id) {
  var url = "/complaint/ticket?cid=" + id;
  $(location).attr('href', url);
}

function displayChart() {
  var url = "/complaint/chart";
  $(location).attr('href', url);
}

//Register right-clicked menu
$(function(){
    var isAdmin =  $("#my_tree :first-child").attr('id');
    if (isAdmin == "isAdmin") {
      $.contextMenu({
          selector: '.root_node', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var url;
              switch (key) 
              {
                case "new child":
                  url = "/node/create?parent=" + node_id;
                  $(location).attr('href', url);
                  break;
                case "new resource":
                  url = "/resource/create?node_id=" + node_id;
                  $(location).attr('href', url);
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" }
          }
      });

      $.contextMenu({
          selector: '.tree_nodes', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var url;
              switch (key) 
              {
                case "new child":
                  url = "/node/create?parent=" + node_id;
                  $(location).attr('href', url);
                  break;
                case "new resource":
                  url = "/resource/create?node_id=" + node_id;
                  $(location).attr('href', url);
                  break;
                case "delete":
                  url = "/node/destroy?node_id=" + node_id;
                  $(location).attr('href', url);
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" },
              "delete": {name: "Remove node"}
          }
      });

      $.contextMenu({
          selector: '.resources', 
          callback: function(key, opt) {
              var resource_id = opt.$trigger.attr("id").split("_")[1];
              var url;
              switch (key) 
              {
                case "delete":
                  url = "/node/destroy?node_id=" + resource_id;
                  $(location).attr('href', url);
                  break;
              }
          },
          items: {
              "delete": {name: "Remove resource" }
          }
      });
    }
});
