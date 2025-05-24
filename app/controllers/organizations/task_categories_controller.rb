class Organizations::TaskCategoriesController < Organizations::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :set_task_category, only: [:show, :edit, :update, :destroy]
  before_action :set_default_breadcrumbs
  before_action :add_task_category_breadcrumb, only: [:show, :edit]
  after_action :verify_authorized

  def index
    authorize TaskCategory
    @task_categories = policy_scope(@organization.task_categories)
                      .ordered_by_name
                      .page(params[:page])
                      .per(15)
  end

  def show
    authorize @task_category
    @tasks = @task_category.tasks.includes(:project, :assignee, :reporter)
                          .newest_first
                          .page(params[:page])
                          .per(10)
  end

  def new
    @task_category = @organization.task_categories.new
    authorize @task_category
  end

  def edit
    authorize @task_category
  end

  def create
    @task_category = @organization.task_categories.new(task_category_params)
    authorize @task_category

    if @task_category.save
      redirect_to organization_task_category_url(@organization, @task_category), notice: t("task_categories.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task_category

    if @task_category.update(task_category_params)
      redirect_to organization_task_category_url(@organization, @task_category), notice: t("task_categories.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task_category

    @task_category.destroy!
    redirect_to organization_task_categories_url(@organization), notice: t("task_categories.destroy.success")
  end

  private

  def set_task_category
    @task_category = policy_scope(@organization.task_categories).find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organization_task_categories_path, alert: t("task_categories.not_found")
  end

  def task_category_params
    permitted_params = params.require(:task_category).permit(:name, :description, :color, :active)
    
    # Strip and sanitize text inputs
    [:name, :description].each do |attr|
      if permitted_params[attr].present?
        permitted_params[attr] = strip_tags(permitted_params[attr].strip)
      end
    end

    permitted_params
  end

  def set_default_breadcrumbs
    add_breadcrumb t("breadcrumbs.home"), :root_path
    add_breadcrumb t("breadcrumbs.organizations"), :organizations_path
    add_breadcrumb @organization.name, organization_path(@organization)
    add_breadcrumb t("breadcrumbs.task_categories"), :organization_task_categories_path
  end

  def add_task_category_breadcrumb
    add_breadcrumb @task_category.name, organization_task_category_path(@organization, @task_category)
  end

  def strip_tags(text)
    sanitize(text, tags: [])
  end
end