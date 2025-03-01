class Organizations::MemberWorklogsController < Organizations::BaseController
  before_action :set_member_worklog, only: [ :show, :edit, :update, :destroy ]

  # GET /member_worklogs
  def index
    @member_worklogs = MemberWorklog.all

    # Uncomment to authorize with Pundit
    # authorize @member_worklogs
  end

  # GET /member_worklogs/1 or /member_worklogs/1.json
  def show
  end

  # GET /member_worklogs/new
  def new
    @member_worklog = MemberWorklog.new

    # Uncomment to authorize with Pundit
    # authorize @member_worklog
  end

  # GET /member_worklogs/1/edit
  def edit
  end

  # POST /member_worklogs or /member_worklogs.json
  def create
    @member_worklog = MemberWorklog.new(member_worklog_params)

    # Uncomment to authorize with Pundit
    # authorize @member_worklog

    respond_to do |format|
      if @member_worklog.save
        format.html { redirect_to @member_worklog, notice: "Member worklog was successfully created." }
        format.json { render :show, status: :created, location: @member_worklog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @member_worklog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /member_worklogs/1 or /member_worklogs/1.json
  def update
    respond_to do |format|
      if @member_worklog.update(member_worklog_params)
        format.html { redirect_to @member_worklog, notice: "Member worklog was successfully updated." }
        format.json { render :show, status: :ok, location: @member_worklog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @member_worklog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /member_worklogs/1 or /member_worklogs/1.json
  def destroy
    @member_worklog.destroy!
    respond_to do |format|
      format.html { redirect_to member_worklogs_url, status: :see_other, notice: "Member worklog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_member_worklog
    @member_worklog = MemberWorklog.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @member_worklog
  rescue ActiveRecord::RecordNotFound
    redirect_to member_worklogs_path
  end

  def member_worklog_params
    params.require(:member_worklog).permit(:organization_id, :membership_id, :date, :type)

    # Uncomment to use Pundit permitted attributes
    # params.require(:member_worklog).permit(policy(@member_worklog).permitted_attributes)
  end
end
