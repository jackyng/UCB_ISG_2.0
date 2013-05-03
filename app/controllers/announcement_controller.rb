class AnnouncementController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, except: [:index, :notice]

  before_filter :check_admin_privilege, except: [:index, :notice]

  def index
    @notices = Announcement.all
  end

  def notice
    begin
      @notice = Announcement.find(params[:id])
    rescue
      flash[:errors] << "Could not find announcement with id '#{params[:id]}'"
      redirect_to announcement_path
    end
  end

  def create
    if request.method == "POST"
      new_announcement = @admin.announcements.new(
        :title => params[:title],
        :description => params[:description]
      )

      if new_announcement.save
        flash[:notice] = "Successfully submitted announcement '#{new_announcement.title}'."
        redirect_to announcement_path
      else
        new_announcement.errors.map do |k, v|
          flash[:errors] << "#{k} error: #{v}."
        end
      end
    end
  end

  def edit
    begin
      @announcement = Announcement.find(params[:id])
    rescue
      flash[:errors] << "Could not find announcement with id '#{params[:id]}'"
      redirect_to announcement_path and return
    end

    if request.method == "POST"
      @announcement.title = params[:title]
      @announcement.description = params[:description]
      if @announcement.save
        flash[:notice] = "Successfully updated announcement '#{@announcement.title}'."
        redirect_to announcement_path
      else
        @announcement.errors.map do |k, v|
          flash[:errors] << "#{k} error: #{v}."
        end
      end
    end
  end

  def destroy
    begin
      announcement = Announcement.find(params[:id])
      if announcement.destroy
        flash[:notice] = "Successfully removed announcement '#{announcement.title}'"
      else
        flash[:errors] << "Can't remove announcement '#{announcement.title}'"
      end
    rescue
      flash[:errors] << "Could not find announcement with id '#{params[:id]}'"
    end
    redirect_to announcement_path
  end

  def toggle_show
    begin
      announcement = Announcement.find(params[:id])
      announcement.toggle!(:shown_on_homepage)
      if announcement.shown_on_homepage
        flash[:notice] = "Announcement '#{announcement.title}' will be shown on homepage"
      else
        flash[:notice] = "Announcement '#{announcement.title}' won't be shown on homepage"
      end
    rescue
      flash[:errors] << "Could not find announcement with id '#{params[:id]}'"
    end
    redirect_to announcement_path
  end
end
