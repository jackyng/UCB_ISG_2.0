class AnnouncementController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege

def index
	@notices = Announcement.all()
end

def create
	new_announcement= Announcement.new(
			:title => params[:title],
      		:description => params[:description],
      		:admin => @admin
	  )

    if new_announcement.save
      flash[:notice] = "Successfully submitted announcement '#{new_announcement.title}'."
      redirect_to announcement_path
  	end
end

def edit
    @notice = Announcement.find(params[:nid])
    if @notice.update_attributes(title: params[:title], description: params[:description])
      redirect_to announcement_path
    end
end

def destroy
end

end