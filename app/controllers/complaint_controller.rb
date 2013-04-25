class ComplaintController < ApplicationController
	# This requires the user to be authenticated for viewing all pages.
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege, only: [:chart, :getComplaintData]
  before_filter :setup_session_info # Somehow before_filter in application_controller doesn't work

  def update_status
    begin
      @complaint = Complaint.find(params[:id])
    rescue
      flash[:error] = "Could not find complaint with id '#{params[:id]}'"
      redirect_to complaint_path and return
    end
    if params[:status]
      unless @complaint.update_attributes(status: params[:status])
        flash[:error] = "Couldn't update status of complaint #{@complaint.id} to '#{params[:status]}'"
      else
        flash[:notice] = "Status of Complaint '#{@complaint.title}' updated."
      end
    else
      flash[:error] = "Parameter status missing"
    end
    redirect_to complaint_path
  end

	def index
    if @admin
      @complaints = Complaint.all()
    elsif @user
      @complaints = Complaint.find_all_by_user_id(@user)
    else
      flash[:error] = "Must login to view your list of complaints"
    end
  end

	def create
    if @admin
      flash[:error] = "Only normal user can create complaint"
    elsif @user
      if params[:title] and params[:description]
    		new_complaint = @user.complaints.new(
    			:title => params[:title],
          :user_email => params[:user_email],
    			:ip_address => @remote_ip,
    			:status => "new"	
    	  )
        unless new_complaint.save
          flash[:error] = new_complaint.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
          return
        end

        first_message = new_complaint.messages.new(
          :user => @user,
          :content => params[:description],
        )
        if first_message.save
          flash[:notice] = "Successfully submitted complaint '#{new_complaint.title}'."
        else
          flash[:error] = first_message.errors.map {|k,v| "#{k.to_s} error: #{v}"}.join(". ")
          new_complaint.destroy
          return
      	end
      else
        # Go to the form for creating complaints
        return
      end
    else
      flash[:error] = "Have to logged in as a normal user to submit ticket"
    end
    redirect_to complaint_path
	end

	def destroy
    begin
		  @complaint = Complaint.find(params[:id])
    rescue
      flash[:error] = "Could not find complaint with id '#{params[:id]}'"
      redirect_to complaint_path and return
    end

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
				if totalResolved[date] and complaint.status == "completed"
					totalResolved[date] += 1
				elsif totalUnresolved[date] and complaint.status == "new"
					totalUnresolved[date] += 1
				end
			else
				totalComplaints[date] = 1
				if complaint.status == "completed"
					totalResolved[date] = 1
					totalUnresolved[date] = 0
				elsif complaint.status == "new"
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