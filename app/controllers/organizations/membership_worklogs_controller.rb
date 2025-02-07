class Organizations::MembershipWorklogsController < Organizations::BaseController
  before_action :set_membership_worklog, only: [ :show, :edit, :update, :destroy ]

  # GET /membership_worklogs
  def index
    @membership_worklogs = MembershipWorklog.all

    # Uncomment to authorize with Pundit
    # authorize @membership_worklogs
  end

  # GET /membership_worklogs/1 or /membership_worklogs/1.json
  def show
  end

  # GET /membership_worklogs/new
  def new
    @membership_worklog = MembershipWorklog.new

    # Uncomment to authorize with Pundit
    # authorize @membership_worklog
  end

  # GET /membership_worklogs/1/edit
  def edit
  end

  # POST /membership_worklogs or /membership_worklogs.json
  def create
    @membership_worklog = MembershipWorklog.new(membership_worklog_params)

    # Uncomment to authorize with Pundit
    # authorize @membership_worklog

    respond_to do |format|
      if @membership_worklog.save
        format.html { redirect_to @membership_worklog, notice: "Membership worklog was successfully created." }
        format.json { render :show, status: :created, location: @membership_worklog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @membership_worklog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /membership_worklogs/1 or /membership_worklogs/1.json
  def update
    respond_to do |format|
      if @membership_worklog.update(membership_worklog_params)
        format.html { redirect_to @membership_worklog, notice: "Membership worklog was successfully updated." }
        format.json { render :show, status: :ok, location: @membership_worklog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @membership_worklog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /membership_worklogs/1 or /membership_worklogs/1.json
  def destroy
    @membership_worklog.destroy!
    respond_to do |format|
      format.html { redirect_to membership_worklogs_url, status: :see_other, notice: "Membership worklog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_membership_worklog
    @membership_worklog = MembershipWorklog.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @membership_worklog
  rescue ActiveRecord::RecordNotFound
    redirect_to membership_worklogs_path
  end

  def membership_worklog_params
    params.require(:membership_worklog).permit(:organization_id, :membership_id, :date, :check_in, :check_out, :type)

    # Uncomment to use Pundit permitted attributes
    # params.require(:membership_worklog).permit(policy(@membership_worklog).permitted_attributes)
  end
end
