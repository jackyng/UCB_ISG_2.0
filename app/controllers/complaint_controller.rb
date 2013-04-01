class ComplaintController < ApplicationController
	def index
	    if params[:id] == nil
	    	return
	    end
	    
	    id = params[:id]

	    @complaint = Complaint.find(id)
  	end

  	def create
  	end

  	def destroy
  	end

  	def show_all

  	end
end
