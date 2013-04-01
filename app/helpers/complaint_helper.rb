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
end
