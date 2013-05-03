module ComplaintHelper
	def getComplaintRowColor(state)
		color = state == "completed" ? "success" : "warning"
		return color.html_safe
	end

	def displayContent(complaint_id)
		current_complaint = Complaint.find_by_id(complaint_id)
		messages = Message.ordered_by_complaint(complaint_id)
		content = "<table><tr><td><h2>#{h(current_complaint.title)}</h2></td><td><div class=\"span7\"></div></td>"
		content << "<td><a class=\"btn btn-primary\" href=\"#{h(message_reply_path(messages[-1].id))}\" data-method=\"get\">Reply</a></td></table>"
		content << "<h5>Description:</h5>"
		content << "<div class=complaint>#{h(messages[0].content)}</div>"
		content.html_safe
	end

	def displayMessages(complaint_id)
		messages = Message.ordered_by_complaint(complaint_id)
		messages.shift
		html_code = "<table>"
		html_code << "<tr>"
		html_code << "<th class='span2'>Message no.</th>"
		html_code << "<th class='span3'>Author</th>"
		html_code << "<th class='span7'>Content</th>"
		html_code << "</tr>"
		messages.each do |message|
			html_code << "<tr>"
			author = message.admin || message.user
			html_code << "<td>#{message.depth}</td>"
			html_code << "<td>#{author.fullname}</td>"
			html_code << "<td>#{message.content}</td>"
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
		html_code = "#{admin.fullname}"
		html_code.html_safe
	end

end
