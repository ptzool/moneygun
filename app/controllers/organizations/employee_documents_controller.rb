class Organizations::EmployeeDocumentsController < Organizations::BaseController
  before_action :set_employee_document, only: [:show, :edit, :update, :destroy]
  before_action :set_employee, only: [:index, :new, :create]

  # GET /employee_documents
  def index
    authorize EmployeeDocument
    @employee_documents = @organization.employees.find(params[:employee_id]).employee_documents

  end

  # GET /employee_documents/1 or /employee_documents/1.json
  def show
  end

  def new
    @employee_document = @organization.employee_documents.new

    authorize @employee_document
  end

  # GET /employee_documents/1/edit
  def edit
  end

  # POST /employee_documents or /employee_documents.json
  def create
    @employee_document = @organization.employee_documents.new(employee_document_params)

    if @employee_document.save
      redirect_to organization_employee_employee_documents_path(@organization, @employee, @employee_document), notice: "Employee document was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /employee_documents/1 or /employee_documents/1.json
  def update
    respond_to do |format|
      if @employee_document.update(employee_document_params)
        format.html { redirect_to @employee_document, notice: "Employee document was successfully updated." }
        format.json { render :show, status: :ok, location: @employee_document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_documents/1 or /employee_documents/1.json
  def destroy
    @employee_document.destroy!
    respond_to do |format|
      format.html { redirect_to employee_documents_url, status: :see_other, notice: "Employee document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_employee_document
    @employee_document = EmployeeDocument.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @employee_document
  rescue ActiveRecord::RecordNotFound
    redirect_to employee_documents_path
  end

  def set_employee
    @employee = @organization.employees.find(params[:employee_id])
    authorize @employee

  rescue ActiveRecord::RecordNotFound
    redirect_to organization_employees_path
  end


  def employee_document_params
    params.require(:employee_document).permit(:employee_document).merge(organization: @organization, employee: @employee)

    # Uncomment to use Pundit permitted attributes
    # params.require(:employee_document).permit(policy(@employee_document).permitted_attributes)
  end
end
