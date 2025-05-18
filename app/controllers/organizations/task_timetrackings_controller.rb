class Organizations::TaskTimetrackingsController < Organizations::BaseController
  before_action :set_task, only: [ :new, :create, :calendar, :bulk_update ]
  before_action :set_task_timetracking, only: [ :show, :edit, :update, :destroy ]

  def index
    if params[:task_id].present?
      @task = @organization.tasks.find_by!(id: params[:task_id])
      @task_timetrackings = policy_scope(TaskTimetracking).where(task: @task)
      authorize @task_timetrackings
    else
      redirect_to organization_tasks_path(@organization), alert: t("tasks.select_task")
      nil
    end
  end

  def calendar
    authorize @task, :show?
    @task_timetrackings = policy_scope(TaskTimetracking).where(task: @task)
    @task_timetracking = @task.task_timetrackings.new

    respond_to do |format|
      format.html
      format.json {
        events = @task_timetrackings.map do |tt|
          {
            id: tt.id,
            title: "Time Log",
            start: "#{tt.date}T#{tt.start&.strftime('%H:%M') || '09:00'}",
            end: "#{tt.date}T#{tt.end&.strftime('%H:%M') || '17:00'}",
            duration: tt.duration_in_hours,
            allDay: (tt.start.nil? || tt.end.nil?),
            extendedProps: {
              task_id: tt.task_id,
              membership_id: tt.membership_id,
              duration: tt.duration_in_hours
            }
          }
        end
        render json: events
      }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html { redirect_to organization_tasks_path(@organization), alert: "Not authorized to view this task's time tracking." }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  def show
    authorize @task_timetracking
  end

  def new
    if params[:task_id]
      @task = @organization.tasks.find_by!(id: params[:task_id])
      @task_timetracking = @task.task_timetrackings.new
    else
      redirect_to organization_tasks_path(@organization), alert: t("tasks.select_task")
      return
    end
    authorize @task_timetracking
  end

  def edit
    authorize @task_timetracking
  end

  def update
    authorize @task_timetracking

    if @task_timetracking.update(task_timetracking_params)
      respond_to do |format|
        format.html { redirect_to organization_task_task_timetracking_url(@organization, @task, @task_timetracking), notice: t("task_timetrackings.update.success") }
        format.json { render json: @task_timetracking }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task_timetracking.errors, status: :unprocessable_entity }
      end
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html { redirect_to organization_task_path(@organization, @task), alert: "Not authorized to update this time entry." }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  def create
    @task_timetracking = @task.task_timetrackings.new(task_timetracking_params)
    authorize @task_timetracking

    if @task_timetracking.save
      respond_to do |format|
        format.html { redirect_to organization_task_url(@organization, @task), notice: t("task_timetrackings.create.success") }
        format.json { render json: @task_timetracking, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task_timetracking.errors, status: :unprocessable_entity }
      end
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html { redirect_to organization_task_path(@organization, @task), alert: "Not authorized to create time entries for this task." }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  def destroy
    authorize @task_timetracking
    task = @task_timetracking.task
    @task_timetracking.destroy!

    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || organization_task_task_timetrackings_url(@organization, task), notice: t("task_timetrackings.destroy.success"), status: :see_other }
      format.json { head :no_content }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@task_timetracking) }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.html { redirect_to organization_task_path(@organization, task), alert: "Not authorized to delete this time entry." }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@task_timetracking, partial: "task_timetracking", locals: { task_timetracking: @task_timetracking }) }
    end
  end
  
  def bulk_update
    @task = @organization.tasks.find_by!(id: params[:task_id])
    authorize @task, :update?
    
    entries_data = params[:entries]
    
    results = { 
      success: [], 
      error: [] 
    }
    
    if entries_data.present?
      entries_data.each do |entry_data|
        date = entry_data[:date]
        entry_type = entry_data[:type] # 'work', 'vacation', 'sick'
        hours = entry_data[:hours].to_f
        
        # Skip invalid entries
        next if date.blank? || hours <= 0
        
        # Find existing entry for this date or create new one
        time_entry = @task.task_timetrackings.find_by(date: date, membership_id: @current_membership.id)
        
        if time_entry.present?
          # Update existing entry
          if entry_data[:delete] == true
            time_entry.destroy
            results[:success] << { date: date, action: 'deleted' }
          else
            time_entry.duration = (hours * 60).to_i
            
            if time_entry.save
              results[:success] << { date: date, action: 'updated', hours: hours }
            else
              results[:error] << { date: date, errors: time_entry.errors.full_messages }
            end
          end
        else
          # Create new entry
          time_entry = @task.task_timetrackings.new(
            date: date,
            duration: (hours * 60).to_i,
            membership_id: @current_membership.id
          )
          
          if time_entry.save
            results[:success] << { date: date, action: 'created', hours: hours }
          else
            results[:error] << { date: date, errors: time_entry.errors.full_messages }
          end
        end
      end
    end
    
    respond_to do |format|
      format.json { render json: results }
    end
  rescue Pundit::NotAuthorizedError
    respond_to do |format|
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  private

  def set_task
    @task = @organization.tasks.find_by!(id: params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path(@organization), alert: t("tasks.not_found")
  end

  def set_task_timetracking
    @task_timetracking = TaskTimetracking.joins(:task).find_by!(id: params[:id], tasks: { organization_id: @organization.id })
    @task = @task_timetracking.task
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_tasks_path(@organization), alert: t("task_timetrackings.not_found")
  end

  def task_timetracking_params
    params_hash = params.require(:task_timetracking).permit(:date, :start, :end, :duration, :duration_in_hours)

    # Handle duration_in_hours parameter if provided
    if params_hash[:duration_in_hours].present?
      params_hash[:duration] = (params_hash[:duration_in_hours].to_f * 60).to_i
      params_hash.delete(:duration_in_hours)
    # If duration is provided and seems to be in hours, convert to minutes
    elsif params_hash[:duration].present? && params_hash[:duration].to_f < 100
      params_hash[:duration] = (params_hash[:duration].to_f * 60).to_i
    end

    # Ensure duration is positive
    if params_hash[:duration].present? && params_hash[:duration].to_i <= 0
      params_hash[:duration] = 30  # Default to 30 minutes if invalid
    end

    # Ensure date is present
    params_hash[:date] ||= Date.today

    params_hash.merge(membership_id: @current_membership.id)
  rescue ActionController::ParameterMissing
    { date: Date.today, duration: 60, membership_id: @current_membership.id }
  end
end
