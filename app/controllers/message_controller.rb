class MessageController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def index
    if params[:complaint_id].nil?
      redirect_to complaint_path and return
    end

    @complaint = Complaint.find(params[:complaint_id])
    @messages = @complaint.messages
  end

  def create
  end

  def reply
    if params[:id].nil?
      flash[:error] = "Couldn't find id of original message"
      redirect_to complaint_path and return
    end

    if params[:content]
      current_message = Message.find(params[:id])
      @new_message = Message.new(
        complaint: current_message.complaint,
        depth: current_message.depth+1,
        content: params[:content]
      )
      if @admin
        @new_message.admin = @admin
      elsif @user
        @new_message.user = @user
      end

      if @new_message.save
        flash[:notice] = "Replied message"
        redirect_to complaint_path
      else
        flash[:error] = @new_message.errors[:content]
      end
    end
  end

  def destroy
  end
end