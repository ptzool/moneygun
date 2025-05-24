class Organizations::InboxesController < Organizations::BaseController
  before_action :set_inbox, only: %i[ show edit update destroy ]

  def index
    authorize Inbox
    @inboxes = @organization.inboxes
  end

  def show
  end

  def new
    @inbox = @organization.inboxes.new
    authorize @inbox
  end

  def edit
  end

  def create
    @inbox = @organization.inboxes.new(inbox_params)
    authorize @inbox

    if @inbox.save
      redirect_to organization_inbox_url(@organization, @inbox), notice: "Inbox was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @inbox.update(inbox_params)
      redirect_to organization_inbox_url(@organization, @inbox), notice: "Inbox was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @inbox.destroy!

    redirect_to organization_inboxes_url(@organization), notice: "Inbox was successfully destroyed."
  end

  private
    def set_inbox
      @inbox = @organization.inboxes.find(params[:id])
      authorize @inbox
    end

    def inbox_params
      params.require(:inbox).permit(:name)
    end
end
