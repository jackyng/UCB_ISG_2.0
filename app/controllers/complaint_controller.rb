class ComplaintController < ApplicationController

	# This requires the user to be authenticated for viewing all pages.
  	before_filter CASClient::Frameworks::Rails::Filter

  	before_filter :get_calnet_info

	def index
	    if params[:id] == nil
	    	return
	    end
	    
	    id = params[:id]
	    @complaint = Complaint.find(id)
  	end

  	def create
  		new_complaint = Complaint.new(
  			:title => params[:title],
  			:description => params[:description],
  			:ip_address => @remote_ip,
  			:isResolved => false,
  			:user => @current_user,		
  			:user_email => params[:user_email]
		  )

	    if new_complaint.save
	      flash[:notice] = "Successfully submitted complaint '#{new_complaint.title}'."
	      redirect_to complaint_path
	  	end
  	end

  	def destroy
  		@complaint = Complaint.find(params[:complaint_id])
  		complaint_title = @complaint.title
  		@complaint.destroy

      flash[:notice] = "Successfully removed complaint '#{complaint_title}'."
      redirect_to complaint_path
  	end

  	def list_all
  		@complaints = Complaint.all()
  	end

  	def mark_as_resolved
  		@complaint = Complaint.find(params[:complaint_id])
  		@complaint.isResolved = true
  		@complaint.save
  		flash[:notice] = "Successfully marked complaint as resolved."
  	end

  	def mark_as_unresolved
  		@complaint = Complaint.find(params[:complaint_id])
  		@complaint.isResolved = false
  		@complaint.save
  		flash[:notice] = "Successfully marked complaint as unresolved."
  	end
end
