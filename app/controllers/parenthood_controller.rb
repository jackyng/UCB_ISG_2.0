class ParenthoodController < ApplicationController
  def add
  	@parenthood = Parenthood.new(:node_id => params[:node_id], :parent_id => params[:parent_id])
	  if @parenthood.save
	    flash[:notice] = "Added parent."
	    redirect_to root_url
	  else
	    flash[:error] = "Unable to add parent."
	    redirect_to root_url
	  end
  end

  def create_node_then_add_child
    @parent_id = params[:parent_id]
    render 'node/create'
  end

  def remove
  end
end
