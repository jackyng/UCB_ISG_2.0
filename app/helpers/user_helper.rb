module UserHelper
	def isAdmin?(state)
		if (state)
			return "Yes"
		else
			return "No"
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
