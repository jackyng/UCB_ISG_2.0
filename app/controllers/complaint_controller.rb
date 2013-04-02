class ComplaintController < ApplicationController
	# This requires the user to be authenticated for viewing all pages.
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :get_calnet_info

  def toggle
  	@c = Complaint.find(params[:id])
  	@c.toggle!(:isResolved)
  	redirect_to complaint_path
  end

	def index
    unless @current_user.nil?
      @user_complaints = Complaint.find_all_by_user_id(@current_user)
    end
  end

	def create
		new_complaint = Complaint.new(
			:title => params[:title],
      :user_email => params[:user_email],
			:description => params[:description],
			:ip_address => @remote_ip,
			:isResolved => false,
			:user => @current_user		
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
