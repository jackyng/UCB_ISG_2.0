module ComplaintHelper
	def getComplaintRowColor(state)
		color = state == "completed" ? "success" : "warning"
		return color.html_safe
	end

	def displayContent(complaint_id)
		current_complaint = Complaint.find_by_id(complaint_id)
		messages = Message.ordered_by_complaint(complaint_id)
		content = "<table><tr><td><h2>#{h(current_complaint.title)}</h2></td><td><div class=\"span7\"></div></td>"
		content << "<td><button class=\"btn btn-primary\" onclick=\"displayMessagesForm(#{h(messages[-1].id)})\">Reply</button></td></table>"
		content << "<h5>Description:</h5>"
		content << "<div class=complaint>#{h(messages[0].content)}</div>"
		content.html_safe
	end

	def displayMessages(complaint_id)
		messages = Message.ordered_by_complaint(complaint_id)
		messages.shift
		html_code = "<table class=\"table table-stripped table-hover table-condensed\">"
		html_code << "<tr>"
		html_code << "<th class='span2'>Message no.</th>"
		html_code << "<th class='span3'>Author</th>"
		html_code << "<th class='span7'>Content</th>"
		html_code << "</tr>"
		messages.each do |message|
			html_code << "<tr>"
			author = message.admin || message.user
			html_code << "<td class='span2'>#{message.depth}</td>"
			html_code << "<td class='span3'>#{author.fullname}</td>"
			html_code << "<td class='span7'>#{message.content}</td>"
			html_code << "</tr>"
		end
		html_code << "</table>"
		html_code.html_safe
	end

	def backbutton()
		back = "<a class=\"btn btn-small btn-primary\" href=\"#{h(complaint_path)}\" data-method=\"get\">Back</a>"
		back.html_safe
	end

	def displayAdmin(admin_id)
		admin = Admin.find_by_id(admin_id)
		if not admin.nil?
			html_code = "#{admin.fullname}"
			html_code.html_safe
		end
	end
end
