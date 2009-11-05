class Admin::EventsController < Admin::ResourceController

  def index
    @events = Event.unapproved.order('created_at DESC')
    @status = 'Unapproved'
  end

  def approved
    @events = Event.approved.order('created_at DESC')
    @status = 'Approved'
    render :template => 'admin/events/index'
  end

  def unapproved
    @events = Event.unapproved.order('created_at DESC')
    @status = 'Unapproved'
    render :template => 'admin/events/index'
  end

  def all
    @events = Event.submitted.order('created_at DESC')
    @status = 'All'
    render :template => 'admin/events/index'
  end

  def approve
    @event = Event.find(params[:id])
    @event.approve!

    respond_to do |format|
      format.js
    end
  end

  def disapprove
    @event = Event.find(params[:id])
    @event.disapprove!

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.js
    end
  end
  
end
