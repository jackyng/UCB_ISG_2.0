class AdminController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  before_filter :check_admin_privilege

  def search
    if request.method == "POST"
      filter = ""
      filter1 = "(givenName=#{params[:first_name]}*)"
      filter2 = "(sn=#{params[:last_name]}*)"
      if params[:first_name] and params[:last_name]
        filter = "(&#{filter1}#{filter2})"
      elsif params[:first_name]
        filter = filter1
      elsif params[:last_name]
        filter = filter2
      else
        flash[:errors] << "Either first and/or last name is required!"
        return
      end

      ldap = Net::LDAP.new(
        host: 'ldap.berkeley.edu',
        port: 389
      )
      if ldap.bind
        @ldap_entries = ldap.search(
          base:          "ou=people,dc=berkeley,dc=edu",
          filter:        Net::LDAP::Filter.construct( filter ),
          attributes:    [ "displayName", "uid", "mail" ],
          return_result: true
        )
        if @ldap_entries.blank?
          flash[:errors] << "Cannot find anyone with that first and/or last name"
        elsif @ldap_entries.count == 1
          flash[:notice] = "Found this person matching that first and/or last name"
        elsif @ldap_entries.count > 1
          flash[:notice] = "Found these people matching that first and/or last name"
        end
      end
    end
  end

  def create
    if params[:calnetID]
      if params[:email].nil?
        flash[:error] = "Need an email to be an admin"
        redirect_to admin_path and return
      end
      @new_admin = Admin.new(fullname: params[:fullname], calnetID: params[:calnetID], email: params[:email], last_request_time: Time.now)
      if @new_admin.save
        u = User.find_by_calnetID(params[:calnetID])
        u.destroy unless u.nil?
        flash[:notice] = "Successfully added admin '#{@new_admin.fullname}'"
      else
        flash[:error] = @new_admin.errors.values.join(". ")
      end
      redirect_to admin_path
    end
  end

  def destroy
    if params[:id]
      admin = Admin.find(params[:id])
      User.create(fullname: admin.fullname, calnetID: admin.calnetID, email: admin.email, last_request_time: Time.now)
      admin.destroy
      flash[:notice] = "Successfully removed admin '#{admin.fullname}'"
    end
    redirect_to admin_path
  end

  def index
    @admins = Admin.all()
    @users = User.all()
  end
end
