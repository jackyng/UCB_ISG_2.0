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
		content = "<span><h1>#{h(current_complaint.title)}</h1></span>"
		content << "<span><div id=complaint>#{h(current_complaint.description)}</div></span>"
		content.html_safe
	end

	def backbutton()
		back = "<span><a href=\"#{h(complaint_path)}\" data-method=\"get\">Back</a></span>"
		back.html_safe
	end

end
