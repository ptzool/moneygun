class Organizations::MemberWorklogsController < Organizations::BaseController
  before_action :set_member_worklog, only: [ :show, :edit, :update, :destroy ]

  # GET /member_worklogs
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    start_date = @date.beginning_of_month.beginning_of_week
    end_date = @date.end_of_month.end_of_week
    @calendar_dates = (start_date..end_date).to_a
    
    @member_worklogs = MemberWorklog.where(
      membership_id: @current_membership.id,
      date: start_date..end_date
    ).index_by(&:date)

    # Uncomment to authorize with Pundit
    # authorize @member_worklogs
  end

  # GET /member_worklogs/1 or /member_worklogs/1.json
  def show
  end

  # GET /member_worklogs/new
  def new
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @member_worklog = MemberWorklog.new(
      organization_id: @organization.id,
      membership_id: @current_membership.id,
      date: @date,
      type: MemberWorklog::WORKLOG_TYPES[:work] # Default to work type
    )

    # Uncomment to authorize with Pundit
    # authorize @member_worklog
  end

  # GET /member_worklogs/1/edit
  def edit
  end

  # POST /member_worklogs or /member_worklogs.json
  def create
    @member_worklog = MemberWorklog.new(member_worklog_params)
    @member_worklog.organization_id = @organization.id
    @member_worklog.membership_id = @current_membership.id

    # Uncomment to authorize with Pundit
    # authorize @member_worklog

    respond_to do |format|
      if @member_worklog.save
        format.html { redirect_to organization_member_worklogs_path(@organization, date: @member_worklog.date.beginning_of_month), notice: "Member worklog was successfully created." }
        format.json { render json: { success: true, message: "Worklog was successfully created." }, status: :created }
        format.turbo_stream { redirect_to organization_member_worklogs_path(@organization, date: @member_worklog.date.beginning_of_month), notice: "Member worklog was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @member_worklog.errors }, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /member_worklogs/1 or /member_worklogs/1.json
  def update
    respond_to do |format|
      if @member_worklog.update(member_worklog_params)
        format.html { redirect_to organization_member_worklogs_path(@organization, date: @member_worklog.date.beginning_of_month), notice: "Member worklog was successfully updated." }
        format.json { render json: { success: true, message: "Worklog was successfully updated." }, status: :ok }
        format.turbo_stream { redirect_to organization_member_worklogs_path(@organization, date: @member_worklog.date.beginning_of_month), notice: "Member worklog was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @member_worklog.errors }, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /member_worklogs/1 or /member_worklogs/1.json
  def destroy
    date = @member_worklog.date.beginning_of_month
    @member_worklog.destroy!
    respond_to do |format|
      format.html { redirect_to organization_member_worklogs_path(@organization, date: date), status: :see_other, notice: "Member worklog was successfully destroyed." }
      format.json { render json: { success: true, message: "Worklog was successfully deleted." }, status: :ok }
      format.turbo_stream { redirect_to organization_member_worklogs_path(@organization, date: date), status: :see_other, notice: "Member worklog was successfully destroyed." }
    end
  end

  # Bulk update worklogs for multiple dates
  def bulk_update
    puts "BULK_UPDATE CALLED WITH PARAMS: #{params.inspect}"
    dates = params[:dates]
    worklog_type = params[:worklog_type]
    
    Rails.logger.info("BULK UPDATE - dates: #{dates.inspect}, worklog_type: #{worklog_type.inspect}")
    
    if dates.present? && worklog_type.present?
      success = true
      errors = []
      
      Rails.logger.info("BULK UPDATE - Current membership: #{@current_membership.inspect}")
      Rails.logger.info("BULK UPDATE - Organization: #{@organization.inspect}")
      
      dates.each do |date|
        begin
          parsed_date = Date.parse(date)
          Rails.logger.info("BULK UPDATE - Processing date: #{parsed_date}")
          
          existing_worklog = MemberWorklog.find_by(
            membership_id: @current_membership.id,
            organization_id: @organization.id,
            date: parsed_date
          )
          
          if existing_worklog
            Rails.logger.info("BULK UPDATE - Found existing worklog: #{existing_worklog.inspect}")
            unless existing_worklog.update(type: worklog_type)
              success = false
              errors << "Failed to update worklog for #{date}: #{existing_worklog.errors.full_messages.join(', ')}"
              Rails.logger.error("BULK UPDATE - Update failed: #{existing_worklog.errors.full_messages}")
            end
          else
            Rails.logger.info("BULK UPDATE - Creating new worklog for date: #{parsed_date}")
            new_worklog = MemberWorklog.new(
              membership_id: @current_membership.id,
              organization_id: @organization.id,
              date: parsed_date,
              type: worklog_type
            )
            
            unless new_worklog.save
              success = false
              errors << "Failed to create worklog for #{date}: #{new_worklog.errors.full_messages.join(', ')}"
              Rails.logger.error("BULK UPDATE - Create failed: #{new_worklog.errors.full_messages}")
            end
          end
        rescue => e
          Rails.logger.error("BULK UPDATE - Error processing date #{date}: #{e.message}")
          success = false
          errors << "Error processing date #{date}: #{e.message}"
        end
      end
      
      result = { success: success, errors: errors }
      Rails.logger.info("BULK UPDATE - Result: #{result.inspect}")
      render json: result
    else
      Rails.logger.error("BULK UPDATE - Missing required parameters")
      render json: { success: false, errors: ["Missing dates or worklog type"] }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("BULK UPDATE - Unexpected error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render json: { success: false, errors: ["An unexpected error occurred: #{e.message}"] }, status: :internal_server_error
  end

  private

  def set_member_worklog
    @member_worklog = MemberWorklog.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @member_worklog
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_member_worklogs_path(@organization)
  end

  def member_worklog_params
    # Explicitly permit type instead of worklog_type
    if params[:member_worklog][:worklog_type].present?
      params[:member_worklog][:type] = params[:member_worklog][:worklog_type]
    end
    
    params.require(:member_worklog).permit(:date, :type)

    # Uncomment to use Pundit permitted attributes
    # params.require(:member_worklog).permit(policy(@member_worklog).permitted_attributes)
  end

end
