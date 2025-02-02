class Organizations::EmployeesController < Organizations::BaseController
  before_action :set_employee, only: [:show, :destroy]
  before_action :set_select_collections, only: [:new, :create]

  # GET /employees
  def index
    authorize Employee
    @employees = @organization.employees.page(params[:page])
  end

  # GET /employees/1 or /employees/1.json
  def show
  end

  def new
      @employee = @organization.employees.new

      authorize @employee
    end

  # GET /employees/1/edit
  def edit
  end

  def create
    @employee = @organization.employees.new(employee_params)
    authorize @employee

    if @employee.save
      redirect_to organization_employee_url(@organization, @employee), notice: "Employee was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy!

    redirect_to organization_employees_url(@organization), notice: "Employee was successfully destroyed."
  end

  private

  def set_employee
    @employee = @organization.employees.find(params[:id])
    authorize @employee

  rescue ActiveRecord::RecordNotFound
    redirect_to employees_path
  end

  def set_select_collections
    @memberships = @organization.memberships
  end

  def employee_params
    params.require(:employee).permit(:membership_id).merge(organization: @organization)
  end
end
