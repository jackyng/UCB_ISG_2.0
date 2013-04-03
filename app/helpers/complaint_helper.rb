module ComplaintHelper
	def isResolved(state)
		if (state)
			return "Done"
		else
			return "Not Yet"
		end
	end

	def getRowColor(state)
		color = "warning"
		if (state)
			color = "success" 
		end
		return color.html_safe
	end

	def displayContent(id)
		current_complaint = Complaint.find_by_id(id)
		content = "<h2>#{h(current_complaint.title)}</h2>"
		content << "<h5>Description:</h5>"
		content << "<div class=complaint>#{h(current_complaint.description)}</div>"
		content.html_safe
	end

	def backbutton()
		back = "<a class=\"btn btn-small btn-primary\" href=\"#{h(complaint_path)}\" data-method=\"get\">Back</a>"
		back.html_safe
	end

end
