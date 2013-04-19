class ComplaintController < ApplicationController
	include ApplicationHelper
	# This requires the user to be authenticated for viewing all pages.
  before_filter CASClient::Frameworks::Rails::Filter

  def update_status
    @c = Complaint.find(params[:id])
    unless @c.update_attributes(status: params[:status])
      flash[:error] = "Couldn't update status of complaint #{@c.id} to '#{params[:status]}'"
    end
    redirect_to complaint_path
  end

	def index
    if @admin
      @complaints = Complaint.all()
    elsif @user
      @complaints = Complaint.find_by_user_id(@user)
    end
  end

	def create
		new_complaint = Complaint.new(
			:title => params[:title],
      :user_email => params[:user_email],
			:ip_address => @remote_ip,
			:status => "new",
			:user => @user		
	  )
    if new_complaint.save 
    # 	new_message = new_complaint.messages.new(
    # 		:complaint => new_complaint,
	  	# 	:depth => 0,
	  	# 	:content => params[:description]
	  	# )
	  	# if new_message.save
      	flash[:notice] = "Successfully submitted complaint '#{new_complaint.title}'."
      	redirect_to complaint_path
      # end
  	end
	end

	def destroy
		@complaint = Complaint.find(params[:complaint_id])
		complaint_title = @complaint.title
		@complaint.destroy

    flash[:notice] = "Successfully removed complaint '#{complaint_title}'."
    redirect_to complaint_path
	end

	def getComplaintData
		data = {}
		totalComplaints = {}
		totalResolved = {}
		totalUnresolved = {}
		Complaint.all().each do |complaint| 
			date = complaint.created_at.to_date.to_s.gsub('-', '/')
			if totalComplaints[date]
				totalComplaints[date] += 1
				if totalResolved[date] && complaint.isResolved
					totalResolved[date] += 1
				elsif totalUnresolved[date] && !complaint.isResolved
					totalUnresolved[date] += 1
				end
			else
				totalComplaints[date] = 1
				if complaint.isResolved
					totalResolved[date] = 1
					totalUnresolved[date] = 0
				else
					totalUnresolved[date] = 1
					totalResolved[date] = 0
				end
			end
		end
		data[:totalComplaints] = totalComplaints
		data[:totalResolved] = totalResolved
		data[:totalUnresolved] = totalUnresolved
		respond_to do |format|
			format.json {render :json => data}
		end
	end
end